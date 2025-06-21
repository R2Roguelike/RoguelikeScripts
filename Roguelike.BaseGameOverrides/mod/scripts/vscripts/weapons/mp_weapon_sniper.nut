
global function MpWeaponSniper_Init

global function OnWeaponActivate_weapon_sniper
global function OnWeaponPrimaryAttack_weapon_sniper
global function OnProjectileCollision_weapon_sniper

#if CLIENT
global function OnClientAnimEvent_weapon_sniper
#endif // #if CLIENT

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_sniper
#endif // #if SERVER

void function MpWeaponSniper_Init()
{
	SniperPrecache()
}

void function SniperPrecache()
{
	PrecacheParticleSystem( $"wpn_mflash_snp_hmn_smoke_side_FP" )
	PrecacheParticleSystem( $"wpn_mflash_snp_hmn_smoke_side" )
	PrecacheParticleSystem( $"Rocket_Smoke_SMR_Glow" )
}

void function OnWeaponActivate_weapon_sniper( entity weapon )
{
#if CLIENT
	UpdateViewmodelAmmo( false, weapon )
#endif // #if CLIENT
}

#if CLIENT
void function OnClientAnimEvent_weapon_sniper( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )

	if ( name == "muzzle_flash" )
	{

		if ( IsOwnerViewPlayerFullyADSed( weapon ) )
			return

		weapon.PlayWeaponEffect( $"wpn_mflash_snp_hmn_smoke_side_FP", $"wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_L" )
		weapon.PlayWeaponEffect( $"wpn_mflash_snp_hmn_smoke_side_FP", $"wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_R" )
	}
}

#endif // #if CLIENT

var function OnWeaponPrimaryAttack_weapon_sniper( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_sniper( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	return FireWeaponPlayerAndNPC( weapon, attackParams, false )
}
#endif // #if SERVER

int function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true

	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	if (Roguelike_GetWeaponPerks( weapon ).contains("firestar-launcher") && shouldCreateProjectile)
	{
		int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
		int damageFlags = weapon.GetWeaponDamageFlags()
		entity bolt = weapon.FireWeaponGrenade( attackParams.pos, attackParams.dir * boltSpeed, <0,0,0>, 0.0, damageFlags, damageFlags, playerFired, playerFired, false )
		return 1
	}
	if ( shouldCreateProjectile )
	{
		int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
		int damageFlags = weapon.GetWeaponDamageFlags()
		entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )

		if ( bolt != null )
		{
			bolt.kv.gravity = expect float( weapon.GetWeaponInfoFileKeyField( "bolt_gravity_amount" ) )

#if CLIENT
				//StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"Rocket_Smoke_SMR_Glow" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
#endif // #if CLIENT
		}
	}

	return 1
}

void function OnProjectileCollision_weapon_sniper( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
		entity sourceWeapon = Roguelike_FindWeapon( projectile.GetOwner(), projectile.ProjectileGetWeaponClassName() )
		if (Roguelike_GetWeaponPerks( sourceWeapon ).contains("firestar-launcher"))
		{
			table collisionParams =
			{
				pos = pos,
				normal = normal,
				hitEnt = hitEnt,
				hitbox = hitbox
			}
			bool result = PlantStickyEntity( projectile, collisionParams )

			if (result)
			{
				print("burn!")
				thread ThermiteBurn( THERMITE_GRENADE_BURN_TIME, projectile.GetOwner(), projectile )
			}
		}
		int bounceCount = projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_ricochet_max_count )
		if ( projectile.proj.projectileBounceCount >= bounceCount )
			return

		if ( hitEnt == svGlobal.worldspawn )
			EmitSoundAtPosition( TEAM_UNASSIGNED, pos, "Bullets.DefaultNearmiss" )

		projectile.proj.projectileBounceCount++
	#endif
}