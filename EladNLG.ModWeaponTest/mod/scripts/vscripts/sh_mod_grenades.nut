global function Sh_ModGrenades_Init

const array<string> MOD_GRENADES = [
    "mp_weapon_frag_grenade",
    "mp_weapon_grenade_emp",
    "mp_weapon_grenade_gravity",
    "mp_weapon_satchel",
    "mp_weapon_grenade_electric_smoke",
    "mp_weapon_thermite_grenade"
]

void function Sh_ModGrenades_Init()
{
    AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_OVERRIDE, ApplyModWeaponVars )
}

void function ApplyModWeaponVars( entity weapon )
{
    entity owner = weapon.GetWeaponOwner()

    string weaponClassName = weapon.GetWeaponClassName()
    if (!MOD_GRENADES.contains(weaponClassName))
        return

    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 300 )
    ModWeaponVars_SetFloat( weapon, eWeaponVar.regen_ammo_refill_rate, 10.0 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_min_to_fire, 150 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_per_shot, 150 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_default_total, 300 )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_damage, 2 ) // increase damage
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_damage_heavy_armor, 3 ) // REALLY increase damage against titans

    if (weaponClassName == "mp_weapon_thermite_grenade" || weaponClassName == "mp_weapon_grenade_gravity")
    {
        ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 450 )
        ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_default_total, 450 )
    }
}