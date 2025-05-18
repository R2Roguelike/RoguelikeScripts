untyped
global function MpTitanAbilityHover_Init
global function OnWeaponPrimaryAttack_TitanHover
const LERP_IN_FLOAT = 0.5

#if SERVER
global function NPC_OnWeaponPrimaryAttack_TitanHover
global function FlyerHovers
#endif

void function MpTitanAbilityHover_Init()
{
	PrecacheParticleSystem( $"P_xo_jet_fly_large" )
	PrecacheParticleSystem( $"P_xo_jet_fly_small" )
	RegisterSignal("StopHover")
}

var function OnWeaponPrimaryAttack_TitanHover( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity flyer = weapon.GetWeaponOwner()
	if ( !IsAlive( flyer ) )
		return

	if ( flyer.IsPlayer() )
		PlayerUsedOffhand( flyer, weapon )

	#if SERVER
		HoverSounds soundInfo
		soundInfo.liftoff_1p = "titan_flight_liftoff_1p"
		soundInfo.liftoff_3p = "titan_flight_liftoff_3p"
		soundInfo.hover_1p = "titan_flight_hover_1p"
		soundInfo.hover_3p = "titan_flight_hover_3p"
		soundInfo.descent_1p = "titan_flight_descent_1p"
		soundInfo.descent_3p = "titan_flight_descent_3p"
		soundInfo.landing_1p = "core_ability_land_1p"
		soundInfo.landing_3p = "core_ability_land_3p"
		float horizontalVelocity
		entity soul = flyer.GetTitanSoul()
		if ( IsValid( soul ) && SoulHasPassive( soul, ePassives.PAS_NORTHSTAR_FLIGHTCORE ) )
			horizontalVelocity = 350.0
		else
			horizontalVelocity = 250.0
		thread FlyerHovers( flyer, soundInfo, 3.0, horizontalVelocity )
	#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER

var function NPC_OnWeaponPrimaryAttack_TitanHover( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnWeaponPrimaryAttack_TitanHover( weapon, attackParams )
}

void function FlyerHovers( entity player, HoverSounds soundInfo, float flightTime = 3.0, float horizVel = 200.0, bool isCore = false )
{
	if (!("hovering" in player.s))
		player.s.hovering <- 0
	if (player.IsPlayer() && Roguelike_HasMod( player, "hover_toggle" ) && !isCore)
	{
		if (player.s.hovering > 0)
		{
			player.Signal("StopHover")
			return
		}
		else
		{
			flightTime = 9999.9
		}
	}
	player.s.hovering++
	player.EndSignal( "StopHover" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )

	thread AirborneThink( player, soundInfo )
	if ( player.IsPlayer() )
	{
		player.Server_TurnDodgeDisabledOn()
	    player.kv.airSpeed = horizVel
	    player.kv.airAcceleration = 540
	    player.kv.gravity = 0.0
	}

	CreateShake( player.GetOrigin(), 16, 150, 1.00, 400 )
	PlayFX( FLIGHT_CORE_IMPACT_FX, player.GetOrigin() )

	float startTime = Time()

	array<entity> activeFX

	player.SetGroundFrictionScale( 0 )

	if ( player.LookupAttachment( "FX_L_BOT_THRUST" ) != 0 ) // BT doesn't have this attachment
	{
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_L_BOT_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_R_BOT_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_L_TOP_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_R_TOP_THRUST" ) ) )
	}

	EmitSoundOnEntityOnlyToPlayer( player, player,  soundInfo.liftoff_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.liftoff_3p )
	EmitSoundOnEntityOnlyToPlayer( player, player,  soundInfo.hover_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.hover_3p )

	float RISE_VEL = 600
	float movestunEffect = 1.0 - StatusEffect_Get( player, eStatusEffect.dodge_speed_slow )

	entity soul = player.GetTitanSoul()
	if ( soul == null )
		soul = player

	float fadeTime = 0.75
	int statusEffectID = StatusEffect_AddTimed( soul, eStatusEffect.dodge_speed_slow, 0.35, flightTime + fadeTime, fadeTime )

	OnThreadEnd(
		function() : ( activeFX, player, soundInfo, statusEffectID, isCore )
		{
			if ( IsValid( player ) )
			{
				player.Signal("StopHover")
				EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.descent_1p )
				EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.descent_3p )
				if (IsValid(player.GetTitanSoul()))
					StatusEffect_Stop( player.GetTitanSoul(), statusEffectID )
				StopSoundOnEntity( player, soundInfo.hover_1p )
				StopSoundOnEntity( player, soundInfo.hover_3p )

				player.s.hovering--
				player.SetGroundFrictionScale( 1 )
				if ( player.IsPlayer() )
				{
					player.Server_TurnDodgeDisabledOff()
					player.kv.airSpeed = player.GetPlayerSettingsField( "airSpeed" )
					player.kv.airAcceleration = player.GetPlayerSettingsField( "airAcceleration" )
					player.kv.gravity = player.GetPlayerSettingsField( "gravityScale" )
					if ( player.IsOnGround() )
					{
						EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.landing_1p )
						EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.landing_3p )
					}
				}
				else
				{
					if ( player.IsOnGround() )
						EmitSoundOnEntity( player, soundInfo.landing_3p )
				}
			}

			foreach ( fx in activeFX )
			{
				if ( IsValid( fx ) )
					fx.Destroy()
			}
		}
	)


	vector mins = GetBoundsMin( HULL_TITAN )
	vector maxs = GetBoundsMax( HULL_TITAN )

	int solidMask = TRACE_MASK_PLAYERSOLID
	int collisionGroup = TRACE_COLLISION_GROUP_PLAYER

	TraceResults results = TraceHull( player.GetOrigin(), player.GetOrigin() + <0,0,50>, mins, maxs, [], solidMask, collisionGroup )
	printt(results.fraction)
	vector origin = player.GetOrigin()
	player.SetOrigin( origin + <0,0,500> )
	player.SetOrigin( origin + <0,0,results.fraction*50> )
	//player.ForceCheckGroundEntity()

	vector startOrigin = player.GetOrigin()

	for ( ; (!player.IsOnGround() || Time() - startTime < 0.5); )
	{
		float timePassed = Time() - startTime
		if ( timePassed > flightTime )
			break

		float height
		if ( timePassed < LERP_IN_FLOAT )
		 	height = GraphCapped( timePassed, 0, LERP_IN_FLOAT, RISE_VEL * 0.5, RISE_VEL )
		 else
		 	height = GraphCapped( timePassed, LERP_IN_FLOAT, LERP_IN_FLOAT + 0.75, RISE_VEL, 15 )

		height *= movestunEffect

		vector vel = player.GetVelocity()
		vel.z = height

		float horizLimit = max( horizVel + 50, Length( <vel.x, vel.y, 0> ) - 200 * 0.05 )

		vel = LimitVelocityHorizontal( vel, horizLimit )

		player.SetVelocity( vel )
		WaitFrame()
	}

	vector endOrigin = player.GetOrigin()

	// printt( endOrigin - startOrigin )
}

void function AirborneThink( entity player, HoverSounds soundInfo )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "DisembarkingTitan" )

	if ( player.IsPlayer() )
		player.SetTitanDisembarkEnabled( false )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) && player.IsPlayer() )
				player.SetTitanDisembarkEnabled( true )
		}
	)
	wait 0.1

	while( !player.IsOnGround() )
	{
		wait 0.1
	}

	if ( player.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.landing_1p )
		EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.landing_3p )
	}
	else
	{
		EmitSoundOnEntity( player, soundInfo.landing_3p )
	}
}

vector function LimitVelocityHorizontal( vector vel, float speed )
{
	vector horzVel = <vel.x, vel.y, 0>
	if ( Length( horzVel ) <= speed )
		return vel

	horzVel = Normalize( horzVel )
	horzVel *= speed
	vel.x = horzVel.x
	vel.y = horzVel.y
	return vel
}
#endif // SERVER
