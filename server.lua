AddEventHandler('playerConnecting', function()
	TriggerClientEvent('showNotification', -1,"~g~".. GetPlayerName(source).."~w~ joined.")
end)

AddEventHandler('playerDropped', function()
	TriggerClientEvent('showNotification', -1,"~r~".. GetPlayerName(source).."~w~ left.")
end)

RegisterServerEvent('playerDied')
AddEventHandler('playerDied',function(killer,reason)
    print(reason)
	if killer == "**Invalid**" then 
		reason = 2
	end
	if reason == 0 then
        TriggerClientEvent('showNotification', -1,"".. GetPlayerName(source).." committed suicide. ")
	elseif reason == 1 then
		TriggerClientEvent('showNotification', -1,"".. killer .. " killed "..GetPlayerName(source)..".")
	else
		TriggerClientEvent('showNotification', -1,"".. GetPlayerName(source).." died.")
	end
end)

RegisterServerEvent('baseevents:onPlayerDied')
AddEventHandler('baseevents:onPlayerDied',  function()
    print("i'm dead")
end)