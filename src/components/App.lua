local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local RoactRodux = require(Packages.RoactRodux)

local StudioTheme = require(script.Parent.StudioTheme)
local LoadingIndicator = require(script.Parent.LoadingIndicator)
local MainView = require(script.Parent.views.Main)
local DataStoreView = require(script.Parent.views.DataStore)

local e = Roact.createElement

local function App(props, hooks)
  local theme = StudioTheme.useTheme(hooks)

  if not props.placeName then
    return e(LoadingIndicator, {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.5, 0),
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

  if props.selectedDataStore then
    return e(DataStoreView)
  end

  return e(MainView)
end

local AppWrapper = RoactHooks.new(Roact)(function(props, hooks)
  local theme = StudioTheme.useTheme(hooks)

  return e("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
  }, {
    Contents = App(props, hooks)
  })
end)

return RoactRodux.connect(
  function(state)
    return {
      placeName = state.placeName,
      selectedDataStore = state.selectedDataStore,
    }
  end
)(AppWrapper)
