-- � Limetric Studios ( www.limetricstudios.com ) -- All rights reserved.
-- See LICENSE.txt for license information

local table = table
local math = math
local string = string
local util = util
local pairs = pairs
local team = team
local player = player
local timer = timer
local umsg = umsg
local ents = ents

local dmg = 0
local olddmg = 0
local mul = 0

-- Process shop upgrades and more
function GM:DoDamageUpgrades ( ent, attacker, inflictor, dmginfo )

	dmg = dmginfo:GetDamage()

	if attacker:IsPlayer() then

		olddmg = dmginfo:GetDamage() 
		mul = 0.1 + ((attacker:GetRank() * 1) / 100 )
		
		if attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
			if attacker:GetActiveWeapon().Primary.Ammo == "pistol" and attacker:GetPerk("_medic") then
				dmg = dmg + (dmg * mul)
			elseif attacker:GetActiveWeapon().Primary.Ammo == "ar2" and attacker:GetPerk("_commando") then
				dmg = dmg + (dmg * mul)
				
				if attacker:GetPerk("_enforcer") then
					dmg = dmg + 1
				end
			elseif attacker:GetActiveWeapon().Primary.Ammo == "smg1" and attacker:GetPerk("_support2") or attacker:GetActiveWeapon().Primary.Ammo == "buckshot" and attacker:GetPerk("_support2") then
				dmg = dmg + (dmg * mul)		
			elseif attacker:GetActiveWeapon().Primary.Ammo == "357" and attacker:GetPerk("_sharpshooter") then
				if attacker:GetPerk("_highcal") then
					mul = mul + 0.05		
					
				elseif attacker:GetPerk("_frictionburn") and math.random(1,5) == 1 then
					ent:TakeDamageOverTime(5, 1, 5, attacker, inflictor )
					ent:Ignite(5,0)			
				end

				dmg = dmg + (dmg * mul)	
				
			elseif attacker:GetActiveWeapon().Primary.Ammo == "Battery" and attacker:GetPerk("_medic") then --mediguns
			
				if attacker:GetPerk("_battlemedic") then
					dmg = dmg + 1			
				elseif attacker:GetPerk("_bleed") then
					ent:TakeDamageOverTime(dmg*0.1, 1, 5, attacker, inflictor )	
					mul = mul - 0.1
				end
				
				dmg = dmg + (dmg * mul)

			elseif  attacker:GetPerk("_engineer") then
			
				if attacker:GetActiveWeapon().Primary.Ammo == "none" then
					dmg = dmg + (dmg * mul)	
					if attacker:GetPerk("_darkenergy") then
						dmg = dmg + 1
					end					
				end

				if attacker:GetPerk("_combustion") and inflictor:GetClass() == "env_explosion" then
					ent:TakeDamageOverTime(5, 1, 5, attacker, inflictor )
					ent:Ignite(5,0)		
				end
				
			elseif attacker:GetPerk("_berserker") then
			
				if not dmginfo:IsMeleeDamage() then
					dmg = dmg * 0.9
				else
					if attacker:GetPerk("_headhunter") then
						mul = mul - 0.15
					elseif attacker:GetPerk("_freeman") then
						mul = mul + 0.1
					elseif attacker:GetPerk("_executioner") then
						mul = mul - 0.25
						if ent:Health() < ent:GetMaximumHealth()*0.3 then
							mul = mul + 1
						end
					end

					dmg = dmg + (dmg * mul)					
				end

			elseif attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD and ent:IsPlayer() then
			
				if attacker:HasBought("vampire") and attacker:Health() + dmg * 0.5 < attacker:GetMaximumHealth() then	
					attacker:SetHealth(attacker:Health() + dmg * 0.5)	
				end		
			
				if ent:GetPerk("_sharpshooter") and ent.DataTable["ShopItems"][69] and math.random(1,5) == 1 then
					dmginfo:SetDamage(0)				
				elseif ent:GetPerk("_medic") then
					dmg = dmg - (dmg * ((2*ent:GetRank())/100) + 0.1)	

				elseif ent:GetPerk("_kevlarcommando2") then
					dmg = dmg*0.8			
				end
			end
		end

		if attacker.DamageOutput then
			attacker:ChatPrint("damage: " .. math.Round(dmg) .. " | multiplier: " .. (1 + mul) .. " | old damage: " .. math.Round(olddmg))
		end
		
	end
	
	dmginfo:SetDamage( dmg )
end

