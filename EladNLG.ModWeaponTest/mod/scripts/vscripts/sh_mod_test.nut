untyped
global function Sh_ModWeaponVarTest_Init
global function Roguelike_GetWeaponPerks

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

    if (IsValid(owner) && owner.IsPlayer())
    {
        PlayerWeaponBuffs( weapon, owner )
    }

    ModWeaponVars_SetInt( weapon, eWeaponVar.pass_through_depth, maxint(weapon.GetWeaponSettingInt(eWeaponVar.pass_through_depth), 1 ) )

    if (weapon.GetWeaponClassName() != "mp_titanweapon_sniper")
        ModWeaponVars_SetBool( weapon, eWeaponVar.critical_hit, false )
    else
    {
        if (IsValid(owner) && owner.IsPlayer())
        {
            bool hasCritCharge = Roguelike_HasMod( owner, "crit_charge" ) || ("cc" in weapon.s)
            if (hasCritCharge)
            {
                if (Roguelike_HasMod( owner, "crit_charge" ))
                    weapon.s.cc <- Time() + 10.0
                if (Time() > weapon.s.cc)
                    delete weapon.s.cc

                ModWeaponVars_ScaleVar( weapon, eWeaponVar.charge_time, 2.0 )
            }

        }
    }
    if (weapon.GetWeaponClassName() == "mp_titanweapon_leadwall" && IsValid(owner) && RSE_Get( owner, RoguelikeEffect.ronin_overload ) > 0.0)
        ModWeaponVars_SetBool( weapon, eWeaponVar.ammo_no_remove_from_clip, true )


    #if SERVER
    if (IsValid(owner) && !owner.IsPlayer())
    {
        NPCWeaponBuffs( weapon, owner )
    }
    #endif

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

            if (Time() - weapon.s.lastEquippedTime > max(min(5.0 / maxAmmo, 3.0), 0.05) - 0.01 && ammo < maxAmmo)
            {
                weapon.s.lastEquippedTime = Time()
                weapon.SetWeaponPrimaryClipCount(minint(maxAmmo, ammo + 1))
            }
        }

        if (IsValid(owner.GetActiveWeapon()) && !owner.GetActiveWeapon().IsWeaponOffhand())
        {
            ModWeaponVars_SetBool( weapon, eWeaponVar.instant_swap_to, true )
        }
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.deploy_time, 0.333 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.raise_time, 0.333 )
    }
}

void function PlayerWeaponBuffs( entity weapon, entity owner )
{
    ModWeaponVars_SetFloat( weapon, eWeaponVar.melee_attack_animtime, 0.8 )
    ModWeaponVars_SetFloat( weapon, eWeaponVar.melee_lunge_time, 0.1 )
    // quick recovery
    ModWeaponVars_SetFloat( weapon, eWeaponVar.melee_raise_recovery_animtime_normal, 0.1 )
    ModWeaponVars_SetFloat( weapon, eWeaponVar.melee_raise_recovery_animtime_quick, 0.1 )
    string weaponClassName = weapon.GetWeaponClassName()
    if (weaponClassName == "mp_titanability_rearm" && Roguelike_HasMod( owner, "quick_rearm" ))
        ScaleCooldown( weapon, 0.5 )
    else if (Roguelike_HasMod( owner, "quick_rearm" ) && owner.IsTitan())
    {
        ScaleCooldown( weapon, 4 ) // +300%
    }
    /*
    if (weaponClassName == "mp_weapon_frag_grenade" && Roguelike_HasMod( owner, "impact_frag"))
    {
    }
    */
    if (weaponClassName == "mp_weapon_wingman_n")
    {
        ModWeaponVars_ScaleDamage( weapon, 1.2 )
    }
    if (weaponClassName == "mp_titanweapon_xo16_shorty" && Roguelike_HasMod( owner, "xo16_long_range"))
    {
        //ModWeaponVars_SetBool( weapon, eWeaponVar.looping_sounds, false )
        //ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 0.9 )
        //ModWeaponVars_SetString( weapon, eWeaponVar.fire_sound_3, "Weapon_xo16_fire_first_1P" )
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
            ModWeaponVars_ScaleVar( weapon, weaponVar, 0.4 )
        foreach (int weaponVar in HIP_SPREAD_VARS)
            ModWeaponVars_ScaleVar( weapon, weaponVar, 0.6 )

    }
    if (Roguelike_HasMod( owner, "vortex_anti_drain") )
    {
        switch (weaponClassName)
        {
            case "mp_titanweapon_vortex_shield":
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.charge_time, 0.75 )
                break
            case "mp_titanweapon_vortex_shield_ion":
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.shared_energy_charge_cost, 1.334 )
                break
        }
    }
    if (weaponClassName == "mp_titanweapon_shoulder_rockets" && Roguelike_HasMod( owner, "dumbfire_rockets" ))
    {
        ModWeaponVars_ScaleDamage( weapon, 2.5 )
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
            int index = weapon.GetInventoryIndex()
            //float cdScalar = Roguelike_GetTitanCooldownReduction( power )
            if (weapon.GetWeaponInfoFileKeyField("cooldown_type") != "shared_energy")
                ScaleCooldown( weapon, 1.5 )


            if (index == 0 && Roguelike_HasMod( owner, "offensive_charge" ))
            {
                int ammoPerShot = weapon.GetAmmoPerShot()
                ModWeaponVars_AddToVar( weapon, eWeaponVar.ammo_clip_size, ammoPerShot )
                ModWeaponVars_AddToVar( weapon, eWeaponVar.ammo_default_total, ammoPerShot )
            }

            if (Roguelike_HasMod( owner, "offensive_cd" ) && index == 0)
                ScaleCooldown( weapon, 0.75 )
            if (Roguelike_HasMod( owner, "defensive_cd" ) && index == 1)
                ScaleCooldown( weapon, 0.75 )
            if (Roguelike_HasMod( owner, "utility_cd" ) && index == 2)
                ScaleCooldown( weapon, 0.75 )
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
            ScaleCooldown( weapon, 0.65 )
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
        if (owner.IsTitan())
        {
            if (Roguelike_HasMod( owner, "weapon_load" ))
            {
                foreach (int weaponVar in RELOAD_TIME_VARS)
                    ModWeaponVars_ScaleVar( weapon, weaponVar, 0.65 )
            }
            if (Roguelike_HasMod( owner, "bonus_mag" ))
            {
                int magSize = weapon.GetWeaponSettingInt(eWeaponVar.ammo_clip_size)
                ModWeaponVars_AddToVar( weapon, eWeaponVar.ammo_clip_size, minint(magSize, 50) )
            }
        }
        else
        {
            
            if (Roguelike_HasMod( owner, "mag_size_pilot" ))
            {
                entity ordnance = owner.GetOffhandWeapon(0)
                if (IsValid(ordnance) && Roguelike_GetWeaponElement( weaponClassName ) == Roguelike_GetWeaponElement( ordnance.GetWeaponClassName() ))
                    ModWeaponVars_AddToVar( weapon, eWeaponVar.ammo_clip_size, 5 )
            }

            
            array<string> weaponPerks = Roguelike_GetWeaponPerks( weapon )

            int stat = -1
            table<int, float> values = {
                [ RARITY_UNCOMMON ] = 0.0,
                [ RARITY_RARE ] = 0.0,
                [ RARITY_EPIC ] = 0.15,
                [ RARITY_LEGENDARY ] = 0.25
            }
            float valuePerLevel = 0.15

            if (weapon.GetWeaponInfoFileKeyField( "inventory_slot" ) == "special")
            {
                stat = eWeaponVar.impulse_force
                values = {
                    [ RARITY_UNCOMMON ] = 0.0,
                    [ RARITY_RARE ] = 0.0,
                    [ RARITY_EPIC ] = 0.25,
                    [ RARITY_LEGENDARY ] = 0.5
                }
                valuePerLevel = 0.25
            }

            float bonus = 0.0

            int level = 0
            
            foreach (string perk in weaponPerks)
            {
                if (StartsWith(perk, "level_"))
                {
                    level = int( weaponPerks[0].slice( 6, weaponPerks[0].len() ))
                    continue
                }

                switch (perk)
                {
                    case "uncommon":
                        bonus += values[RARITY_UNCOMMON]
                        break
                    case "rare":
                        bonus += values[RARITY_RARE]
                        break
                    case "epic":
                        bonus += values[RARITY_EPIC]
                        break
                    case "legendary":
                        bonus += values[RARITY_LEGENDARY]
                        break
                    default:
                        RoguelikeWeaponPerk perk = GetWeaponPerkDataByName(perk)
                        if (perk.mwvCallback != null)
                            perk.mwvCallback( weapon, owner, level )
                        break
                }
            }

            bonus += valuePerLevel * level

            if (stat == -1)
            {
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_value, 1.0 + bonus )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_value, 1.0 + bonus )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_value, 1.0 + bonus )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_damage, 1.0 + bonus )
            }
            else
                ModWeaponVars_ScaleVar( weapon, stat, 1.0 + bonus )


            ModWeaponVars_SetBool( weapon, eWeaponVar.ammo_no_remove_from_stockpile, true )
            if (Roguelike_HasMod( owner, "cq_plus" ))
                CloseQuartersPlus( weapon, owner )
            if (Roguelike_HasMod( owner, "long_plus" ))
                LongRangePlus( weapon, owner )
            if (Roguelike_HasMod( owner, "snipers_dream" ) && weapon.GetWeaponInfoFileKeyField("menu_category") == "sniper")
            {
                foreach (int weaponVar in HIP_SPREAD_VARS)
                    ModWeaponVars_ScaleVar( weapon, weaponVar, 0.2 )
                foreach (int weaponVar in RELOAD_TIME_VARS)
                    ModWeaponVars_ScaleVar( weapon, weaponVar, 0.75 )
                float zoomFov = weapon.GetWeaponSettingFloat( eWeaponVar.zoom_fov )
                ModWeaponVars_SetFloat( weapon, eWeaponVar.zoom_fov, GraphCapped( 0.25, 0, 1, zoomFov, 70 ) )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 1.25 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.rechamber_time, 0.8 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_value_titanarmor, 2.0 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_value_titanarmor, 2.0 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_damage_heavy_armor, 2.0 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.zoom_time_in, 0.001 )
                ModWeaponVars_ScaleVar( weapon, eWeaponVar.zoom_time_out, 0.001 )
            }

            if (Roguelike_HasMod( owner, "ranger" ))
            {
                foreach (int weaponVar in HIP_SPREAD_VARS)
                    ModWeaponVars_ScaleVar( weapon, weaponVar, 0.4 )

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
                float scalar = 0.5
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
    if (weaponClassName == "mp_titanweapon_particle_accelerator")
    {
        if (weapon.IsWeaponInAds() && !weapon.HasMod("proto_particle_accelerator"))
        {
            ModWeaponVars_SetBool( weapon, eWeaponVar.is_burn_mod, true )
        }
    }
    if (weaponClassName == "mp_titancore_flight_core" && Roguelike_HasMod( owner, "first_class_flight" ))
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.core_duration, 1.25 )
    if (Roguelike_HasMod( owner, "anti_shield" ))
    {
        ModWeaponVars_AddToVar( weapon, eWeaponVar.vortex_drain, 0.05 )
    }
    if (weaponClassName == "mp_titanability_hover" && Roguelike_HasMod( owner, "hover_toggle" ))
    {
        ScaleCooldown( weapon, 0.5 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.fire_duration, 0.25 )
    }
    if (weaponClassName == "mp_titanweapon_predator_cannon" && Roguelike_HasMod( owner, "mag_cap" ))
    {
        int overcap = weapon.GetWeaponSettingInt(eWeaponVar.ammo_clip_size) - 150
        if (overcap > 0)
        {
            ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 150 )
            ModWeaponVars_SetInt( weapon, eWeaponVar.custom_int_3, overcap )
        }
    }
    if (weaponClassName == "mp_titanweapon_particle_accelerator" && Roguelike_HasMod( owner, "energy_split" ))
    {
        ModWeaponVars_ScaleDamage( weapon, 0.666 )
    }
    if (weaponClassName == "mp_titanweapon_flightcore_rockets" && Roguelike_HasMod( owner, "cluster_core" ))
        ModWeaponVars_ScaleDamage( weapon, 0.3 )
}

void function LongRangePlus( entity weapon, entity owner )
{
    switch (weapon.GetWeaponInfoFileKeyField( "menu_category" ))
    {
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
        case "sniper":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.fire_rate, 1.25 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.rechamber_time, 0.8 )
            break
        default:
            // no effect
            break
    }
}

void function CloseQuartersPlus( entity weapon, entity owner )
{
    switch (weapon.GetWeaponInfoFileKeyField( "menu_category" ))
    {
        case "smg":
            foreach (int weaponVar in RELOAD_TIME_VARS)
                ModWeaponVars_ScaleVar( weapon, weaponVar, 0.8 )
            break
        case "shotgun":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_distance, 1.3 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_distance, 1.3 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_distance, 1.3 )
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
    foreach (int weaponVar in RELOAD_TIME_VARS)
        ModWeaponVars_ScaleVar( weapon, weaponVar, 0.25 )

    // mgl fucked fr fr
    if (weapon.GetWeaponClassName() == "mp_weapon_mgl")
        return
    if (weapon.GetWeaponClassName() == "mp_titanweapon_tracker_rockets")
        return
    // WHY
    if (weapon.GetWeaponClassName() == "mp_titanability_roguelike_pylon")
        return

    float cd = GraphCapped( GetConVarFloat("sp_difficulty"), 0, 3, 1, 0.05 )


    if (GetEliteType(owner) == "enraged")
    {
        ModWeaponVars_SetFloat( weapon, eWeaponVar.npc_max_range, 500 )
        ModWeaponVars_SetFloat( weapon, eWeaponVar.npc_min_range, 0 )
    }

    // defensives can be frustrating and also fuck w/ ai :/
    if (weapon.IsWeaponOffhand() && weapon.GetInventoryIndex() == 1)
    {
        cd = GraphCapped( GetConVarFloat("sp_difficulty"), 0, 3, 1, 0.75 )
        switch (Roguelike_GetRunModifier("defense"))
        {
            case 1:
                cd *= 0.5
                break
            case 2:
                cd *= 0.25
                break
            case 3:
                cd *= 0.0001
                break
        }
    }

    

    ModWeaponVars_ScaleVar( weapon, eWeaponVar.charge_cooldown_time, cd )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.regen_ammo_refill_rate, 1.0 / cd )
    ModWeaponVars_SetInt( weapon, eWeaponVar.npc_min_burst, 1 )
    ModWeaponVars_SetInt( weapon, eWeaponVar.npc_max_burst, 1 )

    if (owner.IsTitan() && weapon.IsWeaponOffhand())
    {
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_rest_time_between_bursts_min, cd )
    }
    else
    {
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_rest_time_between_bursts_min, 0.0 )
        ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_rest_time_between_bursts_max, 0.0 )
    }
    ModWeaponVars_SetFloat( weapon, eWeaponVar.npc_rest_time_between_bursts_max, weapon.GetWeaponSettingFloat(eWeaponVar.npc_rest_time_between_bursts_min) )

    ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_pre_fire_delay, 0.0 )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.npc_pre_fire_delay_interval, 0.0 )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.proficiency_good_additional_rest, 0.0 )
    ModWeaponVars_ScaleVar( weapon, eWeaponVar.proficiency_good_additional_rest, 0.0 )
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
            {
                delete player.s.storedAbilities
                delete player.s.currentLoadout
            }
            player.GiveWeapon(playerTitanWeapons[0])
            player.SetActiveWeaponByName(playerTitanWeapons[0])
            player.GiveWeapon(playerTitanWeapons[1])
            Roguelike_ResetTitanLoadoutFromPrimary( player, player.GetMainWeapons()[0] )
            print("GIVING WEAPON 2")
        }
    }()
}
#endif

string cachedVal
string cachedOffhandVal
array< array<string> > cachedResults
array< string > cachedOffhandResults
array<string> function Roguelike_GetWeaponPerks( entity weapon )
{
    if (!IsValid(weapon))
        return []
    entity owner = weapon.GetWeaponOwner()
    if (!IsValid(owner) || !owner.IsPlayer() || owner.IsTitan())
        return []

    if (weapon.IsWeaponOffhand())
    {
        if (weapon.GetInventoryIndex() != 0)
            return []
        
        if (GetConVarString("player_ordnance_perks") != cachedOffhandVal)
            cachedOffhandResults = split( GetConVarString("player_ordnance_perks"), "," )
        return cachedOffhandResults
    }

    if (GetConVarString("player_weapon_perks") != cachedVal)
    {
        cachedVal = GetConVarString("player_weapon_perks")
        cachedResults.clear()

        foreach (string perksStr in split( GetConVarString("player_weapon_perks"), " " ))
        {
            cachedResults.append(split(perksStr, ","))
        }
    }

    if (cachedResults.len() <= weapon.GetInventoryIndex())
        return []

    return cachedResults[weapon.GetInventoryIndex()]
}

