untyped
global function AddRunEndMenu
global function RunEnd_SetRunData

struct {
    var menu
    string nextMap = ""
    int startPointIndex = 0
    int kills = 69
    float time = 370
    array<string> statNames = []
    array<int> statValues = []
    array<int> statPointMultiplier = []
    array<int> statPointOffset = []
} file

void function AddRunEndMenu()
{
	AddMenu( "RunEndMenu", $"resource/ui/menus/run_end.menu", InitRunEndMenu )
}

void function InitRunEndMenu()
{
    file.menu = GetMenu( "RunEndMenu" )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnRunEndMenuOpen )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnNavBack )

	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
}

void function Continue( var panel )
{
    ExecuteLoadingClientCommands_SetStartPoint( file.nextMap, file.startPointIndex )

    ClientCommand( "map " + file.nextMap )
}

void function RunEnd_SetRunData( table data )
{
    file.statNames.clear()
    file.statValues.clear()
    file.statPointMultiplier.clear()

    file.statNames.append("Real Time Spent")
    file.statValues.append(GetUnixTimestamp() - expect int(data.timestamp))
    file.statPointMultiplier.append(10)
    file.statPointOffset.append(0)

    file.statNames.append("Small Enemy Kills")
    file.statValues.append(expect int(data.gruntsKilled))
    file.statPointMultiplier.append(1000)
    file.statPointOffset.append(0)

    file.statNames.append("Big Enemy Kills")
    file.statValues.append(expect int(data.titansKilled))
    file.statPointMultiplier.append(10000)
    file.statPointOffset.append(0)

    file.statNames.append("Damage Dealt (Pilot)")
    file.statValues.append(int(data.damageDealtPilot))
    file.statPointMultiplier.append(1)
    file.statPointOffset.append(0)

    file.statNames.append("Damage Dealt (Titan)")
    file.statValues.append(int(data.damageDealtTitan))
    file.statPointMultiplier.append(1)
    file.statPointOffset.append(0)

    file.statNames.append("Mods Unlocked")
    file.statValues.append(expect int(data.modsUnlocked))
    file.statPointMultiplier.append(10000)
    file.statPointOffset.append(10) // 

    file.statNames.append("Items Obtained")
    file.statValues.append(expect int(data.itemsObtained))
    file.statPointMultiplier.append(10000)
    file.statPointOffset.append(0) // 
}

void function OnNavBack()
{
    // dont.
    ClientCommand("disconnect") // bye
}

void function OnRunEndMenuOpen()
{
    thread MenuAnimation()
	UpdateFooterOptions()
}

void function MenuAnimation()
{
    int pointTotal = 0
    string label = ""
    string valText = ""
    for (int i = 0; i < file.statNames.len(); i++)
    {
        string name = file.statNames[i]
        int val = file.statValues[i]
        int mult = file.statPointMultiplier[i]
        int offset = file.statPointOffset[i]
        pointTotal += (val - offset) * mult

        if (name == "Real Time Spent") // hack...
        {
            int min = val / 60
            int sec = val % 60
            label += FormatDescription( format("%s: <daze>%i:%02i</>\n", name, min, sec) )
        }
        else
            label += FormatDescription( format("%s: <daze>%i</>\n", name, val) )
        valText += FormatDescription( format("<daze>%s</> pts.\n", RecursiveCommas((val - offset) * mult)) )
    }

    Hud_SetText(Hud_GetChild(file.menu, "StatsLabels"), label)
    Hud_SetText(Hud_GetChild(file.menu, "StatsValues"), AlignStringWithMonoFontEast(valText))
    Hud_SetText(Hud_GetChild(file.menu, "Points"), FormatDescription(format("<daze>%s</> pts.\n", RecursiveCommas(pointTotal))))
}
