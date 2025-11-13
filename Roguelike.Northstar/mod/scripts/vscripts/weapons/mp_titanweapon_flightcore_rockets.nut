global function OnWeaponPrimaryAttack_titanweapon_flightcore_rockets
global function OnProjectileCollision_titanweapon_flightcore_rockets

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_flightcore_rockets
#endif

var function OnWeaponPrimaryAttack_titanweapon_flightcore_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
	if ( !shouldPredict )
		return 1
	#endif

	// Get missile firing information
	entity owner = weapon.GetWeaponOwner()
	vector offset
	int altFireIndex = weapon.GetCurrentAltFireIndex()
	float horizontalMultiplier
	if ( altFireIndex == 1 )
		horizontalMultiplier = RandomFloatRange( 0.25, 0.45 )
	else
		horizontalMultiplier = RandomFloatRange( -0.45, -0.25 )

	if ( owner.IsPlayer() )
		offset = AnglesToRight( owner.CameraAngles() ) * horizontalMultiplier
	#if SERVER
	else
		offset = owner.GetPlayerOrNPCViewRight() * horizontalMultiplier
	#endif

	vector attackDir = attackParams.dir + offset + <0,0,RandomFloatRange(-0.25,0.55)>
	vector attackPos = attackParams.pos + offset*32
	attackDir = Normalize( attackDir )
	entity missile = weapon.FireWeaponMissile( attackPos, attackDir, 1, (damageTypes.projectileImpact | DF_DOOM_FATALITY), damageTypes.explosive, false, shouldPredict )

	if ( missile )
	{
		TraceResults result = TraceLine( owner.EyePosition(), owner.EyePosition() + attackParams.dir*50000, [ owner ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		missile.kv.lifetime = 10
		missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )
		thread DelayedTrackingStart( missile, result.endPos )
	#if SERVER
		missile.SetOwner( owner )
		EmitSoundAtPosition( owner.GetTeam(), result.endPos, "Weapon_FlightCore_Incoming_Projectile" )

		thread MissileThink( missile )
	#endif // SERVER
	}
	return 1
}

void function OnProjectileCollision_titanweapon_flightcore_rockets( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCrit )
{
	#if SERVER
	if (!IsValid(projectile.GetOwner()) || !Roguelike_HasMod( projectile.GetOwner(), "cluster_core" ))
		return

	if (RandomFloat(1.0) > 1.0)
		return

	PopcornInfo popcornInfo

	popcornInfo.weaponName = "mp_titanweapon_flightcore_rockets"
	popcornInfo.weaponMods = []
	popcornInfo.damageSourceId = eDamageSourceId.mp_titanweapon_flightcore_rockets
	popcornInfo.count = 3
	popcornInfo.delay = 2.0
	popcornInfo.offset = CLUSTER_ROCKET_BURST_OFFSET
	popcornInfo.range = 250
	popcornInfo.normal = normal
	popcornInfo.duration = 2.0
	popcornInfo.groupSize = 4
	popcornInfo.hasBase = true

	thread StartClusterExplosions( projectile, projectile.GetOwner(), popcornInfo, CLUSTER_ROCKET_FX_TABLE )
	#endif
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_flightcore_rockets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanweapon_flightcore_rockets( weapon, attackParams )
}

void function MissileThink( entity missile )
{
	missile.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( missile )
		{
			if ( IsValid( missile ) )
				missile.Destroy()
		}
	)

	float life = float( missile.kv.lifetime )

	wait life
}
#endif // SERVER

void function DelayedTrackingStart( entity missile, vector targetPos )
{
	missile.EndSignal( "OnDestroy" )
	wait 0.1
	missile.SetHomingSpeeds( 2000, 0 )
	missile.SetMissileTargetPosition( targetPos )
}