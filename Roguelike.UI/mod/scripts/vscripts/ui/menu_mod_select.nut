untyped
global function ModSelect_Init
global function ModSelect_SetContext

struct {
    var menu
    int chipIndex
    int modIndex
    bool isTitanMod
    int maxUsableEnergy
    GridMenuData gridData
    array<RoguelikeMod> modChoices
    array<RoguelikeMod> usedMods
    int x
    int y
} file

void function ModSelect_Init()
{
	AddMenu( "ModSelect", $"resource/ui/menus/mod_select.menu", InitRoguelikeModSelectMenu )
}

void function InitRoguelikeModSelectMenu()
{
    file.menu = GetMenu("ModSelect")

	file.gridData.columns = 5
	file.gridData.rows = 4
	file.gridData.numElements = 20
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = ContentScaledXAsInt( 80 )
	file.gridData.tileHeight = ContentScaledYAsInt( 80 )
	file.gridData.paddingVert = int( ContentScaledX( 8 ) )
	file.gridData.paddingHorz = int( ContentScaledX( 8 ) )
	file.gridData.initCallback = Slot_Init

    GridMenuInit( file.menu, file.gridData )

	var screen = Hud_GetChild( file.menu, "Screen" )
    print("ADDING CALLBACK")
	Hud_AddEventHandler( screen, UIE_CLICK, OnModSelectBGScreen_Activate )

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnModSelectMenuOpen )
}

void function OnModSelectMenuOpen()
{
    file.modChoices = GetModsForChipSlot( file.chipIndex, file.isTitanMod )

    Grid_InitPage( file.menu, file.gridData )

    var frame = Hud_GetChild( file.menu, "ButtonFrame" )
    Hud_SetY( frame, file.y + ContentScaledYAsInt( 88 ) )
    if (file.isTitanMod)
    {
        Hud_SetX( frame, file.x + ContentScaledXAsInt( 88 - 448 ) )
    }
    else // has to be a pilot mod instead
    {
        Hud_SetX( frame, file.x - ContentScaledXAsInt( 8 ) )
    }
}

void function ModSelect_SetContext( string modSlot, int x, int y )
{
    table runData = Roguelike_GetRunData()
    file.chipIndex = int( modSlot.slice( 2, 3 ) )
    printt(modSlot)
    file.isTitanMod = modSlot.find("Titan") != null
    file.modIndex = int( modSlot.slice( modSlot.len() - 1, modSlot.len() ) )
    int maxEnergy = 0
    if (file.isTitanMod)
    {
        maxEnergy = expect int(runData["ACTitan" + file.chipIndex].energy)
    }
    else
    {
        maxEnergy = expect int(runData["ACPilot" + file.chipIndex].energy)
    }
    int usedEnergy = GetTotalEnergyUsed(file.chipIndex, file.isTitanMod)

    string runTableIndex = FormatModIndex(file.chipIndex, file.isTitanMod, file.modIndex)
    RoguelikeMod currentMod = GetModForIndex(runData[runTableIndex])

    array<RoguelikeMod> usedMods = GetModArrayForCategory( file.chipIndex, file.isTitanMod )
    for (int i = 0; i < usedMods.len(); i++)
    {
        RoguelikeMod mod = usedMods[i]
        if (mod.uniqueName == "empty" || currentMod.uniqueName == mod.uniqueName)
        {
            usedMods.remove(i)
            i--
        }
    }
    file.usedMods = usedMods

    file.maxUsableEnergy = maxEnergy - usedEnergy + GetModForIndex(runData[modSlot]).cost

    file.x = x
    file.y = y
}

bool function Slot_Init( var slot, int elemNum )
{
    if (!("clickCallback" in slot.s))
    {
        Hud_AddEventHandler( Hud_GetChild( slot, "Button" ), UIE_CLICK, ModSlot_Click )
        slot.s.clickCallback <- true
    }

    table runData = Roguelike_GetRunData()
    RemoveHover( slot )
    if (elemNum < file.modChoices.len())
    {
        AddHover( slot, ModSlot_Hover, HOVER_SIMPLE )
        ModSlot_DisplayMod( slot, file.modChoices[elemNum] )
        if (runData.newMods.contains(file.modChoices[elemNum].uniqueName))
        {
            Hud_SetColor( Hud_GetChild(slot, "BG"), 255,128,32, 135 )
        }
        else
        {
            Hud_SetColor( Hud_GetChild(slot, "BG"), 0,0,0, 135 )
        }
        if (file.modChoices[elemNum].cost > file.maxUsableEnergy || file.usedMods.contains(file.modChoices[elemNum]))
            Hud_SetVisible(Hud_GetChild(slot, "Overlay"), true)
    }
    else
    {
        ModSlot_DisplayMod( slot, null )
    }
    return true
}

void function ModSlot_Hover( var slot, var panel )
{
    int elemNum = Grid_GetElemNumForButton( slot )
    RoguelikeMod mod = file.modChoices[elemNum]
    table runData = Roguelike_GetRunData()
    if (runData.newMods.contains(mod.uniqueName))
    {
        runData.newMods.removebyvalue(mod.uniqueName)
        Hud_SetColor( Hud_GetChild(slot, "BG"), 0,0,0, 135 )
    }

    Hud_SetText( Hud_GetChild(panel, "Title"), mod.name)
    string description = format("Energy Cost: ^FFA00000%i^FFFFFFFF\n\n%s", mod.cost, mod.description + GetModDescriptionSuffix(mod))
    if (mod.cost > file.maxUsableEnergy || file.usedMods.contains(file.modChoices[elemNum]))
    {
        description += "\n"
        if (mod.cost > file.maxUsableEnergy)
            description += "\n<red>Not enough energy</>"
        if (file.usedMods.contains(file.modChoices[elemNum]))
            description += "\n<red>Mod already equipped</>"
    }
    Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription(description))
}

void function ModSlot_Click( var button )
{
    var slot = Hud_GetParent( button )
    int elemNum = Grid_GetElemNumForButton( slot )
    if (elemNum >= file.modChoices.len())
        return

    RoguelikeMod choice = file.modChoices[elemNum]
    table runData = Roguelike_GetRunData()

    string modIndex = FormatModIndex(file.chipIndex, file.isTitanMod, file.modIndex)

    if (choice.cost > file.maxUsableEnergy || file.usedMods.contains(file.modChoices[elemNum]))
    {
        EmitUISound( "blackmarket_purchase_fail" )
        return
    }
    runData[modIndex] = choice.index


    CloseActiveMenu()
}

void function OnModSelectBGScreen_Activate( var button )
{
	CloseActiveMenu()
}