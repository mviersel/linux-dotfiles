-- ~/.config/hypr/hyprland.lua

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	hl.exec_cmd(
		"waybar & hyprpaper & steam & hyprsunset & vicinae server & qs -d & gnome-keyring-daemon & systemctl enable --now coolercontrold & mako"
	)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

require("config.monitors")
require("config.keybinds")
-- require("config.programs")
-- require("config.autostart")
-- require("config.appearance")
-- require("config.animations")
-- require("config.workspaces")
-- require("config.windowrules")
