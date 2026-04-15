untyped
global function Chests_Init
global function Roguelike_SetIgnoreBan

const float TRACE_DIST = 100 // lowering this makes the function more likely to generate at lower ceilings, at cost of load time
const float HULL_EXTENTS = 80 // lowering this makes the funtion find a navmesh point nearer to the random point, at cost of load time
global entity s2s_mover = null

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
        case "sp_boomtown_start":
            return [< 5130, -12239, 9662 >, <0, 45-90, 0> ]
        case "sp_sewers1":
            return [<13050, -13000, -120>, <0,165-90,-15>]
        case "sp_timeshift_spoke02":
            return [< 6527, 3104, 11853>, <0, 42-90, 0> ]
        case "sp_beacon":
            return [< -5729, -3150, 2560>, <0, 0-90, 0> ]
        case "sp_tday":
            return [< -5029, -11696, 424.5>, <0, 24-90, 0> ]
        case "sp_skyway_v1":
            return [< 9905, 15692, 6236 >, <0, -138-90, 0> ]

    }

    return []
}

void function EntitiesDidLoad()
{
	array<entity> hurtTriggers = GetEntArrayByClass_Expensive( "trigger_hurt" )
    hurtTriggers.extend( GetEntArrayByClass_Expensive("trigger_out_of_bounds") )
    foreach ( entity trig in GetEntArrayByClass_Expensive("trigger_multiple") )
    {
        if (GetEditorClass(trig) == "trigger_quickdeath")
        {
            hurtTriggers.append(trig)
            continue
        }
        if (GetEditorClass(trig) == "trigger_quickdeath_checkpoint")
        {
            hurtTriggers.append(trig)
            continue
        }
    }
    int attempts = 0;
    int failedToNoTrace = 0;
    int failedToNoNav = 0;
    int failedToOOB = 0;
    int failedToTriggerHurt = 0;
    int failedToSkyBelowUs = 0
    try { TimerEnd() } catch (eeee) {}
    TimerStart()

    //if (GetMapName() == "sp_s2s")
    //    return

    entity worldspawn = GetEnt( "worldspawn" )

    int unlockBit = -1
    switch (GetMapName())
    {
        case "sp_sewers1":
            unlockBit = 0
            break
        case "sp_boomtown_start":
            unlockBit = 1
            break
        case "sp_beacon":
            unlockBit = 2
            break
        case "sp_tday":
            unlockBit = 3
            break
        case "sp_timeshift_spoke02":
            unlockBit = 4
            break
        case "sp_crashsite":
        case "sp_skyway_v1":
            unlockBit = 5
            break
    }
    bool alreadyUnlocked = (GetConVarInt("roguelike_loadouts_unlocked") & (1 << unlockBit)) != 0

    array<vector> loc = GetLegendaryChestLocation()
    if (GetMapName() == "sp_beacon")
    {
        vector c = loc[0]
        for (int i = 0; i < 2; i++)
        {
            entity chest = CreatePropDynamic( $"models/containers/pelican_case_large.mdl", c, <0, (32 + 521 * i) % 360.0, 0>, SOLID_VPHYSICS )
            c = <c.x, c.y, c.z + 30>
        }
        loc[0] = c
    }
    if (loc.len() == 2 && !alreadyUnlocked)
    {
        entity legendaryChest = CreatePropDynamic( $"models/containers/pelican_case_large.mdl", loc[0], loc[1], SOLID_VPHYSICS, 30000 )
        Highlight_SetNeutralHighlight( legendaryChest, "roguelike_legendary_chest" )
        legendaryChest.Solid()
        legendaryChest.SetUsable()
        legendaryChest.SetUsableRadius( 200 )
        if (unlockBit == -1)
            legendaryChest.SetUsePrompts( "me do nothing come back later", "me do nothing come back later" )
        else
        {
            legendaryChest.SetUsePrompts( "Hold %use% Unlock Loadout", "Press %use% Unlock Loadout" )
            thread void function() : (legendaryChest, unlockBit)
            {
                int times = 0

                var playerActivator = legendaryChest.WaitSignal("OnPlayerUse").player
                expect entity( playerActivator )    

                Remote_CallFunction_NonReplay( playerActivator, "ServerCallback_Roguelike_UnlockLoadout", unlockBit )
                legendaryChest.UnsetUsable()
            }()
        }
    }

    array<string> openedChests = split( GetConVarString("roguelike_chests_opened"), " " )
    PRandom rand = NewPRandom(Roguelike_GetLevelSeed())

    int chestCount = 120
    if (GetMapName() == "sp_sewers1")
        chestCount = 180
    if (GetMapName() == "sp_s2s")
        chestCount = 75
    if (GetMapName() == "sp_beacon")
        chestCount = 90
    if (GetMapName() == "sp_crashsite")
        chestCount = 90
    //if (GetMapName() == "sp_beacon" && Roguelike_GetRunModifier("the_long_way") == 2)
    //    chestCount = 90
    for (int i = 0; i < chestCount;)
    {
        vector pos = <PRandomFloat(rand, -30000, 30000), PRandomFloat(rand, -30000, 30000), PRandomFloat(rand, -30000, 30000)>
        if (s2s_mover != null)
            pos += s2s_mover.GetOrigin()
        bool isShop = PRandomInt(rand, 0, 100) < 15
        float rotation = PRandomFloat(rand, -180, 180)
        attempts++
        //if (attempts % 10000 == 0)
        //    printt(attempts)
        //                                                           vvv lowering this makes func more likely
        //
        TraceResults tr = TraceHull( pos, <pos.x, pos.y, pos.z - TRACE_DIST>, < -HULL_EXTENTS / 2, -HULL_EXTENTS / 2, 0>, < HULL_EXTENTS / 2, HULL_EXTENTS / 2, 90>, [], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
        if (!IsValid(tr.hitEnt) || tr.startSolid || DotProduct(tr.surfaceNormal, <0,0,1>) < 0 || tr.fraction < 0.25)
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

        {
            TraceResults tr2 = TraceLine(navPoint, <navPoint.x, navPoint.y, -65535>, [], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE)
            if (tr.hitSky || DistanceSqr(tr2.endPos, tr.endPos) > 10)
            {
                failedToSkyBelowUs++
                continue
            }
        }

        bool invalidLocation = false
        foreach (entity trigger in hurtTriggers)
        {
            if (trigger.ContainsPoint( navPoint + <0,0,32> ))
            {
                invalidLocation = true
                failedToTriggerHurt++
                break
            }
        }

        entity parentEnt = tr.hitEnt
        if (parentEnt != GetEnt("worldspawn"))
        {
            if (GetMapName() == "sp_skyway_v1")
                continue
            //print((parentEnt))
        }

        if (invalidLocation)
            continue

        asset model = isShop ? $"models/beacon/crane_room_monitor_console.mdl" : $"models/containers/pelican_case_large.mdl" 
        vector offset = isShop ? <0,0,1> : <0,0,1>
        entity prop = CreatePropDynamic( model, navPoint + offset, <0,rotation,0>, SOLID_VPHYSICS )
        Highlight_SetNeutralHighlight( prop, "roguelike_chest" )
        prop.Solid()
        prop.SetUsable( )
        if (parentEnt != GetEnt("worldspawn"))
            prop.SetParent(parentEnt)
        prop.s.seed <- PRandomInt(rand)
        prop.SetUsableRadius( 200 )
        if (isShop)
            prop.SetUsePrompts( "Hold %use% to open the shop", "Press %use% to open the shop" )
        else
            prop.SetUsePrompts( "Hold %use% to open chest", "Press %use% to open chest" )

        
        //printt(navPoint + offset, i)
        //prop.SetParent(tr.hitEnt)
        //DispatchSpawn( prop )

        thread void function() : (prop, isShop, i, openedChests)
        {
            prop.EndSignal("OnDestroy")
            int times = 0
            while (true)
            {
                wait 0.001
                if (GetPlayerArray().len() < 1)
                    continue
                entity player = GetPlayerArray()[0]
                if (!IsValid(player))   
                    continue

                bool xray = true
                if (DistanceSqr(player.CameraPosition(), prop.GetWorldSpaceCenter()) > 1000 * 1000)
                    xray = false
                
                if (!Roguelike_HasMod( player, "xray" ))
                    xray = false

                if ("open" in prop.s)
                    return

                if (xray)
                {
                    Highlight_SetNeutralHighlight( prop, "roguelike_chest_xray" )
                }
                else
                {
                    Highlight_SetNeutralHighlight( prop, "roguelike_chest" )
                }
            }
        }()

        thread void function() : (prop, isShop, i, openedChests)
        {
            prop.EndSignal("OnDestroy")
            int times = 0
            while (true)
            {
                if (openedChests.contains(string(i)))
                {
                    Highlight_ClearNeutralHighlight( prop )
                    prop.SetModel( $"models/containers/pelican_case_large_open.mdl" )
                    prop.UnsetUsable()
                    prop.s.open <- true
                    return
                }
                var playerActivator = prop.WaitSignal("OnPlayerUse").player
                expect entity( playerActivator )    

                if (times == 0 && Roguelike_HasMod( playerActivator, "treasure_chests"))
                {
                    AddKillsAndMoney(playerActivator, 0, 50)
                }
                times++
                
                if (isShop)
                {
                    Remote_CallFunction_UI( playerActivator, "Roguelike_OpenShopMenu", expect int(prop.s.seed) )
                }
                else
                {
                    prop.s.open <- true
                    Highlight_ClearNeutralHighlight( prop )
                    prop.SetModel( $"models/containers/pelican_case_large_open.mdl" )
                    prop.UnsetUsable()
                    EmitSoundOnEntity( playerActivator, "UI_PostGame_FDSlideStop" )
                    EmitSoundOnEntity( playerActivator, "UI_PostGame_CoinPlace" )
                    Remote_CallFunction_UI( playerActivator, "Roguelike_GenerateLoot", expect int(prop.s.seed), i )
                    return
                }
            }
        }()
        i++
    }

    printt("failedToNoTrace", failedToNoTrace)
    printt("failedToNoNav", failedToNoNav)
    printt("failedToOOB", failedToOOB)
    printt("failedToSkyBelowUs", failedToSkyBelowUs)
    printt("failedToTriggerHurt", failedToTriggerHurt)
    printt("attempts", attempts)
    printt("Total Time:", TimerEnd() / 1000.0)
}