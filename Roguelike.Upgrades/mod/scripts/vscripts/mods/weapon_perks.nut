global function WeaponPerks_Init

void function WeaponPerks_Init()
{
    array<string> projectileWeapons = ["mp_weapon_sniper", "mp_weapon_doubletake", "mp_weapon_epg", 
        "mp_weapon_lstar", "mp_weapon_arc_launcher", "mp_weapon_wingman_n", "mp_weapon_softball"]
    array<string> spreadWeapons = clone ROGUELIKE_PILOT_WEAPONS
    spreadWeapons.fastremovebyvalue("mp_weapon_shotgun")
    spreadWeapons.fastremovebyvalue("mp_weapon_mastiff")
    spreadWeapons.fastremovebyvalue("mp_weapon_shotgun_pistol")
    spreadWeapons.fastremovebyvalue("mp_weapon_arc_launcher")
    spreadWeapons.fastremovebyvalue("mp_weapon_wingman_n")
    {
        RoguelikeWeaponPerk mod = NewMod("reload_time")
        mod.description = "-%.0f%% Reload Time."
        mod.slot = PERK_SLOT_STAT
        mod.baseValue = 0.15
        mod.valuePerLevel = 0.1
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            foreach (int weaponVar in RELOAD_TIME_VARS)
                ModWeaponVars_ScaleVar( weapon, weaponVar, 1.0 - value )
        } 
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("mag_size")
        mod.description = "+%.0f%% Mag Size."
        mod.slot = PERK_SLOT_STAT
        mod.baseValue = 0.2
        mod.valuePerLevel = 0.1
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.ammo_clip_size, 1.0 + value )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("viewkick")
        mod.description = "-%.0f%% Recoil."
        mod.slot = PERK_SLOT_STAT
        mod.baseValue = 0.25
        mod.valuePerLevel = 0.1
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            float scalar = 1.0 - value
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_firstshot_hipfire, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_min_hipfire, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_max_hipfire, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_firstshot_ads, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_min_ads, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.viewkick_scale_max_ads, scalar )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("hipfire_spread")
        mod.description = "-%.0f%% Hipfire Spread."
        mod.slot = PERK_SLOT_STAT
        mod.baseValue = 0.25
        mod.valuePerLevel = 0.15
        mod.allowedWeapons = spreadWeapons
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            float scalar = 1.0 - value
            foreach (int weaponVar in ADS_SPREAD_VARS)
                ModWeaponVars_ScaleVar( weapon, weaponVar, scalar )
            foreach (int weaponVar in HIP_SPREAD_VARS)
                ModWeaponVars_ScaleVar( weapon, weaponVar, scalar )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("range")
        mod.description = "+%.0f%% Range/Blast Radius."
        mod.slot = PERK_SLOT_STAT
        mod.allowedWeapons = ROGUELIKE_PILOT_WEAPONS
        mod.baseValue = 0.2
        mod.valuePerLevel = 0.1
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            float scalar = 1.0 + value
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_distance, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_distance, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_very_far_distance, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_inner_radius, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosionradius, scalar )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("velocity")
        mod.description = "+%.0f%% Projectile Velocity."
        mod.slot = PERK_SLOT_STAT
        mod.allowedWeapons = projectileWeapons
        mod.baseValue = 0.4
        mod.valuePerLevel = 0.2
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            float scalar = 1.0 + value
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.projectile_launch_speed, scalar )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("titan_dmg")
        mod.description = "+%.0f%% Titan DMG."
        mod.slot = PERK_SLOT_STAT
        mod.baseValue = 0.1
        mod.valuePerLevel = 0.05
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            float scalar = 1.0 + value
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_value_titanarmor, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_value_titanarmor, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_damage_heavy_armor, scalar )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("handling")
        mod.description = "-%.0f%% Swap and ADS in/out Time."
        mod.slot = PERK_SLOT_STAT
        mod.baseValue = 0.25
        mod.valuePerLevel = 0.15
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            float value = mod.baseValue + mod.valuePerLevel * weaponLevel
            float scalar = 1.0 - value
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.raise_time, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.lower_time, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.deploy_time, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.holster_time, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.zoom_time_in, scalar )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.zoom_time_out, scalar )
        }
        #endif
    }

    // PERKS

    {
        RoguelikeWeaponPerk mod = NewMod("explode_kill")
        mod.name = "Explosive Contents"
        mod.description = "Enemies explode on kill."
        mod.slot = PERK_SLOT_PERK
    }
    {
        RoguelikeWeaponPerk mod = NewMod("heal_clip")
        mod.name = "Heal Clip"
        mod.description = "Rapidly killing enemies heals you."
        mod.slot = PERK_SLOT_PERK
    }
    {
        RoguelikeWeaponPerk mod = NewMod("kill_self_dmg")
        mod.name = "Deal with Death"
        mod.description = "Enemy kills grant a stacking damage reduction buff."
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ROGUELIKE_MOVEMENT_TOOLS
    }
    {
        RoguelikeWeaponPerk mod = NewMod("load_other_weapon_on_kill")
        mod.name = "Sidearm"
        mod.description = "On kill, reload your other weapon."
        mod.slot = PERK_SLOT_INHERIT
        mod.allowedWeapons = ["mp_weapon_autopistol", "mp_weapon_wingman", "mp_weapon_wingman_n", "mp_weapon_semipistol", "mp_weapon_shotgun_pistol"]
    }
    {
        RoguelikeWeaponPerk mod = NewMod("rush")
        mod.name = "Rush"
        mod.description = "Kills with this weapon grant <cyan>+40% movement speed for 8s</>."
        mod.slot = PERK_SLOT_PERK
    }
    {
        RoguelikeWeaponPerk mod = NewMod("patience")
        mod.name = "Patience"
        mod.description = "Waiting before firing this weapon increases damage. <red>Includes self-damage!</> Resets when holstered or reloaded."
        mod.slot = PERK_SLOT_PERK
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            ModWeaponVars_ScaleDamage( weapon, GraphCapped( Time() - weapon.GetNextAttackAllowedTime(), 1.5, 6.0, 1.0, 3.0 ) )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("regen_ammo")
        mod.name = "Regen Ammo"
        mod.description = "This weapon regenerates ammo when not firing, as long as its not empty."
        mod.slot = PERK_SLOT_PERK
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            ModWeaponVars_AddToVar( weapon, eWeaponVar.regen_ammo_refill_rate, weapon.GetWeaponSettingFloat(eWeaponVar.fire_rate) * 0.75 )
            ModWeaponVars_SetFloat( weapon, eWeaponVar.regen_ammo_refill_start_delay, 
                max(1.8 / weapon.GetWeaponSettingFloat(eWeaponVar.fire_rate), weapon.GetWeaponSettingFloat(eWeaponVar.regen_ammo_refill_start_delay)) )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("eva_choke")
        mod.name = ""
        mod.description = "Spread +100%, Range +50%."
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ["mp_weapon_shotgun"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            foreach (int weaponVar in ADS_SPREAD_VARS)
                ModWeaponVars_ScaleVar( weapon, weaponVar, 2 )
            foreach (int weaponVar in HIP_SPREAD_VARS)
                ModWeaponVars_ScaleVar( weapon, weaponVar, 2 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_near_distance, 2 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.damage_far_distance, 1.5 )
            ModWeaponVars_SetInt( weapon, eWeaponVar.rui_crosshair_index, 1 )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("star_burst")
        mod.name = "Gamblok"
        mod.description = "+25% DMG. Fires a random amount of shots each burst."
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ["mp_weapon_hemlok"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            weapon.SetWeaponBurstFireCount( int(GraphCapped(pow(weapon.GetNextAttackAllowedTime(), 2) % 0.05, 0, 0.05, 1, 6 )) )
            ModWeaponVars_SetBool( weapon, eWeaponVar.looping_sounds, false )
            ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_min_to_fire, 1 )
            ModWeaponVars_ScaleDamage( weapon, 1.25 )
            ModWeaponVars_SetString( weapon, eWeaponVar.burst_or_looping_fire_sound_start_1p, "" )
            ModWeaponVars_SetString( weapon, eWeaponVar.fire_sound_2_player_1p, "weapon_g2a4_fire_1p" )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("doom_shotgun")
        mod.name = "Super Shotgun"
        mod.description = "+100% DMG, Reloads after every shot. No self-damage, <red>no shotgun launching</>."
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ["mp_weapon_mastiff"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            ModWeaponVars_ScaleDamage( weapon, 2 )
            ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_per_shot, 2 )
            ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_min_to_fire, 2 )
            ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_size_segmented_reload, 2 )
            ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_size, 2 )
            ModWeaponVars_SetInt( weapon, eWeaponVar.ammo_clip_reload_max, 2 ) 
            ModWeaponVars_SetFloat( weapon, eWeaponVar.reloadempty_time, 1.0 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_damage, 0.0 )
            
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("turbocharger")
        mod.name = "Turbocharger"
        mod.description = "Fire rate speeds up much quicker."
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ["mp_weapon_esaw"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            ModWeaponVars_SetBool( weapon, eWeaponVar.looping_sounds, false )
            ModWeaponVars_SetFloat( weapon, eWeaponVar.fire_rate_max_time_speedup, 0.75 )
            ModWeaponVars_SetString( weapon, eWeaponVar.fire_sound_2_player_1p, "weapon_devotion_firstshot_1p" )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("quintuple_take")
        mod.name = "Double-Double Take"
        mod.description = "Fires double the projectiles, in bursts of two. -25% DMG per projectile"
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ["mp_weapon_doubletake"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            ModWeaponVars_SetInt( weapon, eWeaponVar.burst_fire_count, 2 )
            weapon.SetWeaponBurstFireCount(2)
            ModWeaponVars_SetFloat( weapon, eWeaponVar.fire_rate, 7.0 )
            ModWeaponVars_SetFloat( weapon, eWeaponVar.burst_fire_delay, 0.6 )
            ModWeaponVars_ScaleDamage( weapon, 0.75 )
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("w-star")
        mod.name = "Infinite Overheat"
        mod.description = "Instead of overheating, the L-star deals damage to you."
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ["mp_weapon_lstar"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            if (weapon.GetWeaponPrimaryClipCount() == 1)
            {
                #if SERVER
                owner.TakeDamage( 5, owner, owner, { damageSourceId = eDamageSourceId.mp_weapon_lstar })
                #endif
                weapon.SetWeaponPrimaryClipCount(2)
            }
        }
        #endif
    }
// script_ui Roguelike_AddToInventory( RoguelikeWeapon_CreateWeapon("mp_weapon_hemlok", RARITY_RARE, "primary", "star_burst") )
    {
        RoguelikeWeaponPerk mod = NewMod("firestar-launcher")
        mod.name = "Firestar Rifle"
        mod.description = "Launches firestars as projectiles."
        mod.slot = PERK_SLOT_PERK
        mod.allowedWeapons = ["mp_weapon_sniper"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            ModWeaponVars_SetInt(weapon, eWeaponVar.projectile_ricochet_max_count, 10 )
            ModWeaponVars_SetFloat(weapon, eWeaponVar.bolt_bounce_frac, 0.0 )
            ModWeaponVars_SetFloat(weapon, eWeaponVar.projectile_lifetime, 10.0 )
            ModWeaponVars_SetFloat(weapon, eWeaponVar.explosionradius, 120.0 )
            ModWeaponVars_SetFloat(weapon, eWeaponVar.explosion_inner_radius, 5.0 )
            ModWeaponVars_SetInt(weapon, eWeaponVar.explosion_damage, 15 )
            ModWeaponVars_SetInt(weapon, eWeaponVar.explosion_damage_heavy_armor, 25 )
        }
        #endif
    }

    // GRENADE PERKS
    {
        RoguelikeWeaponPerk mod = NewMod("extra_charge")
        mod.name = "Extra Charge"
        mod.description = "+1 Charge."
        mod.slot = PERK_SLOT_GRENADE
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("extra_cd")
        mod.name = "Cooldown++"
        mod.description = "-10% cooldown."
        mod.slot = PERK_SLOT_GRENADE
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("impact_nade")
        mod.name = "Impact Frag"
        mod.description = "Detonates on impact."
        mod.slot = PERK_SLOT_GRENADE
        mod.allowedWeapons = ["mp_weapon_frag_grenade"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
        }
        #endif
    }
    {
        RoguelikeWeaponPerk mod = NewMod("blast_nade")
        mod.name = "Concussive"
        mod.description = "-50% DMG, +25% knockback."
        mod.slot = PERK_SLOT_GRENADE
        mod.allowedWeapons = ["mp_weapon_frag_grenade", "mp_weapon_satchel"]
        #if SERVER || CLIENT
        mod.mwvCallback = void function( entity weapon, entity owner, int weaponLevel ) : (mod)
        {
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.explosion_damage, 0.5 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.impulse_force, 1.25 )
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.impulse_force_explosions, 1.25 )
        }
        #endif
    }
}

RoguelikeWeaponPerk function NewMod(string uniqueName)
{
    RoguelikeWeaponPerk mod = Roguelike_NewWeaponPerk(uniqueName)

    return mod
}