---@enum ResultStatus
ResultStatus = {
    Ok = 0,
    Err = 1,
}

---@class ResultOk<T>: { status: ResultStatus.Ok, val: T }
---@class ResultErr<E>: { status: ResultStatus.Err, val: E }

---@alias Result<T,E> ResultOk<T> | ResultErr<E>

---@class ResultNamespace
Result = {}
Result.__index = {}

---@generic T,E
---@param val T
---@return Result<T,E>
function Result.Ok(val)
    return setmetatable({ status = ResultStatus.Ok, val = val }, Result)
end

---@generic T,E
---@param val E
---@return Result<T,E>
function Result.Err(val)
    return setmetatable({ status = ResultStatus.Err, val = val }, Result)
end

---@generic T,E
---@param self Result<T,E>
---@return T
function Result:unwrap()
    if self.status == ResultStatus.Err then
        error("unwrapped error: " .. tostring(self.val), 2)
    end
    return self.val
end

---@generic T,E
---@param self Result<T,E>
---@param defaultVal T
---@return T
function Result:unwrapOr(defaultVal)
    if self.status == ResultStatus.Err then
        return defaultVal
    end
    return self.val
end

---@generic T,E
---@param self Result<T,E>
---@param f fun(T): T
---@return Result<T,E>
function Result:map(f)
    if self.status == ResultStatus.Err then
        return self
    end
    return setmetatable({ status = ResultStatus.Ok, val = f(self.val) }, Result)
end

---@generic T,E
---@param self Result<T,E>
---@param default T
---@param f fun(T): T
---@return T
function Result:mapOr(default, f)
    if self.status == ResultStatus.Err then
        return default
    end
    return f(self.val)
end

---@generic T,E
---@param self Result<T,E>
---@return boolean
function Result:isOk()
    return self.status == ResultStatus.Ok
end

---@generic T,E
---@param self Result<T,E>
---@return boolean
function Result:isErr()
    return self.status == ResultStatus.Err
end
