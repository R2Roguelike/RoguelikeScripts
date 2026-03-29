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

void function DamageOverTime( entity ent, entity attacker, float dps, float ticksPerSecond, float duration )
{
    ent.EndSignal("OnDeath")
    ent.EndSignal("OnDestroy")
    attacker.EndSignal("OnDeath")
    attacker.EndSignal("OnDestroy")
    int count = int(ceil(duration * ticksPerSecond))
    for ( int i = 0; i < count; i++ )
    {
        ent.TakeDamage( dps / ticksPerSecond, attacker, attacker, { damageSourceId=eDamageSourceId.mp_titanability_rearm }) // hack to make it appear as expedition dmg
        wait 1.0 / ticksPerSecond
    }
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
    {
        if (Roguelike_HasMod( attacker, "crippling_missiles" ))
            thread DamageOverTime( ent, attacker, 10.0, 2.0, 5.0 * (1.0 + Roguelike_GetStat( attacker, "ability_duration" )))
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
    float duration = 16.0
    duration *= 1.0 + Roguelike_GetStat( attacker, "ability_duration" )
    RSE_Apply( ent, RoguelikeEffect.expedition_weaken, cur, duration * cur, duration * cur )
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
