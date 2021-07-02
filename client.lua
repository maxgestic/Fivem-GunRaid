local entry_coors = vector3(5054.20, -5772.90, -3.80)
local entry_tp = vector4(4991.13, -5733.55, 14.84, 149.74)

local searching = false
local secondsRemaining = 0
local current_crate = ""

local unlocking = false

function Draw3DText(x, y, z, scl_factor, text, font)
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

LoadAnim = function(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Citizen.Wait(1)
  end
end

function alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

function notify(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true,false)
end

RegisterNetEvent('usa_gunraid:notify')
AddEventHandler('usa_gunraid:notify', function(msg)
    notify(msg)
end)

RegisterNetEvent('usa_gunraid:currentlysearching')
AddEventHandler('usa_gunraid:currentlysearching', function(search)
    current_crate = search
    searching = true
    secondsRemaining = Config.TimeToSearch
    LoadAnim("random@train_tracks")
    TaskPlayAnim(GetPlayerPed(-1), "random@train_tracks", "idle_e", 2.0, 2.0, -1, 1, 0, false, false, false)
end)

RegisterNetEvent('usa_gunraid:toofarclient')
AddEventHandler('usa_gunraid:toofarclient', function()
    searching = false
    unlocking = false
    notify("You moved too far away!")
    current_crate = ""
    secondsRemaining = 0
    ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('usa_gunraid:searchcomplete')
AddEventHandler('usa_gunraid:searchcomplete', function()
    ClearPedTasks(GetPlayerPed(-1))
    searching = false
    notify("You found a lockbox of some kind!")
    current_crate = ""
    secondsRemaining = 0
end)

RegisterNetEvent('usa_gunraid:unlocking')
AddEventHandler('usa_gunraid:unlocking', function()
    notify("You use the wrench to try and crack open the lockbox!")
    unlocking = true
    secondsRemaining = Config.TimeToUnlockBox
    LoadAnim("mini@repair")
    TaskPlayAnim(GetPlayerPed(-1), "mini@repair", "fixing_a_ped", 2.0, 2.0, -1, 1, 0, false, false, false)
end)

RegisterNetEvent('usa_gunraid:unlockcomplete')
AddEventHandler('usa_gunraid:unlockcomplete', function()
    ClearPedTasks(GetPlayerPed(-1))
    unlocking = false
    notify("You have cracked open the lockbox!")
    secondsRemaining = 0
end)

RegisterNetEvent('usa_gunraid:unlockfailed')
AddEventHandler('usa_gunraid:unlockfailed', function()
    ClearPedTasks(GetPlayerPed(-1))
    unlocking = false
    notify("Your wrench broke and you failed to unlock the box!")
    secondsRemaining = 0
end)

Citizen.CreateThread(function()
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

Citizen.CreateThread(function ()
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

        for i,v in pairs(crates) do

            local crate_pos = v.position

            if Vdist2(GetEntityCoords(PlayerPedId(), false), crate_pos.x, crate_pos.y, crate_pos.z) < 10 then

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