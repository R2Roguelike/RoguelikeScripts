untyped
global function Chests_Init
global function Roguelike_SetIgnoreBan

const float TRACE_DIST = 150 // lowering this makes the function more likely to generate at lower ceilings, at cost of load time
const float HULL_EXTENTS = 80 // lowering this makes the funtion find a navmesh point nearer to the random point, at cost of load time


void function Chests_Init()
{
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function Roguelike_SetIgnoreBan( entity ent )
{
    ent.s.ignoreBan <- true
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

    
    /*entity legendaryChest = CreatePropDynamic( $"models/containers/pelican_case_large.mdl", < -2880, -5530, 206 >, <0,10,0>, SOLID_VPHYSICS )
    Highlight_SetNeutralHighlight( legendaryChest, "roguelike_legendary_chest" )
    legendaryChest.Solid()
    legendaryChest.SetUsable()
    legendaryChest.SetUsableRadius( 200 )
    legendaryChest.SetUsePrompts( "me do nothing come back later", "me do nothing come back later" )*/
    //vector worldMins = expect vector( worldspawn.kv.world_mins )
    //vector worldMaxs = expect vector( worldspawn.kv.world_maxs )

    for (int i = 0; i < 60;)
    {
        vector rand = <RandomFloatRange(-30000, 30000), RandomFloatRange(-30000, 30000),RandomFloatRange(-30000, 30000)>
        //                                                           vvv lowering this makes func more likely
        //
        TraceResults tr = TraceLine( rand, <rand.x, rand.y, rand.z - TRACE_DIST>, [], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
        if (!IsValid(tr.hitEnt))
        {
            failedToNoTrace++
            continue
        }
        
        vector ornull navPoint = NavMesh_ClampPointForHullWithExtents( tr.endPos, HULL_HUMAN, <HULL_EXTENTS, HULL_EXTENTS, 72> )

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
        if (TraceLine(navPoint, <navPoint.x, navPoint.y, -65535>, [], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE).endPos.z > 30000)
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
        
        entity prop = CreatePropDynamic( $"models/containers/pelican_case_large.mdl", navPoint + <0,0,1>, <0,RandomFloatRange(-180, 180),0>, SOLID_VPHYSICS )
        Highlight_SetNeutralHighlight( prop, "roguelike_chest" )
        prop.Solid()
        prop.SetUsable( )
        prop.SetUsableRadius( 200 )
        prop.SetUsePrompts( "Hold %use% to open chest", "Press %use% to open chest" )
        //prop.SetParent(tr.hitEnt)
        //DispatchSpawn( prop )
         printt("<", navPoint.x, ",", navPoint.y, ",", navPoint.z, ">")

        thread void function() : (prop)
        {
            var playerActivator = prop.WaitSignal("OnPlayerUse").player
            expect entity( playerActivator )
            print("bruhu")
            Highlight_ClearNeutralHighlight( prop )
            prop.SetModel( $"models/containers/pelican_case_large_open.mdl" )
            prop.UnsetUsable()
            EmitSoundOnEntity( playerActivator, "UI_PostGame_FDSlideStop" )
            EmitSoundOnEntity( playerActivator, "UI_PostGame_CoinPlace" )
            Remote_CallFunction_UI( playerActivator, "Roguelike_GenerateLoot" )
        }()
        i++
    }

    printt("failedToNoTrace", failedToNoTrace)
    printt("failedToNoNav", failedToNoNav)
    printt("failedToOOB", failedToOOB)
    printt("failedToTriggerHurt", failedToTriggerHurt)
    printt("Total Time:", TimerEnd())
}