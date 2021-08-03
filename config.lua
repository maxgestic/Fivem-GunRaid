Config = {}
Config.TimeToSearch = 30 -- How many seconds it takes to search a crate
Config.TimeToDownload = 40 -- How many seconds it takes to download the access codes from the limo
Config.trackertime = 600 -- How many seconds the hacker will be tracked by a Police Officer that inspected the hacked tower
Config.LockBoxLocation = vector3(-2186.59, 4250.07, 48.94) -- Location where players can unlock the lockbox
Config.TimeToUnlockBox = 60 -- How many seconds it takes to unlock a lockbox
Config.WrenchBreakChance = 10  -- Percentage chance that a wrench will break during the unlock
Config.ElevatorPanelLocation = vector3(5012.34, -5745.27, 16.00) -- Location of elevator panel
Config.ElevatorLocation = vector4(5012.73, -5748.52, 28.94, 149.95) -- Location of elevator
Config.CrateCooldown = 7200 -- How many seconds a crate will be on cooldown for before being able to be searched again
Config.TowerCooldown = 7200 -- How many seconds the cell tower will be on cooldown for before being able to be hacked again
Config.TowerLocation = vector3(750.96, 1273.89, 360.30) -- Location of the cell tower hacking spot
Config.LastHacked = 0 -- Last hacked just leave at 0
Config.FailsToLockdown = 3 -- How many failed hacking attempts will put the cell tower into lockdown and therefore cooldown
Config.CodeLength = 14 -- Length of code obtained from drownloading from the limo
Config.DialogWait = 3000 -- Time in miliseconds between each message from intro NPC
Config.PedLocation = vector4(849.5, -2133.55, 29.30, 357.68) -- Location of intro NPC
Config.LimoSpawnCoords = {vector4(1361.31, 1171.18, 112.21, 180), vector4(1695.94, 3280.73, 40.27, 216.11), vector4(-732.66, 5813.98, 17.40, 205.45)} -- Array of possible spawn locations for the limo
Config.LimoDestination = vector3(-1082.01, -2869.85, 13.11) -- Location of destination where limo will drive to

crates = { -- Array of Crates in mansion
	["crate_1"] = {
		position = { ['x'] = 5013.87, ['y'] = -5752.32, ['z'] = 15.48 },
		progress_position = { ['x'] = 5014.57, ['y'] = -5752.73, ['z'] = 15.73 },
		lastsearched = 0,
		name="crate_1",
		searching = false
	},
	["crate_2"] = {
		position = { ['x'] = 5012.38, ['y'] = -5754.76, ['z'] = 15.48 },
		progress_position = { ['x'] = 5013.21, ['y'] = -5755.27, ['z'] = 15.73 },
		lastsearched = 0,
		name="crate_2",
		searching = false
	},
	["crate_3"] = {
		position = { ['x'] = 5016.73, ['y'] = -5745.67, ['z'] = 15.48 },
		progress_position = { ['x'] = 5017.08, ['y'] = -5745.07, ['z'] = 15.73 },
		lastsearched = 0,
		name="crate_3",
		searching = false
	},
	["crate_4"] = {
		position = { ['x'] = 5009.06, ['y'] = -5745.75, ['z'] = 15.48 },
		progress_position = { ['x'] = 5008.48, ['y'] = -5745.38, ['z'] = 15.73 },
		lastsearched = 0,
		name="crate_4",
		searching = false
	},
	["crate_5"] = {
		position = { ['x'] = 5011.44, ['y'] = -5742.77, ['z'] = 15.48 },
		progress_position = { ['x'] = 5011.32, ['y'] = -5741.78, ['z'] = 15.73 },
		lastsearched = 0,
		name="crate_5",
		searching = false
	},
	["crate_6"] = {
		position = { ['x'] = 5006.09, ['y'] = -5750.99, ['z'] = 15.48 },
		progress_position = { ['x'] = 5005.37, ['y'] = -5750.85, ['z'] = 15.73 },
		lastsearched = 0,
		name="crate_6",
		searching = false
	},
}