untyped
global function Weaken_Init
global function AddWeaken
global function RemoveWeaken
global function GetWeaken

void function Weaken_Init()
{
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_shoulder_rockets, RocketDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_xo16_shorty, PrimaryDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_amp_core, CoreDamage )
}

void function RocketDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity inflictor = DamageInfo_GetInflictor( damageInfo )

    if (!attacker.IsPlayer())
        return

    if (IsValid( inflictor ) && inflictor.IsProjectile() && inflictor.proj.isChargedShot) // atg missile
    {
    }
    if (Roguelike_HasMod(attacker, "inverse_relationship") && attacker != ent)
    {
        int weaken = GetWeaken( ent )
        if (weaken > 0)
        {
            DamageInfo_ScaleDamage( damageInfo, 6 )
            RemoveWeaken( ent, attacker, 6 )
        }
        return
    }
    if (attacker != ent)
        AddWeaken( ent, attacker, 3 )
}


void function PrimaryDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer())
        return
    
    if (Roguelike_HasMod( attacker, "inverse_relationship" ) && attacker != ent)
    {
        AddWeaken( ent, attacker, 2 )
        return
    }
    int weaken = GetWeaken( ent )
    if (weaken > 0)
    {
        DamageInfo_ScaleDamage( damageInfo, 1.25 )
        RemoveWeaken( ent, attacker, 2 )
    }
}

void function CoreDamage( entity ent, var damageInfo )
{
    PrimaryDamage( ent, damageInfo )

    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer())
        return
    
    entity coreWeapon = attacker.GetActiveWeapon() // will always be equipped cuz its hitscan!!!
    coreWeapon.SetWeaponPrimaryClipCount(minint(coreWeapon.GetWeaponPrimaryClipCountMax(), coreWeapon.GetWeaponPrimaryClipCount() + 1))
}

void function AddWeaken( entity ent, entity attacker, int amount )
{
    if (amount <= 0)
        return

    if (GetTitanLoadoutFlags() == EXPEDITION_SCORCH)
    {
        AddBurn( ent, attacker, amount * 3 )
    }

    int cur = GetWeaken( ent )
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_weaken )
    cur = minint(cur + amount, 100)
    StatusEffect_AddEndless( ent, eStatusEffect.roguelike_weaken, cur / 255.0 )
}

void function RemoveWeaken( entity ent, entity attacker, int amount )
{
    if (amount <= 0)
        return

    int cur = GetWeaken( ent )
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_weaken )
    cur = maxint(cur - amount, 0)
    if (GetTitanLoadoutFlags() == EXPEDITION_RONIN)
    {
        AddDaze( ent, attacker, amount * 10 / 255.0 )
    }
    if (cur > 0)
        StatusEffect_AddEndless( ent, eStatusEffect.roguelike_weaken, cur / 255.0 )
}

int function GetWeaken( entity ent )
{
    return RoundToInt( StatusEffect_Get( ent, eStatusEffect.roguelike_weaken ) * 255.0 )
}
