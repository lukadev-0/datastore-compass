local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local Llama = require(Packages.Llama)

local StudioTheme = require(script.Parent.Parent.Parent.StudioTheme)
local Assets = require(script.Parent.Parent.Parent.Parent.assets)

local e = Roact.createElement

local function KeyListItem(props, hooks)
  local theme = StudioTheme.useTheme(hooks)
  local isHovered, setIsHovered = hooks.useState(false)
  local item = props.item :: DataStoreKey

  local styleModifier = if isHovered
    then Enum.StudioStyleGuideModifier.Hover
    else Enum.StudioStyleGuideModifier.Default

  return e("Frame", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Item, styleModifier),
    BorderSizePixel = 0,
  }, {
    Detector = e("TextButton", {
      BackgroundTransparency = 1,
      Size = UDim2.fromScale(1, 1),
      Text = "",

      [Roact.Event.MouseEnter] = function()
        setIsHovered(true)
      end,
  
      [Roact.Event.MouseLeave] = function()
        setIsHovered(false)
      end,

      [Roact.Event.Activated] = function()
        props.onClick()
      end,
    }),

    Corner = e("UICorner", {
      CornerRadius = UDim.new(0, 4),
    }),

    Icon = e("ImageLabel", Llama.Dictionary.merge(Assets.icons.CurlyBraces, {
      Position = UDim2.new(0, 4, 0, 0),
      Size = UDim2.new(0, 24, 0, 24),
      ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.SubText),
      BackgroundTransparency = 1,
    })),

    Name = e("TextLabel", {
      Position = UDim2.new(0, 36, 0, 0),
      Size = UDim2.new(3/5, -40, 1, -1),
      BackgroundTransparency = 1,
      TextSize = 16,
      Font = Enum.Font.SourceSans,
      Text = item.KeyName,
      TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
      TextXAlignment = Enum.TextXAlignment.Left,
    }),
  })
end

return RoactHooks.new(Roact)(KeyListItem)
