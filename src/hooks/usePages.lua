--!strict
local Packages = script.Parent.Parent.Parent
local Llama = require(Packages.Llama)
local Promise = require(Packages.Promise)

local usePromise = require(script.Parent.usePromise)

local function usePages(hooks, fn, dependencies: {any}?)
  local promise = usePromise(hooks, fn, dependencies)
  local items, setItems = hooks.useState({})

  hooks.useEffect(function()
    if promise.data then
      local pages = promise.data :: Pages
      local items = pages:GetCurrentPage()

      setItems(function(currentItems)
        return Llama.List.concat(currentItems, items)
      end)
    end
  end, {promise.data})

  hooks.useEffect(function()
    setItems({})
  end, dependencies)

  local function loadNextPage()
    return promise.promise
      :andThen(function(pages: Pages)
        if pages.IsFinished then
          return true
        end

        return Promise.try(function()
          pages:AdvanceToNextPageAsync()
        end):andThen(function()
          local items = pages:GetCurrentPage()
          
          setItems(function(currentItems)
            return Llama.List.concat(currentItems, items)
          end)
        end)
      end)
  end

  return {
    isLoading = promise.isLoading,
    pages = promise.data,
    error = promise.error,
    promise = promise.promise,
    items = items,
    loadNextPage = loadNextPage,
  }
end

return usePages
