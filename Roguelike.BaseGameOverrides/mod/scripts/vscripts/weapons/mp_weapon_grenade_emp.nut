global function OnProjectileCollision_weapon_grenade_emp

void function OnProjectileCollision_weapon_grenade_emp( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity player = projectile.GetOwner()
	if ( hitEnt == player )
		return

	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}
	
	if (Roguelike_HasMod( player, "ender_pearl" ))
	{
		print("shit")
		float delay = expect float(projectile.ProjectileGetWeaponInfoFileKeyField("grenade_fuse_time"))
		if (delay > 0)
			delay =projectile.GetFuseTime()
			printt("shit", delay)
		
		#if SERVER
		thread void function () : (delay, normal, projectile, player)
		{
			if (!IsValid(projectile))
				return
			///
			projectile.Signal("StopEnderPearl")
			projectile.EndSignal("StopEnderPearl")
			player.EndSignal("OnDestroy")
			projectile.WaitSignal("OnDestroy")
			printt("shit", delay)

			vector pos = projectile.GetOrigin()
			
			bool teleport = true
			TraceResults results = TraceHull( pos + normal * 24, pos, player.GetBoundingMins(), player.GetBoundingMaxs(), [ projectile ], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )
			if (results.startSolid)
			{
				teleport = false
			}
			if (results.fraction < 1.0)
			{
				pos = results.endPos + results.surfaceNormal * 16
			}
			
			if (teleport)
				player.SetOrigin(pos)
				
			player.SetInvulnerable()
			delaythread(0.1) ClearInvincible( player )
		}()
		#endif
	}

	if (projectile.GetProjectileWeaponSettingFloat( eWeaponVar.grenade_fuse_time ) > 0.0)
		return

	if ( IsSingleplayer() && ( player && !player.IsPlayer() ) )
		collisionParams.hitEnt = GetEntByIndex( 0 )

	bool result = PlantStickyEntity( projectile, collisionParams )

	if ( projectile.GrenadeHasIgnited() )
		return

	//Triggering this on the client triggers an impact effect.
	#if SERVER
	projectile.GrenadeIgnite()
	#endif

}