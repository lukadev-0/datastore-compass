local MarketplaceService = game:GetService("MarketplaceService")

local Packages = script.Parent.Parent
local Roact = require(Packages.Roact)
local RoactRodux = require(Packages.RoactRodux)
local Rodux = require(Packages.Rodux)
local Promise = require(Packages.Promise)

local reducer = require(script.Parent.reducer)
local App = require(script.Parent.components.App)
local StudioTheme = require(script.Parent.components.StudioTheme)

local function getSuffix(plugin)
	if plugin.isDev then
		return " [DEV]", "Dev"
	else
		return "", ""
	end
end

local function main(plugin, savedState)
  local displaySuffix, nameSuffix = getSuffix(plugin)

  local toolbar = plugin:toolbar("DataStore Compass" .. displaySuffix)

  local toggleButton = plugin:button(
		toolbar,
		"DataStore Compass",
		"Open the DataStore Compass window",
    "rbxassetid://7245838712"
	)
	toggleButton.ClickableWhenViewportHidden = true

  local store = Rodux.Store.new(reducer, savedState)

	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 556, 240, 556, 240)
	local gui = plugin:createDockWidgetPluginGui("DataStoreCompass" .. nameSuffix, info)
	gui.Name = "DataStoreCompass" .. nameSuffix
	gui.Title = "DataStore Compass" .. displaySuffix
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	toggleButton:SetActive(gui.Enabled)

	local buttonConnection = toggleButton.Click:Connect(function()
		gui.Enabled = not gui.Enabled
	end)

	local function onEnable()
    toggleButton:SetActive(gui.Enabled)

		if gui.Enabled then
			if game.GameId == 0 then
				warn("[DataStore Compass] Publish your game to use DataStore Compass")
				store:dispatch({
					type = "SetPlaceName",
					placeName = { err = "Publish your game to use DataStore Compass" },
				})
				return
			end

			Promise.try(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
				:andThen(function(data)
					store:dispatch({
						type = "SetPlaceName",
						placeName = data.Name,
					})
				end)
				:catch(function(err)
					store:dispatch({
						type = "SetPlaceName",
						placeName = { err = tostring(err) },
					})
				end)
		end
	end

  local guiEnableConnection = gui:GetPropertyChangedSignal("Enabled"):Connect(function()
		onEnable()
  end)
	onEnable()

	local app = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		Roact.createElement(StudioTheme.Provider, nil, {
      App = Roact.createElement(App),
    }),
	})

	local instance = Roact.mount(app, gui, "DataStoreCompass")

	plugin:beforeUnload(function()
		Roact.unmount(instance)
		buttonConnection:Disconnect()
    guiEnableConnection:Disconnect()
		return store:getState()
	end)

	local unloadConnection
	unloadConnection = gui.AncestryChanged:Connect(function()
		print("New DataStore Compass version coming online; unloading the old version")
		unloadConnection:Disconnect()
		plugin:unload()
	end)
end

return main
