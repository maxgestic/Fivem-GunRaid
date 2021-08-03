local entry_coors = vector3(5054.20, -5772.90, -3.80)
local entry_tp = vector4(4991.13, -5733.55, 14.84, 149.74)

local searching = false
local unlocking = false
local secondsRemaining = 0
local current_crate = ""

local targetsEntity = {}
local tracker_active = false
local tracker_shown = false
local limoMoving = false

local tower_hack_count = 0
local gate_hack_count = 0

local hacking = false
local hack_shown = false

local hackerblip
local hackerTracked = false
local hacktracktimer = 0

local d1, v1
local gate_open = false

local currentBlips = {}

local isPolice = false -- PLACEHOLDER FOR BEING ON DUTY AS POLICE


function spawn_gate() -- function to spawn gate

    gate_open = false

    local gate_prop = GetHashKey("h4_mph4_manb_chem_grill_ipl_group")
    gate = CreateObject(gate_prop, 5043.00, -5814.24, -12.15, false, true, true)
    SetEntityHeading(gate, 35.0)
    SetEntityAsMissionEntity(gate, true, true)

    local gate2_prop = GetHashKey("prop_fnclink_03gate2")
    gate2 = CreateObject(gate2_prop, 5040.43, -5815.97, -12.30, false, true, true)
    SetEntityHeading(gate2, 35.0)
    SetEntityAsMissionEntity(gate2, true, true)
    FreezeEntityPosition(gate2, true)

    return

end

function Draw3DText(x, y, z, scl_factor, text, font) -- Function to display 3D text
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght) -- Function to get keyboard input

    -- TextEntry        --> The Text above the typing field in the black square
    -- ExampleText      --> An Example Text, what it should say in the typing field
    -- MaxStringLenght  --> Maximum String Lenght

    AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
    blockinput = true --Blocks new input while typing if **blockinput** is used

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() --Gets the result of the typing
        Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
        blockinput = false --This unblocks new Input when typing is done
        return result --Returns the result
    else
        Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
        blockinput = false --This unblocks new Input when typing is done
        return nil --Returns nil if the typing got aborted
    end
end

LoadAnim = function(dict) -- Function to load animation dict
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Citizen.Wait(1)
  end
end

function alert(msg) -- Function to send alert to player
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

function notify(msg) -- Function to send notification to player
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true,false)
end

function showHelpText(msg) -- Function to send help text to player
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    EndTextCommandDisplayHelp(0,0,0,-1)
end

function tower_result(success, timeremaining, finish) -- Tower Hack Result 

    tower_hack_count = tower_hack_count + 1

    if success then
        
        print('Success with '..timeremaining..'s remaining.')
    end

    if finish and success then

        TriggerEvent('mhacking:hide')

        hacking = false
        hack_shown = false

        start_tracking()

        return

    elseif tower_hack_count == 4 and not success then

        print("Fail")

        TriggerServerEvent('usa_gunraid:hackfail')

        return

    end

end

function gate_result_new(success, timeremaining, finish) -- Hack Gate Result 
    if success then
        gate_hack_count = gate_hack_count + 1
        print('Success with '..timeremaining..'s remaining. Number of successful hacks: ' .. gate_hack_count)
    else
        
        print('Failure')
        -- TriggerServerEvent('usa_gunraid:hackfail')
    end

    if finish and success then

        TriggerEvent('mhacking:hide')

        hacking = false
        hack_shown = false

        local password = KeyboardInput("Enter Verification Access Code:", "", Config.CodeLength)

        TriggerServerEvent("usa_gunraid:verifycode", password)

    end

    return

end

function start_tracking() -- Fuction to start tracking 

    DeletePed(d1)
    DeleteVehicle(v1)

    local vhash = GetHashKey('stretch')
    local dhash = GetHashKey('g_m_m_casrn_01')
    RequestModel(vhash)
    while not HasModelLoaded(vhash) do
        Citizen.Wait(1)
    end

    local count = 0
    for _ in pairs(Config.LimoSpawnCoords) do count = count + 1 end

    random = math.random(count)

    v1 = CreateVehicle(vhash, Config.LimoSpawnCoords[random], true, false)
    -- v1 = CreateVehicle(vhash, -980.06, -2818.48, 13.65, 149.72, true, false) --DEBUG ONLY
    SetVehicleOnGroundProperly(v1)

    RequestModel(dhash)
    while not HasModelLoaded(dhash) do
        Citizen.Wait(1)
    end

    d1 = CreatePedInsideVehicle(v1, 4, dhash, -1, true, false)

    TaskVehicleDriveToCoordLongrange(d1, v1, Config.LimoDestination, 26.0, 447, 0)
    SetPedKeepTask(d1, true)
    SetPedDiesInVehicle(d1, false)
    SetPedDiesInSinkingVehicle(d1, false)
    SetPedDiesWhenInjured(d1, false)

    limoMoving = true

    table.insert(targetsEntity,v1)
    TriggerEvent('mtracker:settargets', targetsEntity)
    notify("Starting Tracker hide and show with HOME")
    TriggerEvent('mtracker:start')

    local idval = (GetPlayerPed(-1))

    TriggerServerEvent("usa_gunraid:hackcomplete")

    tracker_active = true
    tracker_shown = true

    secondsRemaining = Config.TimeToDownload 

end

function RemoveBlips()
    for i = #currentBlips, 1, -1 do
        local b = currentBlips[i]
        if b ~= 0 then
            RemoveBlip(b)
            table.remove(currentBlips, i)
        end
    end
end

function RefreshBlips(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 459)
    SetBlipFlashes(blip, true)
    SetBlipFlashTimer(blip, 5000)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Hacked Signal")
    EndTextCommandSetBlipName(blip)
    table.insert(currentBlips, blip)
end


RegisterNetEvent('usa_gunraid:911placeholder') -- PLACEHOLDER to notify players that have isPolice == true of ongoing hacks and unlocking
AddEventHandler('usa_gunraid:911placeholder', function(msg)
    
    if isPolice then

        notify(msg)

    end

end)

RegisterNetEvent('usa_gunraid:notify') -- Event to send notification to player
AddEventHandler('usa_gunraid:notify', function(msg)

    notify(msg)

end)

RegisterNetEvent('usa_gunraid:alert') -- Event to send alert to player
AddEventHandler('usa_gunraid:alert', function(msg)
    
    alert(msg)

end)

RegisterNetEvent('usa_gunraid:printCodes') -- DEBUG Event that takes valid codes sent by the server and prints in console
AddEventHandler('usa_gunraid:printCodes', function(valid_codes, id)

    local codes = ""

    for i,v in pairs (valid_codes) do

        codes = codes .. v .. " "

    end

    print("Hey ".. id .. " Codes:".. codes)

end)

RegisterNetEvent('usa_gunraid:PedInfo') -- Event when player accepts the offer from NPC and money has been deducted from their cash
AddEventHandler('usa_gunraid:PedInfo', function()

    notify("Clever investment mate! Right listen here is a hacking tablet ok?")
    Citizen.Wait(Config.DialogWait)
    notify("It is preloaded with all the tools you need! A hacking and tracking combo of sorts I made!")
    Citizen.Wait(Config.DialogWait)
    notify("Now on the Cayo Perico island just South East of the Los Santos Port there is a massive mansion!")
    Citizen.Wait(Config.DialogWait)
    notify("Now a little birdy told me that in the basement there are creates full of weapons and ammo!")
    Citizen.Wait(Config.DialogWait)
    notify("Got hold of some old maintanance maps from the 50's and it looks like there is a way in!")
    Citizen.Wait(Config.DialogWait)
    notify("There is an underwater tunnel leading into the basement!")
    Citizen.Wait(Config.DialogWait)
    notify("Now this is where the tablet comes in, the tunnel is secured with a gate. Bummer, I know.")
    Citizen.Wait(Config.DialogWait)
    notify("But there is a small electrical systems box on the south side of the compound!")
    Citizen.Wait(Config.DialogWait)
    notify("But you will need an access code! Lucky for you I know where to get one...")
    Citizen.Wait(Config.DialogWait)
    notify("The driver of the old geezer that owns the massive place has the company access codes on his phone!")
    Citizen.Wait(Config.DialogWait)
    notify("Now you'll have to locate him by hacking the cell tower near the vinewood sign.")
    Citizen.Wait(Config.DialogWait)
    notify("Should be a piece of cake with the tablet.")
    Citizen.Wait(Config.DialogWait)
    notify("However watch out for cops, and don't fail the hack too much or the system will lock down.")
    Citizen.Wait(Config.DialogWait)
    notify("After that just find the vehicle with the tracking app on the tablet and stay close to it!")
    Citizen.Wait(Config.DialogWait)
    notify("With the codes you should be able to unlock the underwater gate from the box.")
    Citizen.Wait(Config.DialogWait)
    notify("Once you have the code, the tablet will add a marker to your GPS for the box.")
    Citizen.Wait(Config.DialogWait)
    notify("Now off you pop, enjoy the riches if you make it out alive from all that!")
    Citizen.Wait(Config.DialogWait)  

end)

RegisterNetEvent('usa_gunraid:NoMoneyPed') -- Event when player accepts the offer from NPC but do not have enough money in their cash
AddEventHandler('usa_gunraid:NoMoneyPed', function(locked)

    notify("Oh don't have the money but want stuff for free from me phhhhf get lost and come back with the cash!")    
    
end)

RegisterNetEvent('usa_gunraid:currentlysearching') -- Event when player is searching the crates
AddEventHandler('usa_gunraid:currentlysearching', function(search)
    current_crate = search
    searching = true
    secondsRemaining = Config.TimeToSearch
    LoadAnim("random@train_tracks")
    TaskPlayAnim(GetPlayerPed(-1), "random@train_tracks", "idle_e", 2.0, 2.0, -1, 1, 0, false, false, false)

end)

RegisterNetEvent('usa_gunraid:searchcomplete') -- Event when player finished search of a crate
AddEventHandler('usa_gunraid:searchcomplete', function()
    ClearPedTasks(GetPlayerPed(-1))
    searching = false
    notify("You found a lockbox of some kind!")
    current_crate = ""
    secondsRemaining = 0

end)

RegisterNetEvent('usa_gunraid:unlocking') -- Event when player is unlocking a lockbox
AddEventHandler('usa_gunraid:unlocking', function()
    notify("You use the wrench to try and crack open the lockbox!")
    unlocking = true
    secondsRemaining = Config.TimeToUnlockBox
    LoadAnim("mini@repair")
    TaskPlayAnim(GetPlayerPed(-1), "mini@repair", "fixing_a_ped", 2.0, 2.0, -1, 1, 0, false, false, false)

end)

RegisterNetEvent('usa_gunraid:unlockfailed') -- Event when players wrench breaks while unlocking lockbox
AddEventHandler('usa_gunraid:unlockfailed', function()
    ClearPedTasks(GetPlayerPed(-1))
    unlocking = false
    notify("Your wrench broke and you failed to unlock the box!")
    secondsRemaining = 0

end)

RegisterNetEvent('usa_gunraid:unlockcomplete') -- Event when player finished search of a crate
AddEventHandler('usa_gunraid:unlockcomplete', function()
    ClearPedTasks(GetPlayerPed(-1))
    unlocking = false
    notify("You have cracked open the lockbox!")
    secondsRemaining = 0

end)

RegisterNetEvent('usa_gunraid:toofarclient') -- Event if player moves to far away from point while searching or unlocking
AddEventHandler('usa_gunraid:toofarclient', function()
    searching = false
    unlocking = false
    notify("You moved too far away!")
    current_crate = ""
    secondsRemaining = 0
    ClearPedTasks(GetPlayerPed(-1))

end)

RegisterNetEvent('usa_gunraid:hackattemptReturn') -- Event when player starts hacking the tower, checks if tower is on lockdown
AddEventHandler('usa_gunraid:hackattemptReturn', function(cooldown)


    if cooldown then

        notify("Tower is in lockdown mode due to recent hack!")

    else

        hacking = true
        hack_shown = true

        TriggerEvent("mhacking:show")
        --TriggerEvent("mhacking:start",7,35,tower_result)
        TriggerEvent("mhacking:seqstart",{6,5,4,3},90,tower_result)
        TriggerServerEvent("usa_gunraid:hackstarted")

    end

end)

RegisterNetEvent('usa_gunraid:hackattemptAlreadyHacking') -- Event if player tries to hack tower while it is currently already being hacked
AddEventHandler('usa_gunraid:hackattemptAlreadyHacking', function(cooldown)

        alert("Tower is already being hacked!")

end)

RegisterNetEvent('usa_gunraid:hackfailReturn') -- Event when player fails a hack, checks if tower is now in lockdown mode and if so lets player know
AddEventHandler('usa_gunraid:hackfailReturn', function(locked)

    if locked then

        alert("The tower has gone into lockdown mode due to 5 failed hacking attempts!")

    end
    
end)

RegisterNetEvent('usa_gunraid:inspectReturn') -- Event when police officer inspects cell tower
AddEventHandler('usa_gunraid:inspectReturn', function(isHacked, cooldown, time)

    time = tonumber(string.format("%." .. 0 .. "f", time))

    if cooldown then
    
        if isHacked then

            notify("Tower was hacked " .. time .. " minutes ago and a signal of the hacker has been found! ")

            hackerTracked = true
            hacktracktimer = Config.trackertime

            TriggerServerEvent('usa_gunraid:activetracking')

        else

            notify("Tower was hacked " .. time .. " minutes ago but no signal could be found!")

        end

    else

        notify("Tower has not been hacked recently!")

    end

end)

RegisterNetEvent("usa_gunraid:updatetracker")
AddEventHandler("usa_gunraid:updatetracker", function(coords)
    if hackerTracked then
        RemoveBlips()
        RefreshBlips(coords)
    end
end)

RegisterNetEvent('usa_gunraid:hackgateReturn') -- Event when player starts hacking the gate controll, checks if is on lockdown
AddEventHandler('usa_gunraid:hackgateReturn', function(cooldown)


    if cooldown then

        notify("Gate controll system locked down due to recent hack!")

    else



        hacking = true
        hack_shown = true

        TriggerEvent("mhacking:show")
        -- TriggerEvent("mhacking:start",7,30,gate_result)
        TriggerEvent("mhacking:seqstart",{7,6,5,4},60,gate_result_new)
        -- TriggerServerEvent("usa_gunraid:hackstarted")


    end

end)

RegisterNetEvent('usa_gunraid:verifycodeReturn') -- Event that opens gate if the entered code is valid
AddEventHandler('usa_gunraid:verifycodeReturn', function(valid)

    time = tonumber(string.format("%." .. 0 .. "f", (Config.GateUnlockTime / 60)))

    if valid then

        alert("Access Code Accepted: Gate Opened for ".. time .." minutes!")
        TriggerServerEvent("usa_gunraid:openGate")

    else

        alert("Invalid Access Code!")

    end

end)

RegisterNetEvent('usa_gunraid:RemoveGate') -- Event to remove gate
AddEventHandler('usa_gunraid:RemoveGate', function()

    DeleteObject(gate)
    DeleteObject(gate2)
    gate_open = true

end)

RegisterNetEvent('usa_gunraid:SpawnGate') -- Event to spawn gate
AddEventHandler('usa_gunraid:SpawnGate', function()

    spawn_gate()

end)

-- DEBUG COMMANDS --
RegisterCommand("newcode", function (source, args)
    
    local letters = "abcdefghijklmnopqrstuvwxyz"
    local numbers = "0123456789"

    local characterSet = letters .. numbers

    local codeLength = Config.CodeLength 
    local code = ""

    for i = 1, codeLength do 

        local rand = math.random(#characterSet)
        code = code .. string.sub(characterSet, rand, rand)

    end

    notify("Download Complete, Access Code: ".. code)

    TriggerServerEvent('usa_gunraid:downloadcomplete', code)

end)

RegisterCommand("codes", function (source, args)
    
    TriggerServerEvent('usa_gunraid:getCodes')

end)

RegisterCommand("spawntrack", function (source, args)
    
    start_tracking()

end)

RegisterCommand("tplimo", function (source, args)

    local coors = GetEntityCoords(d1, false)
    
    SetEntityCoords(PlayerPedId(), coors.x, coors.y, coors.z, true, true, true, false)

end)

RegisterCommand("deletelimo", function(source, args)
    DeletePed(d1)
    DeleteVehicle(v1)

end)

RegisterCommand("togglep", function (source, args)

    if isPolice then

        isPolice = false
        notify("You no longer are police")

    else

        isPolice = true
        notify("You are now police")

    end

end)

RegisterCommand("removegate", function (source, args)

    TriggerServerEvent("usa_gunraid:openGate")

end)
-- END OF DEBUG COMMANDS --


Citizen.CreateThread(function() --innit thread to spawn props

    local box_blip = AddBlipForCoord(4968.76, -5796.05, 19.9)
    SetBlipSprite(box_blip, 186)
    SetBlipColour(box_blip, 1)
    SetBlipDisplay(box_blip, 0)
    SetBlipScale(box_blip, 0.9)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Electrical Box")
    EndTextCommandSetBlipName(box_blip)

    local box_prop = GetHashKey("prop_elecbox_04a")
    box = CreateObject(box_prop, 4968.76, -5796.05, 19.9, false, true, true)
    SetEntityHeading(box, 336.06)
    SetEntityAsMissionEntity(box, true, true)

    spawn_gate()

end)

Citizen.CreateThread(function() -- NPC Conversation 

    ped = GetHashKey("mp_m_weapexp_01")
    RequestModel(ped)
    while not HasModelLoaded(ped) do

        Citizen.Wait(1)

    end
    hintped = CreatePed(4, ped, Config.PedLocation, false, true)
    SetBlockingOfNonTemporaryEvents(hintped, true)
    SetPedDiesWhenInjured(hintped, false)
    SetPedCanPlayAmbientAnims(hintped, true)
    SetPedCanRagdollFromPlayerImpact(hintped, false)
    SetEntityInvincible(hintped, true)
    FreezeEntityPosition(hintped, true)
    TaskPlayAnim(hintped, "amb@world_human_leaning@male@wall@back@foot_up@idle_a", "idle_a", 8.0, 0.0, -1, 1, 0, 0, 0, 0)

    while true do

        Citizen.Wait(0)

        if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.PedLocation) < 30 then

            Draw3DText(Config.PedLocation.x,Config.PedLocation.y, Config.PedLocation.z+1.95, 0.3,  "Speak (E)", 0)

            if IsControlJustReleased(1, 38) then

                if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.PedLocation) < 20 then

                    notify("Hey there mate!")
                    Citizen.Wait(Config.DialogWait)
                    notify("You know that ammunation over there is ripping you off yea?")
                    Citizen.Wait(Config.DialogWait)
                    notify("Lemme tell you this, there is a place where you can fill all your desires for firearms for free!")
                    Citizen.Wait(Config.DialogWait)
                    notify("And I have all the tools and information you need!")
                    Citizen.Wait(Config.DialogWait)
                    notify("For as little as 10K ill give it all to you, what do you say?")
                    alert("Press Y to accept the man's offier or N to decline it.")

                    local input = false

                    while not input do

                        Citizen.Wait(0)

                        if IsControlJustReleased(1, 246) then -- Y key

                            input = true
                            TriggerServerEvent("usa_gunraid:BuyFromPed")

                        end 
                        if IsControlJustReleased(1, 249) then -- N Key

                            notify("Alright well keep spending money then and dont take my help, get lost until ya've grown some balls!")
                            input = true

                        end

                    end

                else

                    notify("Come closer!")

                end

            end

        end

    end 

end)

Citizen.CreateThread(function() -- Hack & Inspect Tower 
    while true do
        Citizen.Wait(0)

        if hacking then

            if (Vdist2(GetEntityCoords(PlayerPedId(), false), 750.52, 1273.90, 360.30) > 4) then

                alert("You moved to far away!")

                TriggerEvent("mhacking:stop")

                hacking = false
                hack_shown = false

            end

        end

        if (Vdist2(GetEntityCoords(PlayerPedId(), false), Config.TowerLocation) < 50) then

            if not hacking and not tracker_active then

                Draw3DText(Config.TowerLocation.x,Config.TowerLocation.y, Config.TowerLocation.z, 0.8,  "Hack Mobile Tower (K)", 0)

                if IsControlJustReleased(1, 311) then

                    -- PLACEHOLDER CHECK IF PLAYER HAS HACKING TABLET

                    if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.TowerLocation) < 10 then

                        TriggerServerEvent('usa_gunraid:hackattempt')
                        

                    else

                        notify("Come closer!")

                    end

                    -- PLACEHOLDER IF PLAYER DOES NOT HAVE HACKING TABLET 
                    -- notify ("You don't have anything to hack with.")


                end

            end

            if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.TowerLocation) < 30 then

                if isPolice then

                    Draw3DText(Config.TowerLocation.x,Config.TowerLocation.y, Config.TowerLocation.z+0.2, 0.6,  "Inspect Mobile Tower Panel (E)", 0)

                    if IsControlJustReleased(1, 38) then

                        if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.TowerLocation) < 10 then

                            TriggerServerEvent('usa_gunraid:inspectpanel')                        

                        else

                            notify("Come closer!")

                        end

                    end

                end

            end

        end

    end 

end)

Citizen.CreateThread(function() -- Limo Tracking & Downloading Thread 

    while true do

        Citizen.Wait(0)

        if IsControlJustReleased(1,213) then -- home key

            if tracker_active then

                if tracker_shown then
                    notify("Hiding Tracker")
                    TriggerEvent('mtracker:stop')
                    tracker_shown = false
                else
                    notify("Showing Tracker")
                    TriggerEvent('mtracker:start')
                    tracker_shown = true
                end

            end

        end

        if tracker_active and (secondsRemaining > 0) then

            while Vdist2(GetEntityCoords(PlayerPedId(), false), GetEntityCoords(d1, false)) < 450 do

                if  not IsPedInVehicle(d1, v1, true) or not limoMoving then

                    break

                end

                showHelpText("Currently downloading stay close to the target! ".. secondsRemaining .. " seconds remaining!")
                Citizen.Wait(1000)
                if(secondsRemaining > 0)then
                    secondsRemaining = secondsRemaining - 1
                end

                if (secondsRemaining == 0) then -- downloading complete

                    alert("Donwload Complete!")


                    TriggerEvent('mtracker:stop')
                    tracker_shown = false
                    tracker_active = false


                    local letters = "abcdefghijklmnopqrstuvwxyz"
                    local numbers = "0123456789"

                    local characterSet = letters .. numbers

                    local codeLength = Config.CodeLength 
                    local code = ""

                    for i = 1, codeLength do 

                        local rand = math.random(#characterSet)
                        code = code .. string.sub(characterSet, rand, rand)

                    end

                    notify("Download Complete, Access Code: ".. code)

                    TriggerServerEvent('usa_gunraid:downloadcomplete', code)

                    notify("Location of Electrical Box added to GPS")

                    SetBlipDisplay(box_blip, 2)

                    break

                end

            end

            if not IsPedInVehicle(d1, v1, true) then

                    alert("The phone of the target has been destroyed!")



                    Citizen.Wait(1000)

                    TriggerEvent('mtracker:stop')
                    tracker_shown = false
                    tracker_active = false

            end

        end

    end

end)

Citizen.CreateThread(function() -- Thread to check if limo arrived 
    while true do

        Citizen.Wait(0)

        while limoMoving do

            Citizen.Wait(0)

            if Vdist2(GetEntityCoords(d1, false), -1082.01, -2869.85, 13.11) < 100 then

                limoMoving = false

                alert("The tracker signal has been lost!")

                DeletePed(d1)
                DeleteVehicle(v1)

                TriggerServerEvent("usa_gunraid:limoarrived")

                TriggerEvent('mtracker:stop')
                tracker_shown = false
                tracker_active = false



            end

        end

    end 

end)

Citizen.CreateThread(function() -- Thread to time how long hacker singal gets shown to PD
    
    while true do

        Citizen.Wait(0)

        while hackerTracked do

            Citizen.Wait(1000)

            if hacktracktimer > 0 then

                hacktracktimer = hacktracktimer - 1

            else

                RemoveBlip(hackerblip)
                alert("The Signal of the hacker has been lost!")
                hackerTracked = false

            end

        end

    end

end)

Citizen.CreateThread(function() -- Hack Gate 
    while true do
        Citizen.Wait(0)

        if hacking then

            if (Vdist2(GetEntityCoords(PlayerPedId(), false), 4968.55, -5796.31, 20.9) > 4) then

                alert("You moved to far away!")

                TriggerEvent("mhacking:stop")

                hacking = false
                hack_shown = false

            end

        end

        if (Vdist2(GetEntityCoords(PlayerPedId(), false), 4968.55, -5796.31, 20.9) < 50) then

            if not hacking then

                Draw3DText(4968.65, -5796.31, 21.2, 0.5,  "Hack Underwater Gate (K)", 0)

                if IsControlJustReleased(1, 311) then

                    if gate_open then

                        alert("The Gate is already open!")

                    else

                        -- PLACEHOLDER CHECK IF PLAYER HAS HACKING TABLET

                        if Vdist2(GetEntityCoords(PlayerPedId(), false), 4968.55, -5796.31, 20.9) < 10 then

                            local password = KeyboardInput("Enter Verification Access Code:", "", Config.CodeLength)

                            TriggerServerEvent("usa_gunraid:verifycode", password)

                            --TriggerServerEvent('usa_gunraid:hackgate')
                            

                        else

                            notify("Come closer!")

                        end

                        -- PLACEHOLDER IF PLAYER DOES NOT HAVE HACKING TABLET 
                        -- notify ("You don't have anything to hack with.")

                    end


                end

            end
        end

    end

end)

Citizen.CreateThread(function() -- Mansion Entrance, Elevator Hack and Crate Search
    while true do

        Citizen.Wait(0)

        if Vdist2(GetEntityCoords(PlayerPedId(), false), entry_coors) < 200 then

            Draw3DText(5054.20, -5772.90, -3.80, 0.8,  "Enter Mansion Basement (E)", 0)

            if IsControlJustReleased(1, 38) then

                if Vdist2(GetEntityCoords(PlayerPedId(), false), entry_coors) < 20 then

                --teleport to mansion

                    alert("Entering Mansion Basement!")

                    DoScreenFadeOut(1000)

                    Citizen.Wait(1000)

                    SetEntityCoords(PlayerPedId(), entry_tp.x, entry_tp.y, entry_tp.z, true, true, true, false)
                    SetEntityHeading(PlayerPedId(), entry_tp.w)

                    Citizen.Wait(1000)

                    DoScreenFadeIn(1000)

                else

                    notify("You are too far from the entry point!")

                end



            end

        end

        if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.ElevatorPanelLocation) < 8 then

            Draw3DText(Config.ElevatorPanelLocation.x, Config.ElevatorPanelLocation.y, Config.ElevatorPanelLocation.z, 0.2,  "Hack Elevator (E)", 0)

            if IsControlJustReleased(1, 38) then

                if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.ElevatorPanelLocation) < 2 then

                -- start elevator hack

                    DoScreenFadeOut(1000)

                    Citizen.Wait(1000)

                    SetEntityCoords(PlayerPedId(), Config.ElevatorLocation.x, Config.ElevatorLocation.y, Config.ElevatorLocation.z, true, true, true, false)
                    SetEntityHeading(PlayerPedId(), Config.ElevatorLocation.w)

                    Citizen.Wait(1000)

                    DoScreenFadeIn(1000)

                else

                    notify("You are too far from the panel!")

                end



            end

        end

        for i,v in pairs(crates) do

            local crate_pos = v.position

            if Vdist2(GetEntityCoords(PlayerPedId(), false), crate_pos.x, crate_pos.y, crate_pos.z) < 3 then

            if not searching then

                Draw3DText(crate_pos.x, crate_pos.y, crate_pos.z, 0.8,  "Search Crates (E)", 0)

                if IsControlJustReleased(1, 38) then

                    if Vdist2(GetEntityCoords(PlayerPedId(), false), crate_pos.x, crate_pos.y, crate_pos.z) < 2 then

                        TriggerServerEvent('usa_gunraid:search', i)

                    else

                        notify("You are too far from the crate!")

                    end

                    

                end

            end

        end


        end

        
        if searching then

            local progress_pos = crates[current_crate].progress_position
            local crate_pos = crates[current_crate].position

            Draw3DText(progress_pos.x, progress_pos.y, progress_pos.z, 0.5, "Searching for goods... " .. secondsRemaining .. " seconds remaining")

            if (Vdist2(GetEntityCoords(PlayerPedId(), false), crate_pos.x, crate_pos.y, crate_pos.z) > 4) then

                TriggerServerEvent('usa_gunraid:toofar')

            end

        end

        if unlocking then

            Draw3DText(Config.LockBoxLocation.x, Config.LockBoxLocation.y, Config.LockBoxLocation.z, 0.5, "Unlocking Box... " .. secondsRemaining .. " seconds remaining")

            if (Vdist2(GetEntityCoords(PlayerPedId(), false), Config.LockBoxLocation.x, Config.LockBoxLocation.y, Config.LockBoxLocation.z) > 4) then

                TriggerServerEvent('usa_gunraid:lockboxtoofar')

            end

        end

        if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.LockBoxLocation) < 30 then

            if not unlocking then

                Draw3DText(Config.LockBoxLocation.x, Config.LockBoxLocation.y, Config.LockBoxLocation.z, 0.8,  "Crack Open Lockbox (E)", 0)

                if IsControlJustReleased(1, 38) then

                    if Vdist2(GetEntityCoords(PlayerPedId(), false), Config.LockBoxLocation) < 10 then

                        TriggerServerEvent('usa_gunraid:unlockbox')

                    else

                        notify("Come closer!")

                    end

                end

            end

        end

    end

end)

Citizen.CreateThread(function() -- Search and Break Box Timers
    while true do
        Citizen.Wait(0)
        if searching then
            Citizen.Wait(1000)
            if(secondsRemaining > 0)then
                secondsRemaining = secondsRemaining - 1
            end
        end
        if unlocking then
            Citizen.Wait(1000)
            if(secondsRemaining > 0)then
                secondsRemaining = secondsRemaining - 1
            end
        end
    end

end)