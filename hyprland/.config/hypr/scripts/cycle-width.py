#!/usr/bin/env python3
import json
import subprocess
import sys

PRESETS = (1 / 3, 1 / 2, 2 / 3)
TOLERANCE = 20  # logische pixels; marge voor gaps en afronding


def query(name):
    result = subprocess.run(
        ["hyprctl", "-j", name],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def main():
    direction = sys.argv[1] if len(sys.argv) > 1 else "next"
    if direction not in ("next", "prev"):
        raise SystemExit("Gebruik: cycle-width.py next|prev")

    win = query("activewindow")
    if not win.get("address"):
        return

    # Fullscreen eerst zelf verlaten.
    if win.get("fullscreen", 0):
        return

    monitor = next(
        m for m in query("monitors")
        if m["id"] == win["monitor"]
    )

    # Monitorpixels omrekenen naar logische coördinaten.
    # Bij een gedraaid scherm wisselen breedte en hoogte.
    transform = monitor.get("transform", 0)
    physical_width = (
        monitor["height"] if transform % 2 else monitor["width"]
    )
    logical_width = physical_width / monitor["scale"]

    # reserved: links, boven, rechts, onder.
    reserved = monitor.get("reserved", [0, 0, 0, 0])
    available_width = logical_width - reserved[0] - reserved[2]

    current_width = win["size"][0]
    widths = [round(available_width * p) for p in PRESETS]

    if direction == "next":
        target = next(
            (w for w in widths if w > current_width + TOLERANCE),
            widths[0],
        )
    else:
        target = next(
            (w for w in reversed(widths)
             if w < current_width - TOLERANCE),
            widths[-1],
        )

    delta = target - current_width

    resize = (
        "hl.dsp.window.resize({"
        f"x = {delta}, y = 0, relative = true, "
        f"window = {json.dumps('address:' + win['address'])}"
        "})"
    )

    result = subprocess.run(
        ["hyprctl", "dispatch", resize],
        check=True,
        capture_output=True,
        text=True,
    )
    print(result.stdout.strip())


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as exc:
        print(f"hyprctl exitcode: {exc.returncode}", file=sys.stderr)
        print(exc.stdout or "", file=sys.stderr)
        print(exc.stderr or "", file=sys.stderr)
        sys.exit(1)
    except (ValueError, KeyError, StopIteration) as exc:
        print(f"Breedte aanpassen mislukt: {exc}", file=sys.stderr)
        sys.exit(1)
