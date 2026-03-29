global function AbilitySlot_Display

string function FormatDuration( float val )
{
    if (val < 10)
    {
        return format("%.1fs", val)
    }

    return format("%.0fs", val)
}


// beacon 3 stays
HoverSimpleBox ornull function GetCooldown( string weapon, int offhandSlot )
{
    if (weapon == "")
        return null

    float multiplier = 1.0
    
    // script_ui "for (int i = 1; i < 5; i++) { Roguelike_GetRunData()["ACTitan" + i].mainStats[0] = GetStatByName("ability_duration").index }"
    switch (offhandSlot)
    {
        case 0:
            if (Roguelike_HasMod("offensive_cd"))
                multiplier *= 0.75
            break
        case 1:
            if (Roguelike_HasMod("defensive_cd"))
                multiplier *= 0.75
            break
        case 2:
            if (Roguelike_HasMod("utility_cd"))
                multiplier *= 0.75
            break
    }
    HoverSimpleBox box
    switch (GetWeaponInfoFileKeyField_Global(weapon, "cooldown_type"))
    {
        case "shield":
            int ammoPerShot = GetWeaponInfoFileKeyField_GlobalInt(weapon, "ammo_per_shot")

            box.label = "Shield Cost"
            box.icon = $"ui/lightning"
            box.initialValue = string(ammoPerShot)
            box.currentValue = string(int(ammoPerShot * Roguelike_GetStat("cd_reduction") * multiplier))
            break

        case "ammo":
        case "ammo_instant":
        case "ammo_deployed":
        case "ammo_timed":
        case "ammo_per_shot":
            int ammoPerShot = GetWeaponInfoFileKeyField_GlobalInt(weapon, "ammo_per_shot")
            float regenRate = GetWeaponInfoFileKeyField_GlobalFloat(weapon, "regen_ammo_refill_rate")
            float cooldown = ammoPerShot / regenRate

            box.label = "Cooldown"
            box.icon = $"ui/cooldown"
            box.initialValue = FormatDuration(cooldown)
            box.currentValue = FormatDuration(cooldown * Roguelike_GetStat("cd_reduction") * multiplier)
            break

        case "charged_shot":
        case "chargeFrac":
        case "vortex_drain":
            float cooldown = GetWeaponInfoFileKeyField_GlobalFloat(weapon, "charge_cooldown_time")

            box.label = "Cooldown"
            box.icon = $"ui/cooldown"
            box.initialValue = FormatDuration(cooldown)
            box.currentValue = FormatDuration(cooldown * Roguelike_GetStat("cd_reduction") * multiplier)
            break

        case "shared_energy":
            int ammoPerShot = GetWeaponInfoFileKeyField_GlobalInt(weapon, "shared_energy_cost")

            box.label = "Energy Cost"
            box.icon = $"ui/lightning"
            box.initialValue = format("%.0f%%", ammoPerShot / 100.0)
            box.currentValue = format("%.0f%%", ammoPerShot * Roguelike_GetStat("cd_reduction") * multiplier / 100.0)
            break

        case "shared_energy_drain":
            int ammoPerShot = GetWeaponInfoFileKeyField_GlobalInt(weapon, "shared_energy_charge_cost") * 60 // drain per sec

            box.label = "Ion Energy Consumed"
            box.icon = $"ui/lightning"
            box.initialValue = format("%.1f%%/s", ammoPerShot / 100.0) // / 10000 * 100
            ammoPerShot = int(ammoPerShot / (1.0 + Roguelike_GetStat("ability_duration")))
            box.currentValue = format("%.1f%%/s", (ammoPerShot * Roguelike_GetStat("cd_reduction") * multiplier) / 100.0) // / 10000 * 100
            break


        default:
            //ModWeaponVars_ScaleVar( weapon, eWeaponVar.grapple_power_required, scalar )
            return null
    }

    return box
}

string function FormatRange( float val )
{
    float valMeters = val * 0.0254
    if (valMeters < 10)
    {
        return format("%.1fm", valMeters)
    }

    return format("%.0fm", valMeters)
}

void function AbilitySlot_Display( var slot, string weapon, int offhandSlot )
{
    asset icon = GetWeaponInfoFileKeyFieldAsset_Global( weapon, "hud_icon" )
    RuiSetImage( Hud_GetRui( Hud_GetChild( slot, "Icon" ) ), "basicImage", icon )

    AddHover( slot, void function( var slot, var panel ) : (weapon, offhandSlot) 
    {
        HoverSimpleData data
        data.title = GetWeaponInfoFileKeyField_GlobalString( weapon, "shortprintname" )
        data.description = GetWeaponInfoFileKeyField_GlobalString( weapon, "longdesc" )

        bool putCdOnNewLine = true 

        // this is fucked but holy shit i do not care
        if (weapon == "mp_titanweapon_shoulder_rockets")
        {
            {
                float base = 35
                float current = base + Roguelike_GetStat("ability_power") * 0.3 + Roguelike_GetTagCount( EXPEDITION_WEAKEN_TAG ) * 10
                HoverSimpleBox box
                box.initialValue = format("+%.0f%%", base)
                box.currentValue = format("+%.0f%%", current)
                box.label = "Weaken DMG Bonus <burn>(↑↑ Ability Power)"
                box.abilityPowerBox = true
                data.boxes.append(box)
            }
            {
                HoverSimpleBox box
                box.initialValue = FormatDuration(1.778)
                box.currentValue = FormatDuration(1.778 * (1.0 + Roguelike_GetStat("ability_duration")))
                box.label = "<weak>Weaken</> Duration/Rocket"
                data.boxes.append(box)
            }
            putCdOnNewLine = false
        }
        if (weapon == "mp_titancore_flame_wave")
        {
            {
                float base = SoftCastToFloat(GetWeaponInfoFileKeyField_Global( weapon, "damage_near_value_titanarmor" ))
                float scalar = SoftCastToFloat(GetWeaponInfoFileKeyField_Global( weapon, "ability_power_scalar_2" ))
                HoverSimpleBox box
                box.initialValue = string(base)
                box.currentValue = string(base + Roguelike_GetStat("ability_power") * scalar)
                box.label = "Damage <burn>(↑↑ Ability Power)"
                box.abilityPowerBox = true
                data.boxes.append(box)
            }
        }
        if (weapon == "mp_titanweapon_meteor")
        {
            {
                float base = 25
                float current = base + Roguelike_GetStat("ability_power") * 0.3
                if (Roguelike_HasMod("scorch_burn_dmg"))
                    current += 25
                HoverSimpleBox box
                box.initialValue = format("+%.0f%%", base)
                box.currentValue = format("+%.0f%%", current)
                box.label = "Burn Bonus DMG <burn>(↑↑ Ability Power)"
                box.abilityPowerBox = true
                data.boxes.append(box)
            }
        }
        if (weapon == "mp_titanweapon_laser_lite")
        {
            {
                float base = 2
                float current = base + Roguelike_GetStat("ability_power") * 0.01
                HoverSimpleBox box
                box.initialValue = format("x%.2f", base)
                box.currentValue = format("x%.2f", current)
                box.label = "<charge>Discharge</> Mult <burn>(↑↑ Ability Power)"
                box.abilityPowerBox = true
                data.boxes.append(box)
            }
            {
                float base = 3
                float current = base + Roguelike_GetStat("ability_power") * 0.015
                HoverSimpleBox box
                box.initialValue = format("x%.2f", base)
                box.currentValue = format("x%.2f", current)
                box.label = "<red>Disorder</> Mult <burn>(↑↑ AP)"
                box.abilityPowerBox = true
                box.newRow = true
                putCdOnNewLine = false
                data.boxes.append(box)
            }
        }
        if (weapon == "mp_titanweapon_laser_trip")
        {
            {
                float base = 30
                float current = base + Roguelike_GetStat("ability_power") * 0.1
                current += Roguelike_GetTagCount( ION_TURRET_DMG_TAG ) * 3.0
                HoverSimpleBox box
                box.initialValue = format("%.0f", base)
                box.currentValue = format("%.0f", current)
                box.label = "Projectile Damage"
                box.abilityPowerBox = true
                box.newRow = true
                putCdOnNewLine = false
                data.boxes.append(box)
            }
        }

        if (GetWeaponInfoFileKeyField_Global( weapon, "ability_power_base_value" ) != null)
        {
            float baseRange = -1.0
            var rangeVar = GetWeaponInfoFileKeyField_Global( weapon, "ability_power_base_value" )
            float scalar = SoftCastToFloat(GetWeaponInfoFileKeyField_Global( weapon, "ability_power_scalar_1" ))
            if (typeof(rangeVar) == "string")
            {
                baseRange = SoftCastToFloat(GetWeaponInfoFileKeyField_Global( weapon, expect string(rangeVar) ))
            }
            else if (typeof(rangeVar) == "float")
            {
                baseRange = expect float(rangeVar)
            }
            else
            {
                baseRange = float(rangeVar)
            }

            float curValue = baseRange + (Roguelike_GetStat("ability_power") * scalar)
            float baseValue = baseRange

            string valueFormat = string(curValue)
            string bonusFormat = string(baseValue)
            string label = rangeVar == "explosionradius" ? "Radius" : "Range"

            switch (GetWeaponInfoFileKeyField_Global( weapon, "ability_power_format" ))
            {
                case "time":
                    valueFormat = FormatDuration(curValue)
                    bonusFormat = FormatDuration(baseValue)
                    label = "Cast Time"
                    break
                case "bonus":
                    valueFormat = format("+%.0f%%", curValue)
                    bonusFormat = format("+%.0f%%", baseValue)
                    label = "Bonus DMG"
                    break
                case "range":
                    valueFormat = FormatRange(curValue)
                    bonusFormat = FormatRange(baseValue)
                    break
                case "speed":
                    valueFormat = FormatRange(curValue) + "/s" // lmao
                    bonusFormat = FormatRange(baseValue) + "/s" // lmao2
                    label = "Speed"
                    break
                case "regen_rate":
                    valueFormat = format("+%.2f%%/s", curValue)
                    bonusFormat = format("+%.2f%%/s", baseValue)
                    label = "Energy Regen Rate"
                    break
                default:
                    label = expect string(GetWeaponInfoFileKeyField_Global( weapon, "ability_power_format" ))
                    break
            }
            HoverSimpleBox box
            box.abilityPowerBox = true
            box.initialValue = bonusFormat
            box.currentValue = valueFormat
            box.label = label + " <burn>(↑↑ Ability Power)"
            data.boxes.append(box)
        }
        if (GetWeaponInfoFileKeyField_Global( weapon, "ability_duration_base_value" ) != null
            && GetWeaponInfoFileKeyField_Global( weapon, "ability_duration_base_value" ) != -1)
        {
            float baseDuration = -1.0
            var durationVar = GetWeaponInfoFileKeyField_Global( weapon, "ability_duration_base_value" )
            if (typeof(durationVar) == "string")
            {
                baseDuration = expect float(GetWeaponInfoFileKeyField_Global( weapon, expect string(durationVar) ))
            }
            else if (typeof(durationVar) == "float")
            {
                baseDuration = expect float(durationVar)
            }
            else
            {
                baseDuration = float(durationVar)
            }
            HoverSimpleBox box
            box.initialValue = FormatDuration(baseDuration)
            box.currentValue = FormatDuration(baseDuration * (1.0 + Roguelike_GetStat("ability_duration")))
            box.label = "Duration"
            data.boxes.append(box)
            putCdOnNewLine = false
        }
        HoverSimpleBox ornull cdBox = GetCooldown(weapon, offhandSlot)
        if (offhandSlot != -1 && cdBox != null)
        {
            expect HoverSimpleBox(cdBox)
            cdBox.newRow = putCdOnNewLine
            data.boxes.append(cdBox)
        }
        HoverSimple_SetData(data)
    } ,HOVER_SIMPLE)
}
