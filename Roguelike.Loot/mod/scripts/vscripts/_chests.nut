untyped
global function Chests_Init

const float TRACE_DIST = 150 // lowering this makes the function more likely to generate at lower ceilings, at cost of load time
const float HULL_EXTENTS = 80 // lowering this makes the funtion find a navmesh point nearer to the random point, at cost of load time


void function Chests_Init()
{
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
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
    //vector worldMins = expect vector( worldspawn.kv.world_mins )
    //vector worldMaxs = expect vector( worldspawn.kv.world_maxs )

    for (int i = 0; i < 150;)
    {
        vector rand = <RandomFloatRange(-40000, 40000), RandomFloatRange(-40000, 40000),RandomFloatRange(-30000, 30000)>
        //                                                           vvv lowering this makes func more likely
        //
        TraceResults tr = TraceLine( rand, <rand.x, rand.y, rand.z - TRACE_DIST>, [], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
        if (!IsValid(tr.hitEnt))
        {
            failedToNoTrace++
            continue
        }
        
        vector ornull navPoint = NavMesh_ClampPointForHullWithExtents( tr.endPos, HULL_HUMAN, <HULL_EXTENTS, HULL_EXTENTS, 30> )

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
        
        entity prop = CreatePropDynamic( $"models/containers/pelican_case_large.mdl", navPoint, <0,RandomFloatRange(-180, 180),0>, SOLID_VPHYSICS )
        Highlight_SetNeutralHighlight( prop, "interact_object_los" )
        prop.Solid()
        prop.SetUsable()
        prop.SetUsableRadius( 200 )
        prop.SetUsePrompts( "Hold %use% to open chest", "Press %use% to open chest" )
        //prop.SetParent(tr.hitEnt)
        //DispatchSpawn( prop )

        thread void function() : (prop)
        {
            var playerActivator = prop.WaitSignal("OnPlayerUse").player
            expect entity( playerActivator )
            print("bruhu")
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