global function Charge_Init
global function IonDischarge

void function Charge_Init()
{
    AddDamageCallbackSourceID( eDamageSourceId.ion_discharge, DischargeDamage )
    AddDamageCallbackSourceID( eDamageSourceId.ion_disorder, DisorderDamage )
}

void function DischargeDamage( entity ent, var damageInfo )
{
	DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_DISCHARGE )
}

void function DisorderDamage( entity ent, var damageInfo )
{
	DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_DISORDER )
}

void function IonDischarge( entity ent, entity attacker, var damageInfo )
{
    if (!attacker.IsPlayer())
        throw "attacker is not a player"

    bool disorder = false
    float scalar = 1
    int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
    if (GetBurn( ent ) > 0.0)
    {
        disorder = true
        //
        scalar += GetBurn( ent ) * 0.02 // +200% at 200%
        RSE_Stop( ent, RoguelikeEffect.burn )
        RSE_Stop( ent, RoguelikeEffect.burn_flame_core )
    }
    if (GetDaze( ent ) > 0)
    {
        disorder = true
        scalar += RSE_Get( ent, RoguelikeEffect.ronin_daze ) * 0.333
        RSE_Stop( ent, RoguelikeEffect.ronin_daze )
    }
    if (GetWeaken( ent ) > 0)
    {
        disorder = true
        scalar += RSE_Get( ent, RoguelikeEffect.expedition_weaken ) * 2
        RSE_Stop( ent, RoguelikeEffect.expedition_weaken )
    }
    if (RSE_Get( ent, RoguelikeEffect.northstar_fulminate ) > 0)
    {
        disorder = true
        scalar += RSE_Get( ent, RoguelikeEffect.northstar_fulminate )
        RSE_Stop( ent, RoguelikeEffect.northstar_fulminate )
    }
    DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_DISCHARGE )
    if (disorder)
    {
        DamageInfo_AddDamageFlags( damageInfo, DAMAGEFLAG_DISORDER )
        scalar += DISORDER_SCALAR_BONUS
    }
    else
    {
    }
    scalar += 1
    int count = 0
    array<string> mods = ["laser_disorder", "discharge_battery", "discharge_crit"]
    foreach (string mod in mods)
    {
        if (Roguelike_HasMod( attacker, mod ))
            count++
    }
    // Discharge/Disorder cannot crit
    
    if (Roguelike_HasMod( attacker, "laser_disorder" ) && damageSourceId == eDamageSourceId.mp_titanweapon_laser_lite)
    {
        attacker.AddSharedEnergy(5000)
    }

    if (!Roguelike_HasMod( attacker, "discharge_crit" ))
        DamageInfo_RemoveCustomDamageType( damageInfo, DF_CRITICAL )

    scalar *= 1.0 + (0.25 * count)
    printt("DISORDER!", scalar)
    DamageInfo_ScaleDamage( damageInfo, scalar )
    RSE_Stop( ent, RoguelikeEffect.ion_charge )
}