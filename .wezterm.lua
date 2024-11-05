-- Reference: https://wezfurlong.org/wezterm/config/files.html


-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'


-- Reference: https://wezfurlong.org/wezterm/config/lua/wezterm.gui/get_appearance.html
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    -- return 'Builtin Solarized Dark'
    return 'Chalk (dark) (terminal.sexy)'
  else
    -- return 'Builtin Solarized Light'
    return 'Chalk (light) (terminal.sexy)'
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())


-- Reference: https://wezfurlong.org/wezterm/config/lua/keyassignment/SendKey.html

local act = wezterm.action

config.keys = {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendKey {
      key = 'b',
      mods = 'ALT',
    },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = act.SendKey { key = 'f', mods = 'ALT' },
  },
}


-- and finally, return the configuration to wezterm
return config
