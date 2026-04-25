local Data = game:GetService("DataStoreService")
local HS = game:GetService("HttpService")
local Reports = Data:GetDataStore("Game__OFFICIAL__Reports")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TextService")
local admins = {"vesbus"}
local Key = "Reports97"

local function CheckAdmin(Player)
    for _,Admin in pairs (admins) do
        if type(Admin) == "string" and string.lower(Admin) == string.lower(Player.Name) then
            return true
        end
    end
    return false
end

function SendReport(player, playerReported, reportOption, OptionalDescription)
	if Reports:GetAsync(Key) == nil or tonumber(Reports:GetAsync(Key)) ~= nil then
		local ReportTable = {
			{ReportedBy = player.Name, PlayerReported = playerReported, ReportChoice = reportOption, OptionDesc = OptionalDescription}
		}
		pcall(function()
			Reports:SetAsync(Key, HS:JSONEncode(ReportTable))
		end)
		return "Finished"
	else
		local ReportTable = HS:JSONDecode(Reports:GetAsync(Key))
		table.insert(ReportTable, {ReportedBy = player.Name, PlayerReported = playerReported, ReportChoice = reportOption, OptionDesc = OptionalDescription})
		pcall(function()
			Reports:SetAsync(Key, HS:JSONEncode(ReportTable))
		end)
		return "Finished"
	end
end
				
function ViewReports(player)
	for i,v in pairs(admins) do
		if CheckAdmin(player) then
			if tonumber(Reports:GetAsync(Key)) ~= nil then
				return "None"
			elseif Reports:GetAsync(Key) == nil then
				return "None"
			elseif tonumber(Reports:GetAsync(Key)) == nil or Reports:GetAsync(Key) ~= nil then
				local Table = HS:JSONDecode(Reports:GetAsync(Key))
				return Table
			end
		else
			return "Unauthorized"
		end
	end
end

function ClearAllReports(player)
	if CheckAdmin(player) then
		pcall(function()
			Reports:SetAsync(Key, 0)
		end)
		return "Cleared"
	else
		return "Unauthorized"
	end
end

function FilterText(player, text)
	local Filter = TS:FilterStringAsync(tostring(text), player.UserId)
	return Filter:GetNonChatStringForBroadcastAsync()
end

RS:FindFirstChild("ReportRemotes"):FindFirstChild("ClearReports").OnServerInvoke = ClearAllReports
RS:FindFirstChild("ReportRemotes"):FindFirstChild("SendUserReport").OnServerInvoke = SendReport
RS:FindFirstChild("ReportRemotes"):FindFirstChild("ViewAllReports").OnServerInvoke = ViewReports
RS:FindFirstChild("ReportRemotes"):FindFirstChild("CheckUserAdmin").OnServerInvoke = CheckAdmin
RS:FindFirstChild("ReportRemotes"):FindFirstChild("FilterReport").OnServerInvoke = FilterText
