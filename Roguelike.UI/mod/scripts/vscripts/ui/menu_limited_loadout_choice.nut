global function LimitedLoadoutChoice_Init
global function Roguelike_SetLoadouts

struct
{
    var menu
    array<string> selectedLoadouts = []
    array<RoguelikeLoadout> choices = []
    int choice = -1
    int option1 = -1
    int option2 = -1
} file

void function LimitedLoadoutChoice_Init()
{
	AddMenu( "LimitedLoadoutChoice", $"resource/ui/menus/limited_loadout_choice.menu", InitLimitedLoadoutChoiceMenu )
}

void function UpdateLoadoutConVar()
{
    SetConVarString( "roguelike_titan_loadout", JoinStringArray( file.selectedLoadouts, " " ) )
    
    if (Roguelike_IsSaveLoaded())
        Roguelike_WriteSaveToDisk()
}

void function InitLimitedLoadoutChoiceMenu()
{
    file.menu = GetMenu("LimitedLoadoutChoice")

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnMenuOpen )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnNavBack )
    VGUIButtonLoadout_Init( Hud_GetChild( file.menu, "Choice1" ) )
    VGUIButtonLoadout_OnClick( Hud_GetChild( file.menu, "Choice1" ), Choice1Click )
    VGUIButtonLoadout_Init( Hud_GetChild( file.menu, "Choice2" ) )
    VGUIButtonLoadout_OnClick( Hud_GetChild( file.menu, "Choice2" ), Choice2Click )
    VGUIButton_Init( Hud_GetChild( file.menu, "Confirm" ) )
    VGUIButton_SetText( Hud_GetChild( file.menu, "Confirm" ), "CONFIRM" )
    VGUIButton_OnClick( Hud_GetChild( file.menu, "Confirm" ), ConfirmClick )
}

void function ConfirmClick(var b)
{
    if (file.choice == -1)
        return

    table runData = Roguelike_GetRunData()
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    loadouts.append(file.choices[file.choice].primary)
    SetConVarString("roguelike_titan_loadout", JoinStringArray( loadouts, " " ) )
    runData.loadouts = GetConVarString("roguelike_titan_loadout")
    CloseActiveMenu(true)
}

void function Roguelike_SetLoadouts( array<string> loadouts )
{
    table runData = Roguelike_GetRunData()
    SetConVarString("roguelike_titan_loadout", JoinStringArray( loadouts, " " ) )
    runData.loadouts = GetConVarString("roguelike_titan_loadout")

    Roguelike_ForceRefreshInventory()
}

void function Choice1Click(var b)
{
    file.choice = file.option1
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice1" ), eVGUIButtonLoadoutState.Selected )
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice2" ), eVGUIButtonLoadoutState.None )
}
void function Choice2Click(var b)
{
    file.choice = file.option2
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice1" ), eVGUIButtonLoadoutState.None )
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice2" ), eVGUIButtonLoadoutState.Selected )
}

void function OnNavBack()
{

}

void function OnMenuOpen()
{
    file.selectedLoadouts = Roguelike_GetTitanLoadouts()
    
    file.choices.clear()
    foreach (RoguelikeLoadout loadout in VALID_LOADOUTS)
    {
        if (LOCKED_LOADOUTS.contains(loadout.primary) || (loadout.primary == "mp_titanweapon_archon_arc_cannon" && !Roguelike_IsLoadoutUnlocked( loadout )))
            continue
        if (file.selectedLoadouts.contains(loadout.primary))
            continue

        file.choices.append(loadout)
    }

    foreach (RoguelikeLoadout c in file.choices)
        printt(c.primary)

    PRandom rand = NewPRandom( Roguelike_GetRunSeed() + 0x312 )
    file.option1 = PRandomInt( rand, file.choices.len() )
    while (file.option2 == -1 || file.option2 == file.option1)
        file.option2 = PRandomInt( rand, file.choices.len() )

    file.choice = -1
    VGUIButtonLoadout_SetText( Hud_GetChild( file.menu, "Choice1" ), file.choices[file.option1].name )
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice1" ), eVGUIButtonLoadoutState.None )
    VGUIButtonLoadout_SetDescriptionText( Hud_GetChild( file.menu, "Choice1" ), FormatDescription(file.choices[file.option1].description) )
    VGUIButtonLoadout_SetText( Hud_GetChild( file.menu, "Choice2" ), file.choices[file.option2].name )
    VGUIButtonLoadout_SetDescriptionText( Hud_GetChild( file.menu, "Choice2" ), FormatDescription(file.choices[file.option2].description) )
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice2" ), eVGUIButtonLoadoutState.None )
}
