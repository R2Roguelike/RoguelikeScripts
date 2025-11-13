untyped
global function Sh_ModGrenades_Init

void function Sh_ModGrenades_Init()
{
    AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_OVERRIDE, Grenades_ApplyModWeaponVars )
    #if SERVER
    foreach (string grenade in ROGUELIKE_GRENADES)
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

    DamageInfo_ScaleDamage( damageInfo, Roguelike_GetGrenadeDamageBoost( Roguelike_GetStat( attacker, STAT_TEMPER ) ) )

    
    entity sourceWeapon = Roguelike_FindWeaponForDamageInfo( damageInfo )

    if (!IsValid(sourceWeapon))
        return

    array<string> weaponPerks = Roguelike_GetWeaponPerks(sourceWeapon)
    if (weaponPerks.contains("epic"))
    {
        DamageInfo_ScaleDamage( damageInfo, 1.15 )
    }
    if (weaponPerks.contains("legendary"))
    {
        DamageInfo_ScaleDamage( damageInfo, 1.25 )
    }
    //if ("roguelikeLevel" in sourceWeapon.s)
    //    DamageInfo_ScaleDamage( damageInfo, 1.0 + 0.1 * expect int(sourceWeapon.s.roguelikeLevel) )
}
#endif

void function Grenades_ApplyModWeaponVars( entity weapon )
{
    string weaponClassName = weapon.GetWeaponClassName()
    entity owner = weapon.GetWeaponOwner()
    if (!ROGUELIKE_GRENADES.contains(weaponClassName))
        return

    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 300 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_default_total, 300 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_stockpile_max, 300 )
    ModWeaponVars_SetString( weapon, eWeaponVar.ammo_display, "bar" )
    ModWeaponVars_SetFloat( weapon, eWeaponVar.regen_ammo_refill_rate, 10.0 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_min_to_fire, 150 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_per_shot, 150 )

    if (weaponClassName == "mp_weapon_thermite_grenade" || weaponClassName == "mp_weapon_grenade_gravity")
    {
        ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 450 )
        ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_default_total, 450 )
    }

    if (!IsValid(owner) || !owner.IsPlayer())
        return

    array<string> weaponPerks = Roguelike_GetWeaponPerks(weapon)
    int level = 0
    float bonus = 0.0
    
    foreach (string perk in weaponPerks)
    {
        if (StartsWith(perk, "level_"))
        {
            level = int( weaponPerks[0].slice( 6, weaponPerks[0].len() ))
            continue
        }

        switch (perk)
        {
            case "common":
            case "rare":
            case "uncommon":
            case "epic":
            case "legendary":
                break

            default:
                RoguelikeWeaponPerk perk = GetWeaponPerkDataByName(perk)
                if (perk.mwvCallback != null)
                    perk.mwvCallback( weapon, owner, level )
                break
        }
    }

    weapon.s.roguelikeLevel <- level

    ScaleCooldown( weapon, 1.0 - level * 0.1 )
}