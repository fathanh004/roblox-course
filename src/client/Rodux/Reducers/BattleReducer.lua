--[=[
 	Owner: rompionyoann
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Reducer
local BattleReducer = Rodux.createReducer({
	enemies = {}, -- Tabel berisi daftar NPC yang sedang dilawan
}, {
	-- Menyetel semua enemy sekaligus
	setEnemies = function(state, action)
		return {
			enemies = action.enemies, -- List of enemies with full data
		}
	end,

	-- Update health enemy tertentu berdasarkan index
	updateEnemyHealth = function(state, action)
		local newEnemies = table.clone(state.enemies)
		for i, enemy in ipairs(newEnemies) do
			if enemy.NpcData.name == action.npcName then
				-- Jika NPC ditemukan, update health-nya
				newEnemies[i].CurrentHealth = action.currentHealth
				break
			end
		end
		return {
			enemies = newEnemies,
		}
	end,

	-- Menambahkan 1 enemy baru
	addEnemy = function(state, action)
		local newState = table.clone(state) or {}

		-- Dapatkan NPC Data dari action
		local npcData = action.npcData

		-- Tambahkan NPC baru dengan CurrentHealth dan MaxHealth ke dalam state
		table.insert(newState.enemies, {
			NpcData = npcData, -- Menyimpan NpcData yang dikirim
			CurrentHealth = 100, -- Misalnya, set initial health = power NPC
			MaxHealth = 100, -- Sama dengan power, atau kamu bisa tentukan nilai lain
		})

		return newState
	end,

	-- Menghapus enemy berdasarkan index
	removeEnemy = function(state, action)
		local newEnemies = table.clone(state.enemies)
		for i, enemy in ipairs(newEnemies) do
			if enemy.NpcData.name == action.npcName then
				-- Jika NPC ditemukan, delete dari list
				table.remove(newEnemies, i)
				break
			end
		end
		return {
			enemies = newEnemies,
		}
	end,
})

return BattleReducer
