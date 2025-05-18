
global function OnProjectileCollision_ClusterRocket

void function OnProjectileCollision_ClusterRocket( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	array<string> mods = projectile.ProjectileGetMods()
	float duration = mods.contains( "pas_northstar_cluster" ) ? PAS_NORTHSTAR_CLUSTER_ROCKET_DURATION : CLUSTER_ROCKET_DURATION

	#if SERVER
		float explosionDelay = expect float( projectile.ProjectileGetWeaponInfoFileKeyField( "projectile_explosion_delay" ) )

		if (IsValid(projectile.GetOwner()) && Roguelike_HasMod( projectile.GetOwner(), "500kg" ) && fabs(float(projectile.GetOwner().kv.gravity)) < 0.0001)
		{
			PlayFX( TITAN_NUCLEAR_CORE_FX_3P, pos + Vector( 0, 0, -10 ), Vector(0,RandomInt(360),0) )

			EmitSoundAtPosition( TEAM_ANY, pos, "titan_nuclear_death_explode" )

			float titanDamage = 1000
			RadiusDamage( pos,			// origin
				projectile.GetOwner(),						// owner
				projectile,							// inflictor
				1000,						// normal damage
				titanDamage,					// heavy armor damage
				500,						// inner radius
				750,						// outer radius
				SF_ENVEXPLOSION_MASK_BRUSHONLY, // flags
				0,							// distFromAttacker
				10000,						// force
				damageTypes.explosive,
				eDamageSourceId.mp_titanweapon_dumbfire_rockets )
		}

		ClusterRocket_Detonate( projectile, normal )
		CreateNoSpawnArea( TEAM_INVALID, TEAM_INVALID, pos, ( duration + explosionDelay ) * 0.5 + 1.0, CLUSTER_ROCKET_BURST_RANGE + 100 )
	#endif
}
