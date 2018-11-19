--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2018, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        os.lua
--

-- define module
local os = os or {}

-- load modules
local string = require("ltui/base/string")

-- is file?
function os.isfile(filepath)
    local file = filepath and io.open(filepath, 'r') or nil
    if file then
        file:close()
    end
    return file ~= nil
end

-- raise an exception and abort the current script
--
-- the parent function will capture it if we uses pcall or xpcall
--
function os.raise(msg, ...)

    -- raise it
    if msg then
        error(string.tryformat(msg, ...))
    else
        error()
    end
end

-- run program
function os.run(cmd, ...)
    return os.execute(string.tryformat(cmd, ...))
end

-- run program and get io output
function os.iorun(cmd, ...)
    local ok = false
    local outs = nil
    local file = io.popen(string.tryformat(cmd, ...), "r")
    if file then
        outs = file:read("*a"):trim()
        file:close()
        ok = true
    end
    return ok, outs
end

-- get host name
function os.host()
    if os._HOST == nil then
        local ok, result = os.iorun("uname") 
        if ok then
            if result:lower():find("linux", 1, true) then
                os._HOST = "linux"
            elseif result:lower():find("darwin", 1, true) then
                os._HOST = "macosx"
            end
        elseif os.run("cmd /c ver") == 0 then
            os._HOST = "windows"
        end
    end
    return os._HOST
end

-- read string data from pasteboard
function os.pbpaste()
    if os.host() == "macosx" then
        local ok, result = os.iorun("pbpaste")
        if ok then
            return result
        end
    elseif os.host() == "linux" then
        local ok, result = os.iorun("xsel --clipboard --output")
        if ok then
            return result
        end
    else
        -- TODO
    end
end

-- copy string data to pasteboard
function os.pbcopy(data)
    if os.host() == "macosx" then
        os.run("bash -c \"echo '" .. data .. "' | pbcopy\"")
    elseif os.host() == "linux" then
        os.run("bash -c \"echo '" .. data .. "' | xsel --clipboard --input\"")
    else
        -- TODO
    end
end

-- return module
return os
