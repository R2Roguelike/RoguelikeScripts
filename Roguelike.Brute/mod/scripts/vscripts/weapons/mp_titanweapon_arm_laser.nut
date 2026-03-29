untyped
global function MpTitanWeaponArmLaser_Init
#if SERVER
global function Brute_ApplyArm
#endif
global function OnWeaponPrimaryAttack_titanweapon_arm_laser

struct
{
	void functionref(entity,entity,int) stunHealCallback
} file

void function MpTitanWeaponArmLaser_Init()
{
	#if SERVER
	RegisterSignal("ArmedTargetChanged")
	RegisterSignal( "CraftBatteryShieldRegen" )
	RegisterWeaponDamageSources(
		{
			mp_titanweapon_arm_laser = "Arm Laser",
		}
	)
	#endif

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_arm_laser, ArmLaser_DamagedTarget )
	#endif
}

var function OnWeaponPrimaryAttack_titanweapon_arm_laser( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	#endif

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 1, DF_GIB | DF_EXPLOSION )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	weapon.SetWeaponChargeFractionForced(1.0)
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}
#if SERVER
void function ArmLaser_DamagedTarget( entity target, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	Brute_ApplyArm( attacker, target, damageInfo )
}

void function Brute_ApplyArm( entity attacker, entity target, var damageInfo )
{
	if (RSE_Get( target, RoguelikeEffect.brute_arm ) > 0.0 && Roguelike_HasMod( attacker, "arm_ed"))
	{
		DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_ARMED )
		DamageInfo_SetDamage( damageInfo, 1000.0 + RSE_Get(target, RoguelikeEffect.brute_arm) * 1000)
	}
	if (!Roguelike_HasMod( attacker, "multi_arm" ))
		attacker.Signal("ArmedTargetChanged")

	if (Roguelike_HasMod( attacker, "arm_load" ))
	{
		RSE_Apply( attacker, RoguelikeEffect.arm_load, 1.0, 12.0, 0.0 )
		foreach (entity weapon in attacker.GetMainWeapons())
		{
			if (weapon.GetWeaponPrimaryClipCountMax() > 0 )
			{
				weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCountMax())
			}
		}
	}
	RSE_Apply( target, RoguelikeEffect.brute_arm, 1.0, 10.0, 10.0 )
	thread ArmedTarget( attacker, target )
}

void function ArmedTarget( entity player, entity target )
{
	player.EndSignal("ArmedTargetChanged")
	target.EndSignal("OnDeath")

	player.e.armedTargets.append(target)

	OnThreadEnd( function() : ( player, target )
	{
		player.e.armedTargets.fastremovebyvalue(target)
		if (IsValid(target))
			RSE_Stop( target, RoguelikeEffect.brute_arm )
	} )
	
	wait 10.0
}
#endif
