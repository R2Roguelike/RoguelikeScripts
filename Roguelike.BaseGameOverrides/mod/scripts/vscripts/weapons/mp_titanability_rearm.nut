//TODO: FIX REARM WHILE FIRING SALVO ROCKETS
untyped

global function OnWeaponPrimaryAttack_titanability_rearm
global function OnWeaponAttemptOffhandSwitch_titanability_rearm

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanability_rearm
#endif

var function OnWeaponPrimaryAttack_titanability_rearm( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )

	entity ordnance = weaponOwner.GetOffhandWeapon( OFFHAND_RIGHT )
	
	array offhandWeapons = weaponOwner.GetOffhandWeapons()
	if (weaponOwner.IsPlayer())
	{
		if (Roguelike_HasMod( weaponOwner, "rearm_reload" ))
			offhandWeapons.extend(weaponOwner.GetMainWeapons())
	#if SERVER
		weaponOwner.s.lastRearm <- Time()

		if ("storedAbilities" in weaponOwner.s)
			offhandWeapons.extend(weaponOwner.s.storedAbilities)
	#endif
	}
	foreach (entity offhand in offhandWeapons)
	{
		if (offhand == weapon)
			continue
		
		if (!IsValid(offhand))
			continue
		
		if (offhand.GetInventoryIndex() == OFFHAND_INVENTORY)
			continue // dont reset equipment!

		if (offhand.GetWeaponPrimaryClipCountMax() > 0)
		offhand.SetWeaponPrimaryClipCount( offhand.GetWeaponPrimaryClipCountMax() )
		#if SERVER
		if ( offhand.IsChargeWeapon() )
			offhand.SetWeaponChargeFractionForced( 0 )
		#endif
	}

	#if SERVER
	if ( weaponOwner.IsPlayer() )//weapon.HasMod( "rapid_rearm" ) &&  )
			weaponOwner.Server_SetDodgePower( 100.0 )
	#endif
	weapon.SetWeaponPrimaryClipCount( 0 )//used to skip the fire animation
	return 0
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanability_rearm( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanability_rearm( weapon, attackParams )
}
#endif

bool function OnWeaponAttemptOffhandSwitch_titanability_rearm( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	bool allowSwitch = false
	foreach (entity offhand in weaponOwner.GetOffhandWeapons())
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
			AddPlayerHint( 1.0, 0.25, $"rui/titan_loadout/tactical/titan_tactical_rearm", "#WPN_TITANABILITY_REARM_ERROR_HINT" )
			if ( weaponOwner == GetLocalViewPlayer() )
				EmitSoundOnEntity( weapon, "titan_dryfire" )
		#endif
	}

	return allowSwitch
}

//UPDATE TO RESTORE CHARGE FOR THE MTMS