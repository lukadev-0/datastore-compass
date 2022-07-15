local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local RoactRodux = require(Packages.RoactRodux)

local StudioTheme = require(script.Parent.StudioTheme)
local LoadingIndicator = require(script.Parent.LoadingIndicator)
local MainView = require(script.Parent.views.Main)

local e = Roact.createElement

local function App(props, hooks)
  local theme = StudioTheme.useTheme(hooks)

  if not props.placeName then
    return e("Frame", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
    }, {
      LoadingIndicator = e(LoadingIndicator, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
      })
    })
  end

  if typeof(props.placeName) == 'table' then
    local err = props.placeName.err
    return e("TextLabel", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
      Font = Enum.Font.SourceSans,
      TextSize = 16,
      TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ErrorText),
      Text = err,
    })
  end

  return e("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
  }, {
    MainView = e(MainView),
  })
end

App = RoactHooks.new(Roact)(App)

return RoactRodux.connect(
  function(state)
    return {
      placeName = state.placeName,
    }
  end
)(App)
