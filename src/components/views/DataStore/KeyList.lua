local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local RoactRodux = require(Packages.RoactRodux)
local Promise = require(Packages.Promise)
local Llama = require(Packages.Llama)

local StudioTheme = require(script.Parent.Parent.Parent.StudioTheme)
local LoadingIndicator = require(script.Parent.Parent.Parent.LoadingIndicator)
local usePages = require(script.Parent.Parent.Parent.Parent.hooks.usePages)
local KeyListItem = require(script.Parent.KeyListItem)
local InfiniteScroller = require(script.Parent.Parent.Parent.InfiniteScroller)

local e = Roact.createElement

local function KeyList(props, hooks)
  local theme = StudioTheme.useTheme(hooks)
  local dataStore = props.dataStore :: DataStore
  local pages = usePages(hooks, function()
    return Promise.try(function()
      return dataStore:ListKeysAsync(props.searchQuery)
    end)
  end, {props.searchQuery, props.refreshTime})

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
    }),

    Contents = if pages.isLoading
      then e(LoadingIndicator, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
      })
      else e(InfiniteScroller, {
        loadMore = pages.loadNextPage,
      }, if #pages.items > 0
          then Llama.Dictionary.map(pages.items, function(item: DataStoreKey)
            return e(KeyListItem, {
              item = item,
              onClick = function()
                props.selectKey(item.KeyName)
              end,
            }), item.KeyName
          end)
          else {
            e("TextLabel", {
              Size = UDim2.new(1, 0, 0, 50),
              BackgroundTransparency = 1,
              Text = "No Results",
              TextSize = 16,
              Font = Enum.Font.SourceSans,
              TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
              TextXAlignment = Enum.TextXAlignment.Center,
              TextYAlignment = Enum.TextYAlignment.Center,
            })
          }
    )
  })
end

KeyList = RoactHooks.new(Roact)(KeyList)

return RoactRodux.connect(
  function(state)
    return {
      refreshTime = state.refreshTime,
      dataStore = state.selectedDataStore,
    }
  end,
  function(dispatch)
    return {
      selectKey = function(key)
        dispatch({
          type = "SelectKey",
          key = key,
        })
      end,
    }
  end
)(KeyList)
