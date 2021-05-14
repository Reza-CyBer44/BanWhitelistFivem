AddEventHandler('DiscordBot:Ready', function()

CurrentBans = json.decode(
                  LoadResourceFile(GetCurrentResourceName(), "BanWhiteList/Bans.json"))
CurrentWhitelists = json.decode(LoadResourceFile(GetCurrentResourceName(),
                                                 "BanWhiteList/Whitelists.json"))

GetPlayerCorrectIdentifier = function(ID)
    local steam, license
    local identifiers = GetPlayerIdentifiers(id)
    for _, v in pairs(identifiers) do
        if string.find(v, "steam:") then
            steam = string.gsub(v, "steam:", "")
        end
        if string.find(v, "license:") then
            license = string.gsub(v, "license:", "")
        end
    end
    if BanWhiteListConfig.IdentifierToWorkWith == 'license' then
        return license
    else
        return steam
    end

end
RemoveWhitelists = function(identifier)
    if has_value(CurrentWhitelists, identifier) then
        table.removekey(CurrentWhitelists,
                        tablefind(CurrentWhitelists, identifier))
        SaveResourceFile(GetCurrentResourceName(), "Whitelists.json",
                         json.encode(CurrentWhitelists), -1)
    end
end

AddToWhitelists = function(identifier)
    if not has_value(CurrentWhitelists, identifier) then
        table.insert(CurrentWhitelists, identifier)
        SaveResourceFile(GetCurrentResourceName(), "Whitelists.json",
                         json.encode(CurrentWhitelists), -1)
    end

end
IsPlayerAlreadyWhitelisted = function(identifier)
    if has_value(CurrentWhitelists, identifier) then return true end
end
BanIdentifier = function(identifier)
    if not has_value(CurrentBans, identifier) then
        table.insert(CurrentBans, identifier)
        SaveResourceFile(GetCurrentResourceName(), "Bans.json",
                         json.encode(CurrentBans), -1)
    end
end
UnbanIdentifier = function(identifier)
    if has_value(CurrentBans, identifier) then
        table.removekey(CurrentBans, tablefind(CurrentBans, identifier))
        SaveResourceFile(GetCurrentResourceName(), "Bans.json",
                         json.encode(CurrentBans), -1)
    end
end

IsPlayerAlreadyBanned = function(identifier)
    if has_value(CurrentBans, identifier) then return true end
end

function tablefind(tab, el)
    if tab and el then
        for index, value in pairs(tab) do
            if value == el then return index end
        end
    end
end
function table.removekey(table, key)
    if table and key then
        local element = table[key]
        table[key] = nil
        return element
    end
end

RegisterDiscordCommand('banid', 'Ban a Player', false,
                                             function(args, channelid,
                                                      discordid, roles)
    if args ~= nil and args[2] and GetPlayerName(args[2]) then
        local PlayerIdentifier = GetPlayerCorrectIdentifier(args[2])
        if not IsPlayerAlreadyBanned(PlayerIdentifier) then
            DropPlayer(args[2], 'You Have Been Banned From The Server')
            BanIdentifier(PlayerIdentifier)
            return 'Succesfuly Banned the Player'
        else
            DropPlayer(args[2], 'You Have Been Banned From The Server')
            return 'This Player is Already Banned'
        end

    else
        return 'Player Not Found'
    end
end)

RegisterDiscordCommand('banoffline',
                                             'Ban a Player By Their Identifier',
                                             false,
                                             function(args, channelid,
                                                      discordid, roles)
    if args ~= nil and args[2] then
        local PlayerIdentifier = args[2]
        if not IsPlayerAlreadyBanned(PlayerIdentifier) then
            BanIdentifier(PlayerIdentifier)
            return 'Succesfuly Banned the Identifier'
        else
            return 'This Identifier is Already In The ban List'
        end

    else
        return 'Please Enter a Identifier'
    end
end)
RegisterDiscordCommand('unban', 'Unban a Identifier',
                                             false,
                                             function(args, channelid,
                                                      discordid, roles)

    if args ~= nil and args[2] then
        local PlayerIdentifier = args[2]
        if not IsPlayerAlreadyBanned(PlayerIdentifier) then
            return 'This Identifier is Not In The Ban List'
        else
            UnbanIdentifier(PlayerIdentifier)
            return 'Succesfully Removed the Identifier From The Ban List'
        end

    else
        return 'Please Enter a Identifier'
    end
end)
RegisterDiscordCommand('removewhitelist',
                                             'Remove a Identifier From Whitelist',
                                             false,
                                             function(args, channelid,
                                                      discordid, roles)
    if args ~= nil and args[2] then
        local PlayerIdentifier = args[2]
        if not IsPlayerAlreadyWhitelisted(PlayerIdentifier) then
            return 'This Identifier is Not In The White List'
        else
            RemoveWhitelist(PlayerIdentifier)
            return 'Succesfully Removed the Identifier From The Ban List'
        end

    else
        return 'Please Enter a Identifier'
    end
end)
RegisterDiscordCommand('addwhitelist',
                                             'Add A Identifier To Whitelist',
                                             false,
                                             function(args, channelid,
                                                      discordid, roles)
    if args ~= nil and args[2] then
        local PlayerIdentifier = args[2]
        if not IsPlayerAlreadyWhitelisted(PlayerIdentifier) then
            AddWhiteList(PlayerIdentifier)
            return 'This Identifier Has been Added to the WhiteList'
        else
            return 'This Identifier is Already in the Whitelist'
        end

    else
        return 'Please Enter a Identifier'
    end
end)

AddEventHandler('playerConnecting', function(name, kick, deferrals)
    local player = source
    local identifier = GetPlayerCorrectIdentifier(player)
    if IsPlayerAlreadyBanned(identifier) then
        CancelEvent()
        kick(BanWhiteListConfig.BanString)
        return
    end
    if BanWhiteListConfig.EnableWhitelist then
        if IsPlayerAlreadyWhitelisted then
            CancelEvent()
            kick(BanWhiteListConfig.WhitelistString)
            return
        end
    end

end)

end)