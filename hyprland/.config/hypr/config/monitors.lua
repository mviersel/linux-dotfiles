-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

------------------
---- MONITORS ----
------------------

hl.monitor({
	output = "DP-2",
	mode = "2560x1440@144",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "DP-3",
	mode = "3840x2160@60",
	position = "-2560x0",
	scale = 1.5,
})

--------------------
---- WORKSPACES ----
--------------------

-- DP-2 Workspaces - Main
hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-2", persistent = true })

-- DP-3 Workspaces - Secondary
hl.workspace_rule({ workspace = "6", monitor = "DP-3", persistent = true })
hl.workspace_rule({ workspace = "7", monitor = "DP-3", persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "DP-3", persistent = true })
hl.workspace_rule({ workspace = "9", monitor = "DP-3", default = true, persistent = true })
