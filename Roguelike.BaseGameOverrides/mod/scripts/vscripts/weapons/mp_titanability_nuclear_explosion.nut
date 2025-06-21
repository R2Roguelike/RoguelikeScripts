#if SERVER
untyped
#endif

global function OnWeaponPrimaryAttack_titanability_nuclear_explosion
#if SERVER
global function OnWeaponNPCPrimaryAttack_titanability_nuclear_explosion
#endif

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanability_nuclear_explosion( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanability_nuclear_explosion( weapon, attackParams )
}
#endif

var function OnWeaponPrimaryAttack_titanability_nuclear_explosion( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	// attackPos = attackParams.pos + ( attackParams.dir * 16 )

	if ( owner.IsPlayer() )
		PlayerUsedOffhand( owner, weapon )

#if SERVER
#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}
