global function LimitedLoadoutChoice_Init

struct
{
    var menu
    array<string> selectedLoadouts = []
    array<string> choices = []
    int choice = -1
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
    loadouts.append(file.choices[file.choice])
    SetConVarString("roguelike_titan_loadout", JoinStringArray( loadouts, " " ) )
    runData.loadouts = GetConVarString("roguelike_titan_loadout")
    CloseActiveMenu(true)
}
void function Choice1Click(var b)
{
    file.choice = 0
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice1" ), eVGUIButtonLoadoutState.Selected )
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice2" ), eVGUIButtonLoadoutState.None )
}
void function Choice2Click(var b)
{
    file.choice = 1
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
    foreach (string loadout in VALID_LOADOUTS)
    {
        if (LOCKED_LOADOUTS.contains(loadout))
            continue
        if (file.selectedLoadouts.contains(loadout))
            continue

        file.choices.append(loadout)
    }

    foreach (string c in file.choices)
        printt(c)
    file.choices.randomize()

    file.choice = -1
    VGUIButtonLoadout_SetText( Hud_GetChild( file.menu, "Choice1" ), GetTitanNameFromWeapon( file.choices[0] ) )
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice1" ), eVGUIButtonLoadoutState.None )
    VGUIButtonLoadout_SetDescriptionText( Hud_GetChild( file.menu, "Choice1" ), FormatDescription(GetTitanDescription( file.choices[0] )) )
    VGUIButtonLoadout_SetText( Hud_GetChild( file.menu, "Choice2" ), GetTitanNameFromWeapon( file.choices[1] ) )
    VGUIButtonLoadout_SetDescriptionText( Hud_GetChild( file.menu, "Choice2" ), FormatDescription(GetTitanDescription( file.choices[1] )) )
    VGUIButtonLoadout_SetState( Hud_GetChild( file.menu, "Choice2" ), eVGUIButtonLoadoutState.None )
}
