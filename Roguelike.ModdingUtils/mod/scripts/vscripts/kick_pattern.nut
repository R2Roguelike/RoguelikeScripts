global function KickPattern_ApplyModWeaponVars
array<string> kickPattern = [
         "-0.30 -0.54 0.40 0.40",
         "0.06 -0.68 0.30 0.30",
         "-0.37 -0.45 0.25 0.25",
         "0.09 -0.57 0.30 0.30",
         "-0.11 -0.45 0.25 0.25",
         "0.03 -0.25 0.25 0.25",
         "-0.06 -0.21 0.30 0.30",
         "-0.23 -0.08 0.30 0.30",
         "-0.17 -0.17 0.30 0.30",
         "-0.29 0.09 0.30 0.30",
         "-0.07 -0.21 0.30 0.30",
         "0.22 -0.23 0.40 0.40",
         "0.30 -0.23 0.40 0.40",
         "0.23 -0.11 0.40 0.40",
         "0.27 -0.07 0.45 0.45",
         "0.26 0.00 0.45 0.45",
         "0.18 0.07 0.45 0.45",
         "0.03 -0.19 0.45 0.45",
         "-0.13 -0.22 0.45 0.45",
         "-0.24 -0.16 0.45 0.45",
         "-0.23 0.00 0.45 0.45",
         "-0.24 -0.05 0.45 0.45",
         "-0.17 0.04 0.45 0.45",
         "-0.21 0.08 0.45 0.45",
         "-0.16 -0.02 0.45 0.45",
         "-0.02 -0.18 0.45 0.45",
         "0.08 -0.06 0.45 0.45",
         "-0.04 -0.09 0.45 0.45",
]


void function KickPattern_ApplyModWeaponVars( entity weapon )
{
    if (weapon.GetWeaponSettingInt(eWeaponVar.ammo_clip_size) <= 0)
        return
    try
    {
        int ammo = weapon.GetWeaponPrimaryClipCount()

        if (weapon.GetWeaponClassName() == "melee_pilot_emptyhanded")
            return

        int maxAmmo = weapon.GetWeaponSettingInt(eWeaponVar.ammo_clip_size)
        float ammoFrac = float(ammo) / maxAmmo
        
        int index = (maxAmmo - ammo) % kickPattern.len()
        array<string> kickPattern = split(kickPattern[index], " ")
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_pitch_base, float(kickPattern[1]))
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_yaw_base, float(kickPattern[0]))
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_pitch_random, 0.0)
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_yaw_random, 0.0)
        /*ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_hipfire_weaponFraction, 0.0)
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_ads_weaponFraction, 0.0)
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_perm_pitch_random, 0.0)
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_perm_yaw_random, 0.0)

        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_pitch_softScale, 0.0)
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_yaw_softScale, 0.0)
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_pitch_hardScale, 1.0)
        ModWeaponVars_SetFloat(weapon, eWeaponVar.viewkick_yaw_hardScale, 1.0)*/
    }
    catch (e)
    {
        // for some reason errors arent fatal here.
        // resort to console spam.
        printt(weapon, e)
    }
}
