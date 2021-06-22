local ESX = nil
TriggerEvent("::{korioz#0110}::esx:getSharedObject", function(obj) ESX = obj end)

RegisterCommand("vote", function(source, args, rawcommand)

    local function getLicense(source)
        for k,v in pairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("license:")) == "license:" then
            return v
            end

        end
        return ""
    end

    playerLicense = getLicense(source) -- TEST

    if playerLicense then
        
        MySQL.Async.fetchAll("SELECT character_id, almacoinn, resetokens FROM users WHERE identifier = '"..playerLicense.."' ", {}, function (result)
            local playerId = result[1].character_id
            local tokens = result[1].almacoinn
            local resetokens = result[1].resetokens

            if playerId and tokens and resetokens then

                PerformHttpRequest("https://api.top-serveurs.net/v1/votes/check?server_token=BOL6BCOX3I&playername="..playerId, function (errorCode, resultData, resultHeaders)
                    local data = json.decode(resultData)

                    if data then
    
                        local tempsApi = string.match(data.message,"%d+")
                        
                        if tonumber(tempsApi) == 1 then
                            tempsRevote = tempsApi.." minute"
                        else
                            tempsRevote = tempsApi.." minutes"
                        end

                        local codeApi = tonumber(data.code)

                            if codeApi == 200 then -- ACTIONS A ENTREPRENDRE SI LE JOUEUR A BIEN VOTE

                                PerformHttpRequest("https://southbeach.city/api/api", function (errorCode, resultData, resultHeaders)
                                    local utcLocalData = json.decode(resultData)

                                    if utcLocalData then
                                        local actualTime = string.gsub(utcLocalData.paris, "%D", "")
    
                                            local resetokensTime = string.gsub(utcReunionData.gmt, "%D", "")

                                            if actualTime >= resetokens then

                                                local tokensGift = math.random( 10, 20 )
        
                                                local tokens = tokens + tokensGift

                                                MySQL.Async.execute("UPDATE users SET almacoinn= '"..tokens.."' WHERE character_id = '"..playerId.."'", {}, function() end)
                                                MySQL.Async.execute("UPDATE users SET resetokens= '"..resetokensTime.."' WHERE character_id = '"..playerId.."'", {}, function() end)

                                                TriggerClientEvent("::{korioz#0110}::esx:showNotification", source, "~g~Vous venez de remporter "..tokensGift.." tokens pour avoir voté pour SouthBeach, Merci à vous !")
                                            else
                                                TriggerClientEvent("::{korioz#0110}::esx:showNotification", source, "~r~Vous avez déjà reçu votre récompense de vote. Veuillez attendre "..tempsRevote)
                                            end

                                    else
                                        TriggerClientEvent("::{korioz#0110}::esx:showNotification", source, "~r~Une erreur est survenue. Veuillez contacter un administrateur - Code erreur : #Kilo")
                                    end

                                end)
    
                            else
                                TriggerClientEvent("::{korioz#0110}::esx:showNotification", source, "~r~Vous n'avez pas voté pour SouthBeach. https://top-serveurs.net/gta/southbeach")
                                MySQL.Async.execute("UPDATE users SET resetokens= '0' WHERE character_id = '"..playerId.."'", {}, function() end)
                            end
    
                    else
                        TriggerClientEvent("::{korioz#0110}::esx:showNotification", source, "~r~Vous n'avez pas voté pour SouthBeach. https://top-serveurs.net/gta/southbeach")
                    end
    
                end)
    
            else
                TriggerClientEvent("::{korioz#0110}::esx:showNotification", source, "~r~Erreur lors de la récupération de votre ID. Veuillez contacter un administrateur")
            end
        end)

    else
        TriggerClientEvent("::{korioz#0110}::esx:showNotification", source, "~r~Erreur lors de la récupération de votre license. Veuillez contacter un administrateur")
    end

end)
