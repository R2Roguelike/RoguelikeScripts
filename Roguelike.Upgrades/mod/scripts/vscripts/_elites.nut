untyped
global function Elites_Init
global function Elites_Add
global function Elites_Generate

struct {
    array<void functionref( entity )> eliteFuncs
} file

void function Elites_Init()
{
	PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT )
	PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT_MOD )
	PrecacheImpactEffectTable( ARC_CANNON_FX_TABLE )
    Elites_Add( Elite_BubbleShield )
    //Elites_Add( Elite_Healing )
    //Elites_Add( Elite_Invulnerable )
}

string function GetEliteType( entity npc )
{
    if ("elite" in npc.s)
        return expect string(npc.s.elite)

    return ""
}

void function Elites_Add( void functionref( entity ) eliteFunc )
{
    file.eliteFuncs.append(eliteFunc)
}

void function Elites_Generate( entity npc )
{
    int levelsComplete = GetConVarInt("roguelike_levels_completed")
    float chance = GraphCapped( levelsComplete, 0, 5, 0.05, 0.333 )
    if (RandomFloat(1) > chance)
        return
    
    if (npc.GetTeam() != TEAM_IMC)
        return

    thread file.eliteFuncs.getrandom()( npc )
}

void function Elite_BubbleShield( entity npc )
{
    if (npc.GetMaxHealth() <= 0)
        return
    npc.s.elite <- "bubble_shield"
    Highlight_SetEnemyHighlight( npc, "elite_bubble_shield")
    if (npc.IsTitan())
    {
        npc.SetNPCMoveFlag( NPCMF_WALK_ALWAYS, true ) // reduce HP by 33% since they can be frustrating to fight against
        npc.SetNPCMoveSpeedScale( 0.333 ) // reduce HP by 33% since they can be frustrating to fight against
        StatusEffect_AddEndless( npc, eStatusEffect.dodge_speed_slow, 0.75 )
    }

    // hopefully this prevents them from dashing?
    // they can get annoying as a titan since you have to practically
    // kiss them on the mouth to damage them
    if (npc.IsTitan())
        npc.EnableNPCMoveFlag(NPCMF_WALK_ALWAYS)

    entity bubbleShield = TestBubbleShield( npc.GetTeam(), npc.GetOrigin(), npc.GetAngles(), npc )

    npc.EndSignal("OnDeath")
    OnThreadEnd(function() : (bubbleShield)
    {
        bubbleShield.Destroy()
    })
    WaitForever()

}

entity function TestBubbleShield( int team, vector origin, vector angles, entity owner = null, float duration = 9999 )
{
	entity bubbleShield = CreateEntity( "prop_dynamic" )
	bubbleShield.SetValueForModelKey( $"models/fx/xo_shield.mdl" )
	bubbleShield.kv.solid = SOLID_VPHYSICS
    bubbleShield.kv.rendercolor = "255 255 0"
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
	bubbleShield.SetPassThroughThickness( 250 ) 
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
    npc.s.elite <- "invulnerable"

    npc.EndSignal("OnDeath")

    bool IsInvulnerable = false
    while (1)
    {
        array<entity> arr = GetNPCArrayEx( "any", npc.GetTeam(), -1, npc.GetOrigin(), npc.IsTitan() ? 1500.0 : 750.0 )

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
            zapBeam.Fire( "StopPlayEndCap", "", 0.2 )
            zapBeam.Kill_Deprecated_UseDestroyInstead( 0.2 )
            cpEnd.Kill_Deprecated_UseDestroyInstead( 0.2 )
            break
        }
        
        if (shieldCanActivate && !IsInvulnerable)
        {
            IsInvulnerable = true
            npc.SetInvulnerable()
            npc.SetNoTarget( true )
            Highlight_SetEnemyHighlight( npc, "elite_invulnerable_on" )
        }
        else if (IsInvulnerable && !shieldCanActivate)
        {
            IsInvulnerable = false
            npc.ClearInvulnerable()
            npc.SetNoTarget( false )
            Highlight_SetEnemyHighlight( npc, "elite_invulnerable_off" )
        }
        
        wait 0.5
    }
}

void function Elite_Healing( entity npc )
{
    npc.s.elite <- "healing"
    Highlight_SetEnemyHighlight( npc, "elite_healing" )
    npc.kv.rendercolor = "0 255 0"
    //TestBubbleShield( npc.GetTeam(), npc.GetOrigin(), npc.GetAngles(), npc )

    npc.EndSignal("OnDeath")

    while (1)
    {
        //HACK - Need a simpler custom FX that doesn't have to be restarted
        array<entity> arr = GetNPCArrayEx( "any", npc.GetTeam(), TEAM_ANY, npc.GetOrigin(), npc.IsTitan() ? 1500.0 : 750.0 )


        foreach (entity ent in arr)
        {
            int healingAmount = 50
            if (ent.IsTitan())
                healingAmount = 400 //
            
            if (ent == npc || GetEliteType(npc) == "healing")
                healingAmount = healingAmount / 3 // heavily reduced!

            ent.SetHealth( minint( ent.GetMaxHealth(), ent.GetHealth() + healingAmount ))

            if (ent == npc)
                continue
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
            zapBeam.Fire( "StopPlayEndCap", "", 0.2 )
            zapBeam.Kill_Deprecated_UseDestroyInstead( 0.2 )
            cpEnd.Kill_Deprecated_UseDestroyInstead( 0.2 )

        }


        wait 0.19
    }
}