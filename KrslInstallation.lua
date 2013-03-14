--[[
  KrslInstallation.lua (v0.5.1)

  Copyright (c) 2013 Krooshal (http://krooshal.com/)

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
]]

json = require "json"
local box = (require 'GGData'):new("Krooshal")

local KrslInstallation = {}
local KrslInstallation_mt = { __index = KrslInstallation }

local function logError(message)
    print ("Krooshal [ERROR] " .. message)
end

local function logInfo(message)
    print ("Krooshal [INFO] " .. message)
end

local function isNilOrBlank(x)
    return (not x) or (x == "nil") or (not not tostring(x):find("^%s*$"))
end

local function getPropertyKey(apiKey, key)
    return string.format("Krooshal_%s_%s", tostring(apiKey), tostring(key))
end

local function getProperty(apiKey, key)
    return box:get(getPropertyKey(apiKey, key))
end

local function setProperty(apiKey, key, value)
    box:set(getPropertyKey(apiKey, key), value)
    box:save()
end

local function xhrOpen(apiKey, urlPart, method, params, onLoad, onError)
    local apiPath = 'https://api.krooshal.com/1/installations'
    local installationId = KrslInstallation:getInstallationId(apiKey)
    if isNilOrBlank(installationId) then
        logInfo("No prior installation detected")
    else
        logInfo("Prior installation detected (" .. installationId .. ")")
        apiPath = (apiPath .. '/' .. installationId)
    end
    if not isNilOrBlank(urlPart) then
        apiPath = (apiPath .. '/' .. urlPart)
    end
    logInfo(method .. "ing to " .. apiPath .. " with " .. json.encode(params))
    local function networkListener (event)
        logInfo("Received " .. event.response .. " with status " .. tostring(event.status))
        if math.floor(event.status/100) ~= 2 then
            event.isError = true
        end
        if (event.isError) then
            if type(onError) == 'function' then
                onError(event)
            end
        else
            if type(onLoad) == 'function' then
                onLoad(event)
            end
        end
    end
    local headers = {['X-Krooshal-Api-Key'] = apiKey}
    local p = {['headers'] = headers}
    if params then
        headers['Content-Type'] = 'application/json'
        p['body'] = json.encode(params)
    end
    network.request(apiPath, method, networkListener, p)
end

function KrslInstallation:getInstallationId(apiKey)
    if (not apiKey) and self then
        apiKey = self.apiKey
    end
    return tostring(getProperty(apiKey, 'installationId'))
end

function KrslInstallation:new()
    local self = {}
    setmetatable(self, KrslInstallation_mt)
    return self
end

local function getTimeZoneOffset()
    local now = os.time()
    now = os.difftime(now, os.time(os.date("!*t", now)))
    local h, m = math.modf(now / 3600)
    return string.format("%+.4d", 100 * h + 60 * m)
end

function KrslInstallation:install(appBundle, appVersion, apiKey, onInstall)
    self.apiKey = apiKey
    if isNilOrBlank(apiKey) then
        logError("Api Key is required")
        return
    end

    local env = {
        osType = system.getInfo("platformName"),
        osVersion = system.getInfo("platformVersion"),
        deviceType = system.getInfo("environment"),
        deviceMaker = system.getInfo("model"),
        appBundle = appBundle,
        appVersion = appVersion,
        timeZone = getTimeZoneOffset(),
        language = system.getPreference("locale", "language"),
        stack = "corona"
    }
    if not env.appBundle then
        logError("Unable to determine installation (appBundle)")
        return
    end
    if not env.appVersion then
        logError("Unable to determine installation (appVersion)")
        return
    end
    xhrOpen(apiKey, '', 'POST', env, function(response)
        pcall(function()
            response = json.decode(response.response)
            if (response and response.installationId) then
                setProperty(apiKey, 'installationId', response.installationId)
            end
        end)
        if (type(onInstall) == 'function') then
            onInstall()
        end
    end, function(response)
        if (response.status == 404) then
            --installationId is corrupt. Clear it and retry
            local installationId = self:getInstallationId()
            if not isNilOrBlank(installationId) then
                setProperty(apiKey, 'installationId', nil)
                self:install(appBundle, appVersion, apiKey, onInstall)
            end
        end
    end)
end

function KrslInstallation:tag(tags)
    xhrOpen(self.apiKey, 'tags', 'POST', {tags = tags})
end

function KrslInstallation:checkForUpdate()
    xhrOpen(self.apiKey, 'status', 'GET', nil, function(response)
        pcall(function()
            if not response then
                return
            end
            response = json.decode(response.response)
            if not response or not response.actions then
                return
            end

            local buttons = {}
            for k in pairs(response.actions) do
              buttons[k] = response.actions[k].label
            end

            native.showAlert(response.title or '', response.message or '', buttons, function(event)
                if (event.action == "clicked") then
                    pcall(function()
                        for k in pairs(response.actions) do
                            if(k == event.index) then
                                xhrOpen(self.apiKey, 'actions', 'POST', {action = response.actions[k].type})
                                local target = response.actions[k].target
                                if (not (target and target.type and target.data)) then
                                    return
                                end
                                if (target.type == 'url') then
                                    system.openURL(target.data)
                                elseif (target.type == 'app_store') then
                                    native.showPopup("appStore", {
                                        iOSAppId = target.data.iOSAppId,
                                        nookAppEAN = target.data.nookAppEAN,
                                        androidAppPackageName = target.data.androidAppPackageName,
                                        supportedAndroidStores = target.data.supportedAndroidStores
                                    })
                                end
                                break
                            end
                        end
                    end)
                elseif (event.action == "cancelled") then
                    self:checkForUpdate()
                end
            end)
        end)
    end)
end

__krslInstallation__ = KrslInstallation:new()

return { getCurrent = __krslInstallation__ }