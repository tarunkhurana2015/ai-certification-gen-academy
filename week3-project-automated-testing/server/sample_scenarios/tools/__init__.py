"""Shared LLM tool registry. Importing does not start Appium or a model."""
# Import the shared configuration and session state; importing them starts no app.
from ._runtime import ToolLimits, ToolRuntime


def build_tools(runtime):
    """Register every implemented tool once; the LLM chooses tools for any request."""
    # Import the Python modules containing the individual build_tool() factories.
    # A module is a file; it is not yet a callable tool exposed to the model.
    from . import (
        observe_current_ui, tap_element, enter_text, scroll_ui, go_back,
        dismiss_keyboard, wait_for_ui, assert_ui, compare_observations,
        review_visual_evidence, relaunch_app, return_to_app, inspect_external_link,
        find_test_data, inspect_network_condition, inspect_storage_condition,
        wait_for_request_started, run_timed_sequence,
    )
    # Use this identical inventory for every human request. Nothing here reads a CSV ID.
    modules = (
        observe_current_ui, tap_element, enter_text, scroll_ui, go_back,
        dismiss_keyboard, wait_for_ui, assert_ui, compare_observations,
        review_visual_evidence, relaunch_app, return_to_app, inspect_external_link,
        find_test_data, inspect_network_condition, inspect_storage_condition,
        wait_for_request_started, run_timed_sequence,
    )
    # Call each factory once with the same host-owned runtime. The factory returns
    # a LangChain tool whose function can access that runtime through a closure.
    # Creating these tool objects performs no Appium action or model request.
    # The notebook passes this list to create_agent(); the model later picks a tool.
    return [module.build_tool(runtime) for module in modules]

# These are the three supported names for notebooks importing from this package.
__all__ = ['ToolLimits', 'ToolRuntime', 'build_tools']
