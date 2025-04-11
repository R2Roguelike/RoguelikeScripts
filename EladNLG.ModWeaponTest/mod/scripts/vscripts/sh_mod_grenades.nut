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
    AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_OVERRIDE, Grenades_ApplyModWeaponVars )
    #if SERVER
    foreach (string grenade in MOD_GRENADES)
        AddDamageCallbackSourceID( eDamageSourceId[grenade], GrenadeDamage )
    #endif
}

#if SERVER
void function GrenadeDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if (!attacker.IsPlayer())
        return
    
    if (attacker == ent)
    {
        print("self damage")
        return
    }
    
    DamageInfo_ScaleDamage( damageInfo, 1.75 )
    DamageInfo_ScaleDamage( damageInfo, Roguelike_GetGrenadeDamageBoost( Roguelike_GetStat( attacker, STAT_TEMPER ) ) )
}
#endif

void function Grenades_ApplyModWeaponVars( entity weapon )
{
    string weaponClassName = weapon.GetWeaponClassName()
    if (!MOD_GRENADES.contains(weaponClassName))
        return

    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 300 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_default_total, 300 )
    ModWeaponVars_SetFloat( weapon, eWeaponVar.regen_ammo_refill_rate, 10.0 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_min_to_fire, 150 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_per_shot, 150 )

    if (weaponClassName == "mp_weapon_thermite_grenade" || weaponClassName == "mp_weapon_grenade_gravity")
    {
        ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 450 )
        ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_default_total, 450 )
    }
}