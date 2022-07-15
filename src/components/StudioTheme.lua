local Studio = settings():GetService("Studio")

local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)

local e = Roact.createElement

local StudioThemeContext = Roact.createContext()

local function StudioThemeProvider(props, hooks)
  local theme, setTheme = hooks.useState(Studio.Theme)

  hooks.useEffect(function()
    local connection = Studio.ThemeChanged:Connect(function()
      setTheme(Studio.Theme)
    end)

    return function()
      connection:Disconnect()
    end
  end)

  return e(StudioThemeContext.Provider, {
    value = theme,
  }, props[Roact.Children])
end

local function useTheme(hooks): StudioTheme
  return hooks.useContext(StudioThemeContext)
end

return {
  Context = StudioThemeContext,
  Provider = RoactHooks.new(Roact)(StudioThemeProvider),
  Consumer = StudioThemeContext.Consumer,
  useTheme = useTheme,
}
