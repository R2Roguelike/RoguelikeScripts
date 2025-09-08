untyped
global function Chests_Init
global function Roguelike_SetIgnoreBan

const float TRACE_DIST = 80 // lowering this makes the function more likely to generate at lower ceilings, at cost of load time
const float HULL_EXTENTS = 80 // lowering this makes the funtion find a navmesh point nearer to the random point, at cost of load time


void function Chests_Init()
{
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function Roguelike_SetIgnoreBan( entity ent )
{
    ent.s.ignoreBan <- true
}

array<vector> function GetLegendaryChestLocation()
{
    switch (GetMapName())
    {
        case "sp_crashsite":
            return [< -2880, -5530, 206 >, <0,10,0>]
        case "sp_sewers1":
            return [<13050, -13000, -120>, <0,165-90,-15>]
    }

    return []
}

void function EntitiesDidLoad()
{
	array<entity> hurtTriggers = GetEntArrayByClass_Expensive( "trigger_hurt" )
    hurtTriggers.extend( GetEntArrayByClass_Expensive("trigger_out_of_bounds") )
    int failedToNoTrace = 0;
    int failedToNoNav = 0;
    int failedToOOB = 0;
    int failedToTriggerHurt = 0;
    try { TimerEnd() } catch (eeee) {}
    TimerStart()

    entity worldspawn = GetEnt( "worldspawn" )

    array<vector> loc = GetLegendaryChestLocation()
    if (loc.len() == 2)
    {
        entity legendaryChest = CreatePropDynamic( $"models/containers/pelican_case_large.mdl", loc[0], loc[1], SOLID_VPHYSICS )
        Highlight_SetNeutralHighlight( legendaryChest, "roguelike_legendary_chest" )
        legendaryChest.Solid()
        legendaryChest.SetUsable()
        legendaryChest.SetUsableRadius( 200 )
        legendaryChest.SetUsePrompts( "me do nothing come back later", "me do nothing come back later" )
    }

    PRandom rand = NewPRandom(Roguelike_GetLevelSeed())
    for (int i = 0; i < 100;)
    {
        vector pos = <PRandomFloat(rand, -30000, 30000), PRandomFloat(rand, -30000, 30000), PRandomFloat(rand, -30000, 30000)>
        //                                                           vvv lowering this makes func more likely
        //
        TraceResults tr = TraceHull( pos, <pos.x, pos.y, pos.z - TRACE_DIST>, < -HULL_EXTENTS / 2, -HULL_EXTENTS / 2, 0>, < HULL_EXTENTS / 2, HULL_EXTENTS / 2, 90>, [], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
        if (!IsValid(tr.hitEnt))
        {
            failedToNoTrace++
            continue
        }

        vector ornull navPoint = NavMesh_ClampPointForHullWithExtents( tr.endPos, HULL_HUMAN, <HULL_EXTENTS, HULL_EXTENTS, 90> )

        if (navPoint == null)
        {
            failedToNoNav++
            continue
        }

        expect vector( navPoint )

        if (TraceLine(navPoint, <navPoint.x, navPoint.y, 65535>, [], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE).endPos.z > 30000)
        {
            failedToOOB++
            continue
        }
        if (TraceLine(navPoint, <navPoint.x, navPoint.y, -65535>, [], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE).endPos.z < -30000)
        {
            failedToOOB++
            continue
        }

        bool invalidLocation = false
        foreach (entity trigger in hurtTriggers)
        {
            if (trigger.ContainsPoint( navPoint ))
            {
                invalidLocation = true
                failedToTriggerHurt++
                break
            }
        }

        if (invalidLocation)
            continue

        bool isShop = PRandomInt(rand, 0, 5) == 1

        // to help with determinism, dont use the PRandom func here, since its pretty much only visual anyways
        asset model = isShop ?  $"models/beacon/beacon_crane_monitor.mdl" : $"models/containers/pelican_case_large.mdl" 
        vector offset = isShop ? <0,0,64> : <0,0,1>
        entity prop = CreatePropDynamic( model, navPoint + offset, <0,RandomFloatRange(-180, 180),0>, SOLID_VPHYSICS )
        Highlight_SetNeutralHighlight( prop, "roguelike_chest" )
        prop.Solid()
        prop.SetUsable( )
        prop.s.seed <- PRandomInt(rand)
        prop.SetUsableRadius( 200 )
        if (isShop)
            prop.SetUsePrompts( "Hold %use% to open the shop", "Press %use% to open the shop" )
        else
            prop.SetUsePrompts( "Hold %use% to open chest", "Press %use% to open chest" )
        //prop.SetParent(tr.hitEnt)
        //DispatchSpawn( prop )
         printt("<", navPoint.x, ",", navPoint.y, ",", navPoint.z, ">")

        thread void function() : (prop, isShop)
        {
            while (true)
            {
                var playerActivator = prop.WaitSignal("OnPlayerUse").player
                expect entity( playerActivator )    
                
                if (isShop)
                {
                    Remote_CallFunction_UI( playerActivator, "Roguelike_OpenShopMenu", expect int(prop.s.seed) )
                }
                else
                {
                    Highlight_ClearNeutralHighlight( prop )
                    prop.SetModel( $"models/containers/pelican_case_large_open.mdl" )
                    prop.UnsetUsable()
                    EmitSoundOnEntity( playerActivator, "UI_PostGame_FDSlideStop" )
                    EmitSoundOnEntity( playerActivator, "UI_PostGame_CoinPlace" )
                    Remote_CallFunction_UI( playerActivator, "Roguelike_GenerateLoot", expect int(prop.s.seed) )
                    return
                }
            }
        }()
        i++
    }

    printt("failedToNoTrace", failedToNoTrace)
    printt("failedToNoNav", failedToNoNav)
    printt("failedToOOB", failedToOOB)
    printt("failedToTriggerHurt", failedToTriggerHurt)
    printt("Total Time:", TimerEnd() / 1000.0)
}