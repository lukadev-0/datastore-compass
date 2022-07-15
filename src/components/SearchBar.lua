local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local Llama = require(Packages.Llama)

local StudioTheme = require(script.Parent.StudioTheme)
local Assets = require(script.Parent.Parent.assets)

local e = Roact.createElement

local function SearchBar(props, hooks)
  local theme = StudioTheme.useTheme(hooks)
  local isHovered, setIsHovered = hooks.useState(false)
  local isFocused, setIsFocused = hooks.useState(false)

  local position = props.Position :: UDim2
  local width = props.Width :: UDim

  local styleModifier = if isFocused
    then Enum.StudioStyleGuideModifier.Selected
    elseif isHovered
    then Enum.StudioStyleGuideModifier.Hover
    else Enum.StudioStyleGuideModifier.Default

  return e("TextBox", {
    -- account for 1 pixel border
    Position = UDim2.new(
      position.X.Scale,
      position.X.Offset + 1,
      position.Y.Scale,
      position.Y.Offset + 1
    ),

    Size = UDim2.new(
      width,
      UDim.new(0, 30)
    ),

    BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),

    Text = props.Text or "",
    PlaceholderText = props.PlaceholderText,

    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
    PlaceholderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
    Font = Enum.Font.SourceSans,
    ClipsDescendants = true,
    ClearTextOnFocus = false,

    [Roact.Event.MouseEnter] = function()
      setIsHovered(true)
    end,

    [Roact.Event.MouseLeave] = function()
      setIsHovered(false)
    end,

    [Roact.Event.Focused] = function()
      setIsFocused(true)
    end,

    [Roact.Event.FocusLost] = function(enterPressed)
      setIsFocused(false)
      if props[Roact.Event.FocusLost] then
        props[Roact.Event.FocusLost](enterPressed)
      end
    end,
  }, {
    Padding = e("UIPadding", {
      PaddingLeft = UDim.new(0, 8),
    }),

    Corner = e("UICorner", {
      CornerRadius = UDim.new(0, 4),
    }),

    Stroke = e("UIStroke", {
      ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
      Thickness = 1,
      Color = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, styleModifier),
    }),

    IconContainer = e("Frame", {
      SizeConstraint = Enum.SizeConstraint.RelativeYY,
      Size = UDim2.fromScale(1, 1),
      Position = UDim2.fromScale(1, 0),
      AnchorPoint = Vector2.new(1, 0),
      BackgroundTransparency = 1,
    }, {
      Border = e("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
      }),

      Detector = e("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
      }),

      IconButton = e("ImageLabel", Llama.Dictionary.merge(Assets.icons.Search, {
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
      }))
    }),
  })
end

return RoactHooks.new(Roact)(SearchBar)
