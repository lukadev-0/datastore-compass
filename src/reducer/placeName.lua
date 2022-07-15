local Packages = script.Parent.Parent.Parent
local Rodux = require(Packages.Rodux)

return Rodux.createReducer(nil, {
  SetPlaceName = function(_, action)
    return action.placeName
  end,
})
