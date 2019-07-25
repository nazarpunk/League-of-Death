do
	local POWERS   = { 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 }
	local MAX, MIN = POWERS[#POWERS], -POWERS[#POWERS]
	
	local ABILITY  = {
		--STR: 1 [1-13]
		FourCC('ZxF0'), -- +1
		FourCC('ZxF1'), -- +2
		FourCC('ZxF2'), -- +4
		FourCC('ZxF3'), -- +8
		FourCC('ZxF4'), -- +16
		FourCC('ZxF5'), -- +32
		FourCC('ZxF6'), -- +64
		FourCC('ZxF7'), -- +128
		FourCC('ZxF8'), -- +256
		FourCC('ZxF9'), -- +512
		FourCC('ZxFa'), -- +1024
		FourCC('ZxFb'), -- +2048
		FourCC('ZxFc'), -- -4096
		-- AGI 2 [14-26]
		FourCC('ZxG0'), -- +1
		FourCC('ZxG1'), -- +2
		FourCC('ZxG2'), -- +4
		FourCC('ZxG3'), -- +8
		FourCC('ZxG4'), -- +16
		FourCC('ZxG5'), -- +32
		FourCC('ZxG6'), -- +64
		FourCC('ZxG7'), -- +128
		FourCC('ZxG8'), -- +256
		FourCC('ZxG9'), -- +512
		FourCC('ZxGa'), -- +1024
		FourCC('ZxGb'), -- +2048
		FourCC('ZxGc'), -- -4096
		-- INT 3 [27-39]
		FourCC('ZxH0'), -- +1
		FourCC('ZxH1'), -- +2
		FourCC('ZxH2'), -- +4
		FourCC('ZxH3'), -- +8
		FourCC('ZxH4'), -- +16
		FourCC('ZxH5'), -- +32
		FourCC('ZxH6'), -- +64
		FourCC('ZxH7'), -- +128
		FourCC('ZxH8'), -- +256
		FourCC('ZxH9'), -- +512
		FourCC('ZxHa'), -- +1024
		FourCC('ZxHb'), -- +2048
		FourCC('ZxHc'), -- -4096
		-- DAMAGE 4 [40-52]
		FourCC('ZxB0'), -- +1
		FourCC('ZxB1'), -- +2
		FourCC('ZxB2'), -- +4
		FourCC('ZxB3'), -- +8
		FourCC('ZxB4'), -- +16
		FourCC('ZxB5'), -- +32
		FourCC('ZxB6'), -- +64
		FourCC('ZxB7'), -- +128
		FourCC('ZxB8'), -- +256
		FourCC('ZxB9'), -- +512
		FourCC('ZxBa'), -- +1024
		FourCC('ZxBb'), -- +2048
		FourCC('ZxBc'), -- -4096
		-- ARMOR 5 [53-65]
		FourCC('ZxA0'), -- +1
		FourCC('ZxA1'), -- +2
		FourCC('ZxA2'), -- +4
		FourCC('ZxA3'), -- +8
		FourCC('ZxA4'), -- +16
		FourCC('ZxA5'), -- +32
		FourCC('ZxA6'), -- +64
		FourCC('ZxA7'), -- +128
		FourCC('ZxA8'), -- +256
		FourCC('ZxA9'), -- +512
		FourCC('ZxAa'), -- +1024
		FourCC('ZxAb'), -- +2048
		FourCC('ZxAc'), -- -4096
		-- HP 6 [66-78] absolute
		FourCC('ZxE0'), -- +1
		FourCC('ZxE1'), -- +2
		FourCC('ZxE2'), -- +4
		FourCC('ZxE3'), -- +8
		FourCC('ZxE4'), -- +16
		FourCC('ZxE5'), -- +32
		FourCC('ZxE6'), -- +64
		FourCC('ZxE7'), -- +128
		FourCC('ZxE8'), -- +256
		FourCC('ZxE9'), -- +512
		FourCC('ZxEa'), -- +1024
		FourCC('ZxEb'), -- +2048
		FourCC('ZxEc'), -- -4096
		-- MP 7 [79-91] percent
		FourCC('ZxD0'), -- +1
		FourCC('ZxD1'), -- +2
		FourCC('ZxD2'), -- +4
		FourCC('ZxD3'), -- +8
		FourCC('ZxD4'), -- +16
		FourCC('ZxD5'), -- +32
		FourCC('ZxD6'), -- +64
		FourCC('ZxD7'), -- +128
		FourCC('ZxD8'), -- +256
		FourCC('ZxD9'), -- +512
		FourCC('ZxDa'), -- +1024
		FourCC('ZxDb'), -- +2048
		FourCC('ZxDc') -- -4096
	}
	local TYPES    = #ABILITY / #POWERS
	
	---@param target unit
	---@param type integer
	function UnitClearBonus (target, type)
		for i = 1, #POWERS do
			UnitRemoveAbility(target, ABILITY[(type - 1) * #POWERS + i])
		end
	end
	
	---@param target unit
	---@param type integer
	---@param ammount integer
	---@return boolean
	function UnitSetBonus (target, type, ammount)
		if ammount < MIN or ammount > MAX then
			print('BonusSystem Error: Bonus too high or low', ammount)
			return false
		elseif type < 1 or type >= TYPES then
			print('BonusSystem Error: Invalid bonus type', type)
			return false
		end
		
		local ability = ABILITY[(type - 1) * #POWERS + #POWERS]
		if ammount < 0 then
			ammount = MAX + ammount
			UnitAddAbility(target, ability)
			UnitMakeAbilityPermanent(target, true, ability)
		else
			UnitRemoveAbility(target, ability)
		end
		
		for i = #POWERS - 1, 1, -1 do
			ability = ABILITY[(type - 1) * #POWERS + i]
			if ammount >= POWERS[i] then
				UnitAddAbility(target, ability)
				UnitMakeAbilityPermanent(target, true, ability)
				ammount = ammount - POWERS[i]
			else
				UnitRemoveAbility(target, ability)
			end
		end
		
		return true
	end
	
	---@param target unit
	---@param type integer
	---@return integer
	function UnitGetBonus (target, type)
		local ammount = 0
		
		if GetUnitAbilityLevel(target, ABILITY[(type - 1) * #POWERS + #POWERS]) > 0 then
			ammount = MIN
		end
		
		for i = 1, #POWERS do
			if GetUnitAbilityLevel(target, ABILITY[(type - 1) * #POWERS + i]) > 0 then
				ammount = ammount + POWERS[i]
			end
		end
		
		return ammount
	end
	
	---@param target unit
	---@param type integer
	---@param ammount integer
	---@return boolean
	function UnitAddBonus (target, type, ammount)
		return UnitSetBonus(target, type, UnitGetBonus(target, type) + ammount)
	end
end