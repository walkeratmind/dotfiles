local wezterm = require("wezterm")
local act = wezterm.action

-- local tmux = {}
-- if wezterm.target_triple == "aarch64-apple-darwin" then
--   tmux = { "/opt/homebrew/bin/tmux", "new", "-Asw" }
-- else
--   tmux = { "tmux", "new", "-Asw" }
-- end

-- set this so that ~ works for path
local set_environment_variables = {
  PATH = wezterm.home_dir .. "/.cargo/bin:" .. os.getenv("PATH"),
}

local config = {
  audible_bell = "Disabled",
  check_for_updates = false,
  inactive_pane_hsb = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 1.0,
  },

  color_scheme = "Catppuccin Mocha", -- Mocha or Macchiato, Frappe, Latte
  -- default_prog = tmux,   -- run tmux on start, or there's key bind below as Ctrl-cmd-s
  default_prog = {
    "/opt/homebrew/bin/nu",
    "-l",
    "-c",
    -- "zellij -l welcome --config-dir ~/.config/yazelix/zellij options --layout-dir ~/.config/yazelix/zellij/layouts",
    "zellij -l welcome options --default-shell nu",
  },

  -- window config

  window_decorations = "RESIZE",
  hide_tab_bar_if_only_one_tab = true,
  window_background_opacity = 0.97,
  adjust_window_size_when_changing_font_size = false,

  default_workspace = "main",
  scrollback_lines = 5000,
  window_close_confirmation = "AlwaysPrompt",

  -- Fonts
  font_size = 14,

  font = wezterm.font_with_fallback({
    -- {
    --   family = "FiraCode Nerd Font",
    --   weight = "Regular",
    --   scale = 1.1,
    --   harfbuzz_features = {
    --     "calt=off",
    --     "cv02=on", -- g
    --     "cv06=on", -- i
    --     "ss01=on", -- r
    --     "ss05=on", -- @
    --     "ss03=0n", -- &
    --     "cv29=off", -- {}
    --     "cv30=on", -- |
    --     -- liga   imaging tools is ==
    --     "cv24=on", -- .-
    --     "cv26=off", -- :-
    --     "cv32=on", -- .=
    --     "ss07=on", -- =~
    --     "ss10=off", -- Fl Tl fi
    --   },
    -- },

    {
      family = "JetBrainsMono Nerd Font",
      -- family = "JetBrains Mono",
      weight = "Regular",
      scale = 1.1,
      harfbuzz_features = {
        "calt=on",
        "cv04=on", -- j
        "cv06=on", -- m

        -- Curly
        -- "ss02=on", -- closed/curly construct for f, l, m, t Ww, y
        "cv05=off", -- l
        "cv02=on", -- t
        -- "cv17=on", -- f
        "cv11=on", -- y

        "ss20=on", -- raised bar for f & other
        "zero=on", -- 0
        "cv08=on", -- Kk

        "cv19=on", -- 8
        "cv99=on", -- Cc
      },
    },
    {
      family = "Noto Color Emoji",
      weight = "Regular",
      scale = 1,
    },
  }),
  -- font_rules = {
  --   {
  --     intensity = "Bold",
  --     italic = true,
  --     font = wezterm.font({
  --       family = "JetBrainsMono Nerd Font",
  --       weight = "Bold",
  --       style = "Italic",
  --     }),
  --   },
  --   {
  --     italic = true,
  --     intensity = "Half",
  --     font = wezterm.font({
  --       family = "JetBrainsMono Nerd Font",
  --       weight = "DemiBold",
  --       style = "Italic",
  --     }),
  --   },
  --   {
  --     italic = true,
  --     intensity = "Normal",
  --     font = wezterm.font({
  --       family = "JetBrainsMono Nerd Font",
  --       style = "Italic",
  --     }),
  --   },
  -- },
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
  disable_default_key_bindings = false,
  keys = {
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    { key = "a", mods = "LEADER|CTRL", action = act({ SendString = "\x00" }) },
    { key = "w", mods = "CMD", action = act.CloseCurrentTab({ confirm = false }) },
    { key = "s", mods = "CTRL|SHIFT", action = act.SendString("tmux new -Asw\r") },
    { key = "-", mods = "LEADER", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
    { key = "\\", mods = "LEADER", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
    { key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
    { key = "c", mods = "LEADER", action = act({ SpawnTab = "CurrentPaneDomain" }) },
    { key = "h", mods = "LEADER", action = act({ ActivatePaneDirection = "Left" }) },
    { key = "j", mods = "LEADER", action = act({ ActivatePaneDirection = "Down" }) },
    { key = "k", mods = "LEADER", action = act({ ActivatePaneDirection = "Up" }) },
    { key = "l", mods = "LEADER", action = act({ ActivatePaneDirection = "Right" }) },
    { key = "H", mods = "CTRL|SHIFT", action = act({ AdjustPaneSize = { "Left", 5 } }) },
    { key = "J", mods = "CTRL|SHIFT", action = act({ AdjustPaneSize = { "Down", 5 } }) },
    { key = "K", mods = "CTRL|SHIFT", action = act({ AdjustPaneSize = { "Up", 5 } }) },
    { key = "L", mods = "CTRL|SHIFT", action = act({ AdjustPaneSize = { "Right", 5 } }) },
    { key = "n", mods = "CTRL|ALT", action = act({ SpawnTab = "CurrentPaneDomain" }) },
    { key = "1", mods = "LEADER", action = act({ ActivateTab = 0 }) },
    { key = "2", mods = "LEADER", action = act({ ActivateTab = 1 }) },
    { key = "3", mods = "LEADER", action = act({ ActivateTab = 2 }) },
    { key = "4", mods = "LEADER", action = act({ ActivateTab = 3 }) },
    { key = "5", mods = "LEADER", action = act({ ActivateTab = 4 }) },
    { key = "6", mods = "LEADER", action = act({ ActivateTab = 5 }) },
    { key = "7", mods = "LEADER", action = act({ ActivateTab = 6 }) },
    { key = "8", mods = "LEADER", action = act({ ActivateTab = 7 }) },
    { key = "9", mods = "LEADER", action = act({ ActivateTab = 8 }) },
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "n", mods = "LEADER", action = act.ShowTabNavigator },

    { key = "w", mods = "LEADER", action = act({ CloseCurrentTab = { confirm = true } }) },

    { key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
    { key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

    { key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },

    { key = "f", mods = "CTRL|ALT", action = "ToggleFullScreen" },
    { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
    { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
    { key = "+", mods = "SHIFT|CTRL", action = "IncreaseFontSize" },
    { key = "-", mods = "SHIFT|CTRL", action = "DecreaseFontSize" },
    { key = "0", mods = "SHIFT|CTRL", action = "ResetFontSize" },
  },
  set_environment_variables = {},
}

-- set gui position on start
wezterm.on("gui-startup", function(cmd)
  -- os.execute("mkdir " .. cache_dir)
  --
  -- local window_size_cache_file = io.open(window_size_cache_path, "r")
  -- local window
  -- if window_size_cache_file ~= nil then
  --   _, _, width, height = string.find(window_size_cache_file:read(), "(%d+),(%d+)")
  --   _, _, window = mux.spawn_window({ width = tonumber(width), height = tonumber(height) })
  --   window_size_cache_file:close()
  -- else
  --   _, _, window = mux.spawn_window({})
  --   window:gui_window():maximize()
  -- end
  window:set_postion(0, 320)
end)

-- wezterm.on("window-resized", function(_, pane)
--   local tab_size = pane:tab():get_size()
--   local cols = tab_size["cols"]
--   local rows = tab_size["rows"] + 2 -- Without adding the 2 here, the window doesn't maximize
--   local contents = string.format("%d,%d", cols, rows)
--
--   local window_size_cache_file = io.open(window_size_cache_path, "w")
--   -- Check if the file was successfully opened
--   if window_size_cache_file then
--     window_size_cache_file:write(contents)
--     window_size_cache_file:close()
--   else
--     print("Error: Could not open file for writing: " .. window_size_cache_path)
--   end
-- end)

-- set native notification
wezterm.on("window-config-reloaded", function(window, pane)
  window:toast_notification("wezterm", "configuration reloaded!", nil, 4000)
end)
return config
