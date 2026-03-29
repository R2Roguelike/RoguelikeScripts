//TODO: FIX REARM WHILE FIRING SALVO ROCKETS
untyped

global function OnWeaponPrimaryAttack_titanability_rearm_brute
global function OnWeaponAttemptOffhandSwitch_titanability_rearm_brute
global function OnWeaponChargeBegin_titanability_stun_laser
global function OnWeaponChargeEnd_titanability_stun_laser
global function OnWeaponVortexHitBullet_titanweapon_stun_laser
global function OnWeaponVortexHitProjectile_titanweapon_stun_laser

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanability_rearm_brute
#endif

var function OnWeaponPrimaryAttack_titanability_rearm_brute( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	entity ordnance = weaponOwner.GetOffhandWeapon( OFFHAND_RIGHT )

	array<entity> offhandWeapons = weaponOwner.GetMainWeapons()
	int loadedWeapons = 0
	if (offhandWeapons.len() < 2)
		loadedWeapons++
	if (Roguelike_HasMod( weaponOwner, "quick_charge"))
		offhandWeapons.append(weaponOwner.GetOffhandWeapon(0))
	foreach (entity offhand in offhandWeapons)
	{
		if (offhand == weapon)
			continue

		if (!IsValid(offhand))
			continue

		if (offhand.GetInventoryIndex() == OFFHAND_INVENTORY)
			continue // dont reset equipment!
	
		if (offhand.GetWeaponPrimaryClipCountMax() > 0 && offhand.GetWeaponPrimaryClipCount() != offhand.GetWeaponPrimaryClipCountMax())
		{
			loadedWeapons++
			offhand.SetWeaponPrimaryClipCount( offhand.GetWeaponPrimaryClipCountMax() )
		}
		#if SERVER
		if ( offhand.IsChargeWeapon() && offhand.IsWeaponOffhand() )
			offhand.SetWeaponChargeFractionForced( 1 ) // northstar interaction - immediate charge up
		#endif
	}

	#if SERVER
	if (weaponOwner.GetActiveWeapon().IsReloading())
	{
		weaponOwner.HolsterWeapon()
		weaponOwner.DeployWeapon()
	}
	if (loadedWeapons > 1 && Roguelike_HasMod( weaponOwner, "dual_load" )) // 2 or more
	{
		float duration = 20.0
    	duration *= 1.0 + Roguelike_GetStat( weaponOwner, "ability_duration" )
		RSE_Apply( weaponOwner, RoguelikeEffect.dual_load, 1.0, duration, 0.0 )
	}
	if (Roguelike_HasMod( weaponOwner, "infinite_ammo" )) // 2 or more
	{
		float duration = 10.0
    duration *= 1.0 + Roguelike_GetStat( weaponOwner, "ability_duration" )
		RSE_Apply( weaponOwner, RoguelikeEffect.infinite_ammo, 1.0, duration, 0.0 )
	}
	if (Roguelike_HasMod( weaponOwner, "burst_load" )) // 2 or more
	{
		RSE_Apply( weaponOwner, RoguelikeEffect.burst_load, 1.0 )
	}

	if (Roguelike_HasMod( weaponOwner, "quickload_firerate"))
		RSE_Apply( weaponOwner, RoguelikeEffect.brute_quickload_firerate, 1.0, 3.0, 3.0 )

	
	MessageToPlayer( weaponOwner, eEventNotifications.WEAP_GotAmmo, weapon, 500 )
	#endif

	//weapon.SetWeaponPrimaryClipCount( 0 )//used to skip the fire animation
	return weapon.GetAmmoPerShot()
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanability_rearm_brute( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanability_rearm( weapon, attackParams )
}
#endif

bool function OnWeaponAttemptOffhandSwitch_titanability_rearm_brute( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	bool allowSwitch = IsTitanCoreFiring( weaponOwner )
	foreach (entity offhand in weaponOwner.GetMainWeapons())
	{
		if (offhand == weapon)
			continue

		if (!IsValid(offhand))
			continue

		if ( offhand.GetWeaponPrimaryClipCountMax() > 0 && offhand.GetWeaponPrimaryClipCount() < offhand.GetWeaponPrimaryClipCountMax() )
			allowSwitch = true

		if ( offhand.IsChargeWeapon() && offhand.GetWeaponChargeFraction() > 0.0 )
			allowSwitch = true
	}

	//if ( weapon.HasMod( "rapid_rearm" ) )
	//{
		// using rearm (40 sec cooldown) to regen just dashes feels stupid imo
		//if ( weaponOwner.GetDodgePower() < 100 )
		//	allowSwitch = true
	//}

	if( !allowSwitch && IsFirstTimePredicted() )
	{
		// Play SFX and show some HUD feedback here...
		#if CLIENT
			AddPlayerHint( 1.0, 0.25, $"rui/pilot_loadout/kit/speed_loader", "#WPN_TITANABILITY_REARM_ERROR_HINT" )
			if ( weaponOwner == GetLocalViewPlayer() )
				EmitSoundOnEntity( weapon, "titan_dryfire" )
		#endif
	}

	return true
}

// actually belongs to energy siphon
bool function OnWeaponChargeBegin_titanability_stun_laser(entity weapon)
{
	if (weapon.GetWeaponPrimaryClipCount() < weapon.GetAmmoPerShot())
		return false

	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
	int sphereClientFXHandle = owner.GetActiveWeapon().PlayWeaponEffectReturnViewEffectHandle( $"wpn_vortex_chargingCP_titan_FP", $"wpn_vortex_chargingCP_titan", "muzzle_flash" )
	EffectSetControlPointVector( sphereClientFXHandle, 1, <192,96,192> )
	#endif
	#if SERVER
	/*entity vortexSphere = CreateEntity( "vortex_sphere" )

	vortexSphere.kv.enabled = 1
	vortexSphere.kv.radius = 150
	vortexSphere.kv.bullet_fov = 120
	vortexSphere.kv.physics_pull_strength = 25
	vortexSphere.kv.physics_side_dampening = 6
	vortexSphere.kv.physics_fov = 360
	vortexSphere.kv.physics_max_mass = 2
	vortexSphere.kv.physics_max_size = 6
	vortexSphere.kv.spawnflags = SF_ABSORB_BULLETS | SF_BLOCK_NPC_WEAPON_LOF

	DispatchSpawn( vortexSphere )
	vortexSphere.SetParent( owner )
	vortexSphere.SetLocalOrigin( <0,20,0> )
	vortexSphere.SetOwner( owner )
	vortexSphere.FireNow("Enable")

	vortexSphere.SetOwnerWeapon( weapon )
	weapon.SetWeaponUtilityEntity( vortexSphere )*/

	#endif
	return true
}
void function OnWeaponChargeEnd_titanability_stun_laser(entity weapon)
{
	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
	
	owner.GetActiveWeapon().StopWeaponEffect($"wpn_vortex_chargingCP_titan_FP", $"wpn_vortex_chargingCP_titan")
	#endif
	#if SERVER
	if (IsValid(weapon.GetWeaponUtilityEntity()))
		weapon.GetWeaponUtilityEntity().Destroy()
	#endif
}

bool function OnWeaponVortexHitBullet_titanweapon_stun_laser( entity weapon, entity vortexSphere, var damageInfo )
{
	if ( weapon.HasMod( "shield_only" ) )
		return true

	#if CLIENT
		return true
	#else
		if ( !ValidateVortexImpact( vortexSphere ) )
			return false

		entity owner = weapon.GetWeaponOwner()
		entity attacker				= DamageInfo_GetAttacker( damageInfo )
		vector origin				= DamageInfo_GetDamagePosition( damageInfo )
		int damageSourceID			= DamageInfo_GetDamageSourceIdentifier( damageInfo )
		entity attackerWeapon		= DamageInfo_GetWeapon( damageInfo )
		if ( PROTO_ATTurretsEnabled() && !IsValid( attackerWeapon ) )
			return true
		string attackerWeaponName	= attackerWeapon.GetWeaponClassName()
		int damageType				= DamageInfo_GetCustomDamageType( damageInfo )

		if ( IsValid( owner ) && owner.IsPlayer() )
		{
			var impact_sound_1p = "Vortex_Shield_AbsorbBulletSmall"
			if ( impact_sound_1p != null )
				EmitSoundOnEntityOnlyToPlayer( weapon, owner, impact_sound_1p )
		}

		return true
	#endif
}

bool function OnWeaponVortexHitProjectile_titanweapon_stun_laser( entity weapon, entity vortexSphere, entity attacker, entity projectile, vector contactPos )
{
	print("shit")
	if ( weapon.HasMod( "shield_only" ) )
		return true

	#if CLIENT
		return true
	#else
		if ( !ValidateVortexImpact( vortexSphere, projectile ) )
			return false

		entity owner = weapon.GetWeaponOwner()
		int damageSourceID = projectile.ProjectileGetDamageSourceID()
		string weaponName = projectile.ProjectileGetWeaponClassName()

		if ( IsValid( owner ) && owner.IsPlayer() )
		{
			var impact_sound_1p = "Vortex_Shield_AbsorbBulletSmall"
			if ( impact_sound_1p != null )
				EmitSoundOnEntityOnlyToPlayer( weapon, owner, impact_sound_1p )
		}

		return true
	#endif
}

//UPDATE TO RESTORE CHARGE FOR THE MTMS