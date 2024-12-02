untyped
global function RoguelikeTimer_Init
global function RoguelikeTimer_OnKilledByPlayer

/*
1 1 1
distribute 15 points randomly

*/

struct {
    int kills = 0
    float startTime = 0.0
} file

void function RoguelikeTimer_Init()
{
    // increase tickrate
    SetConVarFloat("base_tickinterval_sp", 1.0 / 60.0)
    delaythread(0.001) RoguelikeTimer_Think()
    AddCallback_LocalClientPlayerSpawned( LocalPlayerSpawned )
    AddServerToClientStringCommandCallback( "level_end", LevelEnded )
}

void function LevelEnded( array<string> args )
{
    string nextMap = args[0]
    int startPointIndex = int( args[1] )

    RunUIScript( "ClientCallback_LevelEnded", nextMap, startPointIndex, file.kills, Time() - file.startTime )
}

void function LocalPlayerSpawned( entity player )
{
    file.startTime = Time()
}

void function RoguelikeTimer_Think()
{
    var timer = HudElement("RoguelikeTimer")
    var killsBar = Hud_GetChild(timer, "KillsBar")
    var killsRank = Hud_GetChild(timer, "KillsRank")
    var killsLabel = Hud_GetChild(timer, "KillsLabel")
    var bigTimer = Hud_GetChild(timer, "Time")
    var timeBar = Hud_GetChild(timer, "TimeBar")
    var timeRank = Hud_GetChild(timer, "TimeRank")
    var timeLabel = Hud_GetChild(timer, "TimeLabel")
    array<int> killsRequired = GetKillsForMaxRank(GetMapName())
    array<int> timeRequired = GetTimeForMaxRank(GetMapName())
    while (true)
    {
        wait 0.001
        float time = Time() - file.startTime
        for (int i = 4; i >= 0; i--)
        {
            if (i != 0 && file.kills >= killsRequired[i-1])
                continue
            
            if (i == 0)
                Hud_SetBarProgress(killsBar, 1.0)
            else
                Hud_SetBarProgress(killsBar, GraphCapped(file.kills, i == 4 ? 0 : killsRequired[i], killsRequired[i - 1], 0, 1))
            killsBar.SetColor( GetColorForRank(i) )
            killsRank.SetColor( GetColorForRank(i) )
            Hud_SetText(killsRank, GetRankName(i))
            Hud_SetText(killsLabel, "KILLS" + (GetConVarBool("roguelike_timer_debug") ? format(" (%i)", file.kills) : ""))
            break
        }
        for (int i = 0; i < 5; i++)
        {
            if (i != 4 && time > timeRequired[i] * GetTimeRankMultiplier())
                continue
            
            if (i == 4)
                Hud_SetBarProgress(timeBar, 0.0)
            else
                Hud_SetBarProgress(timeBar, GraphCapped(time, (i > 0 ? timeRequired[i - 1] * GetTimeRankMultiplier() : 0.0), timeRequired[i] * GetTimeRankMultiplier(), 1, 0))
            timeBar.SetColor( GetColorForRank(i) )
            timeRank.SetColor( GetColorForRank(i) )
            Hud_SetText(timeRank, GetRankName(i))
            Hud_SetText(timeLabel, "TIME" + (GetConVarBool("roguelike_timer_debug") ? format(" (%02i:%02i)", int(time / 60), int(time % 60)) : ""))
            Hud_SetText(bigTimer, format("%02i:%02i", int(time / 60), int(time % 60)))
            break
        }
    }
}

void function RoguelikeTimer_OnKilledByPlayer( entity victim )
{
    if (!IsValid( victim ))
    {
        AddKills( 1 )
        return
    }
    if (victim.IsTitan())
    {
        AddKills( 8 )
        return
    }
    
    if (IsSuperSpectre( victim ))
    {
        AddKills( 3 )
        return
    }
    
    AddKills( 1 )
}

void function AddKills( int amt )
{
    file.kills += amt
    RunUIScript( "Roguelike_AddMoney", amt )
}