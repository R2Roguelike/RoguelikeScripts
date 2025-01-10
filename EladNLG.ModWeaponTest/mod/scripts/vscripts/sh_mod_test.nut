untyped
global function Sh_ModWeaponVarTest_Init

void function Sh_ModWeaponVarTest_Init()
{
    AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_MULT, ApplyModWeaponVars )
    //AddCallback_ApplyModWeaponVars( 101, KickPattern_ApplyModWeaponVars )
    #if SERVER
	AddCallback_OnLoadSaveGame( RestoreWeaponLoadouts )
    #endif
}

void function ApplyModWeaponVars( entity weapon )
{
    entity owner = weapon.GetWeaponOwner()
    bool isStoredWeapon = false

    if ("storedWeaponOwner" in weapon.s && IsValid(weapon.s.storedWeaponOwner))
    {
        owner = expect entity(weapon.s.storedWeaponOwner)
        isStoredWeapon = true
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.regen_ammo_refill_start_delay, 0 )
    }

    // titan loadout stuff
    if (IsValid(owner) && owner.IsPlayer() && owner.IsTitan() && !weapon.IsWeaponOffhand())
    {
        #if CLIENT && SP
        Cl_SP_UpdateCoreIcon( -1 )
        #endif

        if (!("lastEquippedTime" in weapon.s))
            weapon.s.lastEquippedTime <- -99.9
        if (owner.GetLatestPrimaryWeapon() == weapon)
            weapon.s.lastEquippedTime = Time()
        
        if (Roguelike_HasMod( owner, "titan_holster" ))
        {
            int ammo = weapon.GetWeaponPrimaryClipCount()
            int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()

            if (Time() - weapon.s.lastEquippedTime > min(5.0 / maxAmmo, 2.0) && ammo < maxAmmo)
            {
                printt(weapon.GetWeaponClassName(), weapon.s.lastEquippedTime, Time())
                weapon.s.lastEquippedTime = Time()
                weapon.SetWeaponPrimaryClipCount(minint(maxAmmo, ammo + 1))
            }
        }

        if (IsValid(owner.GetActiveWeapon()) && !owner.GetActiveWeapon().IsWeaponOffhand())
        {
            ModWeaponVars_SetBool( weapon, eWeaponVar.instant_swap_to, true )
        }
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.deploy_time, 0.333 )
    }

    
    if (IsValid(owner) && owner.IsPlayer())
    {
        PlayerWeaponBuffs( weapon, owner )
    }

    #if SERVER
    if (IsValid(owner) && !owner.IsPlayer())
    {
        NPCWeaponBuffs( weapon, owner )
    }
    #endif
}

void function PlayerWeaponBuffs( entity weapon, entity owner )
{
    /*if (ammo == weapon.GetWeaponSettingInt(eWeaponVar.ammo_per_shot) && !weapon.IsWeaponOffhand())
    {
        ModWeaponVars_SetFloat( weapon, eWeaponVar.reload_time, weapon.GetWeaponSettingFloat(eWeaponVar.reload_time) * 0.5)
        ModWeaponVars_SetInt(weapon, eWeaponVar.damage_near_value, weapon.GetWeaponSettingInt(eWeaponVar.damage_near_value) * 2)
        ModWeaponVars_SetInt(weapon, eWeaponVar.damage_far_value, weapon.GetWeaponSettingInt(eWeaponVar.damage_far_value) * 2)
        ModWeaponVars_SetInt(weapon, eWeaponVar.damage_very_far_value, weapon.GetWeaponSettingInt(eWeaponVar.damage_very_far_value) * 2)
        ModWeaponVars_SetInt(weapon, eWeaponVar.explosion_damage, weapon.GetWeaponSettingInt(eWeaponVar.explosion_damage) * 2)
    if (weapon.GetWeaponClassName() == "mp_weapon_r97")
    {
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.ammo_clip_size, 1.0 + 0.5 * StatusEffect_Get( owner, eStatusEffect.roguelike_r97_bonus ) * 255 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 1.0 + 0.5 * StatusEffect_Get( owner, eStatusEffect.roguelike_r97_bonus ) * 255 )
    }
    }*/
    string weaponClassName = weapon.GetWeaponClassName()
    if (weaponClassName == "mp_titanability_rearm" && Roguelike_HasMod( owner, "quick_rearm" ))
        ScaleCooldown( weapon, 0.333 )
    if (["mp_titanweapon_vortex_shield", "mp_titanweapon_shoulder_rockets"].contains(weaponClassName) && Roguelike_HasMod( owner, "quick_rearm" ))
    {
        ScaleCooldown( weapon, 4 ) // +300%
    }
    if (weaponClassName == "mp_titanweapon_xo16_shorty" && Roguelike_HasMod( owner, "xo16_long_range"))
    {
        ModWeaponVars_SetBool( weapon, eWeaponVar.looping_sounds, false )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 0.833333 )
        ModWeaponVars_SetString( weapon, eWeaponVar.fire_sound_3, "Weapon_xo16_fire_first_1P" )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_distance, 2 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_distance, 2 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_distance, 2 )

        ModWeaponVars_SetFloat( weapon, eWeaponVar.spread_air_ads, 1.0 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.spread_air_hip, 2.0 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.spread_max_kick_air_hip, 0.3 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.spread_max_kick_stand_hip, 0.3 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.spread_max_kick_crouch_hip, 0.3 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.spread_max_kick_air_ads, 0.4 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.spread_max_kick_stand_ads, 0.4 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.spread_max_kick_crouch_ads, 0.4 )
        foreach (int weaponVar in ADS_SPREAD_VARS)
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_distance, 0.4 )
        foreach (int weaponVar in HIP_SPREAD_VARS)
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_distance, 0.6 )

    }
    if (weaponClassName == "mp_titanweapon_shoulder_rockets" && Roguelike_HasMod( owner, "dumbfire_rockets" ))
    {
        ModWeaponVars_SetFloat( weapon, eWeaponVar.charge_time, 0.001 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.smart_ammo_search_angle, 0.0 )

        ModWeaponVars_SetFloat( weapon, eWeaponVar.viewkick_yaw_base, 0 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.viewkick_pitch_base, -0.5 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.viewkick_yaw_random, 1 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.viewkick_pitch_random, 0.5 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.viewkick_hipfire_weaponFraction, 0.5 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.viewkick_ads_weaponFraction, 0.5 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.fire_rate, 10 )

        ModWeaponVars_SetBool( weapon, eWeaponVar.smart_ammo_search_players, false )
        ModWeaponVars_SetBool( weapon, eWeaponVar.smart_ammo_search_npcs, false )
        ModWeaponVars_SetInt( weapon, eWeaponVar.rui_crosshair_index, 1 )
    }
    if (weapon.IsWeaponOffhand())
    {
        
        ScaleCooldown( weapon, max(GetConVarFloat("cooldown_reduction"), 0.001) )
        
        if (owner.IsTitan())
        {
            int power = Roguelike_GetStat( owner, STAT_POWER )
            float cdScalar = Roguelike_GetTitanCooldownReduction( power )
            ScaleCooldown( weapon, cdScalar )
        }
        else
        {
            int temper = Roguelike_GetStat( owner, STAT_TEMPER )
            float cdScalar = Roguelike_GetPilotCooldownReduction( temper )
            ScaleCooldown( weapon, cdScalar )
        }

        // Frost Walker
        if (owner.IsSprinting() && Roguelike_HasMod( owner, "frost_walker" ) && owner.IsTitan())
        {
            ScaleCooldown( weapon, 0.5 )
        }
        
        if (weapon.GetInventoryIndex() == 0 && Roguelike_HasMod( owner, "big_boom" ))
        {
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosionradius, 1.25 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_inner_radius, 1.25 )
        }

        if (IsCloaked( owner ) && weapon.GetInventoryIndex() == 0 && Roguelike_HasMod( owner, "cloak_nades" ) && !owner.IsTitan())
        {
            ScaleCooldown( weapon, 0.25 )
        }

        if (weaponClassName == "mp_titanweapon_arc_wave")
        {
            if (IsAlive( owner ) && IsTitanCoreFiring( owner ) // are we using core
            && Roguelike_HasMod( owner, "overcharged_arc_wave" )) // overcharged waves decreases cooldown for arc wave whenever we use core
            {
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.regen_ammo_refill_start_delay, 0.25 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.regen_ammo_refill_rate, 20.0 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_value_titanarmor, 0.333 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_value_titanarmor, 0.333 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 1.5 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.lower_time, 0.5 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.holster_time, 0.5 )
            }
        }
    }
    else
    {
        if (!owner.IsTitan())
        {
            #if CLIENT
            string weaponPerksConVar = GetConVarString( "player_weapon_perks" )
            #elseif SERVER
            string weaponPerksConVar = expect string( owner.GetUserInfoString( "player_weapon_perks" ) )
            #endif
            array<string> weaponPerks
            if (weaponPerksConVar.len() > 0 && weapon.GetInventoryIndex() < 2)
                weaponPerks = split( split( weaponPerksConVar, " " )[weapon.GetInventoryIndex()], "," )

            if (weaponPerks.contains("uncommon"))
                ModWeaponVars_ScaleDamage( weapon, 1.15 )
            else if (weaponPerks.contains("rare"))
                ModWeaponVars_ScaleDamage( weapon, 1.3 )
            else if (weaponPerks.contains("epic"))
                ModWeaponVars_ScaleDamage( weapon, 1.4 )
            else if (weaponPerks.contains("legendary"))
                ModWeaponVars_ScaleDamage( weapon, 1.5 )
            
            //printt(weaponPerks.len())
            if (weaponPerks.len() > 0 && StartsWith(weaponPerks[0], "level_"))
            {
                int level = int( weaponPerks[0].slice( 6, weaponPerks[0].len() ))
                ModWeaponVars_ScaleDamage( weapon, 1.0 + 0.15 * level )
            }


            ModWeaponVars_SetBool( weapon, eWeaponVar.ammo_no_remove_from_stockpile, weapon.GetWeaponInfoFileKeyField("inventory_slot") != "special" )
            if (Roguelike_HasMod( owner, "weapons_plus" ))
                WeaponsPlus( weapon, owner )
            
            if (Roguelike_HasMod( owner, "ranger" ))
            {
                foreach (int weaponVar in HIP_SPREAD_VARS)
                    ModWeaponVars_ScaleVar( weapon, weaponVar, 0.6 )
                    
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_distance, 1.3 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_distance, 1.3 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_distance, 1.3 )
            }

            if (Roguelike_HasMod( owner, "loader" ))
            {
                foreach (int weaponVar in RELOAD_TIME_VARS)
                    ModWeaponVars_ScaleVar( weapon, weaponVar, 0.8 )
            }

            if (Roguelike_HasMod( owner, "compensator" ))
            {
                float scalar = 0.75
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_firstshot_hipfire, scalar )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_min_hipfire, scalar )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_max_hipfire, scalar )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_firstshot_ads, scalar )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_min_ads, scalar )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_max_ads, scalar )
                scalar = 0.4
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_pitch_random, scalar )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_yaw_random, scalar )
            }
        }
    }
}

void function WeaponsPlus( entity weapon, entity owner )
{
    switch (weapon.GetWeaponInfoFileKeyField( "menu_category" ))
    {
        case "smg":
            foreach (int weaponVar in RELOAD_TIME_VARS)
                ModWeaponVars_ScaleVar( weapon, weaponVar, 0.8 )
            break
        case "lmg":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.ammo_clip_size, 1.2 )
            break
        case "ar":
            float scalar = 0.8
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_firstshot_hipfire, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_min_hipfire, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_max_hipfire, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_firstshot_ads, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_min_ads, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_max_ads, scalar )
            break
        case "shotgun":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_distance, 1.3 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_distance, 1.3 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_distance, 1.3 )
            break
        case "sniper":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 1.25 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.rechamber_time, 0.9 ) // reduced effect
            break
        case "special":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosionradius, 1.25 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_inner_radius, 1.5 )
            break
        case "pistol":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_value, 1.3 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_value, 1.3 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_value, 1.3 )
            break
        default:
            // no effect
            break
    }
}

#if SERVER

void function NPCWeaponBuffs( entity weapon, entity owner )
{
    printt(weapon, owner)
    foreach (int weaponVar in RELOAD_TIME_VARS)
        ModWeaponVars_ScaleVar( weapon, weaponVar, 0.25 )
    
    // mgl fucked fr fr
    if (weapon.GetWeaponClassName() == "mp_weapon_mgl")
        return
    
    float cd = GraphCapped( GetConVarFloat("sp_difficulty"), 0, 3, 1, 0.05 )
    
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.charge_cooldown_time, cd )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.regen_ammo_refill_rate, 1.0 / cd )
    if (owner.IsTitan() && weapon.IsWeaponOffhand())
    {
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_rest_time_between_bursts_min, cd )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.npc_rest_time_between_bursts_max, weapon.GetWeaponSettingFloat(eWeaponVar.npc_rest_time_between_bursts_min) )
    }
    else
    {
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_rest_time_between_bursts_min, cd )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.npc_rest_time_between_bursts_max, weapon.GetWeaponSettingFloat(eWeaponVar.npc_rest_time_between_bursts_min) )
    }
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_pre_fire_delay, 0.0 )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_pre_fire_delay_interval, 0.0 )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.proficiency_good_additional_rest, 0.0 )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.proficiency_good_additional_rest, 0.0 )

    if (owner.IsTitan() && weapon.GetWeaponType() != WT_TITANCORE)
    {
        switch (GetSpDifficulty())
        {
            case DIFFICULTY_HARD:
                ModWeaponVars_SetInt( weapon, eWeaponVar.npc_damage_near_value, 
                    (weapon.GetWeaponSettingInt(eWeaponVar.damage_near_value) + weapon.GetWeaponSettingInt(eWeaponVar.npc_damage_near_value)) / 2)
                ModWeaponVars_SetInt( weapon, eWeaponVar.npc_damage_far_value, 
                    (weapon.GetWeaponSettingInt(eWeaponVar.damage_far_value) + weapon.GetWeaponSettingInt(eWeaponVar.npc_damage_far_value)) / 2)
                break
            case DIFFICULTY_MASTER:
                ModWeaponVars_SetInt( weapon, eWeaponVar.npc_damage_near_value, 
                    weapon.GetWeaponSettingInt(eWeaponVar.damage_near_value))
                ModWeaponVars_SetInt( weapon, eWeaponVar.npc_damage_far_value, 
                    weapon.GetWeaponSettingInt(eWeaponVar.damage_far_value))
                break
        }
    }
}

void function RestoreWeaponLoadouts( entity player )
{
    delaythread(0.1) void function() : (player)
    {
        if (player.IsTitan())
        {
            TakeAllWeapons( player )
            array<string> playerTitanWeapons = Roguelike_GetTitanLoadouts()

            if ("storedAbilities" in player.s)
                delete player.s.storedAbilities
            player.GiveWeapon(playerTitanWeapons[0])
            player.SetActiveWeaponByName(playerTitanWeapons[0])
            player.GiveWeapon(playerTitanWeapons[1])
            Roguelike_ResetTitanLoadoutFromPrimary( player, player.GetActiveWeapon() )
            print("GIVING WEAPON 2")
        }
    }()
}
#endif
