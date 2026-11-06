"""Bounded native viewport/container swipes."""
# Literal describes the four accepted direction values in the tool's schema.
from typing import Literal
# isfinite rejects geometry containing NaN or infinity before computing a swipe.
import math
# The decorator exposes the function and its arguments as a LangChain tool.
from langchain_core.tools import tool


def build_tool(runtime):
    # Keep the host's runtime in this closure; only direction and element_ref
    # become model arguments. Registration does not execute a swipe.
    @tool
    def scroll_ui(direction: Literal['up','down','left','right'], element_ref: str = '') -> dict:
        """Reveal content above/below/left/right with one bounded swipe and fresh evidence.

        direction names the content to reveal (down uses an upward finger swipe).
        Optionally constrain the swipe to a current observed container reference;
        otherwise use the configured app viewport. This does not guarantee more
        pages exist or loading completed; inspect or wait for the requested UI.
        """
        # Serialize budget checks, geometry lookup, and dispatch with other work.
        # The context manager releases the lock on every exit path.
        with runtime.lock:
            try:
                # Require the configured foreground app and room for one action
                # plus one scroll before asking Appium for viewport information.
                runtime.require_own_app()
                runtime.require_budget(1, scrolls=1)
                window = runtime.session.driver.get_window_size()
                # By default, the swipe area starts at the window origin and uses
                # its width/height. Convert dimensions to floats for arithmetic.
                rect = {'x':0,'y':0,'width':float(window['width']),'height':float(window['height'])}
                if element_ref:
                    # An optional observed reference restricts the area to a live,
                    # unique, visible, enabled element's Appium rectangle.
                    element, target = runtime.resolve(element_ref)
                    rect = element.rect
                # Keep a known coordinate order: origin x/y, then width/height.
                values = [float(rect[k]) for k in ('x','y','width','height')]
                # NaN/infinite coordinates cannot describe a usable screen area.
                if not all(math.isfinite(value) for value in values):
                    raise ValueError('Invalid viewport geometry.')
                x, y, width, height = values
                # Intersect the element rectangle with the window. x0/y0 are the
                # visible top-left; x1/y1 are the visible bottom-right.
                x0 = max(0, x)
                y0 = max(0, y)
                x1 = min(float(window['width']), x + width)
                y1 = min(float(window['height']), y + height)
                # A narrow, short, or offscreen region cannot support this swipe.
                if x1 - x0 < 80 or y1 - y0 < 80:
                    raise ValueError('The visible scroll area is too small.')
                # Center the swipe on the axis perpendicular to finger movement.
                cx = (x0 + x1) / 2
                cy = (y0 + y1) / 2
                # Each tuple is (start_x, start_y, end_x, end_y). Endpoints at
                # 22%/78% stay inside the area. Content direction is opposite to
                # finger movement: revealing content below requires swiping up.
                points = {'down':(cx,y0+.78*(y1-y0),cx,y0+.22*(y1-y0)),
                          'up':(cx,y0+.22*(y1-y0),cx,y0+.78*(y1-y0)),
                          'right':(x0+.78*(x1-x0),cy,x0+.22*(x1-x0),cy),
                          'left':(x0+.22*(x1-x0),cy,x0+.78*(x1-x0),cy)}
                # Pick the requested path and round its four coordinates to pixels.
                coords = tuple(round(v) for v in points[direction])

                # Defining the callback delays the actual SDK command until mutate
                # has saved intent. *coords unpacks four positional coordinates;
                # duration is the requested swipe time in milliseconds.
                def dispatch():
                    runtime.session.driver.swipe(*coords, duration=450)

                # Record direction/container_ref as request details, dispatch once,
                # and return the receipt with status and fresh post-swipe evidence.
                return runtime.mutate('scroll_ui', dispatch, details={'direction':direction,'container_ref':element_ref})
            except Exception as error:
                # Report a geometry/lookup/precondition failure as saved BLOCKED data.
                return runtime.blocked('scroll_ui', str(error))
    # Return the wrapped tool bound to this host runtime.
    return scroll_ui
