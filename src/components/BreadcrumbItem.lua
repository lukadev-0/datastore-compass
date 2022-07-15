local Packages = script.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RoactHooks = require(Packages.RoactHooks)

local StudioTheme = require(script.Parent.StudioTheme)

local e = Roact.createElement

local function BreadcrumbItem(props, hooks)
  local theme = StudioTheme.useTheme(hooks)
  local isHovered, setIsHovered = hooks.useState(false)

  return e("TextButton", {
    Active = not props.active,
    Text = props.text,
    Size = UDim2.new(0, 0, 1, 0),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1,
    Font = Enum.Font.SourceSans,
    TextSize = 16,
    TextColor3 = theme:GetColor(
      if props.active
        then Enum.StudioStyleGuideColor.BrightText
        elseif isHovered
        then Enum.StudioStyleGuideColor.BrightText
        else Enum.StudioStyleGuideColor.SubText
    ),

    [Roact.Event.Activated] = props.onClick,

    [Roact.Event.MouseEnter] = function()
      setIsHovered(true)
    end,

    [Roact.Event.MouseLeave] = function()
      setIsHovered(false)
    end,
  })
end

return RoactHooks.new(Roact)(BreadcrumbItem)
