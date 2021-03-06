local Packages = script.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactRodux = require(Packages.RoactRodux)
local RoactHooks = require(Packages.RoactHooks)

local TopBar = require(script.Parent.Parent.TopBar)
local DataStoreList = require(script.DataStoreList)
local SearchBar = require(script.Parent.Parent.SearchBar)
local CheckBox = require(script.Parent.Parent.CheckBox)
local StudioTheme = require(script.Parent.Parent.StudioTheme)

local e = Roact.createElement

local function MainView(props, hooks)
  local searchQuery, setSearchQuery = hooks.useState("")
  local useOrdered, setUseOrdered = hooks.useState(false)
  local theme = StudioTheme.useTheme(hooks)

  return Roact.createFragment({
    TopBar = e(TopBar, {
      breadcrumbs = {props.placeName},
    }, {
      UseOrderedCheckBox = e(CheckBox, {
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Checked = useOrdered,

        [Roact.Event.Activated] = function()
          setUseOrdered(not useOrdered)
        end,
      }),

      UseOrderedCheckBoxLabel = e("TextLabel", {
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(0, 135, 1, 0),
        BackgroundTransparency = 1,
        TextSize = 16,
        TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
        Text = "Ordered Data Stores",
        Font = Enum.Font.SourceSans,
      }),
    }),

    Contents = e("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -16, 1, -79),
      Position = UDim2.new(0, 8, 0, 79),
    }, {
      SearchBar = e(SearchBar, {
        Width = UDim.new(1, 0),
        Position = UDim2.new(0, 0),
        PlaceholderText = "Name",

        [Roact.Event.FocusLost] = function(rbx)
          setSearchQuery(rbx.Text)
        end,
      }),

      Table = e("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
      }, {
        DataStoreList = e(DataStoreList, {
          searchQuery = searchQuery,
          useOrdered = useOrdered,
        }),
      }),
    })
  })
end

MainView = RoactHooks.new(Roact)(MainView)

return RoactRodux.connect(
  function(state)
    return {
      placeName = state.placeName,
    }
  end
)(MainView)
