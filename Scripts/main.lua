print("[HealthRegain] Loaded!")

local TIME_TO_REGAIN = 4	-- Second, How many of time needs to wait before health regain
local REGAIN_PERCENT = 0.05	-- Regain percent every TIME_PER_TICK
local TIME_PER_TICK = 100	-- Millisecond, How many of milliseconds we do a check and modify, usually doesnt need to change
local TICK_TO_REGAIN = math.ceil(TIME_TO_REGAIN * (1000 / TIME_PER_TICK))

local Timer = 0
local HealthRegainTracker = {}

ExecuteWithDelay(2000, function()
	RegisterHook("/Script/FPSController.FPSCharacterBase:ReceiveTakeDamage", function(FPSCharacter, DamageAmount, DamageEvent, EventInstigator, DamageCauser)
		local FPSCharacterObj = FPSCharacter:get()
		if not FPSCharacterObj:IsPlayerControlled() then
			return
		end

		HealthRegainTracker[FPSCharacterObj.PlayerState.PlayerID] = {FPSCharacterObj, Timer}
	end)
end)

LoopAsync(TIME_PER_TICK, function()
	ExecuteInGameThread(function()
		Timer = Timer + 1

		for k, v in pairs(HealthRegainTracker) do
			local FPSCharacter = v[1]
			local LastDamageTime = v[2]

			if not FPSCharacter:IsValid() or FPSCharacter:GetHealth() == FPSCharacter:GetMaxHealth() then
				HealthRegainTracker[k] = nil
				goto continue
			end

			if LastDamageTime + TICK_TO_REGAIN > Timer then
				goto continue
			end

			FPSCharacter:SetCurrentHealth(math.min(FPSCharacter:GetHealth() + FPSCharacter:GetMaxHealth() * REGAIN_PERCENT, FPSCharacter:GetMaxHealth()))

			::continue::
		end
	end)
end)
