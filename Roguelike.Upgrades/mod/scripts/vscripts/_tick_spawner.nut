global function TickSpawner_Init

void function TickSpawner_Init()
{
    AddDeathCallback( "npc_titan", TitanOrReaperKilled )
    AddDeathCallback( "npc_super_spectre", TitanOrReaperKilled )
}

void function TitanOrReaperKilled(entity npc, var damageInfo)
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (!IsValid(attacker) || !attacker.IsPlayer())
        return

    if (Roguelike_HasMod( attacker, "tick_spawner" ) && attacker.IsTitan())
    {
        // create tick
        int count = 0

        if (IsSuperSpectre( npc ))
            count = 3

        if (npc.IsTitan())
            count = 5

        for (int i = 0; i < count; i++)
        {
            vector origin = npc.GetWorldSpaceCenter() + <RandomFloatRange(-16, 16), RandomFloatRange(-16, 16), 64>
            entity tick = CreateNPC( "npc_frag_drone", attacker.GetTeam(), origin, <0, RandomFloat(360), 0> )
            tick.SetInvulnerable()
            DispatchSpawn( tick )
            printt("tick...")
            tick.SetOwner( attacker )
            tick.SetBossPlayer( attacker )
            tick.InitFollowBehavior( attacker, GetDefaultNPCFollowBehavior( tick ) )
            tick.SetFollowGoalTolerance( 2000 )
            tick.SetFollowGoalCombatTolerance( 2000 )
            tick.SetFollowTargetMoveTolerance( 250 )
	        //tick.DisableBehavior( "Assault" )
	        tick.EnableBehavior( "Follow" )

        }
    }
}
