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
    int timeRank = 4
    for (int i = 0; i < 4; i++)
    {
        if (file.time > timeRanks[i] * GetTimeRankMultiplier())
            continue

        timeRank = i
        break
    }
    int killsRank = 4
    for (int i = 0; i < 4; i++)
    {
        if (file.kills < killRanks[i])
            continue

        killsRank = i
        break
    }

    // add power
    int prevPower = expect int(runData.powerPlayer)
    int powerGained = RoundToInt(GraphCapped( killsRank, 4, 0, 30, 35 ))
    runData.powerPlayer += powerGained

    runData.map <- file.nextMap
    printt(runData.map)
    runData.startPointIndex <- file.startPointIndex
    printt(runData.startPointIndex)

    // enemy power always increases by 10.
    int levelsCompleted = GetConVarInt("roguelike_levels_completed")
    levelsCompleted++
    int prevEnemyPower = expect int(runData.enemyPower) 
    int enemyPowerGained = 40
    runData.enemyPower += enemyPowerGained
    runData.levelsCompleted <- levelsCompleted

    int modsUnlocked = minint(int(GraphCapped(timeRank, 0, 4, 8, 4)), expect int(runData.lockedMods.len()))
    Roguelike_UnlockMods( modsUnlocked )

    NSSaveJSONFile( "run_backup.json", runData )
    Hud_SetText(Hud_GetChild(file.menu, "PlayerPower"), string( prevPower ))
    Hud_SetText(Hud_GetChild(file.menu, "EnemyPower"), string( prevEnemyPower ))

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
    Hud_SetText(Hud_GetChild(file.menu, "KillsReward"), format("+%i Power", powerGained))

    wait 0.2 

    EmitUISound( "UI_PostGame_CoinPlace" )
    Hud_SetText(Hud_GetChild(file.menu, "PlayerPower"), string( prevPower + powerGained ))

    wait 0.2

    Hud_SetText(Hud_GetChild(file.menu, "EnemyPower"), string( prevEnemyPower + enemyPowerGained ))
    
    wait 0.2

    EmitUISound( "UI_PostGame_TitanSlideStop" )

    float timeFill = GraphCapped( file.time, timeRanks[3] * GetTimeRankMultiplier(), timeRanks[0] * GetTimeRankMultiplier(), 0, 1 )
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
    }
}

void function ClientCallback_LevelEnded( string nextMap, int startPointIndex, int kills, float time )
{
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
