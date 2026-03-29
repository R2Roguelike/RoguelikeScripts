untyped

global function OnWeaponPrimaryAttack_titanweapon_tracker_rockets
global function OnWeaponAttemptOffhandSwitch_titanweapon_tracker_rockets
global function OnWeaponActivate_titanweapon_tracker_rockets
global function MpTitanWeaponTrackerRockets_Init

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanweapon_tracker_rockets
global function AutoFireMissiles
#endif

#if CLIENT
struct
{
	float lastFireFailedTime = 0.0
	float fireFailedDebounceTime = 0.25
} file
#endif

void function MpTitanWeaponTrackerRockets_Init()
{
	RegisterSignal("HackEnd")
	#if CLIENT
	AddCallback_PlayerClassChanged( TrackerRockets_OnPlayerClassChanged )
	#endif
	#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_tracker_rockets, TrackerRocketsDamage )
	AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_salvo_core, SalvoCoreDamage )
	#endif
}

#if SERVER
void function TrackerRocketsDamage( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo)
	entity weapon = DamageInfo_GetWeapon( damageInfo )

	if ((DamageInfo_GetDamageFlags( damageInfo ) & DAMAGEFLAG_CLONE) != 0)
	{
		DamageInfo_ScaleDamage( damageInfo, 0.3 )
	}
	if (IsValid(weapon)) // was hitscan, basically
	{
		if ("hack" in weapon.s)
		{
			thread ToneHack( ent, DamageInfo_GetAttacker( damageInfo ) )
		}
	}
}

void function SalvoCoreDamage( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo)
	entity weapon = DamageInfo_GetWeapon( damageInfo )

	if (Roguelike_HasMod( attacker, "salvo_locks" ))
		ApplyTrackerMark( attacker, ent, true )
}

void function ToneHack( entity target, entity player )
{
	player.EndSignal( "HackEnd" )
	target.EndSignal( "OnDeath" )
	target.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	int oldTeam = target.GetTeam()

	float duration = 15.0
	duration *= 1.0 + Roguelike_GetStat( player, "ability_duration" )

	if (!target.IsTitan())
		return

	// no hacking bosses :)
	if (IsMercTitan( target ))
		return

	SetTeam( target, player.GetTeam() )
	target.e.hacker = player
	player.e.hackedTargets.append(target)
	RSE_Apply( target, RoguelikeEffect.tone_expose, 1.0, duration, duration )

	OnThreadEnd( void function() : (target, oldTeam, player)
	{
		if (IsValid(player))
		{
			player.e.hackedTargets.fastremovebyvalue(target)
		}
		if (IsValid(target))
		{
			RSE_Stop( target, RoguelikeEffect.tone_expose )
			SetTeam(target, oldTeam)
			target.e.hacker = null
		}
	})


	wait duration
}
#endif

void function OnWeaponActivate_titanweapon_tracker_rockets( entity weapon )
{
	if ( !( "initialized" in weapon.s ) )
	{
		SmartAmmo_SetMissileSpeed( weapon, 1800.0 )
		SmartAmmo_SetMissileHomingSpeed( weapon, 200 )
		SmartAmmo_SetUnlockAfterBurst( weapon, false )
		SmartAmmo_SetAllowUnlockedFiring( weapon, true )
		//weapon.s.missileThinkThread <- MissileThink
		weapon.s.initialized <- true
	}
}

var function OnWeaponPrimaryAttack_titanweapon_tracker_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool shouldPredict = weapon.ShouldPredictProjectiles()
	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif

	if (owner.IsPlayer())
	{
		PlayerUsedOffhand( owner, weapon )
		weapon.s.hack <- true
		weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, weapon.GetWeaponDamageFlags() )
		weapon.SetWeaponBurstFireCount(1)
		delete weapon.s.hack
		return 200
	}

	int smartAmmoFired = SmartAmmo_FireWeapon( weapon, attackParams, damageTypes.projectileImpact, damageTypes.explosive )
	int maxTargetedBurst = weapon.GetWeaponSettingInt( eWeaponVar.smart_ammo_max_targeted_burst )
	float shotFrac = 1.0 / maxTargetedBurst.tofloat()

	if ( smartAmmoFired == 0 )
	{
		return 0
	}
	else
	{
		weapon.SetWeaponChargeFractionForced( weapon.GetWeaponChargeFraction() + shotFrac )
	}

	if ( weapon.SmartAmmo_IsEnabled() )
	{
		var allTargets = weapon.SmartAmmo_GetTargets()
		foreach ( target in allTargets )
		{
			if ( SmartAmmo_EntHasEnoughTrackedMarks( weapon, expect entity( target.ent ) ) )
			{
				#if SERVER
					if (target.ent.IsPlayer() && target.ent in weapon.w.targetLockEntityStatusEffectID)
					{
						int statusID = weapon.w.targetLockEntityStatusEffectID[expect entity(target.ent)]
						thread DelayedDisableToneLockOnNotification( expect entity(target.ent), statusID )
					}

					owner.Signal("TrackerRocketsFired")
				#endif
			}
		}
	}

	if ( weapon.GetBurstFireShotsPending() == 1 )
	{
		if ( owner.IsPlayer() )
			PlayerUsedOffhand( owner, weapon )
	}
	return 1
}

function MissileThink( weapon, missile )
{
	expect entity( missile )
	#if SERVER
		missile.EndSignal( "OnDestroy" )
		entity missileTarget = missile.GetMissileTarget()
		if ( IsValid( missileTarget ) )
		{
			float initialHomingSpeed = GraphCapped( Distance( missile.GetOrigin(), missileTarget.GetOrigin() ), 400, 1800, 200, 100 )
			missile.SetHomingSpeeds( initialHomingSpeed, initialHomingSpeed )
		}

		while ( IsValid( missile ) )
		{
			wait 0.2
			float homingSpeed = min( missile.GetHomingSpeed() + 15, 200.0 )
			missile.SetHomingSpeeds( homingSpeed, homingSpeed )
		}

	#endif
}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_tracker_rockets( entity weapon )
{
	if (weapon.GetWeaponOwner().IsPlayer())
		return true
	var allTargets = []
	if ( weapon.SmartAmmo_IsEnabled() )
	{
		allTargets = weapon.SmartAmmo_GetTargets()
	}

	foreach ( target in allTargets )
	{
		if ( SmartAmmo_EntHasEnoughTrackedMarks( weapon, expect entity( target.ent ) ) )
			return true
	}

	#if CLIENT
	float currentTime = Time()
	if ( currentTime - file.lastFireFailedTime > file.fireFailedDebounceTime && !weapon.IsBurstFireInProgress() )
	{
		file.lastFireFailedTime = currentTime
		EmitSoundOnEntity( weapon, "UI_MapPing_Fail" )
		AddPlayerHint( 1.0, 0.25, $"rui/hud/tone_tracker_hud/tone_tracker_3marks", "#WPN_TITAN_TRACKER_ROCKETS_ERROR_HINT" )
	}
	#endif

	return false
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanweapon_tracker_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanweapon_tracker_rockets( weapon, attackParams )
}
#endif

#if CLIENT
void function TrackerRockets_OnPlayerClassChanged( entity player )
{
	HidePlayerHint( "#WPN_TITAN_TRACKER_ROCKETS_ERROR_HINT" )
}
#endif

//This function checks the player being targeted and removes the lockon status effect IF there are no more lock ons
void function DelayedDisableToneLockOnNotification(entity target, int statusID)
{
	//Wait 1 because it feels better to have a little delay between the weapon firing and the target lockon HUD status clearing
	wait 1

	#if SERVER
		if( IsValid( target ))
			StatusEffect_Stop( target, statusID )
	#endif

}
#if SERVER
void function AutoFireMissiles( entity ordnance, entity target, entity owner, bool delockAfterUse = true, bool reducedCooldown = false )
{
	owner.EndSignal("OnDestroy")
	target.EndSignal("OnDestroy")
	EmitSoundOnEntityOnlyToPlayer( owner, owner, "weapon_trackingrockets_fire_1p" )

	int rocketCount = 5 + Roguelike_GetTagCount( owner, TONE_BENEFIT_1 )

	if (Roguelike_HasMod( owner, "barrage_cd" ))
	{
		entity sonar = Roguelike_FindWeapon( owner, "mp_titanability_sonar_pulse" )
		if (IsValid(sonar))
		{
			int ammo = sonar.GetWeaponPrimaryClipCount()
			int maxAmmo = sonar.GetWeaponPrimaryClipCountMax()
			sonar.SetWeaponPrimaryClipCount( minint(int(sonar.GetWeaponSettingFloat(eWeaponVar.regen_ammo_refill_rate)) + ammo, maxAmmo) )
		}
	}

	float duration = 1.5

	thread void function() : (rocketCount, ordnance, owner, target)
	{
		for (int i = 0; i < rocketCount; i++)
		{
			{
				entity missile = ordnance.FireWeaponMissile( owner.EyePosition(), <0,0,1>, 1800.0, ordnance.GetWeaponDamageFlags(), ordnance.GetWeaponDamageFlags(), false, false )
				if (missile != null)
				{
					missile.InitMissileForRandomDriftFromWeaponSettings(owner.EyePosition(), <0,0,1>)
					missile.SetSpeed(SmartAmmo_GetMissileSpeed(ordnance))
					missile.SetHomingSpeeds(500, 500)
					missile.SetMissileTarget( target, <0,0,0> )
				}
			}
			if (Roguelike_HasMod( owner, "dual_fire" ))
			{
				foreach (entity hackedTitan in owner.e.hackedTargets)
				{
					entity missile = ordnance.FireWeaponMissile( owner.EyePosition(), <0,0,1>, 1800.0, ordnance.GetWeaponDamageFlags(), ordnance.GetWeaponDamageFlags(), false, false )
					if (missile != null)
					{
						missile.InitMissileForRandomDriftFromWeaponSettings(owner.EyePosition(), <0,0,1>)
						missile.SetSpeed(SmartAmmo_GetMissileSpeed(ordnance))
						missile.SetHomingSpeeds(500, 500)
						missile.SetOrigin(hackedTitan.GetOrigin() + <0,0,hackedTitan.GetBoundingMaxs().z>)
						missile.SetMissileTarget( target, <0,0,0> )
						missile.SetOwner( hackedTitan )
					}
				}
			}
			wait 0.046
		}
	}()

	duration *= Roguelike_GetStat( owner, "cd_reduction" )

	duration -= 0.2 * Roguelike_GetTagCount( owner, TONE_BENEFIT_2 )

	duration -= 0.01

	if (!reducedCooldown)
		RSE_Apply( target, RoguelikeEffect.tone_tracker_cooldown, 1.0, duration, duration )

	if (duration > 0 && !reducedCooldown)
		wait duration - 0.05
	
	if (delockAfterUse && IsValid(target) && IsAlive(target) && IsValid(ordnance))
		ordnance.SmartAmmo_UntrackEntity( target )
}
#endif