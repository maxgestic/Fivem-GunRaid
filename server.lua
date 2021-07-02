local searching = false
local heist = false
local searchers = {}

RegisterServerEvent('usa_gunraid:toofar')
AddEventHandler('usa_gunraid:toofar', function()

	local source = source
	searching = false

	if searchers[source] then

		TriggerClientEvent('usa_gunraid:toofarclient', source)
		searchers[source] = nil

	end

end)

RegisterServerEvent('usa_gunraid:lockboxtoofar')
AddEventHandler('usa_gunraid:lockboxtoofar', function()

	local source = source
	TriggerClientEvent('usa_gunraid:toofarclient', source)

end)

RegisterServerEvent('usa_gunraid:search')
AddEventHandler('usa_gunraid:search', function(search)
	
	local source = source
	local crate = crates[search]



	if searching == false then 

		searching = true 

		TriggerClientEvent('usa_gunraid:notify', source, "Starting to search Crate! ("..crate.name..")")
		TriggerClientEvent('usa_gunraid:currentlysearching', source, search)

		searchers[source] = search
		local savedSource = source

		SetTimeout(Config.TimeToSearch*1000, function()

			if (searchers[savedSource]) then
			
				searching = false

				TriggerClientEvent('usa_gunraid:searchcomplete', source)

				--ADD LOCKBOX TO SOURCE INVENTORY PLACEHOLDER

			end

		end)

	else

		TriggerClientEvent('usa_gunraid:notify', source, "Someone is already searching this box!")

	end

end)

RegisterServerEvent('usa_gunraid:unlockbox')
AddEventHandler('usa_gunraid:unlockbox', function()

	local source = source

	--if (player has 1 or more lockboxes in their inventory) then PLACEHOLDER
		--if (player has 1 or more wrenches in their inventory) then PLACEHOLDER

			TriggerClientEvent('usa_gunraid:unlocking', source)

			--SEND 911 CALL PLACEHOLDER

			SetTimeout(Config.TimeToUnlockBox*1000, function()

				--if (player has 1 or more lockboxes in their inventory) then PLACEHOLDER
					--if (player has 1 or more wrenches in their inventory) then PLACEHOLDER

						local random = math.random(100)

						if random > Config.WrenchBreakChance then

							--REMOVE LOCKBOX FROM INVENTORY PLACEHOLDER

							--ADD WEAPON TO INVENTORY PLACEHOLDER
						
							TriggerClientEvent('usa_gunraid:unlockcomplete', source)


						else

							--REMOVE WRENCH FROM INVENTORY PLACEHOLDER

							TriggerClientEvent('usa_gunraid:unlockfailed', source)

						end

					--end PLACEHOLDER

				--end PLACEHOLDER

			end)

		--end PLACEHOLDER
	--end PLACEHOLDER

end)