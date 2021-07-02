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

				--ADD LOCKBOX TO SOURCE INVENTORY

			end

		end)

	else

		TriggerClientEvent('usa_gunraid:notify', source, "Already searching!")

	end

end)