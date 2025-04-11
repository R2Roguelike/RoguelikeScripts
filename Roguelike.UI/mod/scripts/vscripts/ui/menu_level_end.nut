untyped
global function AddLevelEndMenu
global function ClientCallback_LevelEnded
global function LevelEnd_ResetTolls
global function Roguelike_UnlockMods
global function Roguelike_BackupRun

struct {
    var menu
    string nextMap = ""
    int startPointIndex = 0
    int kills = 69
    float time = 370
} file

void function AddLevelEndMenu()
{
	AddMenu( "LevelEndMenu", $"resource/ui/menus/level_end.menu", InitLevelEndMenu )
}

void function InitLevelEndMenu()
{
    file.menu = GetMenu( "LevelEndMenu" )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnLevelEndMenuOpen )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnNavBack )
    
    VGUIButton_Init( Hud_GetChild( file.menu, "ContinueButton" ))
    VGUIButton_OnClick( Hud_GetChild( file.menu, "ContinueButton" ), Continue )
}

void function Continue( var panel )
{
    ExecuteLoadingClientCommands_SetStartPoint( file.nextMap, file.startPointIndex )

    ClientCommand( "map " + file.nextMap )
}

void function OnNavBack()
{
    // dont.
}

void function OnLevelEndMenuOpen()
{
    thread MenuAnimation()
}

void function MenuAnimation()
{
    table runData = Roguelike_GetRunData()
    array<int> timeRanks = GetTimeForMaxRank(uiGlobal.loadedLevel)
    array<int> killRanks = GetKillsForMaxRank(uiGlobal.loadedLevel)

    // calculate ranks
    int timeRank = 2
    for (int i = 0; i < 2; i++)
    {
        if (file.time > timeRanks[i] * GetTimeRankMultiplier())
            continue

        timeRank = i
        break
    }
    int killsRank = 2
    for (int i = 0; i < 2; i++)
    {
        if (file.kills < killRanks[i])
            continue

        killsRank = i
        break
    }

    int levelsCompleted = GetConVarInt("roguelike_levels_completed")
    levelsCompleted++

    // add power
    int prevPower = expect int(runData.powerPlayer)
    int powerGained = [300 + 75 * levelsCompleted, 200 + 50 * levelsCompleted, 120 + 30 * levelsCompleted][killsRank]
    Roguelike_AddMoney( powerGained )

    runData.map <- file.nextMap
    printt(runData.map)
    runData.startPointIndex <- file.startPointIndex
    printt(runData.startPointIndex)

    // enemy power always increases by 10.
    int prevEnemyBonusHP = expect int(runData.enemyBonusHP) 
    int prevEnemyDEF = expect int(runData.enemyDEF) 
    int enemyHPGained = 500
    int enemyDEFGained = 100

    switch (GetConVarInt("sp_difficulty"))
    {
        case 0:
        case 1:
            enemyDEFGained = 75
            break
    }
    runData.enemyBonusHP += enemyHPGained
    runData.enemyDEF += enemyDEFGained
    runData.levelsCompleted <- levelsCompleted

    int modsUnlocked = [7,5,3][timeRank]
    Roguelike_UnlockMods( modsUnlocked )

    NSSaveJSONFile( "run_backup.json", runData )
    Hud_SetText(Hud_GetChild(file.menu, "EnemyDEF"), string( prevEnemyDEF ))
    Hud_SetText(Hud_GetChild(file.menu, "EnemyPower"), "+" + string( prevEnemyBonusHP ))

    Hud_SetBarProgress(Hud_GetChild(file.menu, "KillsBar"), 0.0)
    Hud_SetText(Hud_GetChild(file.menu, "KillsRank"), "")
    Hud_SetText(Hud_GetChild(file.menu, "KillsReward"), "")

    Hud_SetBarProgress(Hud_GetChild(file.menu, "TimeBar"), 0.0)
    Hud_SetText(Hud_GetChild(file.menu, "TimeRank"), "")
    Hud_SetText(Hud_GetChild(file.menu, "TimeReward"), "")
    
    Roguelike_ApplyRunDataToConVars()
    
    wait 0.1
    
	EmitUISound( "UI_PostGame_TitanSlideStop" )

    float killsFill = float(file.kills) / killRanks[0]
    Hud_GetChild(file.menu, "KillsBar").SetColor(GetColorForRank(killsRank))
    Hud_SetBarProgress(Hud_GetChild(file.menu, "KillsBar"), killsFill)

    Hud_SetText(Hud_GetChild(file.menu, "KillsRank"), GetRankName(killsRank))
    Hud_GetChild(file.menu, "KillsRank").SetColor(GetColorForRank(killsRank))
    Hud_SetText(Hud_GetChild(file.menu, "KillsReward"), format("+%i$", powerGained))

    wait 0.2 

    EmitUISound( "UI_PostGame_CoinPlace" )
    Hud_SetText(Hud_GetChild(file.menu, "EnemyDEF"), string( prevEnemyDEF + enemyDEFGained ))

    wait 0.2

    Hud_SetText(Hud_GetChild(file.menu, "EnemyPower"), "+" + string( prevEnemyBonusHP + enemyHPGained ))
    
    wait 0.2

    EmitUISound( "UI_PostGame_TitanSlideStop" )

    float timeFill = GraphCapped( file.time, timeRanks[1] * GetTimeRankMultiplier(), timeRanks[0] * GetTimeRankMultiplier(), 0, 1 )
    Hud_SetBarProgress(Hud_GetChild(file.menu, "TimeBar"), timeFill)
    Hud_GetChild(file.menu, "TimeBar").SetColor(GetColorForRank(timeRank))

    Hud_SetText(Hud_GetChild(file.menu, "TimeRank"), GetRankName(timeRank))
    Hud_GetChild(file.menu, "TimeRank").SetColor(GetColorForRank(timeRank))
    Hud_SetText(Hud_GetChild(file.menu, "TimeReward"), format("%i Mods Unlocked", modsUnlocked))
    
    wait 0.2
}

void function Roguelike_BackupRun( int startPoint )
{
    table runData = Roguelike_GetRunData()
    runData.map <- GetActiveLevel()
    runData.startPointIndex <- startPoint
    NSSaveJSONFile( "run_backup.json", runData )
}

void function Roguelike_UnlockMods( int count )
{
    table runData = Roguelike_GetRunData()
    count = minint( count, expect int(runData.lockedMods.len()) )
    for (int i = 1; i <= count; i++)
    {
        string mod = expect string(runData.lockedMods.getrandom())
        RoguelikeMod modStruct = GetModByName(mod)
        printt(modStruct.name)
        runData.lockedMods.fastremovebyvalue(mod)
        runData.unlockedMods.append(mod)
        runData.newMods.append(mod)
    }
}

void function ClientCallback_LevelEnded( string nextMap, int startPointIndex, int kills, float time )
{
    // replace abyss 1 with abyss 3
    if (nextMap == "sp_boomtown_start")
    {
        nextMap = "sp_boomtown_end"
        startPointIndex = 0
    }
    // replace enc 1 with enc 2
    if (nextMap == "sp_hub_timeshift" && startPointIndex == 0)
    {
        nextMap = "sp_timeshift_spoke02"
        startPointIndex = 0
    }
    // replace enc ch.3 with beacon 2
    if (nextMap == "sp_hub_timeshift" && startPointIndex == 7)
    {
        nextMap = "sp_beacon_spoke0"
        startPointIndex = 0
    }
    // replace beacon 3 w/ trial by fire
    if (nextMap == "sp_beacon" && startPointIndex == 2)
    {
        nextMap = "sp_tday"
        startPointIndex = 0
    }
    file.nextMap = nextMap
    file.startPointIndex = startPointIndex
    file.kills = kills
    file.time = time

    AdvanceMenu( file.menu )
}

void function LevelEnd_ResetTolls()
{
    file.kills = 0
    file.time = 0
}
