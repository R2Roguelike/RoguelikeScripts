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
        return // do NOT add weaken. thanks
    }
    if (attacker != ent)
        AddWeaken( ent, attacker, 30 )
}


void function PrimaryDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer())
        return

    int weaken = GetWeaken( ent )
    if (weaken > 0)
    {
        //RemoveWeaken( ent, attacker, 5 )
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

    int cur = GetWeaken( ent )
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_weaken )
    cur = cur + amount
    StatusEffect_AddTimed( ent, eStatusEffect.roguelike_weaken, cur / 255.0, 16.0 * cur / 255.0, 16.0 * cur / 255.0 )
}

void function RemoveWeaken( entity ent, entity attacker, int amount )
{
    if (amount <= 0)
        return

    int cur = GetWeaken( ent )
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_weaken )
    cur = cur - amount
    if (cur > 0)
        StatusEffect_AddTimed( ent, eStatusEffect.roguelike_weaken, cur / 255.0, 16.0 * cur / 255.0, 16.0 * cur / 255.0 )
}

int function GetWeaken( entity ent )
{
    return RoundToInt( StatusEffect_Get( ent, eStatusEffect.roguelike_weaken ) * 255.0 )
}
