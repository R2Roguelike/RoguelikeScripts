untyped
global function RoguelikeTimer_Init
global function ServerCallback_Roguelike_AddMoney
global function Roguelike_ItemGained
global function Roguelike_MoneyGained

/*
1 1 1
distribute 15 points randomly

*/

struct {
    int kills = 0
    float startTime = 0.0
    float lastItemAcquireTime = -99.9
    float lastMoneyGainTime = -99.9
} file

void function RoguelikeTimer_Init()
{
    // increase tickrate
    SetConVarFloat("base_tickinterval_sp", 1.0 / 60.0)

    delaythread(0.001) RoguelikeTimer_Think()
    AddServerToClientStringCommandCallback( "run_end", RunEnded )
    AddServerToClientStringCommandCallback( "run_backup", RunBackup )
    AddServerToClientStringCommandCallback( "level_end", LevelEnded )
}

void function RunEnded( array<string> args )
{
    RunUIScript( "RunEnded" )
}
void function RunBackup( array<string> args )
{
    RunUIScript("Roguelike_BackupRun", int( args[0] ))
}

void function LevelEnded( array<string> args )
{
    string nextMap = args[0]
    int startPointIndex = int( args[1] )

    RunUIScript( "ClientCallback_LevelEnded", nextMap, startPointIndex, expect int(GetServerVar("roguelikeKills")), Time() - expect float(GetServerVar("startTime")) )
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
    Hud_EnableKeyBindingIcons(HudElement("ItemAcquired"))
    while (true)
    {
        // hey elad.
        // please dont change this to a wait 0.
        // if you do, crashes that only the devil knows how to fix will come.
        // k thx.
        wait 0.001
        if (clGlobal.isMenuOpen)
            file.lastItemAcquireTime = -9.9
        HudElement("ItemAcquired").SetAlpha(GraphCapped(Time() - file.lastItemAcquireTime, 4.5, 5.0, 255.0, 0.0))
        if (IsValid(GetLocalClientPlayer()))
        {
            entity player = GetLocalClientPlayer()
            if (player.IsTitan() && player.IsInvulnerable())
                SetCockpitHealthColorTemp( <1, 0.5, -1> )
        }
        float time = Time() - expect float(GetServerVar("startTime"))
        int kills = expect int(GetServerVar("roguelikeKills"))
        for (int i = 2; i >= 0; i--)
        {
            if (i != 0 && kills >= killsRequired[i-1])
                continue
            
            if (i == 0)
                Hud_SetBarProgress(killsBar, 1.0)
            else
                Hud_SetBarProgress(killsBar, GraphCapped(kills, i == 2 ? 0 : killsRequired[i], killsRequired[i - 1], 0, 1))
            killsBar.SetColor( GetColorForRank(i) )
            killsRank.SetColor( GetColorForRank(i) )
            Hud_SetText(killsRank, GetRankName(i))
            Hud_SetText(killsLabel, "KILLS" + (GetConVarBool("roguelike_timer_debug") ? format(" (%i)", kills) : ""))
            break
        }
        for (int i = 0; i < 5; i++)
        {
            if (i != 2 && time > timeRequired[i] * GetTimeRankMultiplier())
                continue
            
            if (i == 2)
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

void function Roguelike_ItemGained()
{
    file.lastItemAcquireTime = Time()
}

void function Roguelike_MoneyGained( int amount )
{

}

void function ServerCallback_Roguelike_AddMoney( int amount )
{
    RunUIScript( "Roguelike_AddMoney", amount )
}