untyped
global function OnWeaponPrimaryAttack_gun_shield
global function MpTitanAbilityGunShield_Init

#if SERVER
global function OnWeaponNpcPrimaryAttack_gun_shield
global function IsGunShieldActive
#else
global function ServerCallback_PilotCreatedGunShield
#endif

const FX_TITAN_GUN_SHIELD_VM = $"P_titan_gun_shield_FP"
const FX_TITAN_GUN_SHIELD_WALL = $"P_titan_gun_shield_3P"
const FX_TITAN_GUN_SHIELD_BREAK = $"P_xo_armor_break_CP"
global const float TITAN_GUN_SHIELD_RADIUS = 105
global const int TITAN_GUN_SHIELD_HEALTH = 2500
global const int PAS_LEGION_SHEILD_HEALTH = 5000

#if CLIENT
struct
{
	int sphereClientFXHandle = -1
} file
#endif

void function MpTitanAbilityGunShield_Init()
{
	PrecacheParticleSystem( FX_TITAN_GUN_SHIELD_WALL )
	PrecacheParticleSystem( FX_TITAN_GUN_SHIELD_VM )
	PrecacheParticleSystem( FX_TITAN_GUN_SHIELD_BREAK )
	RegisterSignal( "GunShieldEnd" )
}

var function OnWeaponPrimaryAttack_gun_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	Assert( IsValid( weaponOwner ), "weapon owner is not valid at the start of on weapon primary attack" )
	Assert( IsAlive( weaponOwner ), "weapon owner is not alive at the start of on weapon primary attack" )
	array<entity> weapons = GetPrimaryWeapons( weaponOwner )
	Assert( weapons.len() > 0 )
	if ( weapons.len() == 0 )
		return 0

	// ROGUELIKE - fix for power shot using the first primary and not the current
	// ALSO - check if primary is pred cannon
	entity primaryWeapon = weaponOwner.GetActiveWeapon()
	if ( !IsValid( primaryWeapon ) || primaryWeapon.GetWeaponClassName() != "mp_titanweapon_predator_cannon" )
		return 0

	if ( weaponOwner.ContextAction_IsActive() )
		return 0

	float duration = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )
	thread GunShieldThink( primaryWeapon, weapon, weaponOwner, duration )
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function GunShieldThink( entity weapon, entity shieldWeapon, entity owner, float duration )
{
	weapon.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "DisembarkingTitan" )
	owner.EndSignal( "TitanEjectionStarted" )
	owner.EndSignal( "SettingsChanged")

	weapon.e.gunShieldActive = true
	//weapon.SetForcedADS()
	//if ( owner.IsPlayer() )
	//	owner.SetMeleeDisabled()

	OnThreadEnd(
	function() : ( weapon, owner )
		{
			if ( IsValid( weapon ) )
			{
				weapon.e.gunShieldActive = false
				if ( !weapon.HasMod( "LongRangePowerShot" ) && !weapon.HasMod( "CloseRangePowerShot" ) && !weapon.HasMod( "SiegeMode" ) )
				{
					while( weapon.GetForcedADS() )
						weapon.ClearForcedADS()
				}
				weapon.StopWeaponEffect( FX_TITAN_GUN_SHIELD_VM, FX_TITAN_GUN_SHIELD_WALL )
			}
			if ( IsValid( owner ) )
			{
				//if ( owner.IsPlayer() )
				//	owner.ClearMeleeDisabled()
				owner.Signal( "GunShieldEnd" )
			}
		}
	)

	while( !weapon.IsReloading() && !CanUseGunShield( owner, true ) )
	{
		wait 0.1
	}

	#if SERVER
		thread Sv_CreateGunShield( owner, weapon, shieldWeapon, duration )
	#endif

	if ( duration > 0 )
		wait duration
	else
		WaitForever()
}

bool function CanUseGunShield( entity owner, bool reqZoom = true )
{
	if ( !owner.IsNPC() )
	{
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
var function OnWeaponNpcPrimaryAttack_gun_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnWeaponPrimaryAttack_gun_shield( weapon, attackParams )
}
#endif

#if SERVER
bool function IsGunShieldActive( entity titan )
{
	return "gunShieldActive" in titan.s
}
void function Sv_CreateGunShield( entity titan, entity weapon, entity shieldWeapon, float duration )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "DisembarkingTitan" )
	titan.EndSignal( "TitanEjectionStarted" )
	titan.EndSignal( "ContextAction_SetBusy" )
	//titan.EndSignal( "LoadoutSwap" )

	entity vortexWeapon = weapon
	entity vortexSphere = CreateGunShieldVortexSphere( titan, vortexWeapon, shieldWeapon )
	int weaponEHandle = vortexWeapon.GetEncodedEHandle()
	int shieldEHandle = vortexSphere.GetEncodedEHandle()
	entity shieldWallFX = vortexSphere.e.shieldWallFX

	vortexSphere.EndSignal( "OnDestroy" )

	if ( titan.IsPlayer() )
	{
		Remote_CallFunction_Replay( titan, "ServerCallback_PilotCreatedGunShield", weaponEHandle, shieldEHandle )
		EmitSoundOnEntityOnlyToPlayer( vortexWeapon, titan, "weapon_predator_mountedshield_start_1p" )
		EmitSoundOnEntityExceptToPlayer( vortexWeapon, titan, "weapon_predator_mountedshield_start_3p" )
	}
	else
	{
		EmitSoundOnEntity( vortexWeapon, "weapon_predator_mountedshield_start_3p" )
	}

	OnThreadEnd(
		function() : ( titan, vortexSphere, vortexWeapon, shieldWallFX )
		{
			if ( IsValid( vortexWeapon ) )
			{
				StopSoundOnEntity( vortexWeapon, "weapon_predator_mountedshield_start_1p" )
				StopSoundOnEntity( vortexWeapon, "weapon_predator_mountedshield_start_3p" )
				if ( IsValid( titan ) && titan.IsPlayer() )
				{
					EmitSoundOnEntityOnlyToPlayer( vortexWeapon, titan, "weapon_predator_mountedshield_stop_1p" )
					EmitSoundOnEntityExceptToPlayer( vortexWeapon, titan, "weapon_predator_mountedshield_stop_3p" )
				}
				else
				{
					EmitSoundOnEntity( vortexWeapon, "weapon_predator_mountedshield_stop_3p" )
				}
				vortexWeapon.SetWeaponUtilityEntity( null )
			}

			delete titan.s.gunShieldActive

			if ( IsValid( shieldWallFX ) )
				EffectStop( shieldWallFX )

			if ( IsValid( vortexSphere ) )
			{
				vortexSphere.Destroy()
			}
			else if ( IsValid( titan ) )
			{
				EmitSoundOnEntity( titan, "titan_energyshield_down" )
				PlayFXOnEntity( FX_TITAN_GUN_SHIELD_BREAK, titan, "PROPGUN" )
				if (Roguelike_HasMod( titan, "power_shield" ))
				{
					printt("shield destroyed!")
					entity primary = Roguelike_FindWeapon( titan, "mp_titanweapon_predator_cannon" )
					primary.SetWeaponPrimaryClipCount(primary.GetWeaponPrimaryClipCountMax())
					entity offensive = Roguelike_FindWeapon( titan, "mp_titanability_power_shot" )
					if (IsValid(offensive))
					{
						offensive.SetWeaponPrimaryClipCount( offensive.GetWeaponPrimaryClipCountMax() )
					}

				}
			}
		}
	)

	titan.s.gunShieldActive <- true

	if ( duration > 0 )
		wait duration
	else
		WaitForever()
}

entity function CreateGunShieldVortexSphere( entity player, entity vortexWeapon, entity shieldWeapon )
{
	int attachmentID = vortexWeapon.LookupAttachment( "gun_shield" )
	float sphereRadius = TITAN_GUN_SHIELD_RADIUS
	entity vortexSphere = CreateEntity( "vortex_sphere" )
	Assert( vortexSphere )

	SetTargetName( vortexSphere, GUN_SHIELD_WALL )

//	if ( 0 )
//	{
		vortexSphere.kv.spawnflags = SF_ABSORB_BULLETS
		vortexSphere.kv.height = TITAN_GUN_SHIELD_RADIUS * 2
		vortexSphere.kv.radius = TITAN_GUN_SHIELD_RADIUS
//	}
//	else
//	{
//		vortexSphere.kv.spawnflags = SF_ABSORB_CYLINDER | SF_ABSORB_BULLETS
//		vortexSphere.kv.height = TITAN_GUN_SHIELD_RADIUS * 2
//		vortexSphere.kv.radius = TITAN_GUN_SHIELD_RADIUS
//	}

	vortexSphere.e.proto_weakToPilotWeapons = false
	vortexSphere.kv.enabled = 0
	vortexSphere.kv.bullet_fov = PLAYER_SHIELD_WALL_FOV
	vortexSphere.kv.physics_pull_strength = 25
	vortexSphere.kv.physics_side_dampening = 6
	vortexSphere.kv.physics_fov = 360
	vortexSphere.kv.physics_max_mass = 2
	vortexSphere.kv.physics_max_size = 6
	float health
	entity soul = player.GetTitanSoul()
	bool hasShieldUpgrade = IsValid( soul ) && SoulHasPassive( soul, ePassives.PAS_LEGION_GUNSHIELD ) || shieldWeapon.HasMod( "fd_gun_shield" )
	if ( hasShieldUpgrade )
		health = PAS_LEGION_SHEILD_HEALTH
	else
		health = TITAN_GUN_SHIELD_HEALTH
	vortexSphere.SetHealth( health )
	vortexSphere.SetMaxHealth( health )

	vortexSphere.SetTakeDamageType( DAMAGE_YES )

	if ( shieldWeapon.HasMod( "npc_infinite_shield" ) )
	{
		vortexSphere.SetInvulnerable()
		SetVortexSphereBulletHitRules( vortexSphere, GunShield_InvulBulletHitRules )
		SetVortexSphereProjectileHitRules( vortexSphere, GunShield_InvulProjectileHitRules )
	}

	DispatchSpawn( vortexSphere )

	vortexSphere.SetOwner( player )
	vortexSphere.SetOwnerWeapon( vortexWeapon )
	vortexSphere.SetParent( vortexWeapon, "gun_shield" )
	vortexWeapon.SetWeaponUtilityEntity( vortexSphere )

	EntFireByHandle( vortexSphere, "Enable", "", 0, null, null )

	// Shield wall fx control point
	entity cpoint = CreateEntity( "info_placement_helper" )
	SetTargetName( cpoint, UniqueString( "shield_wall_controlpoint" ) )
	DispatchSpawn( cpoint )

	vortexSphere.e.shieldWallFX = CreateEntity( "info_particle_system" )
	entity shieldWallFX = vortexSphere.e.shieldWallFX
	shieldWallFX.SetValueForEffectNameKey( FX_TITAN_GUN_SHIELD_WALL )
	shieldWallFX.kv.start_active = 1
	SetVortexSphereShieldWallCPoint( vortexSphere, cpoint )
	shieldWallFX.SetOwner( player )
	shieldWallFX.SetParent( player )
	shieldWallFX.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY) // not owner only
	shieldWallFX.kv.cpoint1 = cpoint.GetTargetName()
	shieldWallFX.SetStopType( "destroyImmediately" )
	shieldWallFX.DisableHibernation()
	shieldWallFX.SetLocalOrigin( < 0, 0, 0 > )

	vortexSphere.SetGunVortexAngles( < 0, 0, 180 > )
	vortexSphere.SetGunVortexAttachment( "gun_shield" )
	vortexSphere.SetVortexEffect( shieldWallFX)

	DispatchSpawn( shieldWallFX )

	if ( shieldWeapon.HasMod( "npc_infinite_shield" ) )
	{
		shieldWallFX.e.cpoint.SetOrigin( < 246.0, 134.0, 40.0 > ) // AMPED COLOR
	}
	else
	{
		thread UpdateGunShieldColor( vortexSphere )
	}

	return vortexSphere
}

void function UpdateGunShieldColor( entity vortexSphere )
{
	while ( IsValid( vortexSphere ) )
	{
		UpdateShieldWallColorForFrac( vortexSphere.e.shieldWallFX, GetHealthFrac( vortexSphere ) )
		WaitFrame()
	}
}

var function GunShield_InvulBulletHitRules( entity vortexSphere, var damageInfo )
{
	DamageInfo_SetDamage( damageInfo, 0 )
}

bool function GunShield_InvulProjectileHitRules( entity vortexSphere, entity attacker, bool takesDamageByDefault )
{
	return false
}
#endif

#if CLIENT
void function ServerCallback_PilotCreatedGunShield( int vortexWeaponEHandle, int vortexSphereEHandle )
{
	entity vortexWeapon = GetEntityFromEncodedEHandle( vortexWeaponEHandle )
	entity vortexSphere = GetEntityFromEncodedEHandle( vortexSphereEHandle )

	if ( !IsValid( vortexWeapon ) )
		return

	if ( !IsValid( vortexSphere ) )
		return

	entity player = vortexWeapon.GetWeaponOwner()

	if ( !IsAlive( player ) )
		return

	thread CL_GunShield_Internal( player, vortexWeapon, vortexSphere )
}

void function CL_GunShield_Internal( entity player, entity vortexWeapon, entity vortexSphere )
{
	vortexSphere.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "GunShieldEnd" )

	asset shieldFX = FX_TITAN_GUN_SHIELD_VM
	//file.sphereClientFXHandle = vortexWeapon.PlayWeaponEffectReturnViewEffectHandle( shieldFX, $"", "gun_shield_fp" )

	OnThreadEnd(
		function() : ()
		{
			if ( file.sphereClientFXHandle != -1 )
				EffectStop( file.sphereClientFXHandle, true, false )

			file.sphereClientFXHandle = -1
		}
	)

	bool weaponWasActive = false
	float oldHealth = float( vortexSphere.GetHealth() )
	while( true )
	{
		bool weaponIsActive = player.GetActiveWeapon() == vortexWeapon

		if (weaponIsActive && !weaponWasActive)
		{
			file.sphereClientFXHandle = vortexWeapon.PlayWeaponEffectReturnViewEffectHandle( shieldFX, $"", "gun_shield_fp" )
		}
		else if (!weaponIsActive && weaponWasActive)
		{
			if ( file.sphereClientFXHandle != -1 )
				EffectStop( file.sphereClientFXHandle, true, false )

			file.sphereClientFXHandle = -1
		}

		weaponWasActive = weaponIsActive

		float newHealth = float( vortexSphere.GetHealth() )
		UpdateShieldColor( player, oldHealth, newHealth, oldHealth == newHealth )
		oldHealth = newHealth
		wait 0.1
	}
	WaitForever()
}

void function UpdateShieldColor( entity player, float oldValue, float newValue, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	if ( player != GetLocalViewPlayer() )
		return

	if ( !IsValid( player ) )
		return

	float shieldFrac = newValue / TITAN_GUN_SHIELD_HEALTH
	vector colorVec = GetShieldTriLerpColor( 1 - shieldFrac )

	if ( EffectDoesExist( file.sphereClientFXHandle ) )
		EffectSetControlPointVector( file.sphereClientFXHandle, 1, colorVec )
}
#endif