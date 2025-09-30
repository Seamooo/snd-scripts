require("common/liberror")

---@class WrathIpcClientConfig
---@field AppName string
WrathIpcClientConfig = {}

---@class WrathIpcClientConfigBuilder
---@field AppName string?
WrathIpcClientConfigBuilder = {}
WrathIpcClientConfigBuilder.__index = WrathIpcClientConfigBuilder

---@return WrathIpcClientConfigBuilder
function WrathIpcClientConfigBuilder.new()
    return setmetatable({}, WrathIpcClientConfigBuilder)
end

---@return Result<WrathIpcClientConfig, string>
---@nodiscard
function WrathIpcClientConfigBuilder:build()
    local AppName = self.AppName
    if AppName == nil then
        return Result.Err("unset app name")
    end
    -- XXX(seamooo) if config ends up getting methods, must set metatable here
    local rv = {
        AppName = AppName,
    }
    return Result.Ok(rv)
end

---@class WrathIpcClient
---@field Config WrathIpcClientConfig
---@field private leaseId WrathComboLeaseGuid
---@field private ipc WrathComboIPC memoised ipc to avoid nilcheck
---@field private _disposed boolean marker for whether the dispose method has been called
WrathIpcClient = {}
WrathIpcClient.__index = WrathIpcClient

---@enum WrathIpcClientError
WrathIpcClientError = {
    IpcNotReady = 0,
    RegisterFailed = 1,
    GetCombosFailed = 2,
    GetComboOptionsFailed = 3,
}


---@param config WrathIpcClientConfig
---@return Result<WrathIpcClient, WrathIpcClientError>
---@nodiscard
function WrathIpcClient.new(config)
    local ipc = IPC.WrathCombo
    if ipc == nil or not ipc.IPCReady() then
        return Result.Err(WrathIpcClientError.IpcNotReady)
    end
    local leaseId = ipc.Register(config.AppName)
    if leaseId == nil then
        return Result.Err(WrathIpcClientError.RegisterFailed)
    end
    return Result.Ok(setmetatable({
        Config = config,
        leaseId = leaseId,
        _disposed = false,
    }, WrathIpcClient))
end

---must call this at the start of every method
---@private
function WrathIpcClient:disposeCheck()
    if self._disposed then error("use after free") end
end

---@param jobId number id of the job to enable rotation options for
---@return Result<nil,WrathIpcClientError>
---@nodiscard
function WrathIpcClient:EnableJobRotations(jobId)
    self:disposeCheck()
    -- unimplemented
    local combos = self.ipc.GetComboNamesForJob(jobId)
    if combos == nil or combos.Count == 0 then
        return Result.Err(WrathIpcClientError.GetCombosFailed)
    end
    local comboOptions = self.ipc.GetComboOptionNamesForJob(jobId)
    if comboOptions == nil then
        return Result.Err(WrathIpcClientError.GetComboOptionsFailed)
    end
    return Result.Ok(nil)
end


function WrathIpcClient:Dispose()
    self:disposeCheck()
    -- release lease
    -- MUST CALL THIS BEFORE EXIT OTHERWISE SCRIPT WILL BE BLACKLISTED
    self.ipc.ReleaseControl(self.leaseId)
    self._disposed = true
end
