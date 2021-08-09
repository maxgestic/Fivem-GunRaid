local searchers = {}
local valid_codes = {}
local isThereSignal = false
local hackFails = 0
local gatehackFails = 0
local TowerHacking = false
local GateHacking = false
local gateOpen = false
local hacker
local interval = 0.5
local isElevatorHacked = false
local elevatorHacking = false
local pedsSpawned = false
local playersInRaid = {}
local pedNets = {}
local hackingTablet = {
	name = "Hacking Tablet",
	price = 10000,
	type = "misc",
	quantity = 1,
	legality = "illigal",
	weight = 10,
	invisibleWhenDropped = false
}

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

RegisterServerEvent('usa_gunraid:getCodes') -- DEBUG Server Event to get Codes valid
AddEventHandler('usa_gunraid:getCodes', function()
	local codes = ""
	for i,v in pairs (valid_codes) do
		codes = codes .. v .. " "
	end
	-- print("Getting Codes" .. codes)
	TriggerClientEvent('usa_gunraid:printCodes',source,  valid_codes, source)
end)

RegisterServerEvent('usa_gunraid:BuyFromPed') -- Server Event that checks if player has enough cash to get advice and hacking tablet, if so gives tablet
AddEventHandler('usa_gunraid:BuyFromPed', function()
	local c = exports["usa-characters"]:GetCharacter(source)
	-- if c.get("money") >= hackingTablet.price then
	-- 	if c.canHoldItem(hackingTablet) then
	-- 		-- give to player
	-- 		c.removeMoney(hackingTablet.price)
	-- 		c.giveItem(hackingTablet)
	-- 		TriggerClientEvent('usa_gunraid:PedInfo', source)
	-- 	else 
	-- 		TriggerClientEvent("usa:notify", source, "Inventory full!")
	-- 	end
	-- else
	-- 	TriggerClientEvent('usa_gunraid:NoMoneyPed', source)
	-- end

	-- PLACEHOLDER REMOVE ON LIVE
	TriggerClientEvent('usa_gunraid:PedInfo', source)
	TriggerClientEvent('usa_gunraid:NoMoneyPed', source)
	-- END OF PLACEHOLDER
end)

RegisterServerEvent('usa_gunraid:hackattempt') -- Server Event that gets called when player attempts to hack tower, checks if tower is on cooldown
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

RegisterServerEvent('usa_gunraid:hackstarted') -- Server Event that gets called when player starts hacking, used to send 911
AddEventHandler('usa_gunraid:hackstarted', function()
	-- PLACEHOLDER SEND 911 TO POLICE
	TriggerClientEvent("usa_gunraid:911placeholder", -1, "911 | Hacking in Progress | Vinewood Sign")
end)

RegisterServerEvent('usa_gunraid:hackcomplete') -- Server Event that gets called when player completes cell tower hack
AddEventHandler('usa_gunraid:hackcomplete', function()
	TowerHacking = false
	isThereSignal = true
	hacker = GetPlayerPed(source)
	Config.LastHacked = os.time() 
end)

RegisterServerEvent('usa_gunraid:hackfail') -- Server Event that gets called when player fails cell tower hack
AddEventHandler('usa_gunraid:hackfail', function()
	TowerHacking = false
	hackFails = hackFails + 1
	local locked = false
	if (hackFails >= Config.FailsToLockdown) then
		hackFails = 0
		Config.LastHacked = os.time()
		locked = true
	end
	TriggerClientEvent('usa_gunraid:hackfailReturn', source, locked)
end)

RegisterServerEvent('usa_gunraid:downloadcomplete') -- Server Event that gets called when player finishes the downloading of the access codes
AddEventHandler('usa_gunraid:downloadcomplete', function(code)
	table.insert(valid_codes, code)
end)

RegisterServerEvent('usa_gunraid:limoarrived') -- Server Event that gets called when limo arrives at desitnation
AddEventHandler('usa_gunraid:limoarrived', function()
	isThereSignal = false
end)

RegisterServerEvent('usa_gunraid:inspectpanel') -- Server Event that gets called when a police officer inspects the cell tower
AddEventHandler('usa_gunraid:inspectpanel', function()
	local cooldown = false
	local lasthack = Config.LastHacked
	if (os.time() - lasthack) < Config.TowerCooldown and lasthack ~= 0 then
        cooldown = true
    else
        cooldown = false
    end
    time = (os.time() - lasthack) / 60
	TriggerClientEvent('usa_gunraid:inspectReturn', source, isThereSignal, cooldown, time)
end)

RegisterServerEvent('usa_gunraid:activetracking') -- 
AddEventHandler('usa_gunraid:activetracking', function()
	local src = source
	local lastUpdateTime = os.time()
	while true do
		if os.difftime(os.time(), lastUpdateTime) >= interval then	
			local coords = GetEntityCoords(hacker)
			TriggerClientEvent("usa_gunraid:updatetracker", src, coords)
			lastUpdateTime = os.time()
		end
		Wait(500)
	end
end)

RegisterServerEvent('usa_gunraid:hackgate') -- TODO Server Event that gets called when a payer starts hacking the gate
AddEventHandler('usa_gunraid:hackgate', function()
    local cooldown = false
	local lasthack = Config.GateLastHacked
	if not GateHacking then
		if (os.time() - lasthack) < Config.GateCooldown and lasthack ~= 0 then
        	cooldown = true
	    else
	        cooldown = false
	        GateHacking = true
	    end
	    TriggerClientEvent('usa_gunraid:hackgateReturn', source, cooldown)
	else
		TriggerClientEvent('usa_gunraid:notify', source, "Someone is already hacking the gate control!")
	end
end)

RegisterServerEvent('usa_gunraid:gatehackfail') -- Server Event that gets called when player fails gate hack
AddEventHandler('usa_gunraid:gatehackfail', function()
	print("Setting gate hack to false")
	GateHacking = false
	gatehackFails = gatehackFails + 1
	local locked = false
	-- print("Failed Hacks: "..gatehackFails)
	if (gatehackFails >= Config.GateFailsToLockdown) then
		gatehackFails = 0
		Config.GateLastHacked = os.time()
		locked = true
	end
	TriggerClientEvent('usa_gunraid:gatehackfailReturn', source, locked)
end)

RegisterServerEvent('usa_gunraid:verifycode') -- Server Event that gets called when player enters a code
AddEventHandler('usa_gunraid:verifycode', function(password)
	local found = false
	for k,v in pairs(valid_codes) do
		if v == password then
			found = true
		end
	end
	GateHacking = false
    TriggerClientEvent('usa_gunraid:verifycodeReturn', source, found)
end)

RegisterServerEvent('usa_gunraid:openGate') -- Server Event that gets called when the gate opens
AddEventHandler('usa_gunraid:openGate', function()
    gateOpen = true
    Config.GateLastHacked = os.time()
    TriggerClientEvent('usa_gunraid:RemoveGate', -1)
    SetTimeout(Config.GateUnlockTime * 1000, function ()
    	gateOpen = false
    	TriggerClientEvent('usa_gunraid:SpawnGate', -1)
    end)
end)

RegisterServerEvent('usa_gunraid:addPlayerToRaid') -- Server Event that gets called when the gate opens
AddEventHandler('usa_gunraid:addPlayerToRaid', function()
    table.insert(playersInRaid, source)
end)

RegisterServerEvent('usa_gunraid:search') -- Server Event that gets called when the player searches a crate
AddEventHandler('usa_gunraid:search', function(search)
	local source = source
	local crate = crates[search]
	if (os.time() - crate.lastsearched) < Config.CrateCooldown and crate.lastsearched ~= 0 then
		TriggerClientEvent('usa_gunraid:notify', source, "This box has already been searched and is empty!")
	else
		if crate.searching == false then 
			crate.searching = true
			local letters = "abcdefghijklmnopqrstuvwxyz"
			local numbers = "0123456789"
			local characterSet = letters .. numbers
			local keyL = Config.CodeLength 
			local key = ""
			for i = 1, keyL do 
				local rand = math.random(#characterSet)
				key = key .. string.sub(characterSet, rand, rand)
			end
			local keySaved = key
			searchers[source] = key
			TriggerClientEvent('usa_gunraid:notify', source, "Starting to search Crate!")
			TriggerClientEvent('usa_gunraid:currentlysearching', source, search)
			SetTimeout(Config.TimeToSearch*1000, function()
				-- print((searchers[source]).. ", " keySaved)
				if (searchers[source]) == keySaved then
					crate.searching = false
					crate.lastsearched = os.time()
					TriggerClientEvent('usa_gunraid:searchcomplete', source,  crate.name)
					--PLACEHOLDER ADD LOCKBOX TO SOURCE INVENTORY PLACEHOLDER
				end
			end)
		else
			TriggerClientEvent('usa_gunraid:notify', source, "Someone is already searching this box!")
		end
	end
end)

RegisterServerEvent('usa_gunraid:toofar') -- Server Event that gets called when the player moves to far away from a crate while searching
AddEventHandler('usa_gunraid:toofar', function(search)
	local source = source
	local crate = crates[search]
	crate.searching = false
	if searchers[source] then
		TriggerClientEvent('usa_gunraid:toofarclient', source, crate.name)
		searchers[source] = nil
	end
end)

RegisterServerEvent('usa_gunraid:hackelevator') -- TODO Server Event that gets called when a payer starts hacking the elevator
AddEventHandler('usa_gunraid:hackelevator', function()
	if not elevatorHacking then
		elevatorHacking = true
    	TriggerClientEvent('usa_gunraid:hackelevatorReturn', source)
    else
    	TriggerClientEvent('usa_gunraid:notify', source, "Someone is already hacking the elevator!")
    end
end)

RegisterServerEvent('usa_gunraid:checkelevator') -- Server Event that gets called when a payer starts hacking the elevator
AddEventHandler('usa_gunraid:checkelevator', function()
	TriggerClientEvent('usa_gunraid:checkelevatorReturn', source, isElevatorHacked)
end)

RegisterServerEvent('usa_gunraid:elevatorHacked') -- Server Event that gets called when a hacks the elevator sucessfully
AddEventHandler('usa_gunraid:elevatorHacked', function()
    isElevatorHacked = true
    elevatorHacking = false
    TriggerClientEvent("usa_gunraid:notify", source, "Elevator has been hacked, it will be open for the next 5 minutes!")
    SetTimeout(300000, function ()
    	isElevatorHacked = false
    end)
end)

RegisterServerEvent('usa_gunraid:elevatorhackfail') -- Server Event that gets called when player fails elevator hack
AddEventHandler('usa_gunraid:elevatorhackfail', function()
	print("Setting elevator hack to false")
	elevatorHacking = false
	TriggerClientEvent('usa_gunraid:elevatorhackfailReturn', source)
end)

RegisterServerEvent('usa_gunraid:unlockbox') -- Server Event that gets called when the player unlocks a lockbox
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

RegisterServerEvent('usa_gunraid:lockboxtoofar') -- Server Event that gets called when the player moves to far from the unlock spot when unlocking a box
AddEventHandler('usa_gunraid:lockboxtoofar', function()
	local source = source
	TriggerClientEvent('usa_gunraid:toofarclient', source)
end)

RegisterServerEvent('usa_gunraid:spawnPedsServer') -- Server Event that gets called when the player goes up the elevator and spawns peds
AddEventHandler('usa_gunraid:spawnPedsServer', function()
	local source = source
	if not pedsSpawned then
		for k,v in pairs(playersInRaid) do
			print(k,v)
		end
		pedsSpawned = true
		TriggerClientEvent('usa_gunraid:spawnPeds', source)
		local playersInArea = true
		local distanceFromRaid = {}
		while playersInArea do
			local distanceFromRaid = {}
			Citizen.Wait(0)
			for k,v in pairs(playersInRaid) do
				local vec1 = GetEntityCoords(GetPlayerPed(v), false)
				local vec2 = vector3(5010.34, -5748.88, 19.80)
				local d1 = false
				if #(vec2 - vec1) > 140 then
					d1 = true
				end
				distanceFromRaid[k] = d1
			end
			if not has_value(distanceFromRaid, false) then 
				playersInArea = false
				for k,v in pairs(pedNets) do
				    local ent = NetworkGetEntityFromNetworkId(v)
				    -- print(ent)
				    DeleteEntity(ent)
				end
				TriggerClientEvent('usa_gunraid:deletePeds', -1)
				pedNets = {}
				pedsSpawned = false
				playersInRaid = {}
				Config.GateLastHacked = os.time()
			end
		end
	end
end)

RegisterServerEvent('usa_gunraid:getNetIDs') -- Server Event that gets called when the player goes up the elevator and spawns peds
AddEventHandler('usa_gunraid:getNetIDs', function(val)
	for k,v in pairs(val) do
		table.insert(pedNets, v)
		-- print(v)
	end
end)

RegisterServerEvent('usa_gunraid:deletePeds') -- Server Event that gets called when the player goes up the elevator and spawns peds
AddEventHandler('usa_gunraid:deletePeds', function(val)
	-- print("deletiong peds")
	for k,v in pairs(pedNets) do
	    local ent = NetworkGetEntityFromNetworkId(v)
	    -- print(ent)
	    DeleteEntity(ent)
	end
	TriggerClientEvent('usa_gunraid:deletePeds', -1)
	pedNets = {}
	pedsSpawned = false
	playersInRaid = {}
end)