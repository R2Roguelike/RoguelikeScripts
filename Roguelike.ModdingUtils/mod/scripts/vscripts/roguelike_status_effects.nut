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
#if CLIENT
global function ServerCallback_RSE_Apply
#endif

global table<int, string> effectDisplayNames = {
    [ RoguelikeEffect.rearm_reload ] = "Rearmed",
    [ RoguelikeEffect.damage_sacrifice_1 ] = "-20% damage",
    [ RoguelikeEffect.damage_sacrifice_2 ] = "-40% damage",
    [ RoguelikeEffect.segment_sacrifice_1 ] = "+20% damage",
    [ RoguelikeEffect.segment_sacrifice_2 ] = "+40% damage",
    [ RoguelikeEffect.ronin_block_buff ] = "Block Power",
    [ RoguelikeEffect.overcrit ] = "Overcrit"
}

global table<int, bool> effectDisplayPercentage = {
    [ RoguelikeEffect.ronin_block_buff ] = true
}
global table<int, bool> effectDisplayStacks = {
    [ RoguelikeEffect.overcrit ] = true
}

#if SERVER
void function RoguelikeStatusEffects_Init()
{
    AddCallback_OnLoadSaveGame( void function( entity player ) : ()
        {
            foreach (entity ent in entitiesToSync)
            {
                foreach (int effect, RSEInstance instance in ent.e.rseData)
                {
                    delaythread(0.1) Remote_CallFunction_NonReplay( player, "ServerCallback_RSE_Apply", ent.GetEncodedEHandle(), effect, instance.stacks, instance.startTime, instance.endTime, instance.fadeOutTime )
                }
            }
        }
    )
}
#endif

RSEInstance ornull function RSE_FindEffect( entity ent, int effect )
{
    foreach (RSEInstance instance in ent.e.rseData)
        if (instance.effect == effect)
            return instance

    return null
}

float function RSE_Get( entity ent, int effect )
{
    RSEInstance ornull instance = RSE_FindEffect( ent, effect )
    if (instance == null)
        return 0.0

    expect RSEInstance(instance)

    return GraphCapped( Time(), instance.endTime - instance.fadeOutTime, instance.endTime, instance.stacks, 0.0 )
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
// if you keep your game running for more than 11 days on the same level unpaused, that is NOT my problem.
// ent - entity to apply the status effect to
// effect - the type of effect to apply
// stacks - the amount stacks to apply. can be fractional
// duration - duration
// fadeOutTime - fade out time. during fadeout, stacks drops LINEARLY.
// refresh - if an effect of the same type previously existed, do we override its duration or not
void function RSE_Apply( entity ent, int effect, float stacks, float duration = 999999.9, float fadeOutTime = 0.0, bool refresh = true )
{
    RSEInstance instance;
    instance.stacks = stacks
    instance.startTime = Time()
    instance.endTime = Time() + duration
    instance.fadeOutTime = fadeOutTime
    instance.effect = effect

    RSEInstance ornull oldEffect = RSE_FindEffect( ent, effect )
    if (oldEffect != null)
    {
        expect RSEInstance(oldEffect)
        if (oldEffect.endTime > Time() && !refresh)
        {
            instance.startTime = oldEffect.startTime
            instance.endTime = oldEffect.endTime
            instance.fadeOutTime = oldEffect.fadeOutTime
        }
        ent.e.rseData.fastremovebyvalue(oldEffect)
    }

    // sync upon load checkpoint
    entitiesToSync.append(ent)
    thread void function() : (ent)
    {
        ent.WaitSignal("OnDestroy")
        entitiesToSync.fastremovebyvalue(ent)
    }()
    
    ent.e.rseData.append(instance)

    foreach (entity player in GetPlayerArray())
        Remote_CallFunction_Replay( player, "ServerCallback_RSE_Apply", ent.GetEncodedEHandle(), effect, stacks, instance.startTime, instance.endTime, fadeOutTime )
}

// RSE_Consume
// ent - the entity to consume status effect
// amount - the amount of stacks to consume. if -1, consume all stacks.
// 
float function RSE_Consume( entity ent, int effect, float amount, bool refresh = false )
{
    RSEInstance ornull oldEffect = RSE_FindEffect( ent, effect )

    if (oldEffect == null)
        return 0.0
    
    RSEInstance instance = expect RSEInstance(oldEffect)

    // normalize it from relative to actual amount to relative to starting amount
    // this is so when we RSE_Consume( ent, effect, 0.5 ) during fadeout, we actually consume 0.5 stacks relative to current time instead of les
    if (amount == -1)
    {
        RSE_Apply( ent, effect, 0.0, 0.0, 0.0 )
        return instance.stacks
    }

    float frac = GraphCapped( Time(), instance.endTime - instance.fadeOutTime, instance.endTime, 1.0, 0.0 )
    amount /= frac

    amount = min(instance.stacks, amount)
    if (refresh)
    {
        RSE_Apply( ent, effect, instance.stacks - amount, RSE_GetDuration( instance ), instance.fadeOutTime )
        return amount
    }

    RSE_Apply( ent, effect, instance.stacks - amount, Time() - instance.endTime, instance.fadeOutTime )
    return amount
}

// RSE_Stop
// stops a status effect. Equivalent to RSE_Consume( ent, effect, -1 ).
float function RSE_Stop( entity ent, int effect )
{
    return RSE_Consume( ent, effect, -1 )
}
#endif

#if CLIENT
void function ServerCallback_RSE_Apply( int handle, int effect, float amount, float startTime, float endTime, float fadeOutTime )
{
    RSEInstance instance;
    instance.stacks = amount
    instance.startTime = startTime
    instance.endTime = endTime
    instance.fadeOutTime = fadeOutTime
    instance.effect = effect

    printt(effect)
    entity ent = GetEntityFromEncodedEHandle( handle )

    // hopefully safe to ignore???????
    if (!IsValid( ent ))
    {
        return
    }
    
    RSEInstance ornull oldEffect = RSE_FindEffect( ent, effect )

    if (oldEffect != null)
        ent.e.rseData.fastremovebyvalue(expect RSEInstance(oldEffect))

    ent.e.rseData.append(instance)
}
#endif