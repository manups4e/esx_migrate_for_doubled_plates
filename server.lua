-- these are all internal variables, there's nothing interesting here
ESX = nil

local NumberCharset = {}
local Charset = {}

local RegisteredPlateTable = {}
local currentExecuting = 0

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('migrate', function(source, args, rawCommand)
	migrateVehicles()
end, true)

function migrateVehicles()
	MySQL.Async.fetchAll('SELECT * FROM user_parkings2', {}, function(result)
		for i=1, #result, 1 do
			Citizen.Wait(0)
			local vehicleProps  = json.decode(result[i].vehicle)
			local vehicle       = json.decode(result[i].vehicle) -- old vehicle
			vehicleProps.plate  = GeneratePlate()                -- generate plate

			migrateVehicle(vehicleProps, vehicle)
		end

		print('\n\n\n')
		print('esx_migrate: done!')
		print('\n\n\n')
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)
		if currentExecuting > (Config.MaxMigrates / 2) then
			currentExecuting = currentExecuting - 1
		end
	end
end)

function migrateVehicle(vehicleProps, vehicleOld)
	while currentExecuting > Config.MaxMigrates do
		Citizen.Wait(0)
	end

	io.write('esx_migrate: migrating . . . ')
	currentExecuting = currentExecuting + 1

	MySQL.Async.execute('UPDATE `user_parkings2` SET `vehicle` = @vehicleNew, `plate` = @plateNew WHERE `vehicle` LIKE "%' .. vehicleOld.plate .. '%"',
	{
		['@vehicleNew'] = json.encode(vehicleProps),
		['@plateNew']   = vehicleProps.plate,
		['@plateOld']   = vehicleOld.plate
	}, function(rowsChanged)
		io.write('OK! (' .. vehicleOld.plate .. ' > ' .. vehicleProps.plate .. ')\n')
		currentExecuting = currentExecuting - 1
	end)

end

-- customize the plate generator here
function GeneratePlate()
	local generatedPlate

	while true do

		if Config.PlateUseDash then
			generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. '-' .. GetRandomNumber(Config.PlateNumbers))
		else
			generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. GetRandomNumber(Config.PlateNumbers))
		end

		if IsPlateTaken(generatedPlate) then
			Citizen.Wait(2) -- don't break the loop til we got an plate that isn't taken
		else
			break
		end
	end

	RegisteredPlateTable[generatedPlate] = true
	return generatedPlate
end

function IsPlateTaken(plate)
	return RegisteredPlateTable[plate]
end

function GetRandomNumber(length)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end