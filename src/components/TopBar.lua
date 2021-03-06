local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local RoactRodux = require(Packages.RoactRodux)

local StudioTheme = require(script.Parent.StudioTheme)
local BreadcrumbItem = require(script.Parent.BreadcrumbItem)
local Assets = require(script.Parent.Parent.assets)
local IconButton = require(script.Parent.IconButton)

local e = Roact.createElement

local function TopBar(props, hooks)
  local theme = StudioTheme.useTheme(hooks)

  local breadcrumbs = {}
  for i, breadcrumb in props.breadcrumbs do
    if i ~= 1 then
      table.insert(breadcrumbs, e("TextLabel", {
        Text = "/",
        Size = UDim2.new(0, 6, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
      }))
    end

    table.insert(breadcrumbs, e(BreadcrumbItem, {
      text = breadcrumb,
      active = i == #props.breadcrumbs,
      onClick = function()
        if i == 2 then
          props.deselectKey()
        end

        if i == 1 then
          props.deselectKey()
          props.deselectDataStore()
        end
      end,
    }))
  end

  return e("Frame", {
    Size = UDim2.new(1, 0, 0, 71),
    BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Titlebar),
    BorderSizePixel = 0,
  }, {
    Row1 = e("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -16, 0, 24),
      Position = UDim2.new(0, 8, 0, 8),
    }, {
      Back = e(IconButton, {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 0, 0, 0),

        color = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
        image = Assets.icons.Back,

        [Roact.Event.Activated] = function()
          if props.selectedKey then
            return props.deselectKey()
          end

          if props.selectedDataStore then
            return props.deselectDataStore()
          end
        end,
      }),

      Refresh = e(IconButton, {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 32, 0, 0),

        color = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
        image = Assets.icons.Refresh,
        
        [Roact.Event.Activated] = function()
          props.onRefresh()
        end,
      }),

      Breadcrumbs = e("Frame", {
        Size = UDim2.new(1, -98, 0, 24),
        Position = UDim2.new(0, 66, 0, 0),
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
        BorderSizePixel = 0,
      }, {
        Corner = e("UICorner", {
          CornerRadius = UDim.new(0, 4),
        }),

        Inner = e("Frame", {
          Size = UDim2.new(1, -64, 1, 0),
          Position = UDim2.new(0, 0, 0, 0),
          BackgroundTransparency = 1,
        }, {
          List = e("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
          }),

          Padding = e("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
          }),

          Roact.createFragment(breadcrumbs),
        }),
      }),

      Menu = e(IconButton, {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -24, 0, 0),

        color = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
        image = Assets.icons.Menu,
      }),
    }),

    Row2 = e("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -16, 0, 24),
      Position = UDim2.new(0, 8, 0, 40),
    }, props[Roact.Children])
  })
end

TopBar = RoactHooks.new(Roact)(TopBar)

return RoactRodux.connect(
  function(state)
    return {
      selectedDataStore = state.selectedDataStore,
      selectedKey = state.selectedKey,
    }
  end,
  function(dispatch)
    return {
      onRefresh = function()
        dispatch({
          type = "Refresh",
        })
      end,

      deselectDataStore = function()
        dispatch({
          type = "SelectDataStore",
          dataStore = nil,
        })
      end,

      deselectKey = function()
        dispatch({
          type = "SelectKey",
          key = nil,
        })
      end,
    }
end
)(TopBar)
