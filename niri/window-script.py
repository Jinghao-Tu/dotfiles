"""
Like open-float, but dynamically. Floats a window when it matches the rules.

Some windows don't have the right title and app-id when they open, and only set
them afterward. This script is like open-float for those windows.

Usage: fill in the RULES array below, then run the script.
"""

from dataclasses import dataclass, field
import json
import logging
import os
from pathlib import Path
import re
from socket import AF_UNIX, SHUT_WR, socket
import sys
from time import sleep


# log_path = Path(__file__).resolve().with_name("script.log")
# # Logger configuration
# logging.basicConfig(
#     filename=log_path,
#     encoding="utf-8",
#     level=logging.INFO,
#     format="%(asctime)s [%(levelname)s] %(message)s",
#     datefmt="%Y-%m-%d %H:%M:%S",
# )
# logger = logging.getLogger(__name__)


# >>>>>>>> put update function here >>>>>>>>
def float(id: int):
    """Switch the window to floating mode and set its position"""
    send({"Action": {"MoveWindowToFloating": {"id": id}}})
    send(
        {
            "Action": {
                "MoveFloatingWindow": {
                    "id": id,
                    "x": {"SetFixed": 1250.0},
                    "y": {"SetFixed": 150.0},
                }
            }
        }
    )


def tile(id: int):
    """Switch the window to tiling mode and set its position"""
    send({"Action": {"MoveWindowToTiling": {"id": id}}})


# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


@dataclass(kw_only=True)
class Match:
    """Class for defining window match conditions by title and/or app_id"""

    title: str | None = None  # Regular expression for the window title
    app_id: str | None = None  # Regular expression for the window app_id

    def matches(self, window):
        """Check whether the window matches the conditions"""
        if self.title is None and self.app_id is None:
            return False

        matched = True

        if self.title is not None:
            matched &= re.search(self.title, window["title"]) is not None
        if self.app_id is not None:
            matched &= re.search(self.app_id, window["app_id"]) is not None

        return matched


@dataclass
class Rule:
    """Class describing a rule consisting of a list of Match conditions and exclusions"""

    match: list[Match] = field(default_factory=list)  # Conditions the window must meet
    exclude: list[Match] = field(
        default_factory=list
    )  # Conditions under which the window should be excluded
    update: callable = None # Function pointer for update action

    def matches(self, window):
        """Check whether the window matches the rule"""
        if len(self.match) > 0 and not any(m.matches(window) for m in self.match):
            return False
        if any(m.matches(window) for m in self.exclude):
            return False

        return True


# Write your rules here. One Rule() = one window-rule {}.
RULES = [
    Rule(match=[Match(app_id="Zotero", title="^..*Zotero$")], exclude=[], update=tile),
]


def send(request):
    """Send a request to the Niri socket"""
    with socket(AF_UNIX) as niri_socket:
        niri_socket.connect(os.environ["NIRI_SOCKET"])
        file = niri_socket.makefile("rw")
        _ = file.write(json.dumps(request))
        file.flush()


def update_matched(windows, win):
    """Check if the window matches any rules and perform the action"""
    win["matched"] = False
    if existing := windows.get(win["id"]):
        win["matched"] = existing["matched"]

    matched_before = win["matched"]

    # Find the first matching rule and get its update function
    matched_rule = None
    for rule in RULES:
        if rule.matches(win):
            matched_rule = rule
            break

    win["matched"] = matched_rule is not None

    # If the window was not previously matched but now matches — apply the action
    if win["matched"] and not matched_before:
        # logger.info(
        #     f"Window matched: title='{win['title']}', app_id='{win['app_id']}' ->> updating"
        # )

        # Call the update function from the matched rule
        if matched_rule.update is not None:
            matched_rule.update(win["id"])
        else:
            raise ValueError("No update function defined for the matched rule")


def main():
    # logger.info("script has been launched")
    # Check if there are any rules at all
    if len(RULES) == 0:
        # logger.warning("fill in the RULES list, then run the script")
        sys.exit(0)

    # Connect to the socket and open the event stream
    niri_socket = socket(AF_UNIX)
    niri_socket.connect(os.environ["NIRI_SOCKET"])
    file = niri_socket.makefile("rw")

    _ = file.write('"EventStream"')  # Subscribe to events
    file.flush()
    niri_socket.shutdown(SHUT_WR)  # Close writing

    # Store information about current windows
    windows = {}

    # Process incoming events from the window manager
    for line in file:
        event = json.loads(line)

        if changed := event.get("WindowsChanged"):
            for win in changed["windows"]:
                update_matched(windows, win)
            windows = {win["id"]: win for win in changed["windows"]}
        elif changed := event.get("WindowOpenedOrChanged"):
            win = changed["window"]
            update_matched(windows, win)
            windows[win["id"]] = win
        elif changed := event.get("WindowClosed"):
            del windows[changed["id"]]


if __name__ == "__main__":
    while True:
        try:
            main()
        except KeyboardInterrupt:
            # logger.info("stopped by CTRL+C")
            break
        except Exception as err:
            # logger.error(f"an error occurred: {err}, restarting...")
            sleep(5.0)
