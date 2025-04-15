--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Freeze = require(Packages.Freeze)

local StringUtility = {}

function StringUtility.GetFirstStringInAlphabet(StringList: { string }): (string, number)
	local alphabeticSort = Freeze.List.sort(StringList, function(a: string, b: string)
		return a:lower() < b:lower()
	end)
	return alphabeticSort[1], table.find(StringList, alphabeticSort[1]) :: number
end

return StringUtility