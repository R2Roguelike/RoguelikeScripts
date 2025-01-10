global function RunSetup_Init

struct 
{
    var menu
    array<string> selectedLoadouts = []
} file

const array<string> AVAILABLE_LOADOUTS = ["mp_titanweapon_xo16_shorty", "mp_titanweapon_meteor", "mp_titanweapon_leadwall"]
const array<string> DIFFICULTY_NAMES = [ "Normal", "Hard", "Master", "Masochist" ]

void function RunSetup_Init()
{
	AddMenu( "RunSetup", $"resource/ui/menus/run_setup.menu", InitRoguelikeRunSetupMenu )
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
    VGUIButton_SetState( button, eVGUIButtonState.Locked )
    VGUIButton_OnClick( button, void function( var panel ) : ()
    {
        if (VGUIButton_GetState( panel ) == eVGUIButtonState.Locked)
            return
        Roguelike_StartNewRun()
		ExecuteLoadingClientCommands_SetStartPoint( "sp_crashsite", 7 )
		ClientCommand( "map sp_crashsite" )
    } )

    bool selected2Loadouts = file.selectedLoadouts.len() >= 2
    for (int i = 0; i < AVAILABLE_LOADOUTS.len(); i++)
    {
        var loadoutButton = Hud_GetChild( file.menu, "LoadoutButton" + i )
        VGUIButton_Init( loadoutButton )
        VGUIButton_SetText( loadoutButton, GetTitanNameFromWeapon(AVAILABLE_LOADOUTS[i]) )
        VGUIButton_OnClick( loadoutButton, LoadoutButtonEventHandler( AVAILABLE_LOADOUTS[i]))

        if (file.selectedLoadouts.contains(AVAILABLE_LOADOUTS[i]))
            VGUIButton_SetState(loadoutButton, eVGUIButtonState.Selected)
        else
            VGUIButton_SetState(loadoutButton, selected2Loadouts ? eVGUIButtonState.Locked : eVGUIButtonState.None)
    }
}

void functionref( var ) function LoadoutButtonEventHandler( string weapon )
{
    return void function( var panel ) : (weapon)
    {
        if (VGUIButton_GetState( panel ) == eVGUIButtonState.Locked)
            return
        
        if (VGUIButton_GetState( panel ) == eVGUIButtonState.Selected)
        {
            file.selectedLoadouts.fastremovebyvalue( weapon )
            Hud_SetText( Hud_GetChild( file.menu, "LoadoutsSelectedCount" ), file.selectedLoadouts.len() + "/2" )
        }
        else
        {
            file.selectedLoadouts.append( weapon )
        }
        Hud_SetText( Hud_GetChild( file.menu, "LoadoutsSelectedCount" ), file.selectedLoadouts.len() + "/2" )
        VGUIButton_SetState( Hud_GetChild( file.menu, "StartButton" ), eVGUIButtonState.Locked )

        bool selected2Loadouts = file.selectedLoadouts.len() >= 2
        
        for (int i = 0; i < AVAILABLE_LOADOUTS.len(); i++)
        {
            var loadoutButton = Hud_GetChild( file.menu, "LoadoutButton" + i )
            if (file.selectedLoadouts.contains(AVAILABLE_LOADOUTS[i]))
                VGUIButton_SetState(loadoutButton, eVGUIButtonState.Selected)
            else
                VGUIButton_SetState(loadoutButton, selected2Loadouts ? eVGUIButtonState.Locked : eVGUIButtonState.None)
        }
        VGUIButton_SetState( Hud_GetChild( file.menu, "StartButton" ), selected2Loadouts ? eVGUIButtonState.Selected : eVGUIButtonState.Locked )
        
        SetConVarString( "roguelike_titan_loadout", JoinStringArray( file.selectedLoadouts, " " ) )
    }
}

void function DifficultyMenuPopUp( var button )
{
	DialogData dialogData
	dialogData.header = "#SP_DIFFICULTY_MISSION_SELECT_TITLE"

	AddDialogButton( dialogData, "Normal", SelectDifficulty( 0 ), "For those who are either fresh off the campaign or after not playing for a long time." )
	AddDialogButton( dialogData, "Hard", SelectDifficulty( 1 ), "The intended experience.\n^F4D5A600Recommended if you've played Titanfall 2 recently." )
	AddDialogButton( dialogData, "Master", SelectDifficulty( 2 ), "Enemy health increased, enemy cooldowns halved.\n^F4D5A600Recommended for those who found Hard too easy." )
	AddDialogButton( dialogData, "Masochist", SelectDifficulty( 3 ), "Enemy health is even worse. Wait, cooldowns? What cooldowns?\n^F4D5A600Recommended if you've beat Roguelike." )

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
