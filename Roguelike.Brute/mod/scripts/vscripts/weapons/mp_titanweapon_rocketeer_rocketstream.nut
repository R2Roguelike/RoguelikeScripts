untyped

global function MpTitanweaponRocketeetRocketStream_Init

global function OnWeaponPrimaryAttack_TitanWeapon_Rocketeer_RocketStream
global function OnWeaponOwnerChanged_TitanWeapon_Rocketeer_RocketStream
global function OnWeaponDeactivate_TitanWeapon_Rocketeer_RocketStream

global function OnWeaponStartZoomIn_TitanWeapon_Rocketeer_RocketStream
global function OnWeaponStartZoomOut_TitanWeapon_Rocketeer_RocketStream

#if SERVER
global function OnWeaponNpcPrimaryAttack_TitanWeapon_Rocketeer_RocketStream
#endif // #if SERVER

#if CLIENT
global function OnClientAnimEvent_TitanWeapon_Rocketeer_RocketStream
#endif // #if CLIENT


const DRAW_DEBUG = 0
const DEBUG_FAIL = 0
const MERGEDEBUG = 0
const DEBUG_TIME = 5
const MIN_HEIGHT = 70
const POINT_FROM = 0
const POINT_TO = 1
const POINT_NEXT = 2
const POINT_FUTURE = 3
const TRACE_DIST_PER_SECTION = 800
const WALL_BUFFER = 74
const STEEPNESS_DOT = 0.6
const MISSILE_LOOKAHEAD = 150 // 150
const MATCHSLOPERISE = 40 // 32
const MISSILE_LIFETIME = 8.0
const FUDGEPOINT_RIGHT = 100
const FUDGEPOINT_UP = 150
const PROX_MISSILE_RANGE = 160
const BURN_CLUSTER_EXPLOSION_INNER_RADIUS = 150
const BURN_CLUSTER_EXPLOSION_RADIUS = 220
const BURN_CLUSTER_EXPLOSION_DAMAGE = 66
const BURN_CLUSTER_EXPLOSION_DAMAGE_HEAVY_ARMOR = 100
const BURN_CLUSTER_NPC_EXPLOSION_DAMAGE = 66
const BURN_CLUSTER_NPC_EXPLOSION_DAMAGE_HEAVY_ARMOR = 100

const asset AMPED_SHOT_PROJECTILE = $"models/weapons/bullets/temp_triple_threat_projectile_large.mdl"


function MpTitanweaponRocketeetRocketStream_Init()
{
	RegisterSignal( "FiredWeapon" )

	PrecacheParticleSystem( $"wpn_muzzleflash_xo_rocket_FP" )
	PrecacheParticleSystem( $"wpn_muzzleflash_xo_rocket" )
	PrecacheParticleSystem( $"wpn_muzzleflash_xo_fp" )
	PrecacheParticleSystem( $"P_muzzleflash_xo_mortar" )

    AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_OVERRIDE, QuadRocket_ApplyModWeaponVars )

#if SERVER
	PrecacheModel( AMPED_SHOT_PROJECTILE )
#endif // #if SERVER
}

void function QuadRocket_ApplyModWeaponVars( entity weapon )
{
	if (weapon.GetWeaponClassName() != "mp_titanweapon_rocketeer_rocketstream")
		return
	entity owner = weapon.GetWeaponOwner()
	if (!IsValid(owner) || !owner.IsPlayer())
		return

	int ammo_per_shot = weapon.GetAmmoPerShot()
}


void function OnWeaponStartZoomIn_TitanWeapon_Rocketeer_RocketStream( entity weapon )
{
#if SERVER
#else
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner == GetLocalViewPlayer() )
		EmitSoundOnEntity( weaponOwner, "Weapon_Particle_Accelerator_WindUp_1P" )
#endif
	//weapon.PlayWeaponEffectNoCull( $"wpn_arc_cannon_electricity_fp", $"wpn_arc_cannon_electricity", "muzzle_flash" )
	//weapon.PlayWeaponEffectNoCull( $"wpn_arc_cannon_charge_fp", $"wpn_arc_cannon_charge", "muzzle_flash" )
	//weapon.EmitWeaponSound( "arc_cannon_charged_loop" )
}

void function OnWeaponStartZoomOut_TitanWeapon_Rocketeer_RocketStream( entity weapon )
{
	//weapon.StopWeaponEffect( $"wpn_arc_cannon_charge_fp", $"wpn_arc_cannon_charge" )
	//weapon.StopWeaponEffect( $"wpn_arc_cannon_electricity_fp", $"wpn_arc_cannon_electricity" )
	//weapon.StopWeaponSound( "arc_cannon_charged_loop" )
}


#if CLIENT
void function OnClientAnimEvent_TitanWeapon_Rocketeer_RocketStream( entity weapon, string name )
{
	if ( name == "muzzle_flash" )
	{
		weapon.PlayWeaponEffect( $"wpn_muzzleflash_xo_fp", $"wpn_muzzleflash_xo_rocket", "muzzle_flash" )
	}
}
#endif // #if CLIENT

var function OnWeaponPrimaryAttack_TitanWeapon_Rocketeer_RocketStream( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return 1
	#endif

	return FireMissileStream( weapon, attackParams, PROJECTILE_PREDICTED )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_TitanWeapon_Rocketeer_RocketStream( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireMissileStream( weapon, attackParams, PROJECTILE_NOT_PREDICTED )
}
#endif // #if SERVER

int function FireMissileStream( entity weapon, WeaponPrimaryAttackParams attackParams, bool predicted )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	if ( weapon.IsWeaponAdsButtonPressed() )
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Rocket_Launcher_Amped_Fire_1P", "Weapon_Titan_Rocket_Launcher_Amped_Fire_3P" )
	else
		weapon.EmitWeaponSound_1p3p( "Weapon_Titan_Rocket_Launcher.RapidFire_1P", "Weapon_Titan_Rocket_Launcher.RapidFire_3P" )

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsValid( weaponOwner ) )
		return 0
	bool adsPressed = weapon.IsWeaponAdsButtonPressed()
	bool hasBurnMod = weapon.HasMod( "burn_mod_titan_rocket_launcher" )
	bool has_s2s_npcMod = weapon.HasMod( "sp_s2s_settings_npc" )
	bool has_mortar_mod = weapon.HasMod( "coop_mortar_titan" )
	if ( !adsPressed )
	{
		int shots = minint( 4, weapon.GetWeaponPrimaryClipCount() )
		if (Roguelike_HasMod(weaponOwner, "power_fire"))
		{
			shots = minint( 8, weapon.GetWeaponPrimaryClipCount() )
			int firstBurstShots = shots / 2
			vector right = AnglesToRight( VectorToAngles( attackParams.dir ) )
			attackParams.dir += right * 0.1
			FireMissileStream_Spiral( weapon, attackParams, predicted, firstBurstShots )
			attackParams.dir -= right * 0.2
			FireMissileStream_Spiral( weapon, attackParams, predicted, shots - firstBurstShots )
		}
		else
		{
			FireMissileStream_Spiral( weapon, attackParams, predicted, shots )
		}
		#if SERVER
		if (weapon.GetWeaponPrimaryClipCount() <= shots)
			RSE_Stop( weaponOwner, RoguelikeEffect.burst_load )
		#endif
		return shots
	}
	else
	{
		//attackParams.pos = attackParams.pos + Vector( 0, 0, -20 )
		// float missileSpeed = 2800
		int shots = minint( Roguelike_HasMod(weaponOwner, "power_fire") ? 2 : 1, weapon.GetWeaponPrimaryClipCount() )
		float missileSpeed = 10000
		if ( has_s2s_npcMod || has_mortar_mod )
			missileSpeed = 2500

		int impactFlags = (DF_IMPACT | DF_GIB | DF_KNOCK_BACK)
		int targets = 1
		if (weaponOwner.e.armedTargets.len() > 0 && Roguelike_HasMod(weaponOwner, "quad_inverted"))
		{
			targets = weaponOwner.e.armedTargets.len()
			missileSpeed = 5000
		}
		vector right = AnglesToRight( VectorToAngles( attackParams.dir ) )
		for (int targetIndex = 0; targetIndex < targets; targetIndex++)
		{
			for (int i = 0; i < shots; i++)
			{
				vector dir = attackParams.dir
				if (shots > 1 && i == 0)
					dir += right * 0.05
				if (shots > 1 && i == 1)
					dir -= right * 0.05
				entity missile = weapon.FireWeaponMissile( attackParams.pos, dir, missileSpeed, impactFlags, damageTypes.explosive | DF_KNOCK_BACK, false, predicted )

				if ( missile )
				{
					SetTeam( missile, weaponOwner.GetTeam() )
		#if SERVER
					if (weaponOwner.e.armedTargets.len() > 0 && Roguelike_HasMod(weaponOwner, "quad_inverted"))
					{
						entity target = weaponOwner.e.armedTargets[targetIndex]
						missile.SetMissileTarget( target, <0,0,0> )
						missile.SetHomingSpeeds(1200,1200) // holy shit
					}
					string whizBySound = "Weapon_Sidwinder_Projectile"
					EmitSoundOnEntity( missile, whizBySound )
					if ( weapon.w.missileFiredCallback != null )
					{
						weapon.w.missileFiredCallback( missile, weaponOwner )
					}
		#endif // #if SERVER
				}
			}
		}

		#if SERVER
		if (weapon.GetWeaponPrimaryClipCount() <= shots)
			RSE_Stop( weaponOwner, RoguelikeEffect.burst_load )
		#endif
		return shots
	}

	unreachable
}


int function FindIdealMissileConfiguration( int numMissiles, int i )
{
	//We're locked into 4 missiles from passing in 0-3, and in the case of 2 we want to fire the horizontal missiles for aesthetic reasons.
	int idealMissile
	if ( numMissiles == 2 )
	{
		if ( i == 0 )
			idealMissile = 1
		else
			idealMissile = 3
	}
	else
	{
		idealMissile = i
	}

	return idealMissile
}

void function FireMissileStream_Spiral( entity weapon, WeaponPrimaryAttackParams attackParams, bool predicted, int numMissiles = 4 )
{
	//attackParams.pos = attackParams.pos + Vector( 0, 0, -20 )
	array<entity> missiles
	float missileSpeed = 1200

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( IsSingleplayer() && weaponOwner.IsPlayer() )
		missileSpeed = 2500

	int targets = 1
	if (weaponOwner.e.armedTargets.len() > 1 && !Roguelike_HasMod(weaponOwner, "quad_inverted"))
		targets = weaponOwner.e.armedTargets.len()
	for (int targetIndex = 0; targetIndex < maxint(1, weaponOwner.e.armedTargets.len()); targetIndex++)
	{
		for ( int i = 0; i < numMissiles; i++ )
		{
			int impactFlags = (DF_IMPACT | DF_GIB | DF_KNOCK_BACK)

			entity missile = weapon.FireWeaponMissile( attackParams.pos, attackParams.dir, missileSpeed, impactFlags, damageTypes.explosive | DF_KNOCK_BACK, false, predicted )
			if ( missile )
			{
				//Spreading out the missiles
				int missileNumber = FindIdealMissileConfiguration( numMissiles, i )
				

				if (weaponOwner.e.armedTargets.len() > 0 && !Roguelike_HasMod(weaponOwner, "quad_inverted"))
				{
					entity target = weaponOwner.e.armedTargets[targetIndex]
					missile.SetMissileTarget( target, <0,0,0> )
					missile.SetHomingSpeeds(200,200)
				}
				else
					missile.InitMissileSpiral( attackParams.pos, attackParams.dir, missileNumber, false, false )

				//missile.s.launchTime <- Time()
				// each missile knows about the other missiles, so they can all blow up together
				//missile.e.projectileGroup = missiles
				missile.kv.lifetime = MISSILE_LIFETIME
				missile.SetSpeed( missileSpeed );
				SetTeam( missile, weapon.GetWeaponOwner().GetTeam() )

				missiles.append( missile )

	#if SERVER
				EmitSoundOnEntity( missile, "Weapon_Sidwinder_Projectile" )
	#endif // #if SERVER
			}
		}
	}
}

void function OnWeaponOwnerChanged_TitanWeapon_Rocketeer_RocketStream( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if SERVER
	weapon.w.missileFiredCallback = null
	#endif
}

void function OnWeaponDeactivate_TitanWeapon_Rocketeer_RocketStream( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()

	if (!IsValid(owner) || !owner.IsPlayer())
		return
	#if CLIENT
	if (owner != GetLocalClientPlayer())
		return
	#endif
	if (!IsValid(owner.GetOffhandWeapon(1)))
		return
	if (owner.GetOffhandWeapon(1).GetWeaponChargeFraction() > 0.0)
	{
		print("shit!")
		owner.GetOffhandWeapon(1).SetWeaponChargeFraction(1.0) // : )
		owner.GetOffhandWeapon(1).SetWeaponChargeFractionForced(1.0) // : )
	}
}