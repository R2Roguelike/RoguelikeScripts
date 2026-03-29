untyped
global function RoguelikeTimer_Init
global function ServerCallback_Roguelike_AddMoney
global function Roguelike_ItemGained
global function Roguelike_MoneyGained
global function ServerCallback_Roguelike_UnlockLoadout
global function RoguelikeTimer_SetMoney
global function Roguelike_UnlockLoadoutAnim
global function RoguelikeTimer_SetStartTime
global function ServerCallback_Roguelike_LoadingCheckpoint
global function Roguelike_SetSpeedrunTimer
global function __HideHud
global function __ShowHud

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
    int startTimeUnix = 0
} file

void function RoguelikeTimer_Init()
{
    // increase tickrate
    SetConVarFloat("base_tickinterval_sp", 1.0 / 60.0)

    delaythread(0.001) RoguelikeTimer_Think()
    AddServerToClientStringCommandCallback( "run_end", RunEnded )
    AddServerToClientStringCommandCallback( "run_won", RunWon )
    AddServerToClientStringCommandCallback( "STOPTHECOUNT", StopTimer )
    AddServerToClientStringCommandCallback( "run_backup", RunBackup )
    AddServerToClientStringCommandCallback( "level_end", LevelEnded )
    RegisterServerVarChangeCallback( "startTime", SetLevelStartTime )
}

void function SetLevelStartTime()
{
    RunUIScript( "ClientCallback_StartLevelTimer" )
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

void function RoguelikeTimer_SetStartTime( int t )
{
    file.startTimeUnix = t
}

void function RunEnded( array<string> args )
{
    RunUIScript( "RunEnded" )
}
void function RunWon( array<string> args )
{
    RunUIScript( "RunWon" )
}
void function StopTimer( array<string> args )
{
    RunUIScript( "ClientCallback_StopTimer" )
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
        
        if (Roguelike_GetRunModifier("speedrun") > 0)
        {
            alpha = 255
        }
        else
        {
            alpha = MoveTowards( alpha, GetServerVar("timerVisible") ? 255.0 : 0.0, 128 * dt )
        }
        timer.SetPanelAlpha( alpha )
        if (IsControllerModeActive())
        {
            Hud_SetText(HudElement("ItemAcquired"), "Item Acquired - Press %scoreboard_focus% to open your inventory")
        }
        else
        {
            Hud_SetText(HudElement("ItemAcquired"), "Item Acquired - Press %titan_loadout_select% to open your inventory")
        }
        HudElement("ItemAcquired").SetAlpha(GraphCapped(Time() - file.lastItemAcquireTime, 4.5, 5.0, 255.0, 0.0))

        Hud_SetVisible( HudElement("RewindLabel"), GetGlobalNetBool("canLoadCheckpoint") && Time() % 2 < 1.0 )
        Hud_SetVisible( HudElement("RewindLabel2"), GetGlobalNetBool("canLoadCheckpoint") && Time() % 2 < 1.0 )
        Hud_SetVisible( HudElement("RewindLabel3"), GetGlobalNetBool("canLoadCheckpoint") )
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
            displayTime = (timeRequired[1]) * GetTimeRankMultiplier() - time
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
            
            if (Roguelike_GetRunModifier("speedrun") <= 0)
                Hud_SetText(bigTimer, format("%02i:%02i ", int(displayTime / 60), int(displayTime % 60)))
            break
        }
    }
}

void function Roguelike_ItemGained()
{
    file.lastItemAcquireTime = Time()
}

void function Roguelike_SetSpeedrunTimer( float time )
{
    var timer = HudElement("RoguelikeTimer")
    int realTime = int(time)
    int ms = int(time * 10 % 10)
    string timeStr = string(realTime)
    /*if (realTime > 3600)
    {
        timeStr = format("%i:%02i:%02i.%01i ", realTime / 3600, (realTime / 60) % 60, realTime % 60, ms)
    }
    else if (realTime > 60)
    {*/
        timeStr = format("%02i:%02i.%01i ", realTime / 60, realTime % 60, ms)
    /*}
    else
    {
        timeStr = format("%i.%01i ", realTime % 60, ms)
    }*/
    
    string cheaterLabel = "^FF404000CHEATS ENABLED"
    if (!GetConVarBool("sv_cheats") && !GetConVarBool("roguelike_unlock_all"))
        cheaterLabel = ""
        
    if (Roguelike_GetRunModifier("speedrun") > 0)
        Hud_SetText(Hud_GetChild(timer, "Time"), timeStr)
    Hud_SetText(HudElement("Velocity"), format("^FF800000%i^ffffffff Heat\n%s\n%s", 
    GetConVarInt("roguelike_run_heat"), 
    DIFFICULTY_NAMES[GetConVarInt("sp_difficulty")], 
    cheaterLabel))
}

void function Roguelike_MoneyGained( int amount )
{

}

void function ServerCallback_Roguelike_AddMoney( int amount )
{
    RunUIScript( "Roguelike_AddMoney", amount )
}

void function Roguelike_UnlockLoadoutAnim( string loadoutName, bool playerHint = false )
{
    thread UnlockLoadoutAnim_Internal( loadoutName, playerHint )
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

void function UnlockLoadoutAnim_Internal( string loadoutName, bool playerHint )
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
    if (playerHint)
    {
		thread AddPlayerHint( 10.0, 1.0, $"", "Golden Chests unlock new Titan loadouts to be picked\nat the start of a new run." )
    }
    while (Time() <= endTime)
    {
        wait 0.001
        float maxWidth = max(ContentScaledX(40) + Hud_GetWidth( loadoutLabel ), ContentScaledX(40) + Hud_GetWidth( loadoutText ))
        float width = (Graph(QuadEaseInOut(InverseLerp(Time() - startTime, 1.25, 2.25)), 0.0, 1.0, ContentScaledX(32), maxWidth))

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

const array<string> checkpointModLines = [
    "^FF404000DEATH AVOIDS YOU. FOR NOW.",
    "^FF404000DEALS LIKE THIS NEVER END WELL.",
    "^FF404000HOW [CENSORED]!",
    "^FF404000LEARN TO TAKE A LOSS, WILL YOU?",
    "^FF404000COWARD.",
    "^FF404000BULLSHIT.",
    "^FF404000LAST CHANCE.",
    "^FF404000YOU DON'T DESERVE THIS.",
    "^FF404000THE GUY WHO ADDED THIS? FUCK HIM.",
    "^FF404000please fail.",
    "^FF404000EAT SHIT!",
    "^FF404000HOPE TO SEE YOU IN HELL!",
    "^FF404000LOOK AT ME, I CAN'T HANDLE DYING! WAH WAH WAH!",
    "^FF404000RIGGED!",
    "^FF404000THIS IS BULLSHIT!",
    "^FF404000HOPE YOUR GAME FREEZES AND THE SAVE GETS DELETED.",
    "^FF404000PLEASE CRASH.",
    "^FF404000HOW FUNNY.",
    "^FF404000HOPE IT REWINDS YOU TO THE LAST LEVEL.",
    "^FF404000NO GURANTEES.",
    "^FF404000WATCH YOURSELF, NOW :)",

    "^70ff7000ONE LAST CHANCE! NOW GO GET EM!",
    "^70ff7000BREATHE. FOCUS. YOU GOT THIS.",
    "^70ff7000HE NEEDS YOU, PILOT.",
    "^70ff7000PROTOCOL THREE.",
    "^70ff7000IT'S NOT OVER YET.",
    "^70ff7000HE LIIIIIIIIIIIIIIIIIIIIVES!",
    "^70ff7000NOTHING A TIME REWIND CAN'T SOLVE!",
    "^70ff7000MRVNS WOULD NEVER LET YOU DO THIS!",
    "^70ff7000GO GET EM, TIGER.",
    "^70ff7000I DON'T HAVE ANY REFERENCES TO MAKE, BUT I BELIEVE IN YOU!",
    "^70ff7000REMEMBER ME!!!!",
    "^70ff7000THIS IS FOR ALL THE BUGS I DIDN'T FIX!",
]
const array<string> checkpointModFoolLines = [
    "^FF404000AHAHAHAHAHAHA!",
    "^FF404000YOU WASTED IT, YOU FOOL!",
    "^FF404000PLEASE do that again :)",
    "^FF404000NOW, **THAT**'S FUNNY.",
]
const array<string> checkpointNormalLines = [
    "Woops.",
    "Let's pretend no one saw that...",
    "Boooo! We want DEATH! BY! COMBAT!",
    "HAHA, THIS GUY FELL!",
    "Slipped on a banana? No worries.",
    "CHAT! LAUGH AT THIS GUY.",
    "I mean, I don't blame you. (I totally blame you.)",
    "FROM IVY, OUT MIDDLE, THROU- ohhhhhh shiiiiiiit.",
    "These checkpoint rewinds are sponsored by #them.",
    "Please, don't do this again.",
    "That was funny. The fact this needs to exist is even funnier.",
    "Millions must wallkick.",
    "balls.... wait, what?",
    "LMAOOOOOOOOOOOOOOOOOOOOOOO",
    "Worst. Country. Ever.",
    "Nobody likes me, so now I load checkpoints for people.",
    "How's your sister?",
    "Happens all the time. NOT!",
    "\"IT'S NOT FUNNY!\" You say. And you're a godawful liar.",
    "Let's keep this one a secret between you and me.",
    "Falls in platforming sections, call him JustANormalUser.",
    "Falls in platforming sections, call him JustANormalLoser.",
    "I wrote HOW MANY LINES FOR THIS?",
    "Watch, they'll fail this section again.",
    "ROCK AND STONE!",
    "Long ago, two races ruled over the earth: HUMANS and HEADS OF GOVERNMENTS.",
    "HA.",
    "... ever feel [CENSORED] over a line of text?"
]

void function __HideHud()
{
    Hud_Hide(HudElement("Velocity"))
    Hud_Hide(HudElement("RoguelikeTimer"))
    __p().ClientCommand("script AddCinematicFlag( __p(), CE_FLAG_HIDE_MAIN_HUD )")
}
void function __ShowHud()
{
    Hud_Show(HudElement("Velocity"))
    Hud_Show(HudElement("RoguelikeTimer"))
    __p().ClientCommand("script RemoveCinematicFlag( __p(), CE_FLAG_HIDE_MAIN_HUD )")
}

void function ServerCallback_Roguelike_LoadingCheckpoint( bool consumeCheckpointMod, bool allowCheckpoint )
{
    if (consumeCheckpointMod)
    {
        RunUIScript("Roguelike_ConsumeCheckpointMod") // consume!
        if (allowCheckpoint)
            Hud_SetText( HudElement("RewindLabel3"), checkpointModFoolLines.getrandom() )
        else
            Hud_SetText( HudElement("RewindLabel3"), checkpointModLines.getrandom() )
        return
    }
    Hud_SetText( HudElement("RewindLabel3"), checkpointNormalLines.getrandom() )
}
