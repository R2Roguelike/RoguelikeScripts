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
        int count = 1

        if (npc.IsTitan())
            count = 3

        for (int i = 0; i < count; i++)
        {
            vector origin = npc.GetOrigin() + <RandomFloatRange(-16, 16), RandomFloatRange(-16, 16), 64>
            entity tick = CreateNPC( "npc_frag_drone", attacker.GetTeam(), origin, <0, RandomFloat(360), 0> )
            DispatchSpawn( tick )
        }
    }
}
