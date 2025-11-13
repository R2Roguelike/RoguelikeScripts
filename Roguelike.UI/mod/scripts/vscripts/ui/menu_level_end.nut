untyped
global function AddLevelEndMenu
global function ClientCallback_LevelEnded
global function LevelEnd_ResetTolls
global function Roguelike_UnlockMods
global function Roguelike_UnlockMod
global function Roguelike_BackupRun
global function Roguelike_UnlockModsForSection

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
    VGUIButton_SetText( Hud_GetChild( file.menu, "ContinueButton" ), ">> CONTINUE >>")
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
    int powerGained = [300 + 75 * levelsCompleted, 200 + 50 * levelsCompleted, 120 + 30 * levelsCompleted][killsRank]
    Roguelike_AddMoney( powerGained )

    runData.map <- file.nextMap
    runData.startPointIndex <- file.startPointIndex

    // enemy power always increases by 10.
    int prevEnemyBonusHP = expect int(runData.enemyBonusHP)
    int prevEnemyDEF = expect int(runData.enemyDEF)
    int enemyHPGained = ENEMY_HP_PER_LEVEL
    int enemyDEFGained = ENEMY_DEF_PER_LEVEL
    float prevCoreGain = 500.0 / (500.0 + prevEnemyDEF)
    float coreGain = 500.0 / (500.0 + prevEnemyDEF + enemyDEFGained)

    switch (GetConVarInt("sp_difficulty"))
    {
        case 0:
            enemyDEFGained = ENEMY_DEF_PER_LEVEL_EASY
            break
        case 2:
            enemyHPGained = ENEMY_HP_PER_LEVEL_HARD
            enemyDEFGained = ENEMY_DEF_PER_LEVEL_HARD
            break
        case 3:
            enemyHPGained = ENEMY_HP_PER_LEVEL_MASTER
            enemyDEFGained = ENEMY_DEF_PER_LEVEL_MASTER
            break
    }
    enemyDEFGained += levelsCompleted * 25
    runData.enemyBonusHP += enemyHPGained
    runData.enemyDEF += enemyDEFGained
    runData.levelsCompleted <- levelsCompleted

    int modsUnlocked = [3,2,1][timeRank]
    Roguelike_UnlockMods( modsUnlocked )

    NSSaveJSONFile( "run_backup.json", runData )
    Hud_SetText(Hud_GetChild(file.menu, "EnemyDEF"), format( "-%.0f%%", (1.0 - coreGain) * 100.0 ) )
    Hud_SetText(Hud_GetChild(file.menu, "EnemyHP"), "+" + string( prevEnemyDEF / 5 ) + "%") // / 500 * 100

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
    Hud_SetText(Hud_GetChild(file.menu, "EnemyDEF"), format( "-%.0f%%", (1.0 - coreGain) * 100.0 ) )

    wait 0.2

    Hud_SetText(Hud_GetChild(file.menu, "EnemyHP"), "+" + string( (prevEnemyDEF + enemyDEFGained) / 5 ) + "%")

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
    runData.timestamp <- GetUnixTimestamp()
    runData.version <- RUNDATA_VERSION
    runData.titanHp <- GetConVarInt("memory_titan_hp")
    runData.titanSettings <- GetConVarString("memory_titan_settings")
    runData.titanMaxHp <- GetConVarInt("memory_titan_max_hp")
    NSSaveJSONFile( "run_backup.json", runData )

    Roguelike_WriteSaveToDisk()
}

void function Roguelike_UnlockMods( int count )
{
    int titanMods = count
    Roguelike_UnlockModsForSection( titanMods, true )
    //Roguelike_UnlockModsForSection( pilotMods, false )
}   

void function Roguelike_UnlockModsForSection( int count, bool isTitan )
{
    PRandom rand = NewPRandom(Roguelike_GetLevelSeed() + 17377)
    table runData = Roguelike_GetRunData()
    array lockedMods = GetAllLockedMods(false)
    
    count = minint( count, lockedMods.len() )
    RunStats_ModsUnlocked( count )

    for (int i = 1; i <= count;)
    {
        int val = PRandomInt(rand, lockedMods.len())
        RoguelikeMod mod = GetModByName(lockedMods[val])
        if (!IsModAvailable(mod))
            continue
        if (Roguelike_IsModUnlocked(mod))
            continue
        if (mod.isTitan != isTitan)
            continue

        Roguelike_UnlockMod( mod )
        i++
    }
}

void function Roguelike_UnlockMod( RoguelikeMod mod )
{
    string uniqueName = mod.uniqueName
    table runData = Roguelike_GetRunData()
    array lockedMods = expect array(mod.isTitan ? runData.lockedTitanMods : runData.lockedPilotMods)
    lockedMods.fastremovebyvalue(uniqueName)
    runData.unlockedMods.append(uniqueName)
    runData.newMods.append(uniqueName)
}

void function ClientCallback_LevelEnded( string nextMap, int startPointIndex, int kills, float time )
{
    // stupidly long starts at BT and goes thru all levels, no skipping
    // long route adds BT and B3
    int route = Roguelike_GetRunModifier("the_long_way")
    if (route != 2)
    {
        // replace abyss 2 with abyss 3
        if (nextMap == "sp_boomtown")
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
        // replace enc ch.3 with trial by fire
        if (nextMap == "sp_hub_timeshift" && startPointIndex == 7)
        {
            nextMap = route > 0 ? "sp_beacon_spoke0" : "sp_beacon"
            startPointIndex = route > 0 ? 0 : 2
        }
        // replace beacon 3 w/ trial by fire
        if (nextMap == "sp_skyway_v1")
        {
            nextMap = "sp_skyway_v1"
            startPointIndex = 1
        }
    }
    file.nextMap = nextMap
    file.startPointIndex = startPointIndex
    file.kills = kills
    file.time = time
    
    AdvanceMenu( file.menu )
    if (GetActiveLevel() == "sp_boomtown_start")
    {
        AdvanceMenu( GetMenu("LimitedLoadoutChoice"))
    }
}

void function LevelEnd_ResetTolls()
{
    file.kills = 0
    file.time = 0
}
