global function RunSetup_Init

struct
{
    var menu
    array<string> selectedLoadouts = []
} file

global const array<string> VALID_LOADOUTS =  ["mp_titanweapon_xo16_shorty",
                                        "mp_titanweapon_sticky_40mm",
                                        "mp_titanweapon_meteor",
                                        "mp_titanweapon_rocketeer_rocketstream",
                                         "mp_titanweapon_particle_accelerator",
                                        "mp_titanweapon_leadwall",
                                          "mp_titanweapon_sniper",
                                        "mp_titanweapon_predator_cannon"]

global const array<string> LOCKED_LOADOUTS =  ["mp_titanweapon_rocketeer_rocketstream",
                                         //"mp_titanweapon_particle_accelerator",
                                         //"mp_titanweapon_sniper"
                                          /*"mp_titanweapon_sticky_40mm"*/]
const array<string> DIFFICULTY_NAMES = [ "Normal", "Hard", "Master", "Masochist" ]

void function RunSetup_Init()
{
	AddMenu( "RunSetup", $"resource/ui/menus/run_setup.menu", InitRoguelikeRunSetupMenu )
}

void function UpdateLoadoutConVar()
{
    SetConVarString( "roguelike_titan_loadout", JoinStringArray( file.selectedLoadouts, " " ) )
    
    if (Roguelike_IsSaveLoaded())
        Roguelike_WriteSaveToDisk()
}

void function InitRoguelikeRunSetupMenu()
{
    file.menu = GetMenu("RunSetup")

    file.selectedLoadouts = Roguelike_GetTitanLoadouts()

    var button = Hud_GetChild( file.menu, "DifficultyButton" )
    VGUIButton_Init( button )
    VGUIButton_SetText( button, format("Change Difficulty [%s]", DIFFICULTY_NAMES[GetConVarInt("sp_difficulty")]))
    VGUIButton_OnClick( button, DifficultyMenuPopUp )

    button = Hud_GetChild( file.menu, "StartButton" )
    VGUIButton_Init( button )
    VGUIButton_SetText( button, "START" )
    VGUIButton_OnClick( button, OnStartClicked )

    array<string> titles = [ "Chassis", "Utility", "Core/Weapon", "Abilities" ]
    for (int i = 0; i < 4; i++)
    {
        button = Hud_GetChild( file.menu, "UpgradeBar" + i )
        Hud_SetVisible( Hud_GetChild( button, i < 2 ? "Title" : "TitleRight" ), false )
        Hud_SetText( Hud_GetChild( button, i < 2 ? "TitleRight" : "Title" ), titles[i] )
        Hud_SetBarProgressDirection( Hud_GetChild( button, "Bar" ), i < 2 ? 1 : 0 )
        Hud_SetBarProgress( Hud_GetChild( button, "BarBG" ), 1 )
        Hud_SetBarProgress( Hud_GetChild( button, "Bar" ), 0.0 )
    }

    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers0" ), "the_long_way")
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers1" ), "pain")
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers2" ), "unwalkable")
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers3" ), "titan_health")
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers4" ), "crit_or_nothing")
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers5" ), "defense")
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers6" ), "time_requirement")
    for (int i = 0; i < 8; i++)
    {
        button = Hud_GetChild( file.menu, "LoadoutButton" + i )
        VGUIButton_Init( button )
        VGUIButton_SetText( button, GetTitanNameFromWeapon(VALID_LOADOUTS[i]) )
        VGUIButton_OnClick( button, DamageLoadoutButtonEventHandler(VALID_LOADOUTS[i]))
        int unselectedState = eVGUIButtonState.None
        VGUIButton_SetState( button, Roguelike_GetTitanLoadouts().contains(VALID_LOADOUTS[i]) ? eVGUIButtonState.Selected : unselectedState )
    }

    UpdateUpgradeBars()

    thread void function() : ()
    {
        while (true)
        {
            Hud_SetText(Hud_GetChild(file.menu, "HeatValue"), " Heat:^FF800000 " + GetConVarInt("roguelike_run_heat") + " ")
            wait 0.001
        }
    }()
}

void function OnStartClicked( var panel )
{
    if (VGUIButton_GetState( panel ) == eVGUIButtonState.Locked)
        return

    Roguelike_StartNewRun()
    
    if (Roguelike_GetRunModifier("the_long_way") != 0)
    {
        ExecuteLoadingClientCommands_SetStartPoint( "sp_crashsite", 7 )
        ClientCommand("map sp_crashsite")
    }
    else
    {
        ExecuteLoadingClientCommands_SetStartPoint( "sp_sewers1", 0 )
        ClientCommand("map sp_sewers1")
    }

    delaythread(0.1) void function() : ()
    {
        if (uiGlobal.isLoading)
            return

        DialogData dialogData
        dialogData.header = "FAILED TO LOAD MAP"
        dialogData.message = "The game did not load the map. This normally happens if you're not logged into EA. Please log into the EA App and try again. (Your game may crash when this happens - just restart the game)"
        dialogData.forceChoice = true

        AddDialogButton( dialogData, "#DISMISS" )

        OpenDialog( dialogData )
    }()
}

void functionref( var ) function DamageLoadoutButtonEventHandler( string weapon )
{
    return void function( var panel ) : (weapon)
    {
        if (VGUIButton_GetState( panel ) == eVGUIButtonState.Disabled)
            return

        int scriptId = int(Hud_GetScriptID( panel ))
        if (VGUIButton_GetState( panel ) == eVGUIButtonState.Selected)
        {
            file.selectedLoadouts.fastremovebyvalue(weapon)
        }
        else
        {
            if (file.selectedLoadouts.len() > 0)
                file.selectedLoadouts[0] = weapon
            else
                file.selectedLoadouts.append( weapon )
        }


        for (int i = 0; i < VALID_LOADOUTS.len(); i++)
        {
            var loadoutButton = Hud_GetChild( file.menu, "LoadoutButton" + i )
            if (file.selectedLoadouts.contains(VALID_LOADOUTS[i]))
                VGUIButton_SetState(loadoutButton, eVGUIButtonState.Selected)
            else if (file.selectedLoadouts.len() >= 1 || LOCKED_LOADOUTS.contains(VALID_LOADOUTS[i]))
            {
                VGUIButton_SetState(loadoutButton, eVGUIButtonState.Locked)
            }
            else
            {
                VGUIButton_SetState(loadoutButton, eVGUIButtonState.None)
            }
        }

        Hud_SetText(Hud_GetChild(file.menu, "DamageLoadoutDescTitle"),
            GetTitanNameFromWeapon(weapon).toupper())
        Hud_SetText(Hud_GetChild(file.menu, "DamageLoadoutDesc"),
            FormatDescription(GetTitanDescription(weapon)))

        UpdateLoadoutConVar()
        UpdateUpgradeBars()
    }
}

void function UpdateUpgradeBars()
{
    for (int i = 0; i < VALID_LOADOUTS.len(); i++)
    {
        var loadoutButton = Hud_GetChild( file.menu, "LoadoutButton" + i )
        VGUIButton_SetValueText( loadoutButton, "" )
        if (file.selectedLoadouts.contains(VALID_LOADOUTS[i]))
        {
            VGUIButton_SetValueText( loadoutButton, string(file.selectedLoadouts.find(VALID_LOADOUTS[i]) + 1))
            VGUIButton_SetState(loadoutButton, eVGUIButtonState.Selected)
        }
        else if (LOCKED_LOADOUTS.contains(VALID_LOADOUTS[i]))
        {
            VGUIButton_SetState(loadoutButton, eVGUIButtonState.Disabled)
        }
        else
        {
            VGUIButton_SetState(loadoutButton, eVGUIButtonState.None)
        }
    }

    VGUIButton_SetState( Hud_GetChild( file.menu, "StartButton" ), file.selectedLoadouts.len() == 1 ? eVGUIButtonState.Selected : eVGUIButtonState.Locked )

    string desc = ""
    string title = ""

    if (file.selectedLoadouts.len() > 0)
    {
        title = GetTitanNameFromWeapon(file.selectedLoadouts[0]).toupper()
        desc = FormatDescription(GetTitanDescription(file.selectedLoadouts[0]))
    }

    Hud_SetText(Hud_GetChild(file.menu, "DamageLoadoutDescTitle"),
        title)
    Hud_SetText(Hud_GetChild(file.menu, "DamageLoadoutDesc"),
        desc)

    for (int i = 0; i < 4; i++)
    {
        var button = Hud_GetChild( file.menu, "UpgradeBar" + i )
        int modCount = 0
        foreach (RoguelikeMod mod in GetModsForChipSlot( i + 1, true, true ))
        {
            if (mod.uniqueName == "empty")
                continue

            modCount++
        }
        Hud_SetBarProgress( Hud_GetChild(button, "Bar"), modCount / 15.0 )
    }
}

void function DifficultyMenuPopUp( var button )
{
	DialogData dialogData
	dialogData.header = "#SP_DIFFICULTY_MISSION_SELECT_TITLE"

	AddDialogButton( dialogData, "Normal", SelectDifficulty( 0 ), NORMAL_DIFFICULTY_DESC )
	AddDialogButton( dialogData, "Hard", SelectDifficulty( 1 ), HARD_DIFFICULTY_DESC )
	AddDialogButton( dialogData, "Master", SelectDifficulty( 2 ), MASTER_DIFFICULTY_DESC )
	AddDialogButton( dialogData, "Masochist", SelectDifficulty( 3 ), MASOCHIST_DIFFICULTY_DESC )

	AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )
	AddDialogFooter( dialogData, "#B_BUTTON_BACK" )
	AddDialogPCBackButton( dialogData )

	OpenDialog( dialogData )
}

void functionref(  ) function SelectDifficulty( int difficulty )
{
    return void function() : (difficulty)
    {
        SetConVarInt( "sp_difficulty", difficulty )
        VGUIButton_SetText( Hud_GetChild( file.menu, "DifficultyButton" ), format("Change Difficulty [%s]", DIFFICULTY_NAMES[difficulty]))
    }
}
