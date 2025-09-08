untyped
global function Elites_Init
global function Elites_Add
global function Elites_Generate
global function GetEliteType
global function HealingElite_Pylon

struct {
    array<void functionref( entity )> eliteTitanFuncs
    array<void functionref( entity )> elitePilotFuncs
} file

void function Elites_Init()
{
    RegisterSignal("MeleeDamage")
    RegisterSignal("SacrificeTime")
    RegisterSignal("LoadoutSwap")
	PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT )
	PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT_MOD )
	PrecacheImpactEffectTable( ARC_CANNON_FX_TABLE )

    
    Elites_Add( Elite_BubbleShield )
    Elites_AddTitan( Elite_Healing )
    Elites_Add( Elite_Enraged )
    Elites_Add( Elite_Invulnerable )
    Elites_AddTitan( Elite_Parry )
    if (!("titan_health" in Roguelike_GetRunModifiers()))
        Elites_AddTitan( Elite_Sacrifice )
}

string function GetEliteType( entity npc )
{
    if ("elite" in npc.s)
        return expect string(npc.s.elite)

    return ""
}

void function Elites_Add( void functionref( entity ) eliteFunc )
{
    file.eliteTitanFuncs.append(eliteFunc)
    file.elitePilotFuncs.append(eliteFunc)
}

void function Elites_AddTitan( void functionref( entity ) eliteFunc )
{
    file.eliteTitanFuncs.append(eliteFunc)
}

void function Elites_AddPilot( void functionref( entity ) eliteFunc )
{
    file.elitePilotFuncs.append(eliteFunc)
}

void function Elites_Generate( entity npc )
{
    int levelsComplete = GetConVarInt("roguelike_levels_completed")
    float chance = 1.0 / GraphCapped( levelsComplete, 0, 5, 10, 5 )
    vector origin = npc.GetOrigin()
    int posSeed = int((origin.x + origin.y + origin.z) * 12341)
    PRandom rand = NewPRandom(Roguelike_GetLevelSeed() + posSeed)
    if (PRandomFloat(rand, 0, 1) > chance)
        return

    delaythread(0.001) void function() : (rand, npc)
    {
        if (!IsValid(npc))
            return
        if (npc.GetTeam() == TEAM_MILITIA)
            return
        if (npc.IsMarkedForDeletion())
            return
        if (IsMercTitan( npc )) // NO BOSSES!!!
            return
        if (!npc.IsTitan() && !IsSuperSpectre(npc))
            thread file.elitePilotFuncs[PRandomInt( rand, file.elitePilotFuncs.len() )]( npc )
        else
            thread file.eliteTitanFuncs[PRandomInt( rand, file.eliteTitanFuncs.len() )]( npc )
    }()
}

void function Elite_Enraged( entity npc )
{
    npc.EndSignal("OnDeath")
    npc.EndSignal("OnDestroy")
    if (!IsValid(npc))
        return
    while (npc.IsInvulnerable())
    {
        wait 0.01
    }
    if (npc.GetMaxHealth() <= 0)
        return
	NPC_SetNuclearPayload( npc )
    npc.s.elite <- "enraged"
    TakeAllWeapons( npc )
    GiveTitanLoadout( npc, npc.ai.titanSpawnLoadout )
    Highlight_SetEnemyHighlight( npc, "elite_enraged")
    npc.SetNPCMoveSpeedScale( 2.0 ) // lololol
    npc.s.healthMult <- 1.0 // MY GOD ARE THEY ANNOYING
    UpdateNPCForSpDifficulty( npc ) // update health

    while (GetPlayerArray().len() < 1)
        wait 0.01
    
    entity lastPlayer = null
    while (1)
    {
        wait 0.19
        
        entity player = npc.GetEnemy()
        //npc.TakeOffhandWeapon(0)
        if (IsAlive(npc))
        {
            if (IsValid(player) && player != lastPlayer && !IsTurret(npc))
            {
                npc.AssaultSetGoalRadius( 100 )
                npc.AssaultSetGoalHeight( 500 )
                npc.AssaultSetArrivalTolerance( 100 )
                npc.AssaultPoint( player.GetOrigin() )
                npc.AssaultSetFightRadius( 100 )
            }
        }

        if (npc.IsTitan() && GetHealthFrac(npc) > 0.2)
            continue

        if (!IsValid(player) || Distance2D( npc.GetOrigin(), player.GetOrigin() ) > 300)
            continue
        
        npc.ClearInvulnerable()
        if(npc.IsTitan())
            AutoTitan_SelfDestruct( npc )
        else
            thread SelfDestruct_Enraged( npc )
        return
    }
}

void function SelfDestruct_Enraged( entity npc )
{
    npc.EndSignal("OnDestroy")
    npc.EndSignal("OnDeath")
    npc.s.attackedByPlayer <- GetPlayerArray()[0]
    npc.SetInvulnerable()
    local e = {}
    e.nukeFX <- []

    OnThreadEnd( void function() : (e) 
    {
        StopSoundOnEntity( e.nukeFXInfoTarget, "titan_nuclear_death_charge" )
        foreach (ent in e.nukeFX)
            ent.Destroy()
    })

    e.needToClearNukeFX <- false
    e.nukeFXInfoTarget <- CreateEntity( "info_target" )
    e.nukeFXInfoTarget.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
    e.nukeFXInfoTarget.SetParent( npc, "CHESTFOCUS" ) //Play FX and sound on entity since we need something that lasts across the player titan -> pilot transition
    DispatchSpawn( e.nukeFXInfoTarget )
    
    EmitSoundOnEntity( e.nukeFXInfoTarget, "titan_nuclear_death_charge" )
    e.nukeFX.append( PlayFXOnEntity( TITAN_NUCLEAR_CORE_NUKE_FX, expect entity( e.nukeFXInfoTarget ) ) )

    AI_CreateDangerousArea_DamageDef( damagedef_nuclear_core, e.nukeFXInfoTarget, npc.GetTeam(), true, true )

    wait 3

    entity nukeFXInfoTarget = expect entity( e.nukeFXInfoTarget )
    EmitSoundOnEntity( e.nukeFXInfoTarget, "titan_nuclear_death_explode" )

    PlayFX( TITAN_NUCLEAR_CORE_FX_3P, nukeFXInfoTarget.GetOrigin() + Vector( 0, 0, -10 ), Vector(0,RandomInt(360),0) )
    
    RadiusDamage_DamageDef( damagedef_nuclear_core,
        nukeFXInfoTarget.GetOrigin(),								// origin
        npc,						// owner
        npc,							// inflictor
        100,						// normal damage
        2000,					// heavy armor damage
        400,						// inner radius
        500,						// outer radius
        0 )									// dist from attacker
    
    npc.Die( npc, npc, {} )

    wait 0.5
}

void function Elite_BubbleShield( entity npc )
{
    npc.EndSignal("OnDeath")
    npc.EndSignal("OnDestroy")
    
    while (npc.IsInvulnerable())
        wait 0.01
    if (npc.GetMaxHealth() <= 0)
        return
    npc.s.elite <- "bubble_shield"
    Highlight_SetEnemyHighlight( npc, "elite_bubble_shield")
    if (npc.IsTitan())
    {
        npc.SetNPCMoveFlag( NPCMF_WALK_ALWAYS, true ) // reduce HP by 33% since they can be frustrating to fight against
        npc.SetNPCMoveSpeedScale( 0.5 ) // reduce HP by 33% since they can be frustrating to fight against
        StatusEffect_AddEndless( npc, eStatusEffect.dodge_speed_slow, 0.75 )
    }

    // hopefully this prevents them from dashing?
    // they can get annoying as a titan since you have to practically
    // kiss them on the mouth to damage them
    if (npc.IsTitan())
        npc.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS)


    entity bubbleShield = TestBubbleShield( npc.GetTeam(), npc.GetOrigin(), npc.GetAngles(), npc )


    OnThreadEnd(function() : (bubbleShield)
    {
        if (IsValid(bubbleShield))
            bubbleShield.Destroy()
    })

    while (1)
    {
        npc.WaitSignal("MeleeDamage")

        bubbleShield.Destroy()

        Highlight_SetEnemyHighlight( npc, "elite_bubble_shield_off")

        wait 30

        Highlight_SetEnemyHighlight( npc, "elite_bubble_shield")

        bubbleShield = TestBubbleShield( npc.GetTeam(), npc.GetOrigin(), npc.GetAngles(), npc )
    }
    WaitForever()

}

void function Elite_Parry( entity npc )
{
    npc.EndSignal("OnDeath")
    npc.EndSignal("OnDestroy")
    
    while (npc.IsInvulnerable())
        wait 0.01
    if (npc.GetMaxHealth() <= 0)
        return
    npc.s.elite <- "parry"
    Highlight_SetEnemyHighlight( npc, "elite_parry")

    OnThreadEnd(function() : ()
    {
    })

    while (1)
    {
        table results = WaitSignal( npc, "MeleeDamage")
        entity player = expect entity(results.attacker)

        if (!player.IsPlayer())
            continue

		EmitSoundOnEntity(player, "ronin_sword_impact_metal_1p_vs_3p")
		EmitSoundOnEntity(player, "ronin_sword_impact_armor_1p_vs_3p")
		EmitSoundOnEntity(player, "titan_rocket_explosion_1p_vs_3p")
        print("FUCK")
        PlayFX( TITAN_NUCLEAR_CORE_FX_3P, npc.GetOrigin() )

        float dist = Distance( npc.GetOrigin(), player.GetOrigin() )
        player.SetVelocity( Normalize( player.GetOrigin() - npc.GetOrigin() ) * 1000 )
        player.TakeDamage( 1000, svGlobal.worldspawn, svGlobal.worldspawn, { origin = npc.GetOrigin(), damageSourceId = eDamageSourceId.auto_titan_melee })
        //RadiusDamage()
    }
    WaitForever()

}

entity function TestBubbleShield( int team, vector origin, vector angles, entity owner = null, float duration = 9999 )
{
	entity bubbleShield = CreateEntity( "prop_dynamic" )
	bubbleShield.SetValueForModelKey( $"models/fx/xo_shield.mdl" )
	bubbleShield.kv.solid = SOLID_VPHYSICS
    bubbleShield.kv.rendercolor = "255 255 0 255"
    bubbleShield.kv.contents = (int(bubbleShield.kv.contents) | CONTENTS_NOGRAPPLE)

    if (owner != null && owner.IsTitan())
    {
        origin += <0,0,60>
    }

	bubbleShield.SetOrigin( origin )
	bubbleShield.SetAngles( angles )
     // Blocks bullets, projectiles but not players and not AI
	bubbleShield.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
    bubbleShield.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	bubbleShield.SetBlocksRadiusDamage( true )
	DispatchSpawn( bubbleShield )
	//bubbleShield.Hide()
    // no, mr railgun sir
	bubbleShield.SetPassThroughThickness( 501 )
    //bubbleShield.SetTeam( owner.GetTeam() )
	//bubbleShield.SetPassThroughDirection( 0 )

	SetTeam( bubbleShield, team )
	array<entity> bubbleShieldFXs

	vector coloredFXOrigin = origin + Vector( 0, 0, 25 )
	table bubbleShieldDotS = expect table( bubbleShield.s )


	bubbleShield.SetParent(owner)

	EmitSoundOnEntity( bubbleShield, "BubbleShield_Sustain_Loop" )

    return bubbleShield
}

void function Elite_Invulnerable( entity npc )
{
    npc.EndSignal("OnDeath")
    npc.EndSignal("OnDestroy")

    while (npc.IsInvulnerable())
        wait 0.01
    // JFS: enemies link to enemies inside the bridge, player cant kill the enemies inside the bridge since enemies remain
    // and enemies cant be killed since there are enemies inside the bridge
    if (GetMapName() == "sp_s2s")
        return
    npc.s.elite <- "invulnerable"

    bool IsInvulnerable = false
    while (1)
    {
        float maxDist = npc.IsTitan() ? 1500.0 : 750.0
        array<entity> arr = GetNPCArrayEx( "any", npc.GetTeam(), -1, npc.GetOrigin(), maxDist )

        bool shieldCanActivate = false
        foreach (entity ent in arr)
        {
            if (GetEliteType(ent) == "invulnerable")
                continue

            if (!ent.IsNPC())
                continue

            if (ent.IsInvulnerable()) // dont create a shield from entities player cant kill
                continue

            if (ent.GetTeam() != npc.GetTeam())
                continue

            shieldCanActivate = true
            npc.SetInvulnerable()
            npc.SetNoTarget( true )

            Highlight_SetEnemyHighlight( npc, "elite_invulnerable_on" )

            while (IsAlive( ent ) && Distance( npc.GetOrigin(), ent.GetOrigin() ) < maxDist && ent.GetTeam() == npc.GetTeam())
            {
                // Control point sets the end position of the effect
                entity cpEnd = CreateEntity( "info_placement_helper" )
                SetTargetName( cpEnd, UniqueString( "arc_cannon_beam_cpEnd" ) )
                cpEnd.SetOrigin( npc.GetWorldSpaceCenter() )
                DispatchSpawn( cpEnd )
                cpEnd.SetParent( ent )

                entity zapBeam = CreateEntity( "info_particle_system" )
                zapBeam.kv.cpoint1 = cpEnd.GetTargetName()
                zapBeam.SetValueForEffectNameKey( ARC_CANNON_BEAM_EFFECT_MOD )
                zapBeam.kv.start_active = 1
                zapBeam.SetOwner( npc )
                zapBeam.SetOrigin( ent.GetWorldSpaceCenter() )
                DispatchSpawn( zapBeam )
                zapBeam.SetParent( ent )

                zapBeam.Fire( "Start" )
                if (!IsTurret( npc ))
                {
                    npc.AssaultSetGoalRadius( 100 )
                    npc.AssaultSetGoalHeight( 500 )
                    npc.AssaultSetArrivalTolerance( 100 )
                    npc.AssaultPoint( ent.GetOrigin() )
                    npc.AssaultSetFightRadius( 100 )
                }

                zapBeam.Fire( "StopPlayEndCap", "", 0.5 )
                zapBeam.Kill_Deprecated_UseDestroyInstead( 0.5 )
                cpEnd.Kill_Deprecated_UseDestroyInstead( 0.5 )

                wait 0.5
            }
            break
        }

        npc.ClearInvulnerable()
        npc.SetNoTarget( false )
        Highlight_SetEnemyHighlight( npc, "elite_invulnerable_off" )

        wait 30.0
    }
}

void function Elite_Healing( entity npc )
{
    npc.EndSignal("OnDeath")
    npc.EndSignal("OnDestroy")

    while (npc.IsInvulnerable())
        wait 0.01
    npc.s.elite <- "healing"
    Highlight_SetEnemyHighlight( npc, "elite_healing" )
    npc.kv.rendercolor = "0 255 0 255"
    //TestBubbleShield( npc.GetTeam(), npc.GetOrigin(), npc.GetAngles(), npc )

    int index = 2
    if (IsValid(npc.GetOffhandWeapon(1)) && npc.GetOffhandWeapon(1).GetWeaponClassName() == "mp_titanability_tether_trap")
        index = 1
    npc.TakeOffhandWeapon(index)
    npc.GiveOffhandWeapon( "mp_titanability_roguelike_pylon", index )
}

void function HealingElite_Pylon( entity npc, entity tower )
{
    tower.EndSignal("OnDeath")
    tower.EndSignal("OnDestroy")

    float range = npc.IsTitan() ? 1500.0 : 750.0
    int team = npc.GetTeam()

    wait 6

    while (1)
    {
        //HACK - Need a simpler custom FX that doesn't have to be restarted
        array<entity> arr = GetNPCArrayEx( "any", team, TEAM_ANY, tower.GetOrigin(), range )
        arr.sort( int function ( entity a, entity b ) : ()
        {
            if (GetHealthFrac(a) < GetHealthFrac(b))
                return 1
            if (GetHealthFrac(a) > GetHealthFrac(b))
                return -1

            return 0
        })

        foreach (entity ent in arr)
        {
            if (!IsValid(ent) || ent.IsMarkedForDeletion() || !IsAlive(ent))
                continue
            
            // dont heal enemies at max health
            if (GetHealthFrac( ent ) > 0.98)
                continue
            
            if (TraceLine( tower.GetWorldSpaceCenter(), ent.GetWorldSpaceCenter(), [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE ).fraction < 0.99)
                continue

            // Control point sets the end position of the effect
            entity cpEnd = CreateEntity( "info_placement_helper" )
            SetTargetName( cpEnd, UniqueString( "arc_cannon_beam_cpEnd" ) )
            cpEnd.SetOrigin( tower.GetWorldSpaceCenter() )
            DispatchSpawn( cpEnd )
            cpEnd.SetParent( ent )

            entity zapBeam = CreateEntity( "info_particle_system" )
            zapBeam.kv.cpoint1 = cpEnd.GetTargetName()
            zapBeam.SetValueForEffectNameKey( ARC_CANNON_BEAM_EFFECT_MOD )
            zapBeam.kv.start_active = 1
            zapBeam.SetOwner( npc )
            zapBeam.SetOrigin( ent.GetWorldSpaceCenter() )
            DispatchSpawn( zapBeam )
            zapBeam.SetParent( ent )

            zapBeam.Fire( "Start" )

            while (IsValid(ent) && IsAlive( ent ) && Distance( npc.GetOrigin(), ent.GetOrigin() ) < range && ent.GetHealth() < ent.GetMaxHealth())
            {
                ent.SetHealth( minint( ent.GetMaxHealth(), ent.GetHealth() + int(ent.GetMaxHealth() * 0.02) ))
                wait 0.19
            }

            zapBeam.Fire( "StopPlayEndCap", "", 0.2 )
            zapBeam.Kill_Deprecated_UseDestroyInstead( 0.2 )
            cpEnd.Kill_Deprecated_UseDestroyInstead( 0.2 )
            break
        }

        wait 1.0
    }
}

void function Elite_Sacrifice( entity npc )
{
    npc.EndSignal("OnDeath")
    npc.EndSignal("OnDestroy")

    while (npc.IsInvulnerable())
        wait 0.01
    npc.s.elite <- "sacrifice"
    Highlight_SetEnemyHighlight( npc, "elite_sacrifice" )
    npc.kv.rendercolor = "255 128 0 255"
    //TestBubbleShield( npc.GetTeam(), npc.GetOrigin(), npc.GetAngles(), npc )

    OnThreadEnd(function() : (npc)
    {
        if ("attackedByPlayer" in npc.s)
            thread SacrificeDeath( npc, expect entity(npc.s.attackedByPlayer) )
    })

    WaitForever()
}

void function SacrificeDeath( entity npc, entity player )
{
    player.Signal("SacrificeTime")
    player.EndSignal("OnDeath")
    player.EndSignal("OnDestroy")
    player.EndSignal("SacrificeTime")

    Remote_CallFunction_Replay( player, "ServerCallback_UpdateHealthSegmentCountRandom", 5 )
    RSE_Apply( player, RoguelikeEffect.sacrifice_roll, 1.0, 4.85, 0.0 )

    array<string> options = ["damage_sacrifice_1", "damage_sacrifice_2", "segment_sacrifice_2", "segment_sacrifice_1"]
    string option = options.getrandom()

    wait 4.89


    entity titan = GetTitanFromPlayer( player )

    if (!IsAlive(player) || !IsValid(titan) || !IsAlive(titan))
        return

    RSE_Apply( player, expect int(getconsttable().RoguelikeEffect[option]), 1.0, 20.0, 0.0 )
    if (!titan.IsPlayer())
        titan.ai.titanSettings.titanSetFileMods.append(option)
    else
    {
        array<string> mods = player.GetPlayerSettingsMods()
        mods.append(option)
        float healthFrac = GetHealthFrac( player )
        player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), mods )
        player.SetHealth( player.GetMaxHealth() * healthFrac )
    }

    OnThreadEnd( function() : (player, option)
    {
        if (!IsValid(player) || !IsAlive(player))
            return
        entity titan = GetTitanFromPlayer( player )
        if (!IsValid(titan) || !IsAlive(titan))
            return
        if (!titan.IsPlayer())
            titan.ai.titanSettings.titanSetFileMods.fastremovebyvalue(option)
        else
        {
            array<string> mods = player.GetPlayerSettingsMods()
            mods.fastremovebyvalue(option)
            float healthFrac = GetHealthFrac( player )
            player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), mods )
            player.SetHealth( player.GetMaxHealth() * healthFrac )
        }
        RSE_Stop( player, expect int(getconsttable().RoguelikeEffect[option] ))

        Remote_CallFunction_Replay( player, "ServerCallback_UpdateHealthSegmentCountRandom", -1 )

    })

    wait 20.0
}