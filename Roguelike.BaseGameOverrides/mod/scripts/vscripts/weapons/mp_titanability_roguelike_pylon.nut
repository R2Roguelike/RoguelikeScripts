#if SERVER
untyped
#endif

global function OnWeaponPrimaryAttack_titanability_roguelike_pylon
global function OnWeaponOwnerChanged_titanability_roguelike_pylon
#if SERVER
global function OnWeaponNPCPrimaryAttack_titanability_roguelike_pylon
#endif

const asset LASER_TRIP_AIRBURST_FX = $"P_impact_exp_arcball_default"
const string LASER_TRIP_AIRBURST_SOUND = "Explo_ProximityEMP_Impact_3P"

const asset LASER_TRIP_BEAM_FX = $"P_wpn_lasertrip_beam"
const asset LASER_TRIP_ZAP_FX = $"P_arc_pylon_zap"

const asset LASER_TRIP_MODEL = $"models/weapons/titan_trip_wire/titan_trip_wire.mdl"
const asset LASER_TRIP_FX_ALL = $"P_wpn_lasertrip_base"
const asset LASER_TRIP_FX_FRIENDLY = $"wpn_grenade_frag_blue_icon"
const asset LASER_TRIP_EXPLODE_FX = $"P_impact_exp_XLG_metal"
const float LASER_TRIP_HEALTH = 300.0
const float LASER_TRIP_INNER_RADIUS = 400.0
const float LASER_TRIP_OUTER_RADIUS = 400.0
const float LASER_TRIP_DAMAGE = 200.0
const float LASER_TRIP_DAMAGE_HEAVY_ARMOR = 1500.0
const float LASER_TRIP_MIN_ANGLE = 180.0
const float LASER_TRIP_BIGZAP_RANGE = 1500.0

const float LASER_TRIP_LIFETIME = 300.0
const float LASER_TRIP_BUILD_TIME = 1.0
const int LASER_TRIP_MAX = 9

const float LASER_TRIP_DEPLOY_POWER = 200.0
const float LASER_TRIP_DEPLOY_SIDE_POWER = 400.0
const int SHARED_ENERGY_RESTORE_AMOUNT = 350

struct
{
	int laserPylonsIdx
} file;

void function MpTitanAbilityRoguelikePylon_Init()
{
	PrecacheModel( LASER_TRIP_MODEL )
	PrecacheParticleSystem( LASER_TRIP_FX_ALL )
	PrecacheParticleSystem( LASER_TRIP_FX_FRIENDLY )
	PrecacheParticleSystem( LASER_TRIP_EXPLODE_FX )
	PrecacheParticleSystem( LASER_TRIP_AIRBURST_FX )
	PrecacheParticleSystem( LASER_TRIP_BEAM_FX )
	PrecacheParticleSystem( LASER_TRIP_ZAP_FX )

}


void function OnWeaponOwnerChanged_titanability_roguelike_pylon( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if SERVER
	entity owner = weapon.GetWeaponOwner()

	if ( owner == null )
		return

	if ( owner.e.roguelikePylonArrayIdx == -1 )
		owner.e.roguelikePylonArrayIdx = CreateScriptManagedEntArray()
	#endif
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanability_roguelike_pylon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanability_roguelike_pylon( weapon, attackParams )
}
#endif

var function OnWeaponPrimaryAttack_titanability_roguelike_pylon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	// attackPos = attackParams.pos + ( attackParams.dir * 16 )

#if CLIENT
		vector origin = owner.OffsetPositionFromView( Vector(0, 0, 0), Vector(25, -25, 15) )
		vector angles = owner.CameraAngles()

		StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( $"wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
#endif // #if CLIENT

	if ( owner.IsPlayer() )
		PlayerUsedOffhand( owner, weapon )

#if SERVER
	//This wave attack is spawning 3 waves, and we want them all to only do damage once to any individual target.
	entity inflictor = CreateDamageInflictorHelper( -1.0 )
#endif

	vector right = CrossProduct( attackParams.dir, <0,0,1> )
	vector dir = attackParams.dir

	array<entity> deployables = []

	dir.z = min( dir.z, -0.2 )

	attackParams.dir = dir
	deployables.append( ThrowDeployable( weapon, attackParams, LASER_TRIP_DEPLOY_POWER, OnLaserPylonPlanted ) )

	#if SERVER
	foreach ( i, deployable in deployables )
	{
		deployable.proj.projectileID = i
		deployable.proj.projectileGroup = clone deployables
		deployable.proj.inflictorOverride = inflictor
	}
	#endif
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnLaserPylonPlanted( entity projectile )
{
	#if SERVER
		thread DeployLaserPylon( projectile )
	#endif

}

#if SERVER
function DeployLaserPylon( entity projectile )
{
	vector origin = projectile.GetOrigin() // - <0,0,40>
	vector angles = projectile.proj.savedAngles
	entity owner = projectile.GetOwner()
	entity inflictor = projectile.proj.inflictorOverride
	entity attachparent = projectile.GetParent()

	projectile.SetModel( $"models/dev/empty_model.mdl" )
	projectile.Hide()

	if ( !IsValid( owner ) )
		return

	if ( IsNPCTitan( owner ) )
	{
		entity bossPlayer = owner.GetBossPlayer()
		if ( IsValid( bossPlayer ) )
			bossPlayer.EndSignal( "OnDestroy" )
	}
	else
	{
		owner.EndSignal( "OnDestroy" )
	}

	int team = owner.GetTeam()
	array<entity> pylons = GetScriptManagedEntArray( owner.e.roguelikePylonArrayIdx )
	if ( pylons.len() >= LASER_TRIP_MAX )
	{
		pylons.sort( SortBySpawnTime )
		pylons[0].Destroy()
	}

	entity tower = CreatePropScript( LASER_TRIP_MODEL, origin, angles, SOLID_VPHYSICS )
	tower.kv.collisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	tower.EnableAttackableByAI( 20, 0, AI_AP_FLAG_NONE )
	SetTargetName( tower, "Roguelike Pylon" )
	tower.SetMaxHealth( LASER_TRIP_HEALTH )
	tower.SetHealth( LASER_TRIP_HEALTH )
	tower.SetTakeDamageType( DAMAGE_YES )
	tower.SetDamageNotifications( true )
	tower.SetDeathNotifications( true )
	tower.SetOwner( owner.GetTitanSoul() )
	tower.SetArmorType( ARMOR_TYPE_HEAVY )
	tower.SetTitle( "Roguelike Pylon" )
	tower.EndSignal( "OnDestroy" )
	switch (GetEliteType( owner ))
	{
		case "healing":
			Highlight_SetEnemyHighlight( tower, "elite_healing_pylon" )
			thread HealingElite_Pylon( owner, tower )
		default:
			break
	}
	EmitSoundOnEntity( tower, "Wpn_LaserTripMine_Land" )
	tower.e.noOwnerFriendlyFire = true

	tower.Anim_Play( "trip_wire_closed_to_open" )
	tower.Anim_DisableUpdatePosition()

	if ( attachparent != null )
		tower.SetParent( attachparent )

	// hijacking this int so we don't create a new one
	string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, LASER_TRIP_BUILD_TIME + LASER_TRIP_LIFETIME, LASER_TRIP_OUTER_RADIUS )

	SetTeam( tower, TEAM_ANY )
	SetObjectCanBeMeleed( tower, true )
	SetVisibleEntitiesInConeQueriableEnabled( tower, true )
	AddEntityCallback_OnDamaged( tower, OnPylonBodyDamaged )
	SetCustomSmartAmmoTarget( tower, false )
	thread TrapDestroyOnRoundEnd( owner, tower )

	entity pylon = CreateEntity( "script_mover" )
	pylon.SetValueForModelKey( $"models/weapons/bullets/triple_threat_projectile.mdl" )
	pylon.kv.fadedist = -1
	pylon.kv.physdamagescale = 0.1
	pylon.kv.inertiaScale = 1.0
	pylon.kv.renderamt = 255
	pylon.kv.rendercolor = "255 255 255"
	pylon.kv.solid = SOLID_HITBOXES
	pylon.kv.SpawnAsPhysicsMover = 0
	SetTargetName( pylon, "Laser Tripwire" )
	pylon.SetOrigin( origin )
	pylon.SetAngles( angles )
	pylon.SetOwner( owner.GetTitanSoul() )

	pylon.SetMaxHealth( LASER_TRIP_HEALTH )
	pylon.SetHealth( LASER_TRIP_HEALTH )
	pylon.SetTakeDamageType( DAMAGE_NO )
	pylon.SetDamageNotifications( true )
	pylon.SetDeathNotifications( true )
	pylon.SetArmorType( ARMOR_TYPE_HEAVY )
	SetVisibleEntitiesInConeQueriableEnabled( pylon, true )
	SetTeam( pylon, team )
	pylon.NotSolid()
	pylon.Hide()


	DispatchSpawn( pylon )
	AddToScriptManagedEntArray( owner.e.roguelikePylonArrayIdx, pylon )

	int damageSourceId = projectile.ProjectileGetDamageSourceID()
	pylon.EndSignal( "OnDestroy" )

	pylon.SetParent( tower, "", true, 0 )
	pylon.NonPhysicsSetMoveModeLocal( true )
	pylon.NonPhysicsMoveTo( pylon.GetLocalOrigin() + <0,0,45>, LASER_TRIP_BUILD_TIME, 0, 0 )
	pylon.e.spawnTime = Time()
	pylon.e.projectileID = projectile.proj.projectileID

	int projCount = projectile.proj.projectileGroup.len()
	foreach ( p in projectile.proj.projectileGroup )
	{
		if ( IsValid( p ) && p.IsProjectile() && p != projectile )
			p.proj.projectileGroup.append( pylon )
	}

	vector pylonOrigin = pylon.GetOrigin()
	OnThreadEnd(
	function() : ( projectile, inflictor, tower, pylon, noSpawnIdx, team, pylonOrigin )
		{
			PlayFX( LASER_TRIP_EXPLODE_FX, pylonOrigin, < -90.0, 0.0, 0.0 > )
			EmitSoundAtPosition( team, pylonOrigin, "Wpn_LaserTripMine_MineDestroyed" )

			entity soul = pylon.GetOwner()
			if ( IsValid( soul ) )
			{
				entity titan = soul.GetTitan()
				if ( IsValid( titan ) )
				{
				}
			}

			foreach ( p in projectile.proj.projectileGroup )
			{
				if ( IsValid( p ) )
				{
					p.Destroy()
				}
			}

			DeleteNoSpawnArea( noSpawnIdx )

			if ( IsValid( tower ) )
			{
				tower.Destroy()
			}

			if ( IsValid( pylon ) )
			{
				foreach ( p in pylon.e.fxArray )
				{
					if ( IsValid( p ) )
						p.Destroy()
				}
				pylon.Destroy()
			}

			if ( IsValid( projectile ) )
				projectile.Destroy()

			if ( IsValid( inflictor ) )
				inflictor.Kill_Deprecated_UseDestroyInstead( 1.0 )
		}
	)

	wait LASER_TRIP_BUILD_TIME

	PlayLoopFXOnEntity( LASER_TRIP_FX_ALL, pylon )

	// AddEntityCallback_OnDamaged( pylon, OnPylonHeadDamaged )

	foreach ( p in projectile.proj.projectileGroup )
	{
		if ( IsValid( p ) && !p.IsProjectile() && p != pylon && p.e.projectileID == projectile.proj.projectileID - 1 )
		{
			vector pOrg = p.GetOrigin()
			vector pylonOrg = pylon.GetOrigin()
			TraceResults trace = TraceLine( pOrg, pylonOrg, [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
			if ( trace.fraction < 0.99 )
				continue

			if ( p.IsMarkedForDeletion() )
				continue

			entity cpEnd = CreateEntity( "info_placement_helper" )
			SetTargetName( cpEnd, UniqueString( "laser_pylon_cpEnd" ) )
			cpEnd.SetParent( p, "center", false, 0.0 )
			DispatchSpawn( cpEnd )

			entity beamFX = CreateEntity( "info_particle_system" )
			beamFX.kv.cpoint1 = cpEnd.GetTargetName()

			beamFX.SetValueForEffectNameKey( LASER_TRIP_BEAM_FX )
			beamFX.kv.start_active = 1
			// SetTeam( beamFX, GetOtherTeam( owner.GetTeam() ) )
			// beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
			beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			beamFX.SetOrigin( pylonOrg )
			vector cpEndPoint = cpEnd.GetOrigin()
			beamFX.SetAngles( VectorToAngles( cpEndPoint - pylon.GetOrigin() ) )
			beamFX.SetParent( pylon, "center", true, 0.0 )
			DispatchSpawn( beamFX )

			vector centerPoint = pylonOrg + ( ( pOrg - pylonOrg ) / 2 )
			EmitSoundAtPosition( TEAM_UNASSIGNED, centerPoint, "Wpn_LaserTripMine_LaserLoop" )
			thread StopLaserSoundAtPosition( pylon, centerPoint )
			if ( projCount == 3 )
				EmitSoundAtPosition( TEAM_UNASSIGNED, centerPoint, "Wpn_LaserTripMine_FirstConnect" )
			else
				EmitSoundAtPosition( TEAM_UNASSIGNED, centerPoint, "Wpn_LaserTripMine_SecondConnect" )

			pylon.e.fxArray.append( p )
		}
	}

	if ( IsValid( projectile ) )
		projectile.Destroy()

	if ( !IsAlive( owner ) )
		return

	if ( !IsNPCTitan( owner ) )
		owner.EndSignal( "OnDeath" )

	wait LASER_TRIP_LIFETIME
}

void function StopLaserSoundAtPosition( entity pylon, vector position )
{
	pylon.WaitSignal( "OnDestroy" )
	StopSoundAtPosition( position, "Wpn_LaserTripMine_LaserLoop" )
}

void function LaserPylonSetThink( entity pylon1, entity pylon2, int ownerTeam )
{
	EndSignal( pylon1, "OnDestroy" )
	EndSignal( pylon2, "OnDestroy" )

	vector p1Org = pylon1.GetOrigin()
	vector p2Org = pylon2.GetOrigin()

	float pylonDist = Length( p2Org - p1Org )
	vector laserOBBOrigin = ( p1Org + p2Org ) / 2.0
	vector laserOOBAngles = VectorToAngles( p2Org - p1Org )
	vector laserOOBMins = < pylonDist * -0.5, -8.0, -8.0 >
	vector laserOOBMaxs = < pylonDist * 0.5, 8.0, 8.0 >

	while ( true )
	{
		array<entity> enemies = GetPlayerArrayOfEnemies( ownerTeam )
		enemies.extend( GetNPCArrayOfEnemies( ownerTeam ) )

		foreach ( enemy in enemies )
		{
			if ( !IsAlive( enemy ) )
				continue

			if ( OBBIntersectsOBB( laserOBBOrigin, laserOOBAngles, laserOOBMins, laserOOBMaxs, enemy.GetOrigin(), <0.0,0.0,0.0>, enemy.GetBoundingMins(), enemy.GetBoundingMaxs(), 0.0 ) )
			{
				//ExplodeAllStickies( enemy, pylon1.GetOwner() )
				pylon1.Destroy()
			}
		}

		WaitFrame()
	}
}

void function OnPylonBodyDamaged( entity pylonBody, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	int attackerTeam = attacker.GetTeam()

	if ( pylonBody.GetTeam() != attacker.GetTeam() && DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.mp_titanability_laser_trip )
	{
		if ( attacker.IsPlayer() )
		{
			attacker.NotifyDidDamage( pylonBody, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
		}
	}
}

#endif

#if SERVER
void function LaserTrip_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( ent.IsPlayer() )
	{
		if ( ent.IsTitan() )
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "titan_rocket_explosion_3p_vs_1p" )
		else
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "flesh_explo_med_3p_vs_1p" )
	}

	if (!IsValid(attacker) || !attacker.IsPlayer())
	{
		return
	}
	float cur = RSE_Get( ent, RoguelikeEffect.ion_charge )
	cur += 0.25
	RSE_Apply( ent, RoguelikeEffect.ion_charge, min(cur, 1.0) )
	if (cur > 0.99 || Roguelike_HasMod( attacker, "pylon_charge" ))
	{
		IonDischarge( ent, attacker, damageInfo )
	}
}
#endif