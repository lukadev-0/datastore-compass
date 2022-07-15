local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)
local Llama = require(Packages.Llama)

local StudioTheme = require(script.Parent.StudioTheme)

local e = Roact.createElement

local function IconButton(props, hooks)
  local theme = StudioTheme.useTheme(hooks)
  local isHovered, setIsHovered = hooks.useState(false)

  local restProps = Llama.Dictionary.removeKeys(props, "color", "image")

  return e("ImageButton", Llama.Dictionary.merge(
    props.image, 
    {
      BackgroundTransparency = if isHovered then 0.8 else 1,
      BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.BrightText),
      ImageColor3 = props.color,
      AutoButtonColor = false,

      [Roact.Event.MouseEnter] = function()
        setIsHovered(true)
      end,

      [Roact.Event.MouseLeave] = function()
        setIsHovered(false)
      end,
    },
    restProps
  ), {
    Corner = e("UICorner", {
      CornerRadius = UDim.new(0, 4),
    }),
  })
end

return RoactHooks.new(Roact)(IconButton)
