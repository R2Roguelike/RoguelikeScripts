global function OnWeaponAttemptOffhandSwitch_titanability_craft_battery
global function OnWeaponPrimaryAttack_titanability_craft_battery
global function OnWeaponChargeBegin_titanability_craft_battery
global function OnWeaponChargeEnd_titanability_craft_battery

global const float CRAFT_BATTERY_CORE_COST = 0.499

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanability_craft_battery
#endif

const FX_EMP_BODY_HUMAN			= $"P_emp_body_human"
const FX_EMP_BODY_TITAN			= $"P_emp_body_titan"
const FX_SHIELD_GAIN_SCREEN		= $"P_xo_shield_up"

struct
{
	void functionref(entity,entity,int) stunHealCallback
} file

bool function OnWeaponAttemptOffhandSwitch_titanability_craft_battery( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	entity soul = owner.GetTitanSoul()
	int curCost = weapon.GetWeaponCurrentEnergyCost()
	float coreFrac = soul.GetTitanSoulNetFloat("coreAvailableFrac")
	bool canUse = owner.CanUseSharedEnergy( curCost )

	if (coreFrac < CRAFT_BATTERY_CORE_COST)
		return false

	return canUse
}

var function OnWeaponPrimaryAttack_titanability_craft_battery( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	#endif

	entity weaponOwner = weapon.GetWeaponOwner()
	entity soul = weaponOwner.GetTitanSoul()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	#if SERVER
	if (Roguelike_HasMod( weaponOwner, "power_battery" ))
	{
		weaponOwner.SetInvulnerable()
		delaythread(3.0) ClearInvincible( weaponOwner )
	}
	Rodeo_GiveExecutingTitanABattery( weaponOwner )
	float coreFrac = soul.GetTitanSoulNetFloat("coreAvailableFrac")
	float cost = CRAFT_BATTERY_CORE_COST
	if (attackParams.burstIndex == 1)
	{
		cost = 0.16
	}
	SoulTitanCore_SetNextAvailableTime( soul, max( coreFrac - cost, 0.0 ) )
	#endif

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	weapon.SetWeaponChargeFractionForced(1.0)
	
	if (Roguelike_HasMod(weaponOwner, "double_battery") && attackParams.burstIndex == 0)
	{
		return 1
	}
	weapon.SetWeaponPrimaryClipCount( 0 )//used to skip the fire animation
	return 0
}

// actually belongs to energy siphon
bool function OnWeaponChargeBegin_titanability_craft_battery(entity weapon)
{
	if (weapon.GetWeaponPrimaryClipCount() < weapon.GetAmmoPerShot())
		return false

	entity owner = weapon.GetWeaponOwner()
	#if SERVER
	print("ayo")
	if (Roguelike_HasMod( owner, "instant_stun" ))
		thread RestoreShieldsRapidly( owner, owner.GetTitanSoul() )
	#endif
	return true
}
void function OnWeaponChargeEnd_titanability_craft_battery(entity weapon)
{
	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
	
	#endif
	#if SERVER
	owner.Signal("CraftBatteryShieldRegen")
	#endif
}

#if SERVER
void function RestoreShieldsRapidly( entity player, entity soul )
{
	player.EndSignal("CraftBatteryShieldRegen")
	while (1)
	{
		soul.SetShieldHealth(minint(soul.GetShieldHealthMax(), soul.GetShieldHealth() + 15))
		wait 0.049
	}
}
var function OnWeaponNPCPrimaryAttack_titanability_craft_battery( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}
#endif
