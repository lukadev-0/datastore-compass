local Packages = script.Parent.Parent
local Rodux = require(Packages.Rodux)

return Rodux.combineReducers({
  placeName = require(script.placeName),
  refreshTime = require(script.refreshTime),
  selectedDataStore = require(script.selectedDataStore),
  selectedKey = require(script.selectedKey),
})
