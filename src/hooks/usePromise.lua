--!strict

local function usePromise(hooks, fn, dependencies: {any}?)
  local isLoading, setIsLoading = hooks.useState(true)
  local data, setData = hooks.useState(nil)
  local err, setErr = hooks.useState(nil)
  local promise = hooks.useMemo(function()
    return fn()
  end, dependencies)

  hooks.useEffect(function()
    setIsLoading(true)
    setData(nil)
    setErr(nil)

    promise:andThen(function(data)
      setIsLoading(false)
      setData(data)
    end):catch(function(err)
      setIsLoading(false)
      setErr(err)
    end)

    return function()
      promise:cancel()
    end
  end, {promise})

  return {
    isLoading = isLoading,
    data = data,
    error = err,
    promise = promise,
  }
end

return usePromise
