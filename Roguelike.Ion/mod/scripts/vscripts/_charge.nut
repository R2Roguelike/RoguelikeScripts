global function Charge_Init
global function IonDischarge
global function AddDisorderCallback

array<float functionref( entity, entity, var )> disorderCallbacks


void function Charge_Init()
{
    AddDamageCallbackSourceID( eDamageSourceId.ion_discharge, DischargeDamage )
    AddDamageCallbackSourceID( eDamageSourceId.ion_disorder, DisorderDamage )
}

// returns a scalar to add to the disorder dmg. 
// value returned should be around 1-2.
// the status effect should end.
void function AddDisorderCallback( float functionref( entity, entity, var ) callback )
{
    disorderCallbacks.append(callback)
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
    float scalar = DISCHARGE_SCALAR
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
    if (RSE_Get( ent, RoguelikeEffect.legion_puncture ) > 0)
    {
        disorder = true
        scalar += RSE_Get( ent, RoguelikeEffect.legion_puncture )
        RSE_Stop( ent, RoguelikeEffect.legion_puncture )
    }
    foreach (float functionref(entity,entity,var) callback in disorderCallbacks)
    {
        float result = callback(ent, attacker, damageInfo)
        if (result != 0)
        {
            disorder = true
            scalar += result
        }
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
    // Discharge/Disorder may crit
    if ((DamageInfo_GetCustomDamageType( damageInfo ) & DF_CRITICAL) == 0)
    {
        if (Roguelike_HasMod( attacker, "discharge_crit" ))
            DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL ) // always crit
    }
    
    if (Roguelike_HasMod( attacker, "laser_disorder" ))
    {
        attacker.AddSharedEnergy(2500)
    }
    
    printt("DISORDER!", scalar)
    DamageInfo_ScaleDamage( damageInfo, scalar )
    RSE_Stop( ent, RoguelikeEffect.ion_charge )
}