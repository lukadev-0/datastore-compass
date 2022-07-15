-- Modified version of https://github.com/tiffany352/Roblox-Tag-Editor/blob/main/src/Loader.server.lua

-- sanity check
if not plugin then
  error("[DataStore Compass] was not run as plugin")
end

local source = script.Parent.Parent
local root = source

-- test-place.project.json adds 'IsDev' attribute to the plugin
local isDev = root:GetAttribute("IsDev") == true

if isDev then
  warn(("[DataStore Compass] IsDev was 'true' on %s"):format(root.Name))

  local ServerStorage = game:GetService("ServerStorage")
  local devSource = ServerStorage:FindFirstChild("DataStore Compass")

  if devSource == nil then
    warn("[DataStore Compass] could not find dev source")
    warn("[DataStore Compass] will not be running in dev mode")

    isDev = false
  else
    warn(("[DataStore Compass] will be using source from %s"):format(devSource:GetFullName()))
    warn("[DataStore Compass] will be running in dev mode")

    root = devSource
    source = devSource
    isDev = true
  end
end

local PluginFacade = {
  _toolbars = {},
  _pluginGuis = {},
  _buttons = {},
  _watching = {},
  _beforeUnload = nil,
  isDev = isDev,
}

function PluginFacade:toolbar(name)
  if self._toolbars[name] then
    return self._toolbars[name]
  end

  local toolbar = plugin:CreateToolbar(name)

  self._toolbars[name] = toolbar

  return toolbar
end

function PluginFacade:button(toolbar, name, tooltip, icon)
  local existingButtons = self._buttons[toolbar]

  if existingButtons then
    local existingButton = existingButtons[name]

    if existingButton then
      return existingButton
    end
  else
    existingButtons = {}
    self._buttons[toolbar] = existingButtons
  end

  local button = toolbar:CreateButton(name, tooltip, icon)

  existingButtons[name] = button

  return button
end

function PluginFacade:createDockWidgetPluginGui(name, ...)
  if self._pluginGuis[name] then
    return self._pluginGuis[name]
  end

  local gui = plugin:CreateDockWidgetPluginGui(name, ...)
  self._pluginGuis[name] = gui

  return gui
end

function PluginFacade:beforeUnload(callback)
  self._beforeUnload = callback
end

function PluginFacade:_load(savedState)
  local ok, result = pcall(require, root.DatastoreCompass.main)

  if not ok then
    warn("[DataStore Compass] plugin failed to load")
    warn(" ", result)
    return
  end

  local Plugin = result

  ok, result = pcall(Plugin, PluginFacade, savedState)

  if not ok then
    warn("[DataStore Compass] error whilst running plugin")
    warn(" ", result)
    return
  end
end

function PluginFacade:unload()
  if self._beforeUnload then
    local saveState = self._beforeUnload()
    self._beforeUnload = nil

    return saveState
  end
end

function PluginFacade:_reload()
  local saveState = self:unload()
  root = source:Clone()

  self:_load(saveState)
end

function PluginFacade:_watch(instance)
  if self._watching[instance] then
    return
  end

  -- Don't watch ourselves!
  if instance == script then
    return
  end

  local changedConnection = instance.Changed:Connect(function()
    print(
      "[DataStore Compass] reloading due to " .. instance
        :GetFullName()
        :gsub("^ServerStorage.DataStore Compass.", "")
    )
    self:_reload()
  end)

  local childAddedConnection = instance.ChildAdded:Connect(function(child)
    self:_watch(child)
  end)

  local connections = {changedConnection, childAddedConnection}

  self._watching[instance] = connections

  for _, child in instance:GetChildren() do
    self:_watch(child)
  end
end

PluginFacade:_load()
PluginFacade:_watch(source)
