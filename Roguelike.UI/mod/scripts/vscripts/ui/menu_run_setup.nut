untyped
global function RunSetup_Init
global function MoveHexForward
global function MoveHexBackward
global function Roguelike_IsLoadoutUnlocked

struct
{
    var menu
    float targetRot = 0
    int selectedLoadout = 0
} file

global const array<string> LOCKED_LOADOUTS =  ["mp_titanweapon_rocketeer_rocketstream",
                                         //"mp_titanweapon_particle_accelerator",
                                         //"mp_titanweapon_sniper"
                                          /*"mp_titanweapon_sticky_40mm"*/]

void function RunSetup_Init()
{
	AddMenu( "RunSetup", $"resource/ui/menus/run_setup.menu", InitRoguelikeRunSetupMenu )
}

float function QuadEaseInOut( float frac )
{
	frac /= 0.5;
	if (frac < 1)
		return 0.5 * frac * frac
	frac--
	return -0.5 * ( frac * ( frac - 2 ) - 1 )
}

void function InitRoguelikeRunSetupMenu()
{
    file.menu = GetMenu("RunSetup")

    try
    {
        // two possible errors
        // loadout is invalid (mod was uninstalled)
        // or there is no loadout set in the convar (Roguelike_GetTitanLoadouts().len() == 0)
        RoguelikeLoadout loadout = expect RoguelikeLoadout(Roguelike_GetLoadoutFromWeapon(Roguelike_GetTitanLoadouts()[0]))
        file.selectedLoadout = loadout.index
    }
    catch (e)
    {
        file.selectedLoadout = 0
    }

    var button = Hud_GetChild( file.menu, "DifficultyButton" )
    VGUIButton_Init( button )
    VGUIButton_SetText( button, format("Change Difficulty [%s]", DIFFICULTY_NAMES[GetConVarInt("sp_difficulty")]))
    VGUIButton_OnClick( button, DifficultyMenuPopUp )

    button = Hud_GetChild( file.menu, "StartButton" )
    VGUIButton_Init( button )
    VGUIButton_SetText( button, "START" )
    VGUIButton_OnClick( button, OnStartClicked )

    button = Hud_GetChild( file.menu, "NextButton" )
    VGUIButton_Init( button )
    VGUIButton_SetImage( button, $"ui/arrow_down")
    VGUIButton_OnClick( button, MoveHexForward )

    button = Hud_GetChild( file.menu, "PrevButton" )
    VGUIButton_Init( button )
    VGUIButton_SetImage( button, $"ui/arrow_up")
    VGUIButton_OnClick( button, MoveHexBackward )

    button = Hud_GetChild( file.menu, "Segments" )
    Hud_SetBarProgress( button, 1.0 )

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, UpdateUpgradeBars )

    /*array<string> titles = [ "Chassis", "Utility", "Core/Weapon", "Abilities" ]
    for (int i = 0; i < 4; i++)
    {
        button = Hud_GetChild( file.menu, "UpgradeBar" + i )
        Hud_SetVisible( Hud_GetChild( button, i < 2 ? "Title" : "TitleRight" ), false )
        Hud_SetText( Hud_GetChild( button, i < 2 ? "TitleRight" : "Title" ), titles[i] )
        Hud_SetBarProgressDirection( Hud_GetChild( button, "Bar" ), i < 2 ? 1 : 0 )
        Hud_SetBarProgress( Hud_GetChild( button, "BarBG" ), 1 )
        Hud_SetBarProgress( Hud_GetChild( button, "Bar" ), 0.0 )
    }*/

    RunModifierPanel_ParseConvar()
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers0" ), "the_long_way" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers1" ), "pain" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers2" ), "unwalkable" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers3" ), "titan_health" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers4" ), "enemy_hp" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers5" ), "defense" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers6" ), "cash_gain" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers7" ), "proj_speed" )
    RunModifier_Init( Hud_GetChild( file.menu, "Modifiers8" ), "elite_freq" )

    thread void function() : ()
    {
        float rot = 0.0
        while (true)
        {
            float dt= Time()
            wait 0.001

            if (GetConVarInt("roguelike_run_heat") >= 15)
            {
                Hud_SetText(Hud_GetChild(file.menu, "HeatValue"), " Heat:^20C0FF00 " + GetConVarInt("roguelike_run_heat") + "/15 ")
            }
            else
            {
                Hud_SetText(Hud_GetChild(file.menu, "HeatValue"), " Heat:^FF800000 " + GetConVarInt("roguelike_run_heat") + "/15 ")
            }

            dt = Time() - dt

            rot = MoveTowards(rot, file.targetRot, Graph( fabs(file.targetRot - rot), 0, 1, dt * 0.05, dt * 5) )
            Hud_SetRotation(Hud_GetChild(file.menu, "BigHex"), rot * 60)
        }
    }()
}

array<RoguelikeLoadout> function Roguelike_GetValidLoadoutChoices()
{
    array<RoguelikeLoadout> validLoadouts = clone VALID_LOADOUTS

    for (int i = validLoadouts.len() - 1; i >= 0; i--)
    {
        if (LOCKED_LOADOUTS.contains(validLoadouts[i].primary) || !Roguelike_IsLoadoutUnlocked( validLoadouts[i] ))
            validLoadouts.remove(i)
    }

    return validLoadouts
}

void function MoveHexBackward( var b )
{
    file.targetRot += 1
    array<RoguelikeLoadout> validLoadouts = Roguelike_GetValidLoadoutChoices()
    
    int index = file.selectedLoadout
    index = (index - 1 < 0) ? validLoadouts.len() - 1 : index - 1
    file.selectedLoadout = index

    UpdateUpgradeBars()
}

void function MoveHexForward( var b )
{
    file.targetRot -= 1
    array<RoguelikeLoadout> validLoadouts = Roguelike_GetValidLoadoutChoices()
    
    int index = file.selectedLoadout
    index = (index + 1 >= validLoadouts.len()) ? 0 : index + 1
    file.selectedLoadout = index
        

    UpdateUpgradeBars()
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

void function UpdateUpgradeBars()
{
    VGUIButton_SetState( Hud_GetChild( file.menu, "StartButton" ), eVGUIButtonState.Selected )

    array<RoguelikeLoadout> validLoadouts = Roguelike_GetValidLoadoutChoices()
    var button = Hud_GetChild( file.menu, "Segments" )
    Hud_SetBarProgress( button, 1.0 )
    
    Hud_SetHeight( button, (validLoadouts.len() - 1) * ContentScaledYAsInt(18) + ContentScaledYAsInt(12) )
    button = Hud_GetChild( file.menu, "SelectedSegment" )
    Hud_SetY( button, file.selectedLoadout * ContentScaledYAsInt(18) * -1 )
    button.SetColor(validLoadouts[ file.selectedLoadout ].color)

    string desc = FormatDescription( validLoadouts[ file.selectedLoadout ].description )
    string title = validLoadouts[ file.selectedLoadout ].name

    SetConVarString( "roguelike_titan_loadout", validLoadouts[ file.selectedLoadout ].primary )
    if (Roguelike_IsSaveLoaded())
        Roguelike_WriteSaveToDisk()

    Hud_SetText(Hud_GetChild(file.menu, "DamageLoadoutDescTitle"),
        title)
    Hud_SetText(Hud_GetChild(file.menu, "DamageLoadoutDesc"),
        desc)

    string elementStr = ""
    switch (validLoadouts[ file.selectedLoadout ].element)
    {
        case RoguelikeElement.physical:
            elementStr = "<daze>Physical</>"
            break
        case RoguelikeElement.electric:
            elementStr = "<cyan>Energy</>"
            break
        case RoguelikeElement.fire:
            elementStr = "<burn>Fire</>"
            break
    }
    Hud_SetText(Hud_GetChild(file.menu, "DamageLoadoutDescRole"),
        FormatDescription(format("%s // %s", elementStr, validLoadouts[ file.selectedLoadout ].role)))

    /*for (int i = 0; i < 4; i++)
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
    }*/
}

void function DifficultyMenuPopUp( var button )
{
	DialogData dialogData
	dialogData.header = "#SP_DIFFICULTY_MISSION_SELECT_TITLE"

	AddDialogButton( dialogData, DIFFICULTY_NAMES[0], SelectDifficulty( 0 ), NORMAL_DIFFICULTY_DESC )
	AddDialogButton( dialogData, DIFFICULTY_NAMES[1], SelectDifficulty( 1 ), HARD_DIFFICULTY_DESC )
	AddDialogButton( dialogData, DIFFICULTY_NAMES[2], SelectDifficulty( 2 ), MASTER_DIFFICULTY_DESC )
	AddDialogButton( dialogData, DIFFICULTY_NAMES[3], SelectDifficulty( 3 ), MASOCHIST_DIFFICULTY_DESC )

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

bool function Roguelike_IsLoadoutUnlocked( RoguelikeLoadout loadout )
{
    int bitIndex = loadout.unlockBit
    int loadoutUnlocks = GetConVarInt("roguelike_loadouts_unlocked")

    if (bitIndex == -1)
        return true
    return bool(loadoutUnlocks & (1 << bitIndex)) || GetConVarBool("roguelike_unlock_all")
}
