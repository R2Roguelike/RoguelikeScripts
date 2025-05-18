untyped

global function OnWeaponPrimaryAttack_weapon_doubletake
global function OnProjectileCollision_weapon_doubletake
#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_doubletake
#endif // #if SERVER

struct {
	float[2][3] boltOffsets = [
		[0.0, -0.25],
		[0.0, 0.25],
		[0.0, 0.0],
	]
} file

var function OnWeaponPrimaryAttack_weapon_doubletake( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, true, weapon )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_doubletake( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, false, weapon )
}
#endif // #if SERVER

function FireWeaponPlayerAndNPC( WeaponPrimaryAttackParams attackParams, bool playerFired, entity weapon )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	entity owner = weapon.GetWeaponOwner()
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	bool hasArcNet = weapon.HasMod( "arc_net" )


	array<entity> projectiles

	if ( shouldCreateProjectile )
	{
		int numProjectiles = weapon.GetProjectilesPerShot()
		Assert( numProjectiles <= file.boltOffsets.len() )

		FireBoltAtOffset( attackParams, playerFired, weapon, [0.0,0.0], projectiles )
		FireBoltAtOffset( attackParams, playerFired, weapon, [0.25,0.0], projectiles )
		FireBoltAtOffset( attackParams, playerFired, weapon, [-0.25,0.0], projectiles )
	}

	return 2
}


void function FireBoltAtOffset(WeaponPrimaryAttackParams attackParams, bool playerFired, entity weapon, array<float> offset, array<entity> projectiles )
{
	entity owner = weapon.GetWeaponOwner()

	vector attackAngles = VectorToAngles( attackParams.dir )
	vector baseUpVec = AnglesToUp( attackAngles )
	vector baseRightVec = AnglesToRight( attackAngles )

	float zoomFrac
	if ( playerFired )
		zoomFrac = owner.GetZoomFrac()
	else
		zoomFrac = 0.5

	float boltSpreadMax = 0.1
	float boltSpreadMin = 0.05

	float spreadFrac = Graph( zoomFrac, 0, 1, boltSpreadMax, boltSpreadMin )

	vector upVec = baseUpVec * offset[1] * spreadFrac
	vector rightVec = baseRightVec * offset[0] * spreadFrac

	vector attackDir = attackParams.dir + upVec + rightVec

	int boltSpeed = 10000
	int damageFlags = weapon.GetWeaponDamageFlags()
	entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackDir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )
	if ( bolt != null )
	{
		if ( offset[0] == 0.0 )
		{
			bolt.SetReducedEffects()
			bolt.SetRicochetMaxCount( 0 )
		}

		bolt.kv.gravity = 0.09

		projectiles.append( bolt )
	}
}

void function OnProjectileCollision_weapon_doubletake( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
		int bounceCount = projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_ricochet_max_count )
		if ( projectile.proj.projectileBounceCount >= bounceCount )
			return

		if ( hitEnt == svGlobal.worldspawn )
			EmitSoundAtPosition( TEAM_UNASSIGNED, pos, "Bullets.DefaultNearmiss" )

		projectile.proj.projectileBounceCount++
	#endif
}