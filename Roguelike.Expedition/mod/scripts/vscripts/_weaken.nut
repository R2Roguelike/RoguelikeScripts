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

    if (attacker)

    if (IsValid( inflictor ) && inflictor.IsProjectile() && inflictor.proj.isChargedShot) // atg missile
    {
        return // do NOT add weaken. thanks
    }
    if (attacker != ent)
    {
        if (Roguelike_HasMod( attacker, "dumbfire_rockets" ))
            AddWeaken( ent, attacker, 2.0 / 9.0 )
        else
            AddWeaken( ent, attacker, 1.0 / 9.0 )
    }
}


void function PrimaryDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (!attacker.IsPlayer())
        return

    float weaken = GetWeaken( ent )
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

void function AddWeaken( entity ent, entity attacker, float amount )
{
    if (amount <= 0)
        return

    float cur = GetWeaken( ent )
    cur = cur + amount
    RSE_Apply( ent, RoguelikeEffect.expedition_weaken, cur, 16.0 * cur, 16.0 * cur )
}

void function RemoveWeaken( entity ent, entity attacker, float amount )
{
    if (amount <= 0)
        return

    float cur = GetWeaken( ent )
    cur = cur - amount
    if (cur > 0)
        RSE_Consume( ent, RoguelikeEffect.expedition_weaken, amount, false )
}

float function GetWeaken( entity ent )
{
    return RSE_Get( ent, RoguelikeEffect.expedition_weaken )
}
