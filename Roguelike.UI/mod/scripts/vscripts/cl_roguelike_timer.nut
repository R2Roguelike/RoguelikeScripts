untyped
global function RoguelikeTimer_Init
global function ServerCallback_Roguelike_AddMoney
global function Roguelike_ItemGained
global function Roguelike_MoneyGained
global function ServerCallback_Roguelike_UnlockLoadout
global function RoguelikeTimer_SetMoney
global function Roguelike_UnlockLoadoutAnim

/*
1 1 1
distribute 15 points randomly

*/

struct {
    int kills = 0
    int money = 0
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

void function RoguelikeTimer_SetMoney( int money )
{
    file.money = money
    var timer = HudElement("RoguelikeTimer")
    var heatLabel = Hud_GetChild(timer, "Heat")

    string heatText = "^ffc04000" + file.money + "$"
    if (GetMapName() == "sp_skyway_v1")
        heatText = "UNTIL FOLD WEAPON FIRES"

    Hud_SetText(heatLabel, heatText)
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

    float time = Time() - expect float(GetServerVar("startTime"))
    if (GetServerVar("isTimerPaused"))
        time = expect float(GetServerVar("timerValue"))

    RunUIScript( "ClientCallback_LevelEnded", nextMap, startPointIndex, expect int(GetServerVar("roguelikeKills")), time )
}

void function RoguelikeTimer_Think()
{
    var timer = HudElement("RoguelikeTimer")
    var killsBar = Hud_GetChild(timer, "KillsBar")
    var killsRank = Hud_GetChild(timer, "KillsRank")
    var killsLabel = Hud_GetChild(timer, "KillsLabel")
    var heatLabel = Hud_GetChild(timer, "Heat")
    var bigTimer = Hud_GetChild(timer, "Time")
    var timeBar = Hud_GetChild(timer, "TimeBar")
    var timeRank = Hud_GetChild(timer, "TimeRank")
    var timeLabel = Hud_GetChild(timer, "TimeLabel")
    array<int> killsRequired = GetKillsForMaxRank(GetMapName())
    array<int> timeRequired = GetTimeForMaxRank(GetMapName())
    Hud_EnableKeyBindingIcons(HudElement("ItemAcquired"))
    HudElement("UnlockAnim").SetPanelAlpha(0) // hide unlockanim
    float alpha = 0.0
    while (true)
    {
        // hey elad.
        // please dont change this to a wait 0.
        // if you do, crashes that only the devil knows how to fix will come.
        // k thx.
        float dt = Time()
        wait 0.001
        dt = Time() - dt
        if (clGlobal.isMenuOpen)
            file.lastItemAcquireTime = -9.9
        
        alpha = MoveTowards( alpha, GetServerVar("timerVisible") ? 255.0 : 0.0, 128 * dt )
        timer.SetPanelAlpha( alpha )
        if (IsControllerModeActive())
        {
            Hud_SetText(HudElement("ItemAcquired"), "Item Acquired - Press %scoreboard_focus% to open your inventory")
        }
        else
        {
            Hud_SetText(HudElement("ItemAcquired"), "Item Acquired - Press %titan_loadout_select% to open your inventory")
        }
        if (IsValid(GetLocalClientPlayer()))
        {
        vector velocity = GetLocalClientPlayer().GetVelocity()
        Hud_SetText(HudElement("Velocity"), format("^FF800000%i^ffffffff Heat\n%s\n<%.1f, %.1f, %.1f>\n%.1f", GetConVarInt("roguelike_run_heat"), DIFFICULTY_NAMES[GetConVarInt("sp_difficulty")],
            velocity.x, velocity.y, velocity.z, Length(<velocity.x, velocity.y, 0>)))
        }
        HudElement("ItemAcquired").SetAlpha(GraphCapped(Time() - file.lastItemAcquireTime, 4.5, 5.0, 255.0, 0.0))
        if (IsValid(GetLocalClientPlayer()))
        {
            entity player = GetLocalClientPlayer()
            if (player.IsTitan() && player.IsInvulnerable())
                SetCockpitHealthColorTemp( <1, 0.5, -1>, -0.7 )
        }
        
        float time = Time() - expect float(GetServerVar("startTime"))

        if (GetServerVar("isTimerPaused"))
            time = expect float(GetServerVar("timerValue"))

        float displayTime = time

        if (GetMapName() == "sp_skyway_v1")
            displayTime = (timeRequired[2]) * GetTimeRankMultiplier() - time
        int kills = expect int(GetServerVar("roguelikeKills"))
        
        if (GetConVarInt("roguelike_run_heat") >= 15)
        {
            Hud_SetColor( heatLabel, 32, 192, 255, 255 )
        }
        else
        {
            Hud_SetColor( heatLabel, 255, 127, 0, 255 )
        }
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
        for (int i = 0; i < 3; i++)
        {
            if (i != 2 && time > timeRequired[i] * GetTimeRankMultiplier())
                continue

            if (i == 2)
                Hud_SetBarProgress(timeBar, 0.0)
            else
                Hud_SetBarProgress(timeBar, GraphCapped(time, (i > 0 ? timeRequired[i - 1] * GetTimeRankMultiplier() : 0.0), timeRequired[i] * GetTimeRankMultiplier(), 1, 0))
            timeBar.SetColor( GetColorForRank(i) )
            timeRank.SetColor( GetColorForRank(i) )
            Hud_SetText(timeRank, GetRankName(i) )
            Hud_SetText(timeLabel, "TIME" + (GetConVarBool("roguelike_timer_debug") ? format(" (%02i:%02i)", int(displayTime / 60), int(displayTime % 60)) : ""))
            Hud_SetText(bigTimer, format("%02i:%02i ", int(displayTime / 60), int(displayTime % 60)))
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

void function Roguelike_UnlockLoadoutAnim( string loadoutName )
{
    thread UnlockLoadoutAnim_Internal( loadoutName )
}

// this is like the third time im pasting this from sp_crashsite.nut. This should be global atp,
// but im not bothering purely because i might eventually discover the hard way that its also defined
// somewhere else.
float function QuadEaseInOut( float frac )
{
	frac /= 0.5;
	if (frac < 1)
		return 0.5 * frac * frac
	frac--
	return -0.5 * ( frac * ( frac - 2 ) - 1 )
}

float function InverseLerp( float t, float a, float b )
{
    return clamp((t - a) / (b - a), 0, 1)
}

void function UnlockLoadoutAnim_Internal( string loadoutName )
{
    var animPanel = HudElement("UnlockAnim")
    var animPanelScreen = Hud_GetChild(animPanel, "Screen") // utility imagepanel for positioning elements
    var loadoutLabel = Hud_GetChild( animPanel, "LoadoutLabel")
    var loadoutText = Hud_GetChild( animPanel, "LoadoutName")
    var lockHandle = Hud_GetChild( animPanel, "LockHandle")

    Hud_SetText( loadoutText, loadoutName )

    float endTime = Time() + 6.25 // 6s + sound delay
    float startTime = Time()
    delaythread(0.25) EmitSoundOnEntity(GetLocalClientPlayer(), "HUD_level_up_pilot_1P")
    while (Time() <= endTime)
    {
        wait 0.001
        float maxWidth = max(90 + Hud_GetWidth( loadoutLabel ), 84 + Hud_GetWidth( loadoutText ))
        float width = (Graph(QuadEaseInOut(InverseLerp(Time() - startTime, 1.25, 2.25)), 0.0, 1.0, 84, maxWidth))

        Hud_SetWidth( animPanel, width )
        Hud_SetWidth( animPanelScreen, width )

        if (endTime - Time() > 2.5)
            animPanel.SetPanelAlpha(GraphCapped(Time() - startTime, 0, 0.2, 0, 255))
        else
        {
            Hud_SetWidth( animPanel, width * QuadEaseInOut(InverseLerp((endTime - Time()), 0.0, 1.5)) )
            Hud_SetWidth( animPanelScreen, width * QuadEaseInOut(InverseLerp((endTime - Time()), 0.0, 1.5)) )
        }

        Hud_SetY( lockHandle, GraphCapped(Time() - startTime, 0.25, 0.45, 0, -8) )
    }
    animPanel.SetPanelAlpha(0)
}

void function ServerCallback_Roguelike_UnlockLoadout( int bit )
{
    RunUIScript("Roguelike_UnlockLoadout", bit)
}
