local heist = false
local searchers = {}
local valid_codes = {}
local isThereSignal = false
local hackFails = 0
local TowerHacking = false
local GateHacking = false
local hacker, netd1, netv1

RegisterServerEvent('usa_gunraid:BuyFromPed')
AddEventHandler('usa_gunraid:BuyFromPed', function()

	-- PLACEHOLDER CHECK IF SOURCE HAS 10000 DOLLARS IN CASH

	-- PLACEHOLDER TAKE 10000 DOLLARS FROM SOURCE

	-- GIVE SOURCE ONE HACKING TABLET

	TriggerClientEvent('usa_gunraid:PedInfo', source)

	-- PLACEHOLDER IF SOURCE DOES NOT HAVE 10000 CASH 

	TriggerClientEvent('usa_gunraid:NoMoneyPed', source)

end)

RegisterServerEvent('usa_gunraid:hackattempt')
AddEventHandler('usa_gunraid:hackattempt', function()

	local cooldown = false
	local lasthack = Config.LastHacked

    if TowerHacking then

    	TriggerClientEvent('usa_gunraid:hackattemptAlreadyHacking', source)


    else

    	if (os.time() - lasthack) < Config.TowerCooldown and lasthack ~= 0 then

        	cooldown = true

	    else

	        cooldown = false
	        TowerHacking = true

	    end

    	TriggerClientEvent('usa_gunraid:hackattemptReturn', source, cooldown)

    end


end)

RegisterServerEvent('usa_gunraid:hackstarted')
AddEventHandler('usa_gunraid:hackstarted', function()
	
	-- PLACEHOLDER SEND 911 TO POLICE
	TriggerClientEvent("usa_gunraid:911placeholder", -1, "911 | Hacking in Progress | Vinewood Sign")

end)

RegisterServerEvent('usa_gunraid:hackcomplete')
AddEventHandler('usa_gunraid:hackcomplete', function()

	TowerHacking = false
	
	isThereSignal = true

	hacker = source

	Config.LastHacked = os.time() 

end)

RegisterServerEvent('usa_gunraid:hackfail')
AddEventHandler('usa_gunraid:hackfail', function()

	TowerHacking = false

	hackFails = hackFails + 1
	local locked = false

	print("Failed Hacks: "..hackFails)

	if (hackFails >= Config.FailsToLockdown) then

		Config.LastHacked = os.time()
		locked = true

	end

	TriggerClientEvent('usa_gunraid:hackfailReturn', source, locked)

end)

RegisterServerEvent('usa_gunraid:downloadcomplete')
AddEventHandler('usa_gunraid:downloadcomplete', function(code)
	
	table.insert(valid_codes, code)

end)

RegisterServerEvent('usa_gunraid:limoarrived')
AddEventHandler('usa_gunraid:limoarrived', function()
	
	isThereSignal = false

end)

RegisterServerEvent('usa_gunraid:getCodes')
AddEventHandler('usa_gunraid:getCodes', function()

	local codes = ""

	for i,v in pairs (valid_codes) do

		codes = codes .. v .. " "

	end

	print("Getting Codes" .. codes)
	
	TriggerClientEvent('usa_gunraid:printCodes',source,  valid_codes, source)

end)

RegisterServerEvent('usa_gunraid:inspectpanel')
AddEventHandler('usa_gunraid:inspectpanel', function()

	local cooldown = false
	local lasthack = Config.LastHacked
	
	if (os.time() - lasthack) < Config.TowerCooldown and lasthack ~= 0 then

        cooldown = true

    else

        cooldown = false

    end

    time = (os.time() - lasthack) / 60
    
	
	TriggerClientEvent('usa_gunraid:inspectReturn', source, isThereSignal, hacker, cooldown, time)

end)


RegisterServerEvent('usa_gunraid:hackgate')
AddEventHandler('usa_gunraid:hackgate', function()

	local cooldown = false
	local lasthack = Config.LastHacked

    TriggerClientEvent('usa_gunraid:hackgateReturn', source, cooldown)

end)

RegisterServerEvent('usa_gunraid:verifycode')
AddEventHandler('usa_gunraid:verifycode', function(password)

	local found = false

	for k,v in pairs(valid_codes) do

		if v == password then

			found = true

		end

	end

    TriggerClientEvent('usa_gunraid:verifycodeReturn', source, found)

end)

RegisterServerEvent('usa_gunraid:openGate')
AddEventHandler('usa_gunraid:openGate', function()

    TriggerClientEvent('usa_gunraid:RemoveGate', -1)

end)

RegisterServerEvent('usa_gunraid:search')
AddEventHandler('usa_gunraid:search', function(search)
	
	local source = source
	local crate = crates[search]

	if (os.time() - crate.lastsearched) < Config.CrateCooldown and crate.lastsearched ~= 0 then

		TriggerClientEvent('usa_gunraid:notify', source, "This box has already been searched and is empty!")

	else

		if crate.searching == false then 

			crate.searching = true 

			TriggerClientEvent('usa_gunraid:notify', source, "Starting to search Crate! ("..crate.name..")")
			TriggerClientEvent('usa_gunraid:currentlysearching', source, search)

			searchers[source] = search
			local savedSource = source

			SetTimeout(Config.TimeToSearch*1000, function()

				if (searchers[savedSource]) then
				
					crate.searching = false

					crate.lastsearched = os.time()

					TriggerClientEvent('usa_gunraid:searchcomplete', source)

					--ADD LOCKBOX TO SOURCE INVENTORY PLACEHOLDER

				end

			end)

		else

			TriggerClientEvent('usa_gunraid:notify', source, "Someone is already searching this box!")

		end

	end

end)

RegisterServerEvent('usa_gunraid:toofar')
AddEventHandler('usa_gunraid:toofar', function()

	local source = source
	crate.searching = false

	if searchers[source] then

		TriggerClientEvent('usa_gunraid:toofarclient', source)
		searchers[source] = nil

	end

end)

RegisterServerEvent('usa_gunraid:unlockbox')
AddEventHandler('usa_gunraid:unlockbox', function()

	local source = source

	--if (player has 1 or more lockboxes in their inventory) then PLACEHOLDER
		--if (player has 1 or more wrenches in their inventory) then PLACEHOLDER

			TriggerClientEvent('usa_gunraid:unlocking', source)

			--SEND 911 CALL PLACEHOLDER
			TriggerClientEvent("usa_gunraid:911placeholder", -1, "911 | Suspicius Person making noise | Great Ocean Highway")

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

RegisterServerEvent('usa_gunraid:lockboxtoofar')
AddEventHandler('usa_gunraid:lockboxtoofar', function()

	local source = source
	TriggerClientEvent('usa_gunraid:toofarclient', source)

end)
