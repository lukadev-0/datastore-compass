local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local Promise = require(Packages.Promise)

local StudioTheme = require(script.Parent.StudioTheme)
local LoadingIndicator = require(script.Parent.LoadingIndicator)

local e = Roact.createElement

local function InfiniteScroller(props, hooks)
  local contentSize, setContentSize = hooks.useState(Vector2.new())
  local shouldLoadMore, setShouldLoadMore = hooks.useState(false)
  local isFinished, setIsFinished = hooks.useState(false)
  local theme = StudioTheme.useTheme(hooks)

  hooks.useEffect(function()
    if shouldLoadMore then
      Promise.resolve(props.loadMore()):andThen(function(isFinished)
        if isFinished then
          setIsFinished(true)
        else
          setShouldLoadMore(false)
        end
      end)
    end
  end, {shouldLoadMore})

  return e("ScrollingFrame", {
    Position = UDim2.new(0, 0, 0, 32),
    Size = UDim2.new(1, 0, 1, -32),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageTransparency = 0,
    ScrollBarImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.BrightText),
    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,

    CanvasSize = UDim2.new(0, 0, 0, contentSize.Y),

    [Roact.Change.CanvasPosition] = function(rbx: ScrollingFrame)
      local scrollY = rbx.CanvasPosition.Y
      local scrollBottom = contentSize.Y - scrollY
      local scrollEnd = scrollBottom - rbx.AbsoluteWindowSize.Y

      if scrollEnd < 500 then
        if not shouldLoadMore then
          setShouldLoadMore(true)
        end
      end
    end,
  }, {
    ListLayout = e("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder,
      FillDirection = Enum.FillDirection.Vertical,
      Padding = UDim.new(0, 4),

      [Roact.Change.AbsoluteContentSize] = function(rbx)
        if contentSize ~= rbx.AbsoluteContentSize then
          setContentSize(rbx.AbsoluteContentSize)
        end
      end,
    }),

    Roact.createFragment(props[Roact.Children]),

    LoadingIndicator = e("Frame", {
      Size = UDim2.new(1, 0, 0, 100),
      BackgroundTransparency = 1,
      LayoutOrder = 9999999,
      Visible = shouldLoadMore and not isFinished,
    }, {
      Indicator = e(LoadingIndicator, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
      })
    })
  })
end

return RoactHooks.new(Roact)(InfiniteScroller)
