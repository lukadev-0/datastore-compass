local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local Llama = require(Packages.Llama)

local StudioTheme = require(script.Parent.StudioTheme)
local Assets = require(script.Parent.Parent.assets)

local e = Roact.createElement

local function CheckBox(props, hooks)
  local theme = StudioTheme.useTheme(hooks)

  local position = props.Position :: UDim2
  local styleModifier = if props.Checked
    then Enum.StudioStyleGuideModifier.Selected
    else Enum.StudioStyleGuideModifier.Default

  return e("Frame", {
    -- account for 1 pixel border
    Position = UDim2.new(
      position.X.Scale,
      position.X.Offset + 1,
      position.Y.Scale,
      position.Y.Offset + 1
    ),

    Size = UDim2.fromOffset(20, 20),
    AnchorPoint = props.AnchorPoint,

    BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBackground, styleModifier),
  }, {
    Detector = e("TextButton", {
      Size = UDim2.fromScale(1, 1),
      BackgroundTransparency = 1,
      Text = "",
      [Roact.Event.Activated] = props[Roact.Event.Activated],
    }),

    Corner = e("UICorner", {
      CornerRadius = UDim.new(0, 4),
    }),

    Stroke = e("UIStroke", {
      ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
      Thickness = 1,
      Color = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldBorder, styleModifier),
    }),

    Indicator = e("ImageLabel", Llama.Dictionary.merge(Assets.icons.Check, {
      Position = UDim2.new(0, 0, 0, 0),
      Size = UDim2.fromOffset(20, 20),
      ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.CheckedFieldIndicator, styleModifier),
      BackgroundTransparency = 1,
      Visible = props.Checked,
    })),
  })
end

return RoactHooks.new(Roact)(CheckBox)
