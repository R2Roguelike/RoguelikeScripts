untyped

global function MpTitanWeaponpredatorcannon_Init
global function OnWeaponActivate_titanweapon_predator_cannon
global function OnWeaponDeactivate_titanweapon_predator_cannon
global function OnWeaponPrimaryAttack_titanweapon_predator_cannon
global function OnWeaponStartZoomIn_titanweapon_predator_cannon
global function OnWeaponStartZoomOut_titanweapon_predator_cannon
global function OnWeaponOwnerChanged_titanweapon_predator_cannon
global function IsPredatorCannonActive

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_predator_cannon
global function OnWeaponNpcPreAttack_titanweapon_predator_cannon
global function IsDamageSourcePowerShot
#endif

const SPIN_EFFECT_1P = $"P_predator_barrel_blur_FP"
const SPIN_EFFECT_3P = $"P_predator_barrel_blur"

void function MpTitanWeaponpredatorcannon_Init()
{
	PrecacheParticleSystem( SPIN_EFFECT_1P )
	PrecacheParticleSystem( SPIN_EFFECT_3P )
	
    AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_OVERRIDE, PredatorCannon_ApplyModWeaponVars )
    AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_OVERRIDE, PowerShot_ApplyModWeaponVars )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_predator_cannon, Roguelike_PredatorCannon_DamagedTarget )
	if ( GetCurrentPlaylistVarInt( "aegis_upgrades", 0 ) == 1 )
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_predator_cannon, PredatorCannon_DamagedTarget )
	#endif
}

void function PowerShot_ApplyModWeaponVars( entity weapon )
{
	if (weapon.GetWeaponClassName() != "mp_titanability_power_shot")
		return
	entity owner = weapon.GetWeaponOwner()
	if (!IsValid(owner) || !owner.IsPlayer())
		return

	array<string> bonusChargeMods = ["swap_load", "stat_belt", "shotgun_mode", "marksman_mode"
									"power_back"]

	int extraCharges = 0
	foreach (string mod in bonusChargeMods)
	{
		if (Roguelike_HasMod( owner, mod ))
			extraCharges++
	}

	int ammo_per_shot = weapon.GetAmmoPerShot()
	ModWeaponVars_AddToVar( weapon, eWeaponVar.ammo_clip_size, ammo_per_shot * extraCharges )
	ModWeaponVars_AddToVar( weapon, eWeaponVar.ammo_default_total, ammo_per_shot * extraCharges )
}

void function PredatorCannon_ApplyModWeaponVars( entity weapon )
{
	if (weapon.GetWeaponClassName() != "mp_titanweapon_predator_cannon")
		return
		
	ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 100 )
	entity owner = weapon.GetWeaponOwner()
	if (!IsValid(owner) || !owner.IsPlayer())
		return
	
	bool CloseRangePowerShot = weapon.HasMod("CloseRangePowerShot")
	bool LongRangePowerShot = weapon.HasMod("LongRangePowerShot")
	bool PowerShot = CloseRangePowerShot || LongRangePowerShot
	bool LongRangeAmmo = weapon.HasMod("LongRangeAmmo")

	array<string> magSizeMods = ["mag_dump", "focus_crystal", "consumption", "ready_up", "puncture_crit_dmg"]
	int bonusMag = 0
	foreach (string mod in magSizeMods)
	{
		if (Roguelike_HasMod( owner, mod ))
			bonusMag += 20
	}

	if (Roguelike_HasMod(owner, "stat_belt"))
		bonusMag += Roguelike_GetStat( owner, STAT_ENERGY )

	ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 100 + bonusMag )
	if (!PowerShot)
	{
		ModWeaponVars_SetInt( weapon, eWeaponVar.damage_near_value_titanarmor, 100)
		ModWeaponVars_SetInt( weapon, eWeaponVar.damage_far_value_titanarmor, 70)
	}
	else
	{
	}

	if (LongRangeAmmo)
		ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_per_shot, 2 )

	ModWeaponVars_SetFloat( weapon, eWeaponVar.zoom_time_in, 1.1 )
	if (Roguelike_HasMod( owner, "ready_up" ))
	{
		ModWeaponVars_ScaleVar( weapon, eWeaponVar.zoom_time_in, 0.5 )
		ModWeaponVars_ScaleVar( weapon, eWeaponVar.zoom_time_out, 0.5 )
		ModWeaponVars_SetFloat( weapon, eWeaponVar.ads_move_speed_scale, 1.0 )
	}
	if (Roguelike_HasMod( owner, "shotgun_mode" ) && !LongRangeAmmo && !PowerShot)
	{
		ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_per_shot, 6 )
		ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 0.333 )
		// workaround for smart mode removing the extra shots fired
		if (weapon.HasMod("Smart_Core"))
			ModWeaponVars_ScaleDamage( weapon, 4.0 )
		//else
		//	ModWeaponVars_ScaleDamage( weapon, 0.8 )
		ModWeaponVars_SetBool( weapon, eWeaponVar.looping_sounds, false )
		ModWeaponVars_SetString( weapon, eWeaponVar.fire_sound_3, "Weapon_Mastiff_Fire_1P")
	}
	if (Roguelike_HasMod( owner, "marksman_mode" ) && LongRangeAmmo && !PowerShot)
	{
		ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_per_shot, 10 )
		ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 0.15 )
		ModWeaponVars_ScaleDamage( weapon, 7.0 )
		ModWeaponVars_SetBool( weapon, eWeaponVar.looping_sounds, false )
		ModWeaponVars_SetString( weapon, eWeaponVar.fire_sound_3, "Weapon_40mm_Fire_1P")
	}

	if (Roguelike_HasMod( owner, "consumption" ) && !PowerShot)
	{
		ModWeaponVars_ScaleVar( weapon, eWeaponVar.ammo_per_shot, 2 )
	}
}

void function OnWeaponStartZoomIn_titanweapon_predator_cannon( entity weapon )
{
	StopSoundOnEntity( weapon, "weapon_predator_winddown_1p" )
	StopSoundOnEntity( weapon, "weapon_predator_winddown_3p" )
	weapon.EmitWeaponSound_1p3p( "Weapon_Predator_MotorLoop_1P", "Weapon_Predator_MotorLoop_3P" )
	weapon.PlayWeaponEffect( SPIN_EFFECT_1P, SPIN_EFFECT_3P, "fx_barrel" )
	entity weaponOwner = weapon.GetWeaponOwner()
	float zoomFrac = weaponOwner.GetZoomFrac()
	float zoomTimeIn = weapon.GetWeaponSettingFloat( eWeaponVar.zoom_time_in )
	float offset = 1.5 - weapon.GetWeaponSettingFloat( eWeaponVar.zoom_time_in )

	#if SERVER
		EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weaponOwner, "weapon_predator_windup_3p", zoomFrac * zoomTimeIn + offset)
	#endif
	#if CLIENT
		StopSoundOnEntity( weaponOwner, "wpn_predator_cannon_ads_out_mech_fr00_1p" )
		float soundDuration = GetSoundDuration( "wpn_predator_cannon_ads_in_mech_fr00_1p" )
		EmitSoundOnEntityWithSeek( weaponOwner, "wpn_predator_cannon_ads_in_mech_fr00_1p", zoomFrac * soundDuration + offset )
		EmitSoundOnEntityWithSeek( weapon, "weapon_predator_windup_1p", zoomFrac * zoomTimeIn + offset )
	#endif
}

void function OnWeaponStartZoomOut_titanweapon_predator_cannon( entity weapon )
{
	StopSpinSounds( weapon )
	entity weaponOwner = weapon.GetWeaponOwner()
	float zoomFrac = weaponOwner.GetZoomFrac()
	float zoomOutTime = weapon.GetWeaponSettingFloat( eWeaponVar.zoom_time_out )

	#if SERVER
		EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weaponOwner, "weapon_predator_winddown_3P", ( 1 - zoomFrac ) * zoomOutTime )
	#endif
	#if CLIENT
		if ( !IsValid( weaponOwner ) )
			return
		float soundDuration = GetSoundDuration( "wpn_predator_cannon_ads_out_mech_fr00_1p" )
		EmitSoundOnEntityWithSeek( weaponOwner, "wpn_predator_cannon_ads_out_mech_fr00_1p", ( 1 - zoomFrac ) * soundDuration )
		EmitSoundOnEntityWithSeek( weapon, "weapon_predator_winddown_1p", ( 1 - zoomFrac ) * zoomOutTime )
	#endif
}

void function OnWeaponOwnerChanged_titanweapon_predator_cannon( entity weapon, WeaponOwnerChangedParams changeParams )
{
	StopSpinSounds( weapon )
}

void function StopSpinSounds( entity weapon )
{
		weapon.StopWeaponSound( "Weapon_Predator_MotorLoop_1P" )
		weapon.StopWeaponSound( "Weapon_Predator_MotorLoop_3P" )
		StopSoundOnEntity( weapon, "weapon_predator_windup_1p" )
		StopSoundOnEntity( weapon, "weapon_predator_windup_3p" )
		weapon.StopWeaponEffect( SPIN_EFFECT_1P, SPIN_EFFECT_3P )
		#if CLIENT
			entity weaponOwner = weapon.GetWeaponOwner()
			if ( !IsValid( weaponOwner ) )
				return
			StopSoundOnEntity( weaponOwner, "wpn_predator_cannon_ads_out_mech_fr00_1p" )
			StopSoundOnEntity( weaponOwner, "wpn_predator_cannon_ads_in_mech_fr00_1p" )
		#endif
}

void function OnWeaponActivate_titanweapon_predator_cannon( entity weapon )
{
	StopSpinSounds( weapon )
	if ( !( "initialized" in weapon.s ) )
	{
		weapon.s.damageValue <- weapon.GetWeaponInfoFileKeyField( "damage_near_value" )
		SmartAmmo_SetAllowUnlockedFiring( weapon, true )
		SmartAmmo_SetUnlockAfterBurst( weapon, false )
		SmartAmmo_SetWarningIndicatorDelay( weapon, 9999.0 )

		weapon.s.initialized <- true
		#if SERVER
			weapon.s.lockStartTime <- Time()
			weapon.s.locking <- true
		#endif
	}

	#if SERVER
	weapon.s.locking = true
	weapon.s.lockStartTime = Time()
	#endif
}

void function OnWeaponDeactivate_titanweapon_predator_cannon( entity weapon )
{
	StopSpinSounds( weapon )
}

var function OnWeaponPrimaryAttack_titanweapon_predator_cannon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	var needsZoom = weapon.GetWeaponInfoFileKeyField( "attack_button_presses_ads" )

	if ( owner.IsPlayer() && needsZoom )
	{
		float zoomFrac = owner.GetZoomFrac()
		if ( zoomFrac < 1 )
			return 0
	}

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	bool hasLongRangePowerShot = weapon.HasMod( "LongRangePowerShot" )
	bool hasCloseRangePowerShot = weapon.HasMod( "CloseRangePowerShot" )
	if ( hasLongRangePowerShot || hasCloseRangePowerShot )
	{
#if SERVER
		if ( owner.IsPlayer() && IsMultiplayer() )
		{
			owner.Anim_PlayGesture( "ACT_SCRIPT_CUSTOM_ATTACK2", 0.2, 0.2, -1.0 )
		}
		else if ( owner.IsNPC() )
		{
			string anim = "ACT_RANGE_ATTACK1_SINGLE"
			if ( owner.IsCrouching() )
				anim = "ACT_RANGE_ATTACK1_LOW_SINGLE"
			owner.Anim_ScriptedPlayActivityByName( anim, true, 0.0 )
		}
#endif
		bool magDump = Roguelike_HasMod( owner, "mag_dump" )
		if ( hasCloseRangePowerShot )
		{
			if ( owner.IsPlayer() )
				weapon.EmitWeaponSound_1p3p( "Weapon_Predator_Powershot_ShortRange_1P", "Weapon_Predator_Powershot_ShortRange_3P" )
			else
				EmitSoundAtPosition( TEAM_UNASSIGNED, attackParams.pos, "Weapon_Predator_Powershot_ShortRange_3P" )

			int damageType
			if ( weapon.HasMod( "fd_CloseRangePowerShot" ) )
				damageType = DF_GIB | DF_EXPLOSION | DF_KNOCK_BACK | DF_SKIPS_DOOMED_STATE
			else
				damageType = DF_GIB | DF_EXPLOSION | DF_KNOCK_BACK

			float bonusDamage = 1.0

			#if SERVER
			weapon.e.windPushEnabled = true
			#endif
			ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 16, damageType, 1.0, 10.0 )

			PowerShotCleanup( owner, weapon, ["CloseRangePowerShot","fd_CloseRangePowerShot","pas_CloseRangePowerShot"] , [] )

			#if SERVER
			if (owner.IsPlayer() && Roguelike_HasMod( owner, "power_back" ) && weapon.e.windPushEnabled)
			{
				owner.SetVelocity( owner.GetVelocity() - AnglesToForward(FlattenAngles(owner.EyeAngles())) * 800 )
				entity powerShot = Roguelike_GetOffhandWeaponByName( owner, "mp_titanability_power_shot" )
				printt(powerShot)
				if (IsValid(powerShot))
					RestoreCooldown( powerShot, 0.5 )
			}
			#endif

			return magDump ? weapon.GetWeaponPrimaryClipCount() / 2 : 1
		}
		else
		{
			if ( owner.IsPlayer() )
				weapon.EmitWeaponSound_1p3p( "Weapon_Predator_Powershot_LongRange_1P", "Weapon_Predator_Powershot_LongRange_3P" )
			else
				EmitSoundAtPosition( TEAM_UNASSIGNED, attackParams.pos, "Weapon_Predator_Powershot_LongRange_3P" )

			entity bolt
			#if CLIENT
			if ( weapon.ShouldPredictProjectiles() )
			#endif
			bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, 10000, damageTypes.gibBullet | DF_IMPACT | DF_EXPLOSION , DF_EXPLOSION | DF_RAGDOLL , PROJECTILE_NOT_PREDICTED, 0 )
			if ( bolt )
			{
				bolt.s.bullets <- weapon.GetWeaponPrimaryClipCount()
				bolt.kv.gravity = -0.1
				#if SERVER
				bolt.e.onlyDamageEntitiesOnce = true
				#endif
			}
		}

		PowerShotCleanup( owner, weapon, ["LongRangePowerShot","fd_LongRangePowerShot","pas_LongRangePowerShot"], [ "LongRangeAmmo" ] )

		return magDump ? weapon.GetWeaponPrimaryClipCount() / 2 : 1
	}
	else
	{
		return FireWeaponPlayerAndNPC( weapon, attackParams, true )
	}
}

#if SERVER
void function OnWeaponNpcPreAttack_titanweapon_predator_cannon( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	thread PredatorSpinup( weaponOwner, weapon )
}

void function PredatorSpinup( entity weaponOwner, entity weapon )
{
	if ( !IsAlive( weaponOwner ) )
		return

	weapon.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( weaponOwner, "Weapon_Predator_MotorLoop_3P" )
	EmitSoundOnEntity( weaponOwner, "Weapon_Predator_Windup_3P" )

	float npc_pre_fire_delay = expect float( weapon.GetWeaponInfoFileKeyField( "npc_pre_fire_delay" ) )

	OnThreadEnd(
		function() : ( weapon, weaponOwner )
		{
			if ( IsValid( weaponOwner ) )
			{
				// foreach ( elem in weaponOwner.e.fxArray )
				// {
				// 	if ( IsValid( elem ) )
				// 		elem.Destroy()
				// }
				// weaponOwner.e.fxArray = []

				StopSoundOnEntity( weaponOwner, "Weapon_Predator_Windup_3P" )
				StopSoundOnEntity( weaponOwner, "Weapon_Predator_MotorLoop_3P" )
			}
		}
	)

	wait npc_pre_fire_delay

	// weaponOwner.e.fxArray.append( PlayLoopFXOnEntity( $"P_wpn_lasercannon_aim_short", weaponOwner, "PROPGUN", null, null, ENTITY_VISIBLE_TO_EVERYONE ) )

	float npc_pre_fire_delay_interval = expect float( weapon.GetWeaponInfoFileKeyField( "npc_pre_fire_delay_interval" ) )

	wait npc_pre_fire_delay_interval
}

var function OnWeaponNpcPrimaryAttack_titanweapon_predator_cannon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnWeaponPrimaryAttack_titanweapon_predator_cannon( weapon, attackParams )
}
#endif

int function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	int damageType = DF_BULLET | DF_STOPS_TITAN_REGEN | DF_GIB
	if ( weapon.HasMod( "Smart_Core" ) )
	{
		return SmartAmmo_FireWeapon( weapon, attackParams, damageType, damageTypes.largeCaliber | DF_STOPS_TITAN_REGEN )
	}
	else
	{
		if (!weapon.HasMod("LongRangeAmmo") && weapon.GetAmmoPerShot() >= 6) // shotgun_mode
		{
			int damageType = DF_BULLET | DF_STOPS_TITAN_REGEN
			weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 4, damageType )
		}
		else
			weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )
		return weapon.GetAmmoPerShot()
	}
	unreachable
}

bool function IsPredatorCannonActive( entity owner, bool reqZoom = true )
{
	if ( !owner.IsNPC() )
	{
		if ( reqZoom && owner.GetZoomFrac() != 1.0 )
			return false

		if ( owner.GetViewModelEntity().GetModelName() != $"models/weapons/titan_predator/atpov_titan_predator.mdl" )
			return false

		if ( owner.PlayerMelee_IsAttackActive() )
			return false
	}
	else
	{
		return owner.GetActiveWeapon().GetWeaponClassName() == "mp_titanweapon_predator_cannon"
	}

	return true
}

#if SERVER
void function PredatorCannon_DamagedTarget( entity target, var damageInfo )
{
	if ( !IsValid( target ) )
		return

	if ( !target.IsTitan() )
		return

	if ( !( DamageInfo_GetCustomDamageType( damageInfo ) & DF_SKIPS_DOOMED_STATE ) )
		return

	if ( GetDoomedState( target ) )
		DamageInfo_SetDamage( damageInfo, target.GetHealth() + 1 )
}

void function Roguelike_PredatorCannon_DamagedTarget( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	if ( !attacker.IsPlayer() )
		return

	if ( Roguelike_HasMod( attacker, "consumption" )  )
		DamageInfo_AddDamageBonus( damageInfo, 0.25 )

	bool isPowerShot
	array<string> mods
	int bullets = 0
	if (IsValid(weapon))
	{
		mods = weapon.GetMods()
		bullets = weapon.GetWeaponPrimaryClipCount()
	}
	if (IsValid(inflictor) && inflictor.IsProjectile())
	{
		mods = inflictor.ProjectileGetMods()
		if ("bullets" in inflictor.s)
			bullets = expect int(inflictor.s.bullets)
	}
	isPowerShot = mods.contains("LongRangePowerShot") || mods.contains("CloseRangePowerShot")
	if (mods.contains("CloseRangePowerShot") && IsValid(weapon))
	{
		weapon.e.windPushEnabled = false
	}
	if (Roguelike_HasMod( attacker, "mag_dump") && isPowerShot)
	{
		DamageInfo_AddDamageBonus( damageInfo, 0.2 + 0.003 * bullets )
	}
}

bool function IsDamageSourcePowerShot( var damageInfo )
{
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if (damageSourceId != eDamageSourceId.mp_titanweapon_predator_cannon)
		return false

	entity weapon = DamageInfo_GetWeapon( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	
	bool isPowerShot
	array<string> mods
	int bullets = 0
	if (IsValid(weapon))
	{
		mods = weapon.GetMods()
	}
	if (IsValid(inflictor) && inflictor.IsProjectile())
	{
		mods = inflictor.ProjectileGetMods()
	}
	return mods.contains("LongRangePowerShot") || mods.contains("CloseRangePowerShot")
}
#endif