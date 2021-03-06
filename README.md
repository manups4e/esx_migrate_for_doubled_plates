# esx_migrate

## READ CAREFULLY AS THIS IS INTENDED TO BE USED ONLY IF YOU NEED TO REPLACE PLATES FOR DOUBLED VEHICLES IN DATABASE. (as happened in my server with more than 2000 bought vehicles..)


## FOR MY SCRIPT TO WORK YOU MUST DO THE NEXT STEP IN 3 DIFFERENT STEPS:
## 1. IMPORT BEFORE.SQL ON ESSENTIALMODE ROOT TABLE
## 2. USE MIGRATE COMMAND IN CMD (no players connected it's better)
## 3. AFTER YOU FINISHED REPLACING ALL THE PLATES IMPORT AFTER.SQL ON YOUR ESSENTIALMODE ROOT TABLE

This script migrates the 'old' `owned_vehicles` database to an improved system. Very basic script and does the job.

Don't forget to change the database to look like this, see how `plate` is the primary key.

```sql
CREATE TABLE `owned_vehicles` (
	`owner` VARCHAR(30) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`plate` VARCHAR(12) NOT NULL COLLATE 'utf8mb4_bin',
	`vehicle` LONGTEXT NULL COLLATE 'utf8mb4_bin',

	PRIMARY KEY (`plate`)
);
```

### What's so good with this anyways?
Currently with all official esx scripts getting a registered vehicle and its owner is not optimized at all.
Let's compare two functions from.... esx_vehicleshop:

#### Before
```lua
function RemoveOwnedVehicle (plate)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles', {}, function (result)
		for i=1, #result, 1 do
			local vehicleProps = json.decode(result[i].vehicle)

			if vehicleProps.plate == plate then
				MySQL.Async.execute('DELETE FROM owned_vehicles WHERE id = @id',
				{
					['@id'] = result[i].id
				})
			end
		end
	end)
end
```

#### After
```lua
function RemoveOwnedVehicle (plate)
	MySQL.Async.execute('DELETE FROM owned_vehicles WHERE plate = @plate',
	{
		['@plate'] = plate
	})
end
```

Since this script replaces vehicle plates you can also configure the template for them over at `config.lua`, remember that scripts using the database `owned_vehicles` will have to be updated aswell in order to take advantage of the db change.

# Legal
### License
esx_migrate - migrate tool for ESX

Copyright (C) 2015-2018 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
