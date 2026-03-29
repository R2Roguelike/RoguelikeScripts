untyped
global function AddInventoryMenu
global function OpenInventoryMenu
global function FormatDescription
global function GetModDescriptionSuffix
global function Roguelike_GetStat
global function Roguelike_ForceRefreshInventory
global function Roguelike_InventorySetLastDiffSetTime
global function GetDismantleFrac
global function AttemptDismantle
global function StopDismantle
global function Roguelike_GetModDescription
global function Roguelike_PulseElem
global function Inventory_GetStatPanel
global function Roguelike_GetStatRaw
global function Roguelike_ConsumeCheckpointMod

struct {
    var menu
    bool isTitanMode = false
    float slideFrac = 0.0
    string nextMap = ""
    int startPointIndex = 0
    int kills = 69
    GridMenuData gridData
    bool isOpen = true
    array<var> modSlots
    float startDismantleTime = -1.0
    float endDismantleTime = -1.0
    array<var> statPanelsTitan
    array<var> statPanelsPilot
} file

void function AddInventoryMenu()
{
    SetConVarInt("script_server_fps", 60)
    SetConVarInt("sv_updaterate_sp", 60)
    SetConVarInt("sv_maxvelocity", 36000)
	AddMenu( "InventoryMenu", $"resource/ui/menus/inventory.menu", InitInventoryMenu )
    delaythread(0.001) UpdateMenuState()
    delaythread(0.001) UpdateInventory()
}

void function InitInventoryMenu()
{
    file.menu = GetMenu( "InventoryMenu" )
    RegisterSignal( "StopDismantle" )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpen )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnClose )

	file.gridData.columns = 2
	file.gridData.rows = 7
	file.gridData.numElements = 16
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = ContentScaledXAsInt( 80 )
	file.gridData.tileHeight = ContentScaledYAsInt( 80 )
	file.gridData.paddingVert = int( ContentScaledX( 8 ) )
	file.gridData.paddingHorz = int( ContentScaledX( 8 ) )
	file.gridData.initCallback = Slot_Init

    GridMenuInit( file.menu, file.gridData )
    Grid_InitPage( file.menu, file.gridData )

    for (int i = 0; i < 19; i++)
    {
        int x = i % 8
        int y = i / 8
        var titanStat = Hud_GetChild( Hud_GetChild(file.menu, "StatPanelTitan"), "GridButton" + x + "x" + y )
        var pilotStat = Hud_GetChild( Hud_GetChild(file.menu, "StatPanelPilot"), "GridButton" + x + "x" + y )
        titanStat.s.index <- i
        pilotStat.s.index <- i
        int eightX = ContentScaledXAsInt(8)
        int eightY = ContentScaledYAsInt(8)
        //Hud_SetX( titanStat, i * (ContentScaledXAsInt(256) + eightX) )
        //Hud_SetX( pilotStat, (3-i) * (ContentScaledXAsInt(256) + eightX) )
        Hud_SetY( titanStat, (i) * (ContentScaledYAsInt(32) + eightY) )
        Hud_SetY( pilotStat, (i) * (ContentScaledYAsInt(32) + eightY) )
        file.statPanelsTitan.append(titanStat)
        file.statPanelsPilot.append(pilotStat)
    }

    foreach (var statPanel in file.statPanelsTitan)
    {
        Hud_SetSize( statPanel, ContentScaledXAsInt(384), ContentScaledYAsInt(36) )
        Hud_Show(statPanel)
    }
    foreach (var statPanel in file.statPanelsPilot)
    {
        Hud_SetSize( statPanel, ContentScaledXAsInt(384), ContentScaledYAsInt(36) )
        Hud_Show(statPanel)
    }

    // add hovers to armor chips
    AddHover( Hud_GetChild( file.menu, "ACPilot1" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot2" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot3" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot4" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan1" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan2" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan3" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan4" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )

    AddHover( Hud_GetChild(file.menu, "WeaponPrimary"), RoguelikeWeapon_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "WeaponSecondary"), RoguelikeWeapon_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "Grenade"), RoguelikeGrenade_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "Datacore"), RoguelikeDatacore_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )

    var switchPanel =  Hud_GetChild(file.menu, "InventorySwitch")
    Hud_EnableKeyBindingIcons( Hud_GetChild( switchPanel, "SwitchPromptLeft"))
    Hud_EnableKeyBindingIcons( Hud_GetChild( switchPanel, "SwitchPromptRight"))

    RegisterButtonPressedCallback( BUTTON_X, AttemptUpgrade )
    RegisterButtonPressedCallback( MOUSE_RIGHT, AttemptUpgrade )
    RegisterButtonPressedCallback( KEY_F, AttemptDismantle )
    RegisterButtonReleasedCallback( KEY_F, StopDismantle )
    RegisterButtonPressedCallback( KEY_Q, QPress )
    RegisterButtonPressedCallback( KEY_E, EPress )
    RegisterButtonPressedCallback( BUTTON_Y, AttemptDismantle )
    RegisterButtonReleasedCallback( BUTTON_Y, StopDismantle )


    array<var> modButtons = GetElementsByClassname( file.menu, "ModSlot" )

    // HELP TEXT
    for (int i = 1; i < 5; i++)
    {
        AddHover( Hud_GetChild(file.menu, "AC" + i + "_PilotHelp"), ModHelp_Hover, HOVER_SIMPLE )
        AddHover( Hud_GetChild(file.menu, "AC" + i + "_TitanHelp"), ModHelp_Hover, HOVER_SIMPLE )
    }

    // STAT IMAGES
    /*for (int i = 0; i < STAT_COUNT; i++)
    {
        string statName = STAT_NAMES[i]
        var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        var bg = Hud_GetChild(statPanel, "BG")
        bg.SetImage( StringToAsset( "ui/stats/" + statName.tolower() ) )
        statPanel.s.data <- i
        AddHover( statPanel, Stat_Hover, HOVER_SIMPLE )

        if (i >= STAT_TITAN_COUNT)
        {
            var label = Hud_GetChild(statPanel, "Value")

            bg.SetColor( [ 255, 176, 0, 255 ] )
            label.SetColor( [ 255, 176, 0, 255 ] )
        }
    }*/

    foreach (var modSlot in modButtons)
    {
        Hud_AddEventHandler( Hud_GetChild(modSlot, "Button"), UIE_CLICK, ModSlot_Click )

        string parentName = Hud_GetHudName( Hud_GetParent( modSlot ) )
        bool isTitan = parentName.find("Titan") != null
        int chipSlot = int( parentName.slice(2, 3) )
        modSlot.s.data <- format("AC%i_%sMod%i", chipSlot, isTitan ? "Titan" : "Pilot", int( Hud_GetScriptID( modSlot ) ))
    }

    file.modSlots.extend(modButtons)

    thread void function() : ()
    {
        while( 1)
        {
            wait 0
            for (int i = 0; i < file.statPanelsTitan.len(); i++)
            {
                //var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
                Hud_GetChild(file.statPanelsTitan[i], "Diff").SetAlpha( GraphCapped( Time() - lastDiffSetTime, 0.1, 0.2, 255.0, 0.0 ))
            }
            for (int i = 0; i < file.statPanelsPilot.len(); i++)
            {
                //var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
                Hud_GetChild(file.statPanelsPilot[i], "Diff").SetAlpha( GraphCapped( Time() - lastDiffSetTime, 0.1, 0.2, 255.0, 0.0 ))
            }
        }
    }()
    thread void function() : ()
    {
        var switchButton = Hud_GetChild( file.menu, "InventorySwitch" )
        var inventory = Hud_GetChild( file.menu, "Inventory" )
        Hud_AddEventHandler( Hud_GetChild( switchButton, "Button" ), UIE_CLICK, SwitchInventoryMode )
        float frac = 0.0
        const int SLIDE_AMOUNT = 640

        while( 1 )
        {
            float dt = Time()
            wait 0
            dt = Time() - dt

            file.slideFrac = clamp( file.slideFrac + (file.isTitanMode ? -3.5 * dt : 3.5 * dt), 0, 1 )

            Hud_SetX( inventory, GraphCapped( QuadEaseInOut( file.slideFrac ), 0, 1, ContentScaledXAsInt(640), ContentScaledXAsInt(-640) ))

            bool isFocused = GetFocus() == Hud_GetChild(switchButton, "Button")
            float prevFrac = frac
            frac = GraphCapped( isFocused ? frac + 5.0 * dt : frac - 5.0 * dt, 0, 1, 0, 1 )
            if (prevFrac == frac)
            {
                Hud_SetEnabled( Hud_GetChild( switchButton, "Button" ), true )
            }

            vector color = VectorLerp( <127, 127, 127>, <255,255,255>, file.isTitanMode ? 1.0 : frac )
            vector pilotColor = VectorLerp( <127, 127, 127>, <255,176,0>, file.isTitanMode ? frac : 1.0 )

            RoguelikeLoadout ornull loadout = Roguelike_GetLoadoutFromIndex(1)
            Hud_SetVisible( Hud_GetChild( file.menu, "StatPanelTitan" ), file.slideFrac < 0.5 )
            Hud_SetVisible( Hud_GetChild( file.menu, "StatPanelPilot" ), file.slideFrac > 0.5 )
            for (int i = 1; i < 5; i++)
            {
                Hud_SetVisible( Hud_GetChild( file.menu, "AC" + i + "_TitanMods" ), file.slideFrac < 0.5 )
                Hud_GetChild( file.menu, "AC" + i + "_TitanMods" ).SetPanelAlpha( 255 * GraphCapped( file.slideFrac, 0.0, 0.5, 1.0, 0.0 ) )
                Hud_GetChild( file.menu, "AC" + i + "_PilotMods" ).SetPanelAlpha( 255 * GraphCapped( file.slideFrac, 1.0, 0.5, 1.0, 0.0 ) )
                Hud_SetVisible( Hud_GetChild( file.menu, "AC" + i + "_PilotMods" ), file.slideFrac > 0.5 )
                if (i == 4)
                {
                    Hud_SetVisible( Hud_GetChild( file.menu, "AC" + i + "_TitanMods" ), file.slideFrac < 0.5 && loadout != null )
                }
            }

            var textLeft = Hud_GetChild( switchButton, "TextLeft" )
            var textRight = Hud_GetChild( switchButton, "TextRight" )
            var barLeft = Hud_GetChild( switchButton, "BarLeft" )
            var barRight = Hud_GetChild( switchButton, "BarRight" )
            Hud_SetColor(textLeft, color.x, color.y, color.z, 255 )
            Hud_SetColor(barLeft, color.x, color.y, color.z, 255 )
            Hud_SetHeight( barLeft, ContentScaledYAsInt(file.isTitanMode ? 200 : GraphCapped( QuadEaseInOut(frac), 0, 1, 100, 150 ) ) )
            Hud_SetHeight( barRight, ContentScaledYAsInt(file.isTitanMode ? GraphCapped( QuadEaseInOut(frac), 0, 1, 100, 150 ) : 200 ) )
            Hud_SetColor(textRight, pilotColor.x, pilotColor.y, pilotColor.z, 255 )
            Hud_SetColor(barRight, pilotColor.x, pilotColor.y, pilotColor.z, 255 )
        }
    }()
}

void function QPress( var b )
{
    if (file.isTitanMode)
        return
    SwitchInventoryMode(b)
}
void function EPress( var b )
{
    if (!file.isTitanMode)
        return
    SwitchInventoryMode(b)
}

void function SwitchInventoryMode( var b )
{
    if (uiGlobal.activeMenu != file.menu)
        return
    print("switch")
    file.isTitanMode = !file.isTitanMode
    Hud_SetFocused( Hud_GetChild( file.menu, "GridPanel" ))
    var switchPanel =  Hud_GetChild(file.menu, "InventorySwitch")
    
    Hud_SetVisible( Hud_GetChild(switchPanel, "SwitchPromptLeft"), !file.isTitanMode )
    Hud_SetVisible( Hud_GetChild(switchPanel, "SwitchPromptRight"), file.isTitanMode )

    Hud_SetEnabled( Hud_GetChild( switchPanel, "Button" ), false )
}

float function QuadEaseInOut( float frac )
{
	frac /= 0.5;
	if (frac < 1)
		return 0.5 * frac * frac
	frac--
	return -0.5 * ( frac * ( frac - 2 ) - 1 )
}


float function GetDismantleFrac()
{
    if (file.startDismantleTime == -1)
        return -1
    return Graph( Time(), file.startDismantleTime, file.endDismantleTime, 0, 1.0 )
}

void function AttemptDismantle( var fuck )
{
    Signal( uiGlobal.signalDummy, "StopDismantle" )
    var slot = GetCurrentHoverTarget()
    if (slot == null)
        return
    if (!("canDismantle" in slot.s))
        return
    thread void function():(slot)
    {
        EmitUISound( "UI_CTF_1P_FlagReturnMeter" )
        EndSignal( uiGlobal.signalDummy, "StopHover" )
        EndSignal( uiGlobal.signalDummy, "StopDismantle" )

        OnThreadEnd( void function() : () {
            file.startDismantleTime = -1.0
            file.endDismantleTime = -1.0
            StopUISound( "UI_CTF_1P_FlagReturnMeter" )
        })
        file.startDismantleTime = Time()
        file.endDismantleTime = Time() + 0.4
        wait 0.4

        // DISMANTLE
        int elemNum = Grid_GetElemNumForButton( slot )
        array inventory = Roguelike_GetInventory()
        table item = expect table(inventory[elemNum])

        SwapSequence(slot)
        if ("moneyInvested" in item)
            Roguelike_AddMoney( expect int(item.moneyInvested) / 4 ) // return 25% of money
        inventory.remove(elemNum)

        EmitUISound( "Menu_LoadOut_WeaponCamo_Select" )
        RefreshInventory()
    }()
}
void function StopDismantle( var fuck )
{
    Signal( uiGlobal.signalDummy, "StopDismantle" )
}

void function Stat_Hover( var statPanel, var panel )
{
    int statIndex = expect int(statPanel.s.index)
    RoguelikeStat stat = GetStatForIndex(statIndex)
    string statName = stat.name
    float statValue = Roguelike_GetStat( stat.uniqueName )
    float statValueRaw = Roguelike_GetStatRaw( stat.uniqueName )

    string title = statName
    string description = "MISSING DESCRIPTION"
    switch (statName)
    {
    }
    if (statValueRaw > STAT_CAP)
    {
        description += "\n\n<red>Increasing a stat above 100 has no effect.</>"
    }
    Hud_SetText( Hud_GetChild(panel, "Title"), title)
    Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription(description) )
}

string function GetModDescriptionSuffix( RoguelikeMod mod )
{
    string result = ""
    //if (mod.loadouts.len() > 1)
    //    return "\n\n<warn>Equipping this mod applies it to the ability GLOBALLY, regardless of loadout."

    return result
}

void function OnOpen()
{
    SetBlurEnabled( true )
    RefreshInventory()
}
void function OnClose()
{
    // TODO: save run data
}

void function RefreshInventory()
{
    table runData = Roguelike_GetRunData()

    table datacore = expect table(runData["Datacore"])

    RoguelikeDatacorePerk datacorePerk = GetDatacorePerkDataByName( expect string(datacore.perk1) )
    float datacoreValue = datacorePerk.baseValue + datacorePerk.valuePerLevel * expect int(datacore.rarity)

    SetConVarString( "player_datacore", format("%i %s %f", datacore.dashes, datacore.perk1, datacoreValue))

    Grid_InitPage( file.menu, file.gridData )
    RoguelikeShop_RefreshInventory()

    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot1"), runData.ACPilot1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot2"), runData.ACPilot2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot3"), runData.ACPilot3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot4"), runData.ACPilot4 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan1"), runData.ACTitan1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan2"), runData.ACTitan2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan3"), runData.ACTitan3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan4"), runData.ACTitan4 )

    InventorySlot_Display( Hud_GetChild(file.menu, "WeaponPrimary"), runData.WeaponPrimary )
    InventorySlot_Display( Hud_GetChild(file.menu, "Datacore"), runData.Datacore )
    InventorySlot_Display( Hud_GetChild(file.menu, "WeaponSecondary"), runData.WeaponSecondary )
    InventorySlot_Display( Hud_GetChild(file.menu, "Grenade"), runData.Grenade )

    bool hasTitanLoadoutPassive = GetTitanLoadoutPassiveData()[0] != "No Passive"

    RoguelikeLoadout ornull loadout = Roguelike_GetLoadoutFromIndex(1)

    for (int i = 1; i <= 4; i++)
    {
        if (i == 4)
        {
            Hud_SetVisible( Hud_GetChild(file.menu, "AC4_TitanEnergy"), loadout != null )
            Hud_SetVisible( Hud_GetChild(file.menu, "AC4_TitanMods"), loadout != null )
        }

        int totalEnergyUsed = GetTotalEnergyUsed( i, true )
        int energyAvailable = ArmorChip_GetMaxEnergy(runData["ACTitan" + i])

        // TITAN
        for (int j = 0; j < MOD_SLOTS; j++)
        {
            string modIndex = FormatModIndex(i, true, j)
            RoguelikeMod mod = GetModForIndex(runData[modIndex])

            if ((mod.isSwappable && totalEnergyUsed > energyAvailable) || IsSlotLocked( i, true, j ))
            {
                if (runData[modIndex] == GetModByName("checkpoint_used").index || 
                    runData[modIndex] == GetModByName("checkpoint_used_2").index)
                    runData[modIndex] <- GetModByName("checkpoint_used_2").index // secret punishment mod :3
                else
                    runData[modIndex] <- GetModByName("empty").index
            }

            totalEnergyUsed = GetTotalEnergyUsed( i, true )
        }
        totalEnergyUsed = GetTotalEnergyUsed( i, true )
        Hud_SetText( Hud_GetChild(Hud_GetChild(file.menu, "AC" + i + "_TitanEnergy"), "EnergyBarBG"), format("%i/%i", totalEnergyUsed, energyAvailable) )

        // REWORK - PILOT no longer has energy
        totalEnergyUsed = GetTotalEnergyUsed( i, false )
        energyAvailable = ArmorChip_GetMaxEnergy(runData["ACPilot" + i])

        for (int j = 0; j < MOD_SLOTS; j++)
        {
            string modIndex = FormatModIndex(i, false, j)
            RoguelikeMod mod = GetModForIndex(runData[modIndex])

            if ((mod.isSwappable && totalEnergyUsed > energyAvailable) || IsSlotLocked( i, false, j ))
            {
                if (runData[modIndex] == GetModByName("checkpoint_used").index || 
                    runData[modIndex] == GetModByName("checkpoint_used_2").index)
                    runData[modIndex] <- GetModByName("checkpoint_used_2").index // secret punishment mod :3
                else
                    runData[modIndex] <- GetModByName("empty").index
            }

            totalEnergyUsed = GetTotalEnergyUsed( i, false )
        }

        Hud_SetText( Hud_GetChild(Hud_GetChild(file.menu, "AC" + i + "_PilotEnergy"), "EnergyBarBG"), format("%i/%i", totalEnergyUsed, energyAvailable) )
    }

    array<var> modButtons = GetElementsByClassname( file.menu, "ModSlot" )
    foreach (var modSlot in modButtons)
    {
        RemoveHover(modSlot)
        string modIndex = expect string(modSlot.s.data)
        if (runData[modIndex] != "")
        {
            bool isTitanMod = modIndex.find("Titan") != null
            int chipIndex = int( modIndex.slice( 2, 3 ) )
            int slotIndex = int( modIndex.slice( modIndex.len() - 1, modIndex.len() ) )
            var slotParent = Hud_GetParent( modSlot )
            var nameLabel = Hud_GetChild( slotParent, "Mod" + slotIndex + "Name" )
            var descLabel = Hud_GetChild( slotParent, "Mod" + slotIndex + "Desc" )

            RoguelikeMod mod = GetModForIndex(runData[modIndex])
            /*if (!isTitanMod)
            {
                table chip = expect table(runData["ACPilot" + chipIndex])
                
                if (chip.mods.len() > slotIndex)
                    mod = GetModForIndex(chip.mods[slotIndex])
                else
                    mod = GetModForIndex(0)
            }*/

            ModSlot_DisplayMod( modSlot, isTitanMod, mod )
            array<RoguelikeMod> slotMods = GetModsForChipSlot( chipIndex, isTitanMod )
            bool notification = false
            foreach (RoguelikeMod newMod in slotMods)
            {
                if (runData.newMods.contains(newMod.uniqueName))
                {
                    notification = true
                    break
                }
            }

            
            //if (isTitanMod)
            {
                Hud_SetVisible( modSlot, !IsSlotLocked( chipIndex, isTitanMod, slotIndex ) )
                Hud_SetVisible( nameLabel, !IsSlotLocked( chipIndex, isTitanMod, slotIndex ) )
                Hud_SetVisible( descLabel, !IsSlotLocked( chipIndex, isTitanMod, slotIndex ) )
            }
            /*else
            {
                Hud_SetVisible( modSlot, mod.index != 0 )
                Hud_SetVisible( nameLabel, mod.index != 0 )
                Hud_SetVisible( descLabel, mod.index != 0 )
            }*/

            nameLabel.SetColor( GetModColor(mod) )
            //descLabel.SetColor( GetModColor(mod) )
            Hud_SetText( nameLabel, mod.name )
            string shortdesc = FormatDescription( mod.shortdesc )
            if (!isTitanMod)
                shortdesc = AlignStringWithMonoFontEast( shortdesc )
            Hud_SetText( descLabel, FormatDescription( shortdesc ) )
            Hud_SetColor(Hud_GetChild(modSlot, "Overlay"), 255, 255, 0, 0 )
            Hud_SetVisible(Hud_GetChild(modSlot, "Overlay"), notification)
            Signal( Hud_GetChild(modSlot, "Overlay"), "ElemFlash" ) // stop flashing
            thread Roguelike_PulseElem( file.menu, Hud_GetChild(modSlot, "Overlay"), ((chipIndex) * 0.2 + (slotIndex % 2 * 0.1)) % 2.0 )

            AddHover( modSlot, ModSlot_Hover, HOVER_SIMPLE )
        }
    }
    
    Roguelike_ApplyRunDataToConVars()

    string statsConVar = ""

    array<float> stats = NewStatArray(true) // includes base value

    switch (Roguelike_GetRunModifier("battery_healing"))
    {
        case 0:
            stats[GetStatByName("battery_healing").index] += 400
            break
        case 1:
            stats[GetStatByName("battery_healing").index] += 200
            break
        case 2:
            break
        case 3:
            stats[GetStatByName("battery_healing").index] -= 200
            break
        case 4:
            stats[GetStatByName("battery_healing").index] -= 400
            break
    }

    for (int chip = 1; chip <= 4; chip++)
    {
        table pilotData = expect table(runData["ACPilot" + chip])
        table titanData = expect table(runData["ACTitan" + chip])

        foreach (table data in [pilotData, titanData])
        {
            AddStatsArrays( stats, ArmorChip_GetStats( data ))
        }
    }

    for (int i = 0; i < 2; i++)
    {
        //AddHover( Hud_GetChild(file.menu, "AC" + i + "_PilotHelp"), ModHelp_Hover, HOVER_SIMPLE )
        string name = "???"

        if (Roguelike_GetTitanLoadouts().len() > i)
        {
            RoguelikeLoadout loadout = expect RoguelikeLoadout(Roguelike_GetLoadoutFromIndex(i))
            name = loadout.name
        }
        Hud_SetText( Hud_GetChild(file.menu, "AC" + (3 + i) + "_TitanHelp"), name + " Chip" )
    }

    foreach (string mod in Roguelike_GetModList()) // returns ints as strings for some reason.... 
    {
        RoguelikeMod modInfo = GetModForIndex(int(mod))
        foreach (RoguelikeStatModifier modifier in modInfo.statModifiers)
        {
            stats[GetStatByName(modifier.stat).index] += modifier.amount
        }
    }
    
    if (Roguelike_HasDatacorePerk( "ability_cd" ))
    {
        float datacoreVal = Roguelike_GetDatacoreValue()
        
        stats[GetStatByName("cd_reduction").index] += 1.0 / (1.0 - datacoreVal / 100.0) - 1.0
    }
    if (Roguelike_HasDatacorePerk( "second_wind" ))
    {
        stats[GetStatByName("battery_healing").index] = RoundToNearestInt(stats[GetStatByName("battery_healing").index] * (100.0 - Roguelike_GetDatacoreValue()) / 100.0)
    }
    if (Roguelike_HasMod("battery_heals"))
    {
        stats[GetStatByName("battery_healing").index] = RoundToNearestInt(stats[GetStatByName("battery_healing").index] * 1.35)
    }
    if (Roguelike_HasMod("max_shield"))
    {
        stats[GetStatByName("max_shields").index] = RoundToNearestInt(stats[GetStatByName("max_shields").index] * 1.5)
    }

    // TITAN LOADOUTS
    
    array<RoguelikeLoadout ornull> titanLoadouts = [Roguelike_GetLoadoutFromIndex(0), Roguelike_GetLoadoutFromIndex(1)]
    
    for (int i = 0; i < 2; i++)
    {
        var weapon = Hud_GetChild(file.menu, "Loadout" + i + "Weapon")
        var offensive = Hud_GetChild(file.menu, "Loadout" + i + "Offensive")
        var utility = Hud_GetChild(file.menu, "Loadout" + i + "Utility")
        var defensive = Hud_GetChild(file.menu, "Loadout" + i + "Defensive")
        var core = Hud_GetChild(file.menu, "Loadout" + i + "Core")
        
        RemoveHover(weapon)
        RemoveHover(offensive)
        RemoveHover(utility)
        RemoveHover(defensive)
        RemoveHover(core)

        if (titanLoadouts[i] == null || !IsFullyConnected())
        {
            Hud_Hide(weapon)
            Hud_Hide(offensive)
            Hud_Hide(utility)
            Hud_Hide(defensive)
            Hud_Hide(core)
            continue
        }
        
        RoguelikeLoadout loadout = expect RoguelikeLoadout(titanLoadouts[i])
        Hud_Show(weapon)
        Hud_Show(offensive)
        Hud_Show(utility)
        Hud_Show(defensive)
        Hud_Show(core)
        AbilitySlot_Display(weapon, loadout.primary, -1)
        AbilitySlot_Display(offensive, loadout.offensive, 0)
        AbilitySlot_Display(utility, loadout.utility, 2)
        AbilitySlot_Display(defensive, loadout.defensive, 1)
        AbilitySlot_Display(core, loadout.core, 3)
    }

    array<RoguelikeStat> titanStats = Roguelike_GetStatsForSide( true, true )
    array<RoguelikeStat> pilotStats = Roguelike_GetStatsForSide( false, true )
    /*for (int i = titanStats.len() - 1; i > 0; i--)
    {
        if (stats[titanStats[i].index] == titanStats[i].baseValue)
            titanStats.remove(i)
    }
    for (int i = pilotStats.len() - 1; i > 0; i--)
    {
        if (stats[pilotStats[i].index] == pilotStats[i].baseValue)
            pilotStats.remove(i)
    }*/
    for (int i = 0; i < file.statPanelsTitan.len(); i++)
    {
        // titan
        var statPanel = file.statPanelsTitan[i]
        
        Hud_Hide( Hud_GetChild(statPanel, "Name"))
        Hud_Hide( Hud_GetChild(statPanel, "Diff"))
        Hud_Hide( Hud_GetChild(statPanel, "Value"))
        Hud_Hide( Hud_GetChild(statPanel, "HeaderTitle"))

        if (titanStats.len() <= i)
        {
            continue
        }
        
        RoguelikeStat stat = titanStats[i]

        if (stat.isHeader)
        {
            Hud_Show( Hud_GetChild(statPanel, "HeaderTitle") )
            Hud_SetText( Hud_GetChild(statPanel, "HeaderTitle"), stat.name)
            continue   
        }
        
        Hud_Show( Hud_GetChild(statPanel, "Name"))
        Hud_Show( Hud_GetChild(statPanel, "Diff"))
        Hud_Show( Hud_GetChild(statPanel, "Value"))
        Hud_SetText( Hud_GetChild(statPanel, "Name"), stat.name)
        Hud_SetColor(Hud_GetChild(statPanel, "Name"), 200, 200, 200, 255 )
        
        if (stat.uniqueName == "ability_power" || stat.name == "Ability Power")
        {
            Hud_SetColor(Hud_GetChild(statPanel, "Name"), 255, 137, 18, 255 )
        }
        RemoveHover( statPanel )
        if (stat.description != "")
        {
            Hud_SetText( Hud_GetChild(statPanel, "Name"), FormatDescription("<daze>(?)</> " + stat.name))
            AddHover( statPanel, void function( var slot, var panel ) : (stat) {
                HoverSimpleData data
                data.title = stat.name
                data.description = stat.description
                HoverSimple_SetData(data)
            }, HOVER_SIMPLE )
        }
        //Hud_SetText( Hud_GetChild(statPanel, "Diff"), stats[titanStats[i].index])
        string format = Roguelike_FormatStatValue(stat, stats[stat.index])
        Hud_SetText( Hud_GetChild(statPanel, "Value"), format)
        Hud_SetText( Hud_GetChild(statPanel, "HeaderTitle"), "")
    }
    
    for (int i = 0; i < file.statPanelsPilot.len(); i++)
    {
        // pilot
        var statPanel = file.statPanelsPilot[i]
        Hud_Hide( Hud_GetChild(statPanel, "Name"))
        Hud_Hide( Hud_GetChild(statPanel, "Diff"))
        Hud_Hide( Hud_GetChild(statPanel, "Value"))
        Hud_Hide( Hud_GetChild(statPanel, "HeaderTitle"))

        if (pilotStats.len() <= i)
        {
            continue
        }

        RoguelikeStat stat = pilotStats[i]

        if (stat.isHeader)
        {
            Hud_Show( Hud_GetChild(statPanel, "HeaderTitle") )
            Hud_SetText( Hud_GetChild(statPanel, "HeaderTitle"), stat.name)
            continue   
        }

        Hud_Show( Hud_GetChild(statPanel, "Name"))
        Hud_Show( Hud_GetChild(statPanel, "Diff"))
        Hud_Show( Hud_GetChild(statPanel, "Value"))
        Hud_SetText( Hud_GetChild(statPanel, "HeaderTitle"), "")
        Hud_SetText( Hud_GetChild(statPanel, "Name"), FormatDescription(stat.name))
        //Hud_SetText( Hud_GetChild(statPanel, "Diff"), stats[titanStats[i].index])
        string format = Roguelike_FormatStatValue(stat, stats[stat.index])
        Hud_SetText( Hud_GetChild(statPanel, "Value"), format)

        //var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        //Hud_SetText( Hud_GetChild(statPanel, "Value"), string( total ) )
    }
    statsConVar = JoinFloatArray( stats, " " )

    // HACK: should be moved to Roguelike_ApplyRunDataToConVars
    SetConVarString( "player_stats", strip( statsConVar ) )

    if (IsFullyConnected() && GetUIPlayer() && !uiGlobal.isLoading)
    {
        ClientCommand( "RefreshInventory" )
        RunClientScript("ClWeaponStatus_RefreshWeaponStatus")
    }
}

bool function Slot_Init( var button, int elemNum )
{
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar1" ), 1 )
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar2" ), 1 )

    button.s.canDismantle <- true

    if (!("clickCallback" in button.s))
    {
        Hud_AddEventHandler( Hud_GetChild( button, "Button" ), UIE_CLICK, InventorySlot_Click )
        button.s.clickCallback <- true
    }

    RemoveHover( button )
    array inventory = Roguelike_GetInventory()
    if (elemNum < inventory.len())
    {
        InventorySlot_Display( button, inventory[elemNum] )
        switch (inventory[elemNum].type)
        {
            case "armor_chip":
                AddHover( button, ArmorChip_GetHoverFunc( file.menu, true, true, true ), HOVER_ARMOR_CHIP )
                break
            case "weapon":
                AddHover( button, RoguelikeWeapon_GetHoverFunc( file.menu, true, true, true ), HOVER_WEAPON )
                break
            case "datacore":
                AddHover( button, RoguelikeDatacore_GetHoverFunc( file.menu, true, true, true ), HOVER_WEAPON )
                break
            case "grenade":
                AddHover( button, RoguelikeGrenade_GetHoverFunc( file.menu, true, true, true ), HOVER_WEAPON )
                break
        }
    }
    else
    {
        InventorySlot_Display( button, null )
    }
    return true
}

bool function TitanStat_Init( var button, int elemNum )
{
    RemoveHover( button )

    return true
}

bool function PilotStat_Init( var button, int elemNum )
{
    RemoveHover( button )
    
    return true
}

void function InventorySlot_Click( var button )
{
    var slot = Hud_GetParent( button )
    table runData = Roguelike_GetRunData()
    array inventory = expect array(runData.inventory)
    int elemNum = Grid_GetElemNumForButton( slot )
    if (elemNum >= inventory.len())
        return
    table curSlot = expect table(inventory[elemNum])

    EmitUISound( "menu_loadout_ordinance_select" )
    SwapSequence(slot)
    switch (curSlot.type)
    {
        case "datacore":
            table equippedChip = expect table(runData["Datacore"])
            runData["Datacore"] = curSlot
            if (curSlot.perk1 == "unlocalized")
            {
                LaunchExternalWebBrowser( "https://www.youtube.com/watch?v=dQw4w9WgXcQ", 2 ) // :)
            }
            inventory[elemNum] = equippedChip
            SwapSequenceAlt(Hud_GetChild(file.menu, "Datacore"))
            break
        case "armor_chip":
            bool isTitan = expect bool( curSlot.isTitan )
            string titanOrPilotString = GetTitanOrPilotFromBool( isTitan )
            int chipSlot = expect int( curSlot.slot )
            table equippedChip = expect table(runData["AC" + titanOrPilotString + chipSlot])
            runData["AC" + titanOrPilotString + chipSlot] = curSlot
            inventory[elemNum] = equippedChip
            SwapSequenceAlt(Hud_GetChild(file.menu, "AC" + titanOrPilotString + chipSlot))
            break
        case "weapon":
            string weaponClassName = expect string(curSlot.weapon)
            string weaponSlot = RoguelikeWeapon_GetSlot( weaponClassName )
            switch (weaponSlot)
            {
                case "primary":
                    table equippedChip = expect table(runData["WeaponPrimary"])
                    runData["WeaponPrimary"] = curSlot
                    inventory[elemNum] = equippedChip
                    SwapSequenceAlt(Hud_GetChild(file.menu, "WeaponPrimary"))
                    break
                case "secondary":
                case "special":
                    table equippedChip = expect table(runData["WeaponSecondary"])
                    runData["WeaponSecondary"] = curSlot
                    inventory[elemNum] = equippedChip
                    SwapSequenceAlt(Hud_GetChild(file.menu, "WeaponSecondary"))
                    break
            }
            break
        case "grenade":
            string weaponClassName = expect string(curSlot.weapon)

            table equippedChip = expect table(runData["Grenade"])
            runData["Grenade"] = curSlot
            inventory[elemNum] = equippedChip
            SwapSequenceAlt(Hud_GetChild(file.menu, "Grenade"))
            break
    }
    RefreshInventory()
}

void function SwapSequence( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")

        Hud_SetVisible(swapEffect, true)
        Hud_SetVisible(swapEffect2, true)

        int scaled48 = ContentScaledYAsInt(40)
        if (t <= 0.5)
        {
            float width = GraphCapped( t, 0.0, 0.5, 0, scaled48)
            Hud_SetY( swapEffect, 0 )
            Hud_SetY( swapEffect2, ContentScaledYAsInt(80) - width )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        else
        {
            float width = GraphCapped( t, 0.5, 1.0, scaled48, 0)
            width = ceil(width)
            Hud_SetY( swapEffect, scaled48 - width )
            Hud_SetY( swapEffect2, scaled48 )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }

        if (t == 1.0)
        {
            Hud_SetVisible(swapEffect, false)
            Hud_SetVisible(swapEffect2, false)
        }
    })
}

void function SwapSequenceAlt( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")

        Hud_SetVisible(swapEffect, true)
        Hud_SetVisible(swapEffect2, true)

        int scaled48 = ContentScaledYAsInt(40)
        if (t <= 0.5)
        {
            float width = GraphCapped( t, 0, 0.5, 0, scaled48)
            width = ceil(width)
            Hud_SetY( swapEffect, scaled48 - width )
            Hud_SetY( swapEffect2, scaled48 )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        else
        {
            float width = GraphCapped( t, 0.5, 1.0, scaled48, 0)
            Hud_SetY( swapEffect, 0 )
            Hud_SetY( swapEffect2, ContentScaledYAsInt(80) - width )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        if (t == 1.0)
        {
            Hud_SetVisible(swapEffect, false)
            Hud_SetVisible(swapEffect2, false)
        }
    })
}

string function GetTitanRole(string weapon)
{
    switch (weapon)
    {
        case "mp_titanweapon_xo16_shorty":
            return "SUPPORT / CD REDUCTION"

        case "mp_titanweapon_sticky_40mm":
            return "Tone"

        case "mp_titanweapon_meteor": // scorch
            return "SUPPORT / DAMAGE"

        case "mp_titanweapon_rocketeer_rocketstream":
            return "Brute"

        case "mp_titanweapon_particle_accelerator":
            return "BURST / SUSTAIN"

        case "mp_titanweapon_leadwall": // ronin
            return "BURST / CQB"

        case "mp_titanweapon_sniper":
            return "BURST / LONG RANGE"

        case "mp_titanweapon_predator_cannon":
            return "SUSTAIN / ANY RANGE"
    }
    return "INVALID"
}

RoguelikeLoadout ornull function Roguelike_GetLoadoutFromIndex( int index )
{
    if (Roguelike_GetTitanLoadouts().len() <= index)
        return null
    
    return Roguelike_GetLoadoutFromWeapon(Roguelike_GetTitanLoadouts()[index])
}

void function ModHelp_Hover( var label, var panel )
{
    string hudName = Hud_GetHudName(label)
    table runData = Roguelike_GetRunData()

    HoverSimpleData data
    string title = "MISSING TITLE"
    string description = "MISSING DESCRIPTION"
    switch (hudName)
    {
        case "AC1_PilotHelp":
            title = "Survival Mods"
            description = "These mods focus on improving your survivability as a pilot."
            break
        case "AC2_PilotHelp":
            title = "Utility Mods"
            description = "These mods focus on improving your pilot overall."
            break
        case "AC3_PilotHelp":
            title = "Weapon Mods"
            description = "These mods focus on improving your weaponry."
            break
        case "AC4_PilotHelp":
            title = "Ability Mods"
            description = "These mods focus on improving your abilities."
            break
        case "AC1_TitanHelp":
            title = "Survival Mods"
            description = "These mods focus on improving your survivability as a titan."
            break
        case "AC2_TitanHelp":
            title = "Utility Mods"
            description = "These mods focus on improving your titan overall."
            break
        case "AC3_TitanHelp":
            RoguelikeLoadout ornull loadout = Roguelike_GetLoadoutFromIndex(0)
            if (loadout != null)
            {
                expect RoguelikeLoadout(loadout)
                title = loadout.name + " Mods"
                description = format("These mods focus on improving %s.\n\n%s", loadout.name, loadout.description)
            }
            break
        case "AC4_TitanHelp":
            RoguelikeLoadout ornull loadout = Roguelike_GetLoadoutFromIndex(1)
            title = "??? Mods"
            description = "These mods focus on... <red>something you haven't acquired yet?</> It seems like you'll have to <red>continue</> for this all to make sense."
            if (loadout != null)
            {
                expect RoguelikeLoadout(loadout)
                title = loadout.name + " Mods"
                description = format("These mods focus on improving %s.\n\n%s", loadout.name, loadout.description)
            }
            break
    }

    data.title = title
    data.description = FormatDescription(description)

    HoverSimple_SetData( data )
}

void function OpenInventoryMenu( bool isTitan )
{
    file.isTitanMode = isTitan
    file.slideFrac = isTitan ? 0.0 : 1.0
    var switchPanel =  Hud_GetChild(file.menu, "InventorySwitch")

    Hud_SetVisible( Hud_GetChild(switchPanel, "SwitchPromptLeft"), !file.isTitanMode )
    Hud_SetVisible( Hud_GetChild(switchPanel, "SwitchPromptRight"), file.isTitanMode )

    if (uiGlobal.activeMenu == null) // bruh
	    AdvanceMenu( file.menu )
}

string function Roguelike_GetModDescription(RoguelikeMod mod)
{
    string desc = ""

    string tagDescs = ""
    if (mod.tags.len() > 0)
    {
        tagDescs = "<cyan>"
        foreach (string tag in mod.tags)
        {
            tagDescs += Roguelike_GetTagDesc(tag) + " "
        }
        tagDescs += "</>\n\n"
    }

    return format("%s", FormatDescription(tagDescs + mod.description))
}

void function ModSlot_Hover( var slot, var panel )
{
    HoverSimpleData hoverData
    string modIndex = expect string(slot.s.data)
    bool isTitanMod = modIndex.find("Titan") != null
    int chipIndex = int( modIndex.slice( 2, 3 ) )
    int slotIndex = int( modIndex.slice( modIndex.len() - 1, modIndex.len() ) )
    table runData = Roguelike_GetRunData()

    RoguelikeMod mod = GetModForIndex(runData[modIndex])
    /*if (!isTitanMod)
    {
        var chip = runData["ACPilot" + chipIndex]
        mod = GetModForIndex( chip.mods[slotIndex] )
    }*/

    hoverData.title = mod.name
    hoverData.color = GetModColor(mod)
    hoverData.description = Roguelike_GetModDescription(mod)
    ModSlot_UpdateBoxes( mod )
    hoverData.boxes = mod.boxes
    HoverSimple_SetData(hoverData)
}

// utility to allow using <color> tags instead of memorizing ^ABCDEF12 sequences
string function FormatDescription(string desc)
{
    string result = desc
    result = StringReplace( result, "</>",     "^FFFFFFFF", true )
    result = StringReplace( result, "<cyan>",  "^20D0FF00", true )
    result = StringReplace( result, "<charge>",  "^40FFFF00", true )
    result = StringReplace( result, "<daze>",  "^FFE16400", true )
    result = StringReplace( result, "<overload>",  "^0080FF00", true )
    result = StringReplace( result, "<warn>",  "^FFA00000", true )
    result = StringReplace( result, "<note>",  "^88888800", true )
    result = StringReplace( result, "<fulm>",  "^4060FF00", true )
    result = StringReplace( result, "<burn>",  "^FF891200", true )
    result = StringReplace( result, "<green>", "^60FF6000", true )
    result = StringReplace( result, "<red>",   "^FF404000", true )
    result = StringReplace( result, "<weak>",  "^B15EFF00", true )
    result = StringReplace( result, "<magic>", "^FF7AF400", true )
    result = StringReplace( result, "<arm>", "^FF40C000", true )
    result = StringReplace( result, "<punc>", "^FF404000", true )
    result = StringReplace( result, "<hack>", "^20FF2000", true )

    return result
}

void function ModSlot_Click( var button )
{
    var slot = Hud_GetParent( button )

    string data = expect string( slot.s.data )

    if (!GetModForIndex(Roguelike_GetRunData()[data]).isSwappable)
        return

    ModSelect_SetContext( data, Hud_GetAbsX( slot ), Hud_GetAbsY( slot ) )

    OpenSubmenu( GetMenu("ModSelect"), false )
}

void function AttemptUpgrade( var env )
{
    if (uiGlobal.activeMenu != file.menu)
        return

    var slot = GetCurrentHoverTarget()
    if (slot == null)
        return

    table data = {}
    if (Hud_GetHudName(slot) in Roguelike_GetRunData())
    {
        data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
    }
    else
    {
        try
        {

        int elemNum = Grid_GetElemNumForButton( slot )
        data = expect table(Roguelike_GetInventory()[elemNum])
        }
        catch (e)
        {
            return
        }
    }

    int price = Roguelike_GetUpgradePrice( data )
    int maxRarityObtained = expect int(Roguelike_GetRunData().maxRarityObtained)
    if ((data.level >= Roguelike_GetItemMaxLevel( data ) && (data.type != "armor_chip" || maxRarityObtained <= data.rarity)) || (Roguelike_GetMoney() < price && !GetConVarBool("roguelike_unlock_all")))
    {
        EmitUISound( "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Unsuccessful_1P" )
        return
    }

    EmitUISound( "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Successful_1P" )
    Roguelike_TakeMoney( price )

    if (data.level == 3 && data.type == "armor_chip")
    {
        data.level = 0
        data.rarity += 1
    }
    else
    {
        data.level += 1
    }
    data.moneyInvested += price

    switch (data.type)
    {
        case "armor_chip":
            break
        case "weapon":
            break
    }

    RefreshInventory()
}

float lastDiffSetTime = -99.9

void function Roguelike_InventorySetLastDiffSetTime(float val)
{
    lastDiffSetTime = val
}

void function UpdateMenuState()
{
	for ( ;; )
	{
		WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		if ( IsFullyConnected() )
		{
			int newState = 0
			if ( IsDialogOnlyActiveMenu() )
				newState = 2
			else if ( uiGlobal.activeMenu != null)
				newState = 1

			RunClientScript( "Healthbars_SetMenuState", newState )
            if (Roguelike_IsRunActive())
            {
                RunClientScript("RoguelikeTimer_SetMoney", Roguelike_GetMoney())
                RunClientScript("RoguelikeTimer_SetStartTime", Roguelike_GetRunData().timestamp)
            }
		}
	}
}

void function UpdateInventory()
{
	for ( ;; )
	{
		WaitSignal( uiGlobal.signalDummy, "LevelStartedLoading" )

        if (!Roguelike_IsRunActive())
        {
            Roguelike_StartNewRun()
        }

        RefreshInventory()
	}
}

void function Roguelike_ForceRefreshInventory()
{
    RefreshInventory()
}

array<string> statsCache
string statsVal
float function Roguelike_GetStat( string stat )
{
    if (statsVal != GetConVarString("player_stats"))
    {
        statsVal = GetConVarString("player_stats")
        statsCache = split( GetConVarString("player_stats"), " " )
        print("alloc")
    }

    int index = GetStatByName(stat).index
    if (statsCache.len() <= index)
        return GetStatByName(stat).baseValue
    float baseVal = float( statsCache[index] )
    
    if (GetStatByName(stat).diminishingReturns)
        return 1.0 / (1.0 + baseVal)

    return baseVal
}
float function Roguelike_GetStatRaw( string stat )
{
    if (statsVal != GetConVarString("player_stats"))
    {
        statsVal = GetConVarString("player_stats")
        statsCache = split( GetConVarString("player_stats"), " " )
        print("alloc")
    }

    int index = GetStatByName(stat).index
    if (statsCache.len() < index)
        return GetStatByName(stat).baseValue
    return float( statsCache[index] )
}

void function Roguelike_PulseElem( var menu, var element, float delay = 0, int startAlpha = 255, int endAlpha = 0, float rate = 2.0 )
{
	EndSignal( menu, "StopMenuAnimation" )

	Assert( element != null )

	Signal( element, "ElemFlash" )
	EndSignal( element, "ElemFlash" )

	local duration = rate
    wait delay
	Hud_SetAlpha( element, startAlpha )
	while ( true )
	{
		Hud_FadeOverTime( element, endAlpha, duration * 0.5, INTERPOLATOR_LINEAR )
		wait duration
        Hud_SetAlpha( element, startAlpha )
	}
}

var function Inventory_GetStatPanel( bool isTitan, int index )
{
    return isTitan ? file.statPanelsTitan[index] : file.statPanelsPilot[index]
}

array<string> datacoreCache
string datacoreVal = ""
bool function Roguelike_HasDatacorePerk( string perk )
{
    if (datacoreVal != GetConVarString("player_datacore"))
    {
        datacoreVal = GetConVarString("player_datacore")
        datacoreCache = split( GetConVarString("player_datacore"), " " )
        print("alloc")
    }
    if (datacoreCache.len() > 1)
        return datacoreCache[1] == perk
    return false
}

float function Roguelike_GetDatacoreValue()
{
    if (datacoreVal != GetConVarString("player_datacore"))
    {
        datacoreVal = GetConVarString("player_datacore")
        datacoreCache = split( GetConVarString("player_datacore"), " " )
        print("alloc")
    }
    if (datacoreCache.len() > 1)
        return float( datacoreCache[2] )
    return 0.0
}

void function Roguelike_ConsumeCheckpointMod()
{
    for (int i = 0; i <= 3; i++)
    {
        string modIndex = format( "AC1_TitanMod%i", i )
        if (GetModForIndex(Roguelike_GetRunData()[modIndex]).uniqueName == "checkpoint")
        {
            Roguelike_GetRunData()[modIndex] <- GetModByName("checkpoint_used").index
            return
        }
    }
}
