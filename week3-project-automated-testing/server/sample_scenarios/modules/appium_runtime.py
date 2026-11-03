"""Explicit local Appium setup and owned iOS Simulator session lifecycle.

Imports are inert. Call prepare_local_appium() to activate/check existing tools,
then enter managed_ios_session() when the lesson is ready to contact the device.
"""

from contextlib import contextmanager
from dataclasses import dataclass, field
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from typing import Any, Iterator, Mapping

from appium import webdriver
from appium.options.ios import XCUITestOptions
from appium.webdriver.client_config import AppiumClientConfig
from selenium.webdriver.common.proxy import Proxy


@dataclass(frozen=True)
class LocalAppiumEnvironment:
    server_dir: Path
    node_bin: Path
    appium_executable: Path
    appium_home: Path
    node_version: str
    npm_version: str
    appium_version: str


@dataclass
class IosSession:
    """Host-owned resources and acknowledged cleanup facts, not an agent result."""

    driver: Any = field(repr=False)
    artifact_root: Path
    log_path: Path
    session_id: str
    server_pid: int
    session_closed: bool = False
    server_exit_code: int | None = None
    cleanup_errors: list[dict[str, str]] = field(default_factory=list)
    # Host lifecycle state: false before/after the managed session body.
    active: bool = field(default=False, init=False)
    _manager: Any = field(default=None, init=False, repr=False, compare=False)


def _process_environment(server_dir: Path, node_bin: Path) -> dict[str, str]:
    environment = os.environ.copy()
    bin_paths = [str(server_dir / "node_modules" / ".bin"), str(node_bin)]
    remaining = [path for path in environment.get("PATH", "").split(os.pathsep) if path not in bin_paths]
    environment["PATH"] = os.pathsep.join([*bin_paths, *remaining])
    environment["APPIUM_HOME"] = str(server_dir / ".tools" / "appium")
    environment["npm_config_cache"] = str(server_dir / ".tools" / "npm-cache")
    return environment


def prepare_local_appium(server_dir: str | Path | None = None) -> LocalAppiumEnvironment:
    """Select existing project tools; do not install packages or start a server."""
    # modules/ -> sample_scenarios/ -> server/, independent of notebook cwd.
    server_dir = Path(server_dir).resolve() if server_dir is not None else Path(__file__).resolve().parents[2]
    if not (server_dir / ".node-version").is_file() or not (server_dir / "package.json").is_file():
        raise RuntimeError("The server folder must contain .node-version and package.json.")
    pinned_node = (server_dir / ".node-version").read_text().strip()
    node_bin = server_dir / ".tools" / f"node-v{pinned_node}-darwin-arm64" / "bin"
    executable = server_dir / "node_modules" / ".bin" / "appium"
    for required in (node_bin / "node", node_bin / "npm", executable):
        if not required.is_file():
            raise FileNotFoundError(f"Required project-local tool is missing: {required}")
    child_env = _process_environment(server_dir, node_bin)
    node_version = subprocess.check_output([str(node_bin / "node"), "--version"],
                                           env=child_env, text=True, timeout=10).strip()
    if node_version != f"v{pinned_node}":
        raise RuntimeError(f"Expected Node v{pinned_node}, found {node_version}.")
    npm_version = subprocess.check_output([str(node_bin / "npm"), "--version"],
                                          env=child_env, text=True, timeout=10).strip()
    expected_appium = json.loads((server_dir / "package.json").read_text())["devDependencies"]["appium"]
    appium_version = subprocess.check_output(
        [str(node_bin / "node"), str(executable), "--version"],
        cwd=server_dir, env=child_env, text=True, timeout=30,
    ).strip()
    if appium_version != expected_appium:
        raise RuntimeError(f"Expected Appium {expected_appium}, found {appium_version}.")
    # Match the earlier notebook's explicit kernel activation; never do this at import.
    for name in ("PATH", "APPIUM_HOME", "npm_config_cache"):
        os.environ[name] = child_env[name]
    return LocalAppiumEnvironment(server_dir, node_bin, executable,
                                  server_dir / ".tools" / "appium", node_version,
                                  npm_version, appium_version)


def _verified_ios_options(profile: Mapping[str, Any]) -> XCUITestOptions:
    if profile.get("platform") != "ios" or profile.get("execution_provider") != "local":
        raise ValueError("This helper requires a local iOS profile.")
    for name in ("simulator_udid", "app_bundle_id"):
        if not isinstance(profile.get(name), str) or not profile[name].strip():
            raise ValueError(f"A nonempty {name} is required.")
    devices = json.loads(subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "--json"], text=True, timeout=20,
    ))
    matches = [device for entries in devices["devices"].values() for device in entries
               if device["udid"] == profile["simulator_udid"]]
    if len(matches) != 1 or matches[0]["state"] != "Booted" or not matches[0].get("isAvailable"):
        raise RuntimeError("The selected Simulator must be available and booted.")
    app_path = subprocess.check_output(
        ["xcrun", "simctl", "get_app_container", profile["simulator_udid"], profile["app_bundle_id"], "app"],
        text=True, timeout=20,
    ).strip()
    if not Path(app_path).is_dir():
        raise RuntimeError("The configured application container could not be verified.")
    options = XCUITestOptions()
    options.udid = profile["simulator_udid"]
    options.bundle_id = profile["app_bundle_id"]
    options.no_reset = True
    options.full_reset = False
    options.set_capability("appium:wdaBindingIP", "127.0.0.1")
    options.set_capability("appium:wdaLocalPort", 8100)
    return options


def _wait_for_status(process: subprocess.Popen, url: str, version: str, log_path: Path) -> None:
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"Appium exited early; inspect {log_path}")
        try:
            with opener.open(url + "/status", timeout=2) as response:
                status = json.load(response)["value"]
            if status.get("ready") is not True or status.get("build", {}).get("version") != version:
                raise RuntimeError("Appium did not return the expected readiness/version.")
            if process.poll() is not None:
                raise RuntimeError("The owned Appium process stopped during readiness verification.")
            return
        except urllib.error.URLError:
            time.sleep(0.25)
    raise TimeoutError(f"Appium startup timed out; inspect {log_path}")


def _stop_owned_process(process: subprocess.Popen) -> int:
    if process.poll() is None:
        process.terminate()
        try:
            return process.wait(timeout=20)
        except subprocess.TimeoutExpired:
            process.kill()
    return process.wait(timeout=5)


@contextmanager
def managed_ios_session(environment: LocalAppiumEnvironment,
                        profile: Mapping[str, Any]) -> Iterator[IosSession]:
    """Create one local session and always clean up only the resources we own."""
    options = _verified_ios_options(profile)
    host, port = "127.0.0.1", 4723
    with socket.socket() as probe:
        probe.bind((host, port))  # A busy port is an error; its owner is left alone.
    log_dir = environment.server_dir / ".tools" / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", prefix="ios-session-config-", suffix=".json",
                                     dir=log_dir, delete=False) as config_file:
        json.dump({"server": {}}, config_file)
    client_config = AppiumClientConfig(
        remote_server_addr=f"http://{host}:{port}", timeout=300,
        proxy=Proxy({"proxyType": "direct"}),
        init_args_for_pool_manager={"init_args_for_pool_manager": {"retries": 0}},
    )
    process, driver, session = None, None, None
    with tempfile.NamedTemporaryFile(mode="w", prefix="ios-session-", suffix=".log",
                                     dir=log_dir, delete=False) as log_file:
        log_path = Path(log_file.name)
        print("Server/session log:", log_path, flush=True)
        try:
            process = subprocess.Popen(
                [str(environment.node_bin / "node"), str(environment.appium_executable),
                 "--config", config_file.name, "--address", host, "--port", str(port),
                 "--log-no-colors", "--log-timestamp"],
                cwd=environment.server_dir,
                env=_process_environment(environment.server_dir, environment.node_bin),
                stdout=log_file, stderr=subprocess.STDOUT,
            )
            print("Owned Appium PID:", process.pid, flush=True)
            _wait_for_status(process, client_config.remote_server_addr, environment.appium_version, log_path)
            driver = webdriver.Remote(command_executor=client_config.remote_server_addr,
                                      options=options, client_config=client_config)
            if not driver.session_id:
                raise RuntimeError("The client did not receive a session ID.")
            client_config.timeout = 20
            session = IosSession(driver, environment.server_dir / ".tools" / "observations",
                                 log_path, driver.session_id, process.pid)
            session.active = True
            yield session
        finally:
            # Invalidate captures before attempting any remote cleanup.
            if session is not None:
                session.active = False
            primary_error = sys.exc_info()[1]
            cleanup_errors = []
            try:
                if driver is not None:
                    client_config.timeout = 20
                    driver.quit()
                    if session is not None:
                        session.session_closed = True
                    print("Automation session closed.", flush=True)
            except Exception as error:
                cleanup_errors.append(error)
            finally:
                if process is not None:
                    try:
                        exit_code = _stop_owned_process(process)
                        if session is not None:
                            session.server_exit_code = exit_code
                        print("Owned Appium process stopped; exit code:", exit_code, flush=True)
                    except Exception as error:
                        cleanup_errors.append(error)
            if cleanup_errors:
                details = [{"type": type(error).__name__, "message": str(error)} for error in cleanup_errors]
                if session is not None:
                    session.cleanup_errors.extend(details)
                if primary_error is not None:
                    primary_error.add_note(f"Additional Appium cleanup errors: {details}")
                else:
                    raise RuntimeError(f"Appium cleanup did not complete: {details}") from cleanup_errors[0]


def start_ios_session(environment: LocalAppiumEnvironment,
                      profile: Mapping[str, Any]) -> IosSession:
    """Start a notebook session; pair this call with stop_ios_session in finally.

    Retain the existing context manager so its startup-failure handling and
    owned-resource cleanup remain the same. Entering it performs the startup.
    """
    manager = managed_ios_session(environment, profile)
    session = manager.__enter__()
    session._manager = manager
    return session


def stop_ios_session(session: IosSession) -> None:
    """Close a session created by start_ios_session; repeated calls are harmless."""
    manager = session._manager
    if manager is None:
        return
    session._manager = None
    # Forward an in-flight error from the caller's finally block so cleanup
    # failures are attached to it rather than replacing the original error.
    manager.__exit__(*sys.exc_info())
