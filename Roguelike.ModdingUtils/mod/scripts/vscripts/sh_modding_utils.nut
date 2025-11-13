globalize_all_functions

void function ModdingUtils_Init()
{
    print("balls")
    if (IsSingleplayer())
        SetConVarBool("sv_cheats", true)
    else
        SetConVarBool("sv_cheats", false)
}

entity function __w()
{
    return __p().GetActiveWeapon()
}

entity function __p()
{
    return GetPlayerArray()[0]
}

void function __core()
{
    #if SERVER
     PlayerEarnMeter_AddOwnedFrac( GetPlayerArray()[0], 5 )
     #endif
}

void function __die()
{
    #if SERVER
     GetPlayerArray()[0].Die()
     #endif
}

entity function __offhand(int slot)
{
    return __p().GetOffhandWeapon(slot)
}

void function __cooldown(int slot)
{
    entity offhand = __p().GetOffhandWeapon(slot)
    print(offhand.GetWeaponSettingInt(eWeaponVar.ammo_per_shot) / offhand.GetWeaponSettingFloat(eWeaponVar.regen_ammo_refill_rate))
}

#if SERVER
void function DEV_SpawnFrozenTitan(string baseClass, string aiSettings, int team, string weaponName = "")
{
    thread void function() : (baseClass, aiSettings, team, weaponName)
    {
	    bool restoreHostThreadMode = GetConVarInt( "host_thread_mode" ) != 0
        entity npc = DEV_SpawnNPCWithWeaponAtCrosshairStart( restoreHostThreadMode, baseClass, aiSettings, team, weaponName )
        DispatchSpawn( npc )
        npc.Freeze()

        AddEntityCallback_OnDamaged( npc, void function( entity titan, var damageInfo ) : (){
            if (titan.GetHealth() < DamageInfo_GetDamage( damageInfo ) && titan.IsFrozen())
                titan.Unfreeze()
        })
        DEV_SpawnNPCWithWeaponAtCrosshairEnd( restoreHostThreadMode )
    }()
}
#endif
