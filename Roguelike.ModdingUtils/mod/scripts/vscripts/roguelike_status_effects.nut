global function RSE_Get
global function RSE_GetIntensity
// CLIENT should never use these, since these arent predicted
#if SERVER
global function RSE_Apply
global function RSE_Consume
global function RSE_Stop
global function RoguelikeStatusEffects_Init
array<entity> entitiesToSync
#endif
global function RSE_GetEffectFrac
global function RSE_GetEffectEndTime
#if CLIENT
global function ServerCallback_RSE_Apply
#endif

global table<int, string> effectDisplayNames = {
    [ RoguelikeEffect.rearm_reload ] = "Rearmed",
    [ RoguelikeEffect.damage_sacrifice_1 ] = "-20% damage",
    [ RoguelikeEffect.damage_sacrifice_2 ] = "-40% damage",
    [ RoguelikeEffect.segment_sacrifice_1 ] = "+20% damage",
    [ RoguelikeEffect.segment_sacrifice_2 ] = "+40% damage",
    [ RoguelikeEffect.scorch_warmth ] = "Warm",
    [ RoguelikeEffect.ronin_block_buff ] = "Block Power",
    [ RoguelikeEffect.overcrit ] = "Overcrit",
    [ RoguelikeEffect.parry ] = "Parry CD",
    [ RoguelikeEffect.counter ] = "Counter CD",
    [ RoguelikeEffect.offense_canister ] = "Burning!",
    [ RoguelikeEffect.master_fire ] = "Fire Mastery",
    [ RoguelikeEffect.master_electric ] = "Energy Mastery",
    [ RoguelikeEffect.master_physical ] = "Physical Mastery",
    [ RoguelikeEffect.explosive_start ] = "Explosive Start",
    [ RoguelikeEffect.explosive_end ] = "Explosive End",
    [ RoguelikeEffect.kill_self_dmg ] = "Deal with Death",
    [ RoguelikeEffect.physical_spread ] = "Impending Impact",
    [ RoguelikeEffect.gun_shield_shield ] = "Shields to Shields",
    [ RoguelikeEffect.polarity_blue ] = "Blue Polarity",
    [ RoguelikeEffect.polarity_red ] = "Red Polarity",
    [ RoguelikeEffect.swap ] = "Divided",
    [ RoguelikeEffect.dash_plus ] = "Dash+",
    [ RoguelikeEffect.buff_turret ] = "Turret Buff",
    [ RoguelikeEffect.mag_size_inf ] = "Blood Mag",
    [ RoguelikeEffect.brute_quickload_firerate ] = "Quickfire",
    [ RoguelikeEffect.dual_load ] = "Dual Load",
    [ RoguelikeEffect.infinite_ammo ] = "Infinite Ammo",
    [ RoguelikeEffect.burst_load ] = "Burst Load",
    [ RoguelikeEffect.brute_infinite_core ] = "Power Core",
    [ RoguelikeEffect.arm_load ] = "Loading Arm",
    [ RoguelikeEffect.xo16_intensify ] = "Intensifying Magazine",
    [ RoguelikeEffect.tanky_perk ] = "Batterized"
}

global table<int, bool functionref( entity )> effectDisplayConditions = {
}

global table<int, bool> effectDisplayPercentage = {
    [ RoguelikeEffect.ronin_block_buff ] = true,
    //[ RoguelikeEffect.brute_infinite_core ] = true
}

global table<int, bool> effectDisplayStacks = {
    [ RoguelikeEffect.overcrit ] = true,
    [ RoguelikeEffect.kill_self_dmg ] = true,
    [ RoguelikeEffect.polarity_blue ] = true,
    [ RoguelikeEffect.polarity_red ] = true,
    [ RoguelikeEffect.mag_size_inf ] = true,
    [ RoguelikeEffect.tanky_perk ] = true,
    [ RoguelikeEffect.explosive_end ] = true,
    [ RoguelikeEffect.xo16_intensify ] = true
}

#if SERVER
void function RoguelikeStatusEffects_Init()
{
    AddCallback_OnLoadSaveGame( void function( entity player ) : ()
        {
            foreach (int i, entity ent in entitiesToSync)
            {
                foreach (int effect, RSEInstance instance in ent.e.rseData)
                {
                    if (instance.endTime < Time())
                        continue
                    
                    delaythread(i * 0.01) Remote_CallFunction_NonReplay( player, "ServerCallback_RSE_Apply", ent.GetEncodedEHandle(), effect, instance.stacks, instance.startTime, instance.endTime, instance.fadeOutTime, false, instance.instanceId )
                }
            }
        }
    )
}
#endif

array<RSEInstance> function RSE_FindEffect( entity ent, int effect )
{
    array<RSEInstance> result = []
    foreach (RSEInstance instance in ent.e.rseData)
    {
        if (instance.effect == effect)
            result.append( instance )
    }

    return result
}

float function RSE_Get( entity ent, int effect )
{
    for (int i = ent.e.rseData.len() - 1; i > -1; i--)
    {
        if (ent.e.rseData[i].endTime < Time())
            ent.e.rseData.remove(i)
    }
    array<RSEInstance> instances = RSE_FindEffect( ent, effect )
    if (instances.len() <= 0)
        return 0.0

    float value = 0.0
    foreach (RSEInstance instance in instances)
    {
        value += GraphCapped( Time(), instance.endTime - instance.fadeOutTime, instance.endTime, instance.stacks, 0.0 )
    }

    return value
}

float function RSE_GetIntensity( RSEInstance instance )
{
    return GraphCapped( Time(), instance.endTime - instance.fadeOutTime, instance.endTime, instance.stacks, 0.0 )
}

float function RSE_GetDuration( RSEInstance instance )
{
    return instance.endTime - instance.startTime
}

#if SERVER
bool function RSE_HasInstanceId( entity ent, int effect, int instanceId )
{
    foreach (RSEInstance instance in ent.e.rseData)
    {
        if (instance.effect == effect && instance.instanceId == instanceId)
            return true
    }
    return false
}

// if you keep your game running for more than 11 days on the same level unpaused, that is NOT my problem.
// ent - entity to apply the status effect to
// effect - the type of effect to apply
// stacks - the amount stacks to apply. can be fractional
// duration - duration
// fadeOutTime - fade out time. during fadeout, stacks drops LINEARLY.
// refresh - if an effect of the same type previously existed, do we override it or not
void function RSE_Apply( entity ent, int effect, float stacks, float duration = 999999.9, float fadeOutTime = 0.0, bool refresh = true, int instanceId = -1 )
{
    RSEInstance instance;
    instance.stacks = stacks
    instance.startTime = Time()
    instance.endTime = Time() + duration
    instance.fadeOutTime = fadeOutTime
    instance.effect = effect
    instance.instanceId = instanceId

    for (int i = ent.e.rseData.len() - 1; i > -1; i--)
    {
        if (ent.e.rseData[i].endTime < Time())
            ent.e.rseData.remove(i)
    }
    
    array<RSEInstance> oldEffect = RSE_FindEffect( ent, effect )
    if (oldEffect.len() > 0 && refresh)
    {
        foreach (RSEInstance e in oldEffect)
        {
            if (instanceId == e.instanceId)
                ent.e.rseData.fastremovebyvalue(e)
        }
        oldEffect.clear()
    }

    // sync upon load checkpoint
    if (!entitiesToSync.contains(ent))
    {
        entitiesToSync.append(ent)
        thread void function() : (ent)
        {
            WaitSignal(ent, "OnDeath", "OnDestroy")
            entitiesToSync.fastremovebyvalue(ent)
        }()
    }

    ent.e.rseData.append(instance)

    foreach (entity player in GetPlayerArray())
        Remote_CallFunction_Replay( player, "ServerCallback_RSE_Apply", ent.GetEncodedEHandle(), effect, stacks, instance.startTime, instance.endTime, fadeOutTime, refresh, instanceId )
}

// RSE_Consume
// ent - the entity to consume status effect
// amount - the amount of stacks to consume. if -1, consume all stacks.
//
// wasnt use so im removing support for it, complicated to implement with multiple instances now being applicable to a single entity
float function RSE_Consume( entity ent, int effect, float amount, bool refresh = false )
{
    return -1
}

// RSE_Stop
// stops a status effect. Equivalent to RSE_Consume( ent, effect, -1 ).
void function RSE_Stop( entity ent, int effect )
{
    RSE_Apply( ent, effect, 0.0, 0.0, 0.0, true )
}
#endif

float function RSE_GetEffectEndTime( entity ent, int effect )
{
    array<RSEInstance> instances = RSE_FindEffect( ent, effect )
    if (instances.len() <= 0)
        return 0.0

    float result = 0.0
    foreach (RSEInstance instance in instances)
        result = max(instance.endTime, result)

    return result
}

float function RSE_GetEffectFrac( entity ent, int effect )
{
    array<RSEInstance> instance = RSE_FindEffect( ent, effect )
    if (instance.len() == 0)
        return 0.0
    if (instance.len() > 1)
        return -1.0

    return GraphCapped( Time(), instance[0].startTime, instance[0].endTime, 1.0, 0.0 )
}

#if CLIENT
void function ServerCallback_RSE_Apply( int handle, int effect, float amount, float startTime, float endTime, float fadeOutTime, bool refresh, int instanceId )
{
    RSEInstance instance;
    instance.stacks = amount
    instance.startTime = startTime
    instance.endTime = endTime
    instance.fadeOutTime = fadeOutTime
    instance.effect = effect
    instance.instanceId = instanceId

    entity ent = GetEntityFromEncodedEHandle( handle )

    // hopefully safe to ignore???????
    if (!IsValid( ent ))
    {
        return
    }

    for (int i = ent.e.rseData.len() - 1; i > -1; i--)
    {
        if (ent.e.rseData[i].endTime < Time())
            ent.e.rseData.remove(i)
    }
    array<RSEInstance> oldEffect = RSE_FindEffect( ent, effect )
    
    if (oldEffect.len() > 0 && refresh)
    {
        foreach (RSEInstance e in oldEffect)
        {
            if (e.instanceId == instanceId)
                ent.e.rseData.fastremovebyvalue(e)
        }
        oldEffect.clear()
    }

    ent.e.rseData.append(instance)
}
#endif