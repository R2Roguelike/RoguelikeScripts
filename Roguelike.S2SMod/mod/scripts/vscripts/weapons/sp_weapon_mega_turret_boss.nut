untyped

global function OnWeaponPrimaryAttack_mega_turret_boss
global function OnWeaponActivate_mega_turret_boss
global function OnWeaponDeactivate_mega_turret_boss

#if SERVER
global function OnWeaponNpcPrimaryAttack_mega_turret_boss

struct
{
	table<int,entity> shellEject
	int barrelIndex = 0
}file

#endif // #if SERVER

const asset ModelMT = $"models/turrets/turret_imc_lrg.mdl"  // the return value for turretEnt.GetModelName()
const asset CANNON_FX		= $"P_muzzleflash_MaltaGun"
const asset CANNON_FX_LIGHT = $"mflash_maltagun_tracer_fake"

// this list has to match the order that the barrels are set up in the QC file
const WeaponBarrelInfo = {
	[ ModelMT ] = [
		{
			muzzleFlashTag	= "MUZZLE_LEFT_UPPER"
			shellEjectTag 	= "SHELL_LEFT_UPPER"
		}
		{
			muzzleFlashTag	= "MUZZLE_LEFT_LOWER"
			shellEjectTag	= "SHELL_LEFT_LOWER"
		}
		{
			muzzleFlashTag	= "MUZZLE_RIGHT_UPPER"
			shellEjectTag	= "SHELL_RIGHT_UPPER"
		}
		{
			muzzleFlashTag	= "MUZZLE_RIGHT_LOWER"
			shellEjectTag	= "SHELL_RIGHT_LOWER"
		}
	]
}

var function OnWeaponPrimaryAttack_mega_turret_boss( entity weapon, WeaponPrimaryAttackParams attackParams )
{

}

#if SERVER
var function OnWeaponNpcPrimaryAttack_mega_turret_boss( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	entity turretOwner = weapon.GetOwner()
	turretOwner.Signal( "shoot" )

	if ( !IsAlive( turretOwner ) )
		return

	int barrelIndex = file.barrelIndex// RandomInt( 4 )
	file.barrelIndex++
	if ( file.barrelIndex >= 4 )
		file.barrelIndex = 0

	table<string,string> barrelInfo = WeaponBarrelInfo[ turretOwner.GetModelName() ][ barrelIndex ]

	int fxID = GetParticleSystemIndex( CANNON_FX )
	int flashFxId = GetParticleSystemIndex( $"wpn_muzzleflash_40mm" )

	int attachID = turretOwner.LookupAttachment(  barrelInfo.muzzleFlashTag )
	vector origin = turretOwner.GetAttachmentOrigin( attachID )
	//print(origin)
	//StartParticleEffectOnEntity( turretOwner, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	StartParticleEffectOnEntity( turretOwner, flashFxId, FX_PATTACH_POINT_FOLLOW, attachID )

	vector dir = attackParams.dir
	if (IsValid(turretOwner.GetEnemy()))
		dir = Normalize(turretOwner.GetEnemy().GetWorldSpaceCenter() - origin)

	vector right = AnglesToRight( VectorToAngles(dir) )
	vector up = AnglesToUp( VectorToAngles(dir) )

	dir += right * RandomFloatRange(-0.01, 0.01) + up * RandomFloatRange(-0.01, 0.01)

	float projSpeedMultiplier = 0.5
	switch (GetConVarInt("sp_difficulty"))
	{
		
	}
	weapon.FireWeaponMissile( origin, dir, 1, damageTypes.explosive, damageTypes.explosive, false, false )
}

#endif

void function OnWeaponActivate_mega_turret_boss( entity weapon )
{

}

void function OnWeaponDeactivate_mega_turret_boss( entity weapon )
{

}

