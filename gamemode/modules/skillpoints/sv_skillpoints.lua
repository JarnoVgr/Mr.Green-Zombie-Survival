-- Eat with skill!
-- Serverside functions goes here
-- TODO: Make it better 
AddCSLuaFile("cl_skillpoints.lua")
AddCSLuaFile("sh_skillpoints.lua")

include("sh_skillpoints.lua")


SKILLPOINTS = true
if not SKILLPOINTS then
	return
end

skillpoints = {}

function GM:CheckPlayerScore(pl)
	local score = pl:GetScore()
	if self.RetroUnlocks[score] then
		local reward = self.RetroUnlocks[score][math.random(1, #self.RetroUnlocks[score])]
		if string.sub(reward, 1, 1) == "_" then
			-- PowerupFunctions[reward](pl)
		elseif pl:HasWeapon(reward) then
			local hasall = true
			for _, anotherwep in pairs(self.Rewards[score]) do
				if not pl:HasWeapon(anotherwep) then
					pl:Give(anotherwep)
					local wep = pl:GetWeapon(anotherwep)
					if wep:IsValid() then
						pl.HighestAmmoType = string.lower(wep:GetPrimaryAmmoTypeString() or pl.HighestAmmoType)
					end
					hasall = false
					break
				end
			end
			if hasall then
				local wep = pl:GetWeapon(reward)
				if wep:IsValid() then
					local ammotype = string.lower(wep:GetPrimaryAmmoTypeString() or pl.HighestAmmoType or "pistol")
					pl:GiveAmmo(self.AmmoRegeneration[ammotype], ammotype, true)
				end
			end
		else
			pl:Give(reward)
			local wep = pl:GetWeapon(reward)
			if wep:IsValid() then
				pl.HighestAmmoType = string.lower(wep:GetPrimaryAmmoTypeString() or pl.HighestAmmoType)
			end
		end
	end
end

--Called in PlayerInitialSpawn
function skillpoints.SetupSkillPoints(pl)
	if not IsValid(pl) or not pl:IsPlayer() then
		return
	end

	if pl:IsBot() then
		--Used for testing purposes
		pl:SetScore(math.random(0, 600))
	else
		pl:SetScore(0)
	end
end

--Alias
skillpoints.Clean = skillpoints.SetupSkillPoints

--Add nessesary amount of skill points
function skillpoints.AddSkillPoints(pl, amount)
	if not amount or amount == 0 or not IsValid(pl) or not pl:IsPlayer() then
		return false
	end

	pl:AddScore(amount)
	if skillpoints.GetSkillPoints(pl) >= 100 then
		local item = "zs_ammobox"	

		local delta = 1 - math.Clamp( ( ROUNDSTART_TIME - CurTime()) / ROUNDTIME, 0, 1 )
		local babyPrice = math.Round(delta*1000) + 100			
		local possibleWeapons = {}

		for wep,tab in pairs(GAMEMODE.HumanWeapons) do
			if tab.Price and tab.HumanClass then
				if tab.HumanClass ~= pl:GetHumanClass() then continue end
			
				if tab.Price <= babyPrice then
					table.insert(possibleWeapons,wep)			
				end

			end
		end

		item = table.Random(possibleWeapons)

		local itemToSpawn = ents.Create(item)			

		if IsValid(itemToSpawn) then
			if pl:Crouching() then
				itemToSpawn:SetPos(pl:GetPos()+Vector(0,0,20))			
			else
				itemToSpawn:SetPos(pl:GetPos()+Vector(0,0,32))			
			end
			itemToSpawn:Spawn()

			local phys = itemToSpawn:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:ApplyForceCenter(Vector(math.Rand(25, 175),math.Rand(25, 175),math.Rand(50, 375)))
				phys:SetAngles(Angle(math.Rand(0, 180),math.Rand(0, 180),math.Rand(0, 180)))
			end
		end	
		skillpoints.TakeSkillPoints(pl,100)
		pl:Message(item .. " dropped.", 1)			
	end		
	
	return true
end

--Take nessesary amount of skill points
function skillpoints.TakeSkillPoints(pl, amount)
	if not amount or amount == 0 or not IsValid(pl) or not pl:IsPlayer() then
		return false
	end
	
	pl:AddScore(-1 * amount)
	return true
end

--Get
function skillpoints.GetSkillPoints(pl)
	if not IsValid(pl) or not pl:IsPlayer() then
		return false
	end
	
	return pl:GetScore()
end

--Use it when you want player to achieve skillshot
function skillpoints.AchieveSkillShot(pl, victim, name)
	if not IsValid(pl) or not pl:IsPlayer() or not IsValid(victim) or not victim:IsPlayer() then
		return
	end
	
	local Team
	
	if pl:IsHuman() then
		Team = "Humans"
	elseif pl:IsZombie() then
		Team = "Zombies"
	else
		return
	end
	
	if not SkillPointsTable[Team][name] then
		return
	end
	
	local Amount = SkillPointsTable[Team][name].Points
	--[[local Name = SkillPointsTable[Team][name].Name
	local Col = SkillPointsTable[Team][name].Color
	local Pos = victim:GetPos() + Vector(0,0,math.random(55,77))]]

	skillpoints.AddSkillPoints(pl, Amount)
end