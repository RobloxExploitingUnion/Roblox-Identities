local function try(fn, ...)
	return (pcall(fn, ...))
end

local securityChecks = {
	{
		name = "None",
		number = 0,
		canAccess = try(function() return game.Name end) -- Wouldn't this mean "DataModelSecurity" or sum?
	},
	{
		name = "PluginSecurity",
		number = 1,
		canAccess = try(function() return game:GetService("CoreGui").Name end)
	},
	{
		name = "LocalUserSecurity",
		number = 3,
		canAccess = try(function() return game.DataCost end)
	},
	{
		name = "WritePlayerSecurity",
		number = 4,
		canAccess = try(Instance.new, "Player")
	},
	{
		name = "RobloxScriptSecurity",
		number = 5,
		canAccess = try(function() return game:GetService("CorePackages").Name end)
	},
	{
		name = "RobloxSecurity",
		number = 6,
		canAccess = try(function() return Instance.new("SurfaceAppearance").TexturePack end)
	},
	{
		name = "NotAccessibleSecurity",
		number = 7,
		canAccess = try(function() Instance.new("MeshPart").MeshId = "" end)
	},
	{
		name = "Assistant",
		number = 8, -- ?
		canAccess = try(function() local s=game:GetService("StreamingService")s:RegisterCommandInternal("sup",function(...)return ... end,false,true)s:UnregisterCommand("sup") end) -- this should be enough, even though this can be faked lmao
	},
	{
		name = "OpenCloud",
		number = 9, -- ?
		canAccess = false -- ?
	}
}

local function getCustomIndex(table, index, value)
	for _, x in pairs(table) do
		if x[index] == value then
			return x
		end
	end
end

local identityCapabilities = { -- ty https://github.com/InfernusScripts
	{"LocalGui",  {"PluginSecurity", "None", "LocalUserSecurity"}},
	{"GameScript",  {"None"}},
	{"CoreScript",  {"PluginSecurity", "None", "LocalUserSecurity", "RobloxScriptSecurity"}},
	{"CommandBar",  {"PluginSecurity", "None", "LocalUserSecurity"}},
	{"StudioPlugin",  {"PluginSecurity", "None"}},
	{"ElevatedStudioPlugin",  {"PluginSecurity", "None", "LocalUserSecurity", "RobloxScriptSecurity"}},
	{"COM",  {"PluginSecurity", "None", "LocalUserSecurity", "WritePlayerSecurity", "RobloxScriptSecurity", "RobloxSecurity", "NotAccessibleSecurity"}},
	{"WebService",  {"PluginSecurity", "None", "LocalUserSecurity", "WritePlayerSecurity", "RobloxScriptSecurity", "RobloxSecurity", "NotAccessibleSecurity"}},
	{"Replicator",  {"WritePlayerSecurity", "None", "RobloxScriptSecurity"}},
	{"Assistant",  {"Assistant", "None", "PluginSecurity", "LocalUserSecurity"}},
	{"OpenCloudSession",  {"OpenCloud", "None"}}
}

local realId = 0
local requirementLength = 0

for identity, capabilities in pairs(identityCapabilities) do
	identityName = capabilities[1]
	capabilities = capabilities[2]
    local index = 0
	for _, capability in pairs(capabilities) do
        local capabilityTable = getCustomIndex(securityChecks, "name", capability)
		if capabilityTable.canAccess then
			index+= 1
		end
	end
    requirementLength = #capabilities > requirementLength and #capabilities or requirementLength
    realId = requirementLength == #capabilities and index == #capabilities and identity or realId
end

local act = print
if realId ~= getthreadidentity() then
    act = warn
    warn(("Fake identity is '%u' which requires '%s'."):format(getthreadidentity(), game:GetService("HttpService"):JSONEncode(identityCapabilities[getthreadidentity()][2])))
end

act(("Real identity is '%u' which requires '%s'."):format(realId, game:GetService("HttpService"):JSONEncode(identityCapabilities[realId][2])))
if setclipboard then
    setclipboard(game:GetService("HttpService"):JSONEncode(act == print and identityCapabilities[realId][2] or {Real = identityCapabilities[realId][2], Fake = identityCapabilities[getthreadidentity()][2]}))
    act((act == print and ("Fulfilled requirements for Level '%u'"):format(getthreadidentity()) or "Requirements") .. " copied to clipboard")
end
