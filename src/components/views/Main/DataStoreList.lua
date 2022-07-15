local DataStoreService = game:GetService("DataStoreService")

local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local RoactRodux = require(Packages.RoactRodux)
local Promise = require(Packages.Promise)
local Llama = require(Packages.Llama)

local StudioTheme = require(script.Parent.Parent.Parent.StudioTheme)
local LoadingIndicator = require(script.Parent.Parent.Parent.LoadingIndicator)
local usePages = require(script.Parent.Parent.Parent.Parent.hooks.usePages)
local DataStoreListItem = require(script.Parent.DataStoreListItem)
local InfiniteScroller = require(script.Parent.Parent.Parent.InfiniteScroller)

local e = Roact.createElement

local function DataStoreList(props, hooks)
  local theme = StudioTheme.useTheme(hooks)
  local pages = usePages(hooks, function()
    return Promise.try(function()
      return DataStoreService:ListDataStoresAsync(props.searchQuery)
    end)
  end, {props.searchQuery, props.refreshTime})

  if pages.isLoading then
    return e(LoadingIndicator, {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.5, 0),
    })
  end

  return Roact.createFragment({
    Header = e("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, 24),
      Position = UDim2.new(0, 0, 0, 0),
    }, {
      Border = e("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
        BorderSizePixel = 0,
      }),

      Name = e("TextLabel", {
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(3/5, -40, 1, -1),
        BackgroundTransparency = 1,
        TextSize = 16,
        Font = Enum.Font.SourceSans,
        Text = "Name",
        TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
        TextXAlignment = Enum.TextXAlignment.Left,
      }),

      UpdatedAt = e("TextLabel", {
        Position = UDim2.new(3/5, 4, 0, 0),
        Size = UDim2.new(1/5, -8, 1, -1),
        BackgroundTransparency = 1,
        TextSize = 16,
        Font = Enum.Font.SourceSans,
        Text = "Updated At",
        TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
        TextXAlignment = Enum.TextXAlignment.Left,
      }),

      CreatedAt = e("TextLabel", {
        Position = UDim2.new(4/5, 4, 0, 0),
        Size = UDim2.new(1/5, -8, 1, -1),
        BackgroundTransparency = 1,
        TextSize = 16,
        Font = Enum.Font.SourceSans,
        Text = "Created At",
        TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
        TextXAlignment = Enum.TextXAlignment.Left,
      }),
    }),

    Contents = e(InfiniteScroller, {
      loadMore = pages.loadNextPage,
    }, {
      ListLayout = e("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 4),
      }),

      if #pages.items > 0
        then Roact.createFragment(
          Llama.Dictionary.map(pages.items, function(item: DataStoreInfo)
            return e(DataStoreListItem, {
              item = item,
              onClick = function()
                props.selectDataStore(
                  if props.useOrdered
                    then DataStoreService:GetOrderedDataStore(item.DataStoreName)
                    else DataStoreService:GetDataStore(item.DataStoreName)
                )
              end,
            }), item.DataStoreName
          end)
        )
        else e("TextLabel", {
          Size = UDim2.new(1, 0, 0, 50),
          BackgroundTransparency = 1,
          Text = "No Results",
          TextSize = 16,
          Font = Enum.Font.SourceSans,
          TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
          TextXAlignment = Enum.TextXAlignment.Center,
          TextYAlignment = Enum.TextYAlignment.Center,
        }),
    })
  })
end

DataStoreList = RoactHooks.new(Roact)(DataStoreList)

return RoactRodux.connect(
  function(state)
    return {
      refreshTime = state.refreshTime,
    }
  end,
  function(dispatch)
    return {
      selectDataStore = function(dataStore)
        dispatch({
          type = "SelectDataStore",
          dataStore = dataStore,
        })
      end,
    }
  end
)(DataStoreList)
