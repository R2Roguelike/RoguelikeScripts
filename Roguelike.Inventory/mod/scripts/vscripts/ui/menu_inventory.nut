untyped
global function AddInventoryMenu
global function OpenInventoryMenu

struct {
    var menu
    string nextMap = ""
    int startPointIndex = 0
    int kills = 69
    float time = 370
    GridMenuData gridData
    bool isOpen = true
    array<var> modSlots
    float startDismantleTime = -1.0
    float endDismantleTime = -1.0
} file

void function AddInventoryMenu()
{
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

	file.gridData.columns = 8
	file.gridData.rows = 2
	file.gridData.numElements = 16
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = 96
	file.gridData.tileHeight = 96
	file.gridData.paddingVert = 8
	file.gridData.paddingHorz = 8
	file.gridData.initCallback = Slot_Init

    GridMenuInit( file.menu, file.gridData )
    Grid_InitPage( file.menu, file.gridData )

    // add hovers to armor chips
    AddHover( Hud_GetChild( file.menu, "AC1" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "AC2" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "AC3" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "AC4" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )

    RegisterButtonPressedCallback( BUTTON_X, AttemptUpgrade )
    RegisterButtonPressedCallback( MOUSE_RIGHT, AttemptUpgrade )
    RegisterButtonPressedCallback( KEY_F, AttemptDismantle )
    RegisterButtonReleasedCallback( KEY_F, StopDismantle )
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
    for (int i = 0; i < 6; i++)
    {
        string statName = STAT_NAMES[i]
        var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        var bg = Hud_GetChild(statPanel, "BG")
        bg.SetImage( StringToAsset( "ui/stats/" + statName.tolower() ) )
        statPanel.s.data <- i
        AddHover( statPanel, Stat_Hover, HOVER_SIMPLE )

        if (i >= 3)
        {
            var label = Hud_GetChild(statPanel, "Value")

            bg.SetColor( [ 255, 176, 0, 255 ] )
            label.SetColor( [ 255, 176, 0, 255 ] )
        }
    }

    foreach (var modSlot in modButtons)
    {
        Hud_AddEventHandler( Hud_GetChild(modSlot, "Button"), UIE_CLICK, ModSlot_Click )

        string parentName = Hud_GetHudName( Hud_GetParent( modSlot ) )
        bool isTitan = parentName.find("Titan") != null
        int chipSlot = int( parentName.slice(2, 3) )
        modSlot.s.data <- format("AC%i_%sMod%i", chipSlot, isTitan ? "Titan" : "Pilot", int( Hud_GetScriptID( modSlot ) ))
    }

    file.modSlots.extend(modButtons)
}

void function AttemptDismantle( var fuck )
{
    Signal( uiGlobal.signalDummy, "StopDismantle" )
    var slot = GetCurrentHoverTarget()
    if (slot == null)
        return
    if (!("elemNum" in slot.s))
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
        file.endDismantleTime = Time() + 0.75
        wait 0.75
        
        // DISMANTLE
        int elemNum = Grid_GetElemNumForButton( slot )
        array inventory = Roguelike_GetInventory()
        table item = expect table(inventory[elemNum])
        if ("moneyInvested" in item)
            Roguelike_AddMoney( expect int(item.moneyInvested) * 2 / 3 ) // return 66% of money
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
    int statIndex = expect int(statPanel.s.data)
    string statName = STAT_NAMES[statIndex]
    int statValue = Roguelike_GetStat( statIndex )
    int statValueRaw = Roguelike_GetStatRaw( statIndex )

    string title = statName
    string description = "MISSING DESCRIPTION"
    switch (statIndex)
    {
        case STAT_ARMOR:
            description = format("Reduces Titan damage taken.\n\n"
                + "Titan damage reduced by ^40FFFF00%.1f%%^40FFFFFF.", 
                Roguelike_GetTitanDamageResist(statValue) * 100.0
            )
            break
        case STAT_ENERGY:
            description = format("Increases Titan Core gain rate and decreases Titan Dash cooldown.\n\n" +
                "Core gain increased by ^40FFFF00%.1f%%^40FFFFFF.\nTitan Dash cooldown decreased by ^40FFFF00%.1f%%^40FFFFFF.",
                Roguelike_GetCoreGainBonus( statValue ) * 100.0,
                100.0 - Roguelike_GetDashCooldownMultiplier( statValue ) * 100.0
            )
            break
        case STAT_POWER:
            description = format("Reduces Titan ability cooldowns.\n\n" +
                "Titan ability cooldowns reduced by about ^40FFFF00%.1f%%^40FFFFFF.",
                100.0 - Roguelike_GetTitanCooldownReduction(statValue) * 100.0
            )
            break
        case STAT_TEMPER:
            description = format("Reduces Pilot ability cooldowns.\n\n" +
                "Pilot ability cooldowns reduced by about ^40FFFF00%.1f%%^40FFFFFF.",
                100.0 - Roguelike_GetPilotCooldownReduction(statValue) * 100.0
            )
            break
        case STAT_SPEED:
            description = format("Increases Pilot movement speed.\n\n" +
                "Pilot movement speed increased by ^40FFFF00%.1f%%^40FFFFFF.",
                Roguelike_GetPilotSpeedBonus(statValue) * 100.0
            )
            break
        case STAT_ENDURANCE:
            description = format("Increases Pilot max health.\n\n" +
                "Max health increased by ^40FFFF00%i%%^40FFFFFF.",
                int(Roguelike_GetPilotHealthBonus(statValue) * 100.0)
            )
            break
    }
    if (statValueRaw > 100)
    {
        description += "\n\n^FF404000Increasing a stat above 100 has no effect.^40FFFFFF"
    }
    Hud_SetText( Hud_GetChild(panel, "Title"), title)
    Hud_SetText( Hud_GetChild(panel, "Description"), description )
    Hud_SetHeight( panel, 64 + 16 + Hud_GetHeight(Hud_GetChild(panel, "Description")) )
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

    Grid_InitPage( file.menu, file.gridData )

    Hud_SetText( Hud_GetChild(file.menu, "Money"), Roguelike_GetMoney() + "$" )

    InventorySlot_Display( Hud_GetChild(file.menu, "AC1"), runData.AC1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "AC2"), runData.AC2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "AC3"), runData.AC3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "AC4"), runData.AC4 )

    for (int i = 1; i < 5; i++)
    {
        int totalEnergyUsed = GetTotalEnergyUsed( i, false )
        if (totalEnergyUsed > expect int(runData["AC" + i].pilotEnergy))
        {
            // reset all mods, total energy used is more than max energy
            for (int j = 0; j < MOD_SLOTS; j++)
            {
                runData[FormatModIndex(i, false, j)] <- 0
            }
            totalEnergyUsed = 0
        }
        Hud_SetText(Hud_GetChild(file.menu, format("AC%i_PilotEnergy", i)), format("%i/%i", totalEnergyUsed, runData["AC" + i].pilotEnergy))

        totalEnergyUsed = GetTotalEnergyUsed( i, true )
        if (totalEnergyUsed > expect int(runData["AC" + i].titanEnergy))
        {
            // reset all mods, total energy used is more than max energy
            for (int j = 0; j < MOD_SLOTS; j++)
            {
                runData[FormatModIndex(i, true, j)] <- 0
            }
            totalEnergyUsed = 0
        }
        Hud_SetText(Hud_GetChild(file.menu, format("AC%i_TitanEnergy", i)), format("%i/%i", totalEnergyUsed, runData["AC" + i].titanEnergy))
    }

    array<var> modButtons = GetElementsByClassname( file.menu, "ModSlot" )
    foreach (var modSlot in modButtons)
    {
        RemoveHover(modSlot)
        string modIndex = expect string(modSlot.s.data)
        if (runData[modIndex] != "")
        {
            ModSlot_DisplayMod( modSlot, GetModForIndex(runData[modIndex]) )
            AddHover( modSlot, ModSlot_Hover, HOVER_SIMPLE )
        }
    }

    string modConVar = ""
    for (int i = 1; i < 5; i++)
    {
        for (int j = 0; j < MOD_SLOTS; j++)
        {
            modConVar += runData["AC" + i + "_PilotMod" + j] + " "
            modConVar += runData["AC" + i + "_TitanMod" + j] + " "
        }
    }
    SetConVarString( "player_mods", strip( modConVar ) )

    string statsConVar = ""

    for (int i = 0; i < 6; i++)
    {
        int total = 0
        string statName = STAT_NAMES[i]
        
        for (int chip = 1; chip < 5; chip++)
        {
            table data = expect table(runData["AC" + chip])

            int value = expect int(data.stats[i])
            if (i < 3)
                total += value * expect int(data.titanEnergy)
            else
                total += value * expect int(data.pilotEnergy)
        }

        var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        Hud_SetText( Hud_GetChild(statPanel, "Value"), string( total ) )
        statsConVar += total + " "
    }
    SetConVarString( "player_stats", strip( statsConVar ) )

    if (IsFullyConnected() && GetUIPlayer())
    {
        ClientCommand( "RefreshInventory" )
    }
}

bool function Slot_Init( var button, int elemNum )
{
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar1" ), 1 )
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar2" ), 1 )

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
                AddHover( button, ArmorChip_Hover, HOVER_ARMOR_CHIP )
                break
        }
    }
    else
    {
        InventorySlot_Display( button, null )
    }
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

    switch (curSlot.type)
    {
        case "armor_chip":
            int chipSlot = expect int( curSlot.slot )
            table equippedChip = expect table(runData["AC" + chipSlot])
            runData["AC" + chipSlot] = curSlot
            inventory[elemNum] = equippedChip
            EmitUISound( "menu_loadout_ordinance_select" )
            SwapSequence(slot)
            SwapSequenceAlt(Hud_GetChild(file.menu, "AC" + chipSlot))

            var equippedChipPanel = Hud_GetChild(file.menu, "AC" + chipSlot)
            
            RefreshInventory()
            break
    }    
}

void function SwapSequence( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")
        
        if (t <= 0.5)
        {
            float width = GraphCapped( t, 0.0, 0.5, 0, 48)
            Hud_SetY( swapEffect, 0 )
            Hud_SetY( swapEffect2, 96 - width )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        else
        {
            float width = GraphCapped( t, 0.5, 1.0, 48, 0)
            width = ceil(width)
            Hud_SetY( swapEffect, 48 - width )
            Hud_SetY( swapEffect2, 48 )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
    })
}

void function SwapSequenceAlt( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")
        
        if (t <= 0.5)
        {
            float width = GraphCapped( t, 0, 0.5, 0, 48)
            width = ceil(width)
            Hud_SetY( swapEffect, 48 - width )
            Hud_SetY( swapEffect2, 48 )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        else
        {
            float width = GraphCapped( t, 0.5, 1.0, 48, 0)
            Hud_SetY( swapEffect, 0 )
            Hud_SetY( swapEffect2, 96 - width )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
    })
}

void function ModHelp_Hover( var label, var panel )
{
    string hudName = Hud_GetHudName(label)
    table runData = Roguelike_GetRunData()


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
            title = "Ronin"
            description = "No need for a shield if you've got a giant sword...\n\nRonin's status effect is ^FFE16400Daze^FFFFFFFF." + 
                "\n^FFE16400Daze^FFFFFFFF is inflicted by using your ^40FFFF00shotgun^FFFFFFFF, and is consumed on ^40FFFF00sword hits^FFFFFFFF to " +
                "increase damage by up to 100%.\n\n" +
                "^FFE16400Stack The Deck.^FFFFFFFF Most damage multipliers stack multiplicatively. Use multiple damage bonuses to create an advantage."
            break
        case "AC4_TitanHelp":
            title = "Scorch"
            description = "Set the world ablaze.\n\nScorch's status effect is ^FFAF4B00Burn^FFFFFFFF." + 
                "\n^FFAF4B00Burn^FFFFFFFF is inflicted by using ^40FFFF00any ability^FFFFFFFF. Fully burnt enemies " +
                "^FF404000Erupt^FFFFFFFF, causing a massive explosion and tons of damage.\n\n" +
                "^FFAF4B00Blow Them Up.^FFFFFFFF All of Scorch's abilities deal 75% less damage, but Eruptions more than compensate for that."
            break
    }

    Hud_SetText( Hud_GetChild(panel, "Title"), title)
    Hud_SetText( Hud_GetChild(panel, "Description"), description )
    Hud_SetHeight( panel, 64 + 16 + Hud_GetHeight(Hud_GetChild(panel, "Description")) )
}

void function OpenInventoryMenu()
{
	AdvanceMenu( file.menu )
}

void function ModSlot_Hover( var slot, var panel )
{
    string modIndex = expect string(slot.s.data)
    table runData = Roguelike_GetRunData()

    RoguelikeMod mod = GetModForIndex(runData[modIndex])

    Hud_SetText( Hud_GetChild(panel, "Title"), mod.name)
    Hud_SetHeight( panel, 64 + 16 + Hud_GetHeight(Hud_GetChild(panel, "Description")) )
    Hud_SetText( Hud_GetChild(panel, "Description"), format("Energy Cost: ^FF800000%i^FFFFFFFF\n\n%s", mod.cost, mod.description) )
}
void function ModSlot_Click( var button )
{
    var slot = Hud_GetParent( button )

    ModSelect_SetContext( expect string( slot.s.data ), Hud_GetAbsX( slot ), Hud_GetAbsY( slot ) )

    OpenSubmenu( GetMenu("ModSelect"), false )
}

void function AttemptUpgrade( var env )
{
    if (uiGlobal.activeMenu != file.menu)
        return

    var slot = GetCurrentHoverTarget()
    if (slot == null)
        return
    if (!("armorChip" in slot.s))
        return

    table data = {}
    if (StartsWith( Hud_GetHudName(slot), "AC" ))
    {
        data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
    }
    else
    {
        int elemNum = Grid_GetElemNumForButton( slot )
        data = expect table(Roguelike_GetInventory()[elemNum])
    }

    if (data.level >= 5 || Roguelike_GetMoney() < 35)
    {
        EmitUISound( "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Unsuccessful_1P" )
        return
    }
    
    EmitUISound( "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Successful_1P" )
    Roguelike_TakeMoney( 35 )
    data.moneyInvested += 35
    data.level += 1
    data.titanEnergy += 1
    data.pilotEnergy += 1

    RefreshInventory()
}

void function ArmorChip_Hover( var slot, var panel )
{
    table data = {}
    if (StartsWith( Hud_GetHudName(slot), "AC" ))
    {
        data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
    }
    else
    {
        int elemNum = Grid_GetElemNumForButton( slot )
        data = expect table(Roguelike_GetInventory()[elemNum])
    }

    slot.s.armorChip <- true

    Hud_SetHeight( panel, 296 )
    Hud_EnableKeyBindingIcons( Hud_GetChild( panel, "FooterText") )

    var titleStrip = Hud_GetChild(panel, "TitleStrip")
    var title = Hud_GetChild(panel, "Title")
    var bg = Hud_GetChild(panel, "BG")
    var levelBar = Hud_GetChild(panel, "EnergyBar1")
    var barBG = Hud_GetChild(panel, "EnergyBarBG")
    var energyLabel = Hud_GetChild(panel, "EnergyCount")
    
    Hud_SetColor( energyLabel, 25, 25, 25, 255 )
    Hud_SetText( energyLabel, format("%i Titan | %i Pilot", data.titanEnergy, data.pilotEnergy) )

    Hud_SetBarProgress( barBG, 1.0 )
    Hud_SetBarProgress( levelBar, data.level / 5.0 )
    Hud_SetColor( levelBar, 25, 25, 25, 255 )
    Hud_SetColor( title, 25, 25, 25, 255 )

    int slot = expect int( data.slot )
    
    Hud_SetColor( title, 25, 25, 25, 255 )
    switch (slot)
    {
        case 1:
            Hud_SetColor( titleStrip, 0, 214, 255, 255 )
            Hud_SetColor( bg, 0, 173, 204, 255 )
            break
        case 2:
            Hud_SetColor( titleStrip, 165, 255, 0, 255 )
            Hud_SetColor( bg, 136, 204, 0, 255 )
            break
        case 3:
            // note, this  slightly breaks the square pallette in favor of accessibility
            Hud_SetColor( titleStrip, 197, 0, 255, 255 )
            Hud_SetColor( bg, 153, 0, 204, 255 )
            Hud_SetColor( energyLabel, 255, 255, 255, 255 )
            Hud_SetColor( title, 255, 255, 255, 255 )
            Hud_SetColor( levelBar, 255, 255, 255, 255 )
            break
        case 4:
            Hud_SetColor( titleStrip, 255, 117, 0, 255 )
            Hud_SetColor( bg, 204, 92, 0, 255 )
            break
    }

    for (int i = 0; i < 6; i++)
    {
        string stat = STAT_NAMES[i]
        var statPanel = Hud_GetChild(panel, stat)
        int value = expect int(data.stats[i])
        if (i < 3)
        {
            value *= expect int(data.titanEnergy)
        }
        else
        {
            value *= expect int(data.pilotEnergy) 
        }
        var bar = Hud_GetChild(statPanel, "Bar")
        var label = Hud_GetChild(statPanel, "Label")
        var valueText = Hud_GetChild(statPanel, "Value")
        switch (slot)
        {
            case 3:
                Hud_SetColor(bar, 255, 255, 255, 255)
                Hud_SetColor(label, 255, 255, 255, 255)
                Hud_SetColor(valueText, 255, 255, 255, 255)
                break
            default:
                Hud_SetColor(bar, 25, 25, 25, 255)
                Hud_SetColor(label, 25, 25, 25, 255)
                Hud_SetColor(valueText, 25, 25, 25, 255)
                break
        }
        Hud_SetBarProgress(bar, value / 66.0)
        Hud_SetText(label, stat)
        Hud_SetText(valueText, "+" + value)
    }

    if (file.startDismantleTime != -1.0)
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), GraphCapped(Time(), file.startDismantleTime, file.endDismantleTime, 0, 1) )
    }
    else
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), 0.0 )
    }
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

int function Roguelike_GetStat( int stat )
{
    return minint(int( split( GetConVarString("player_stats"), " " )[stat] ), 100)
}
int function Roguelike_GetStatRaw( int stat )
{
    return int( split( GetConVarString("player_stats"), " " )[stat] )
}
