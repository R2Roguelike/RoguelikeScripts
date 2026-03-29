untyped
global function RoguelikeShop_Init
global function Roguelike_OpenShopMenu
global function RoguelikeShop_RefreshInventory

struct
{
    var menu
    GridMenuData gridData
    int seed
    array<RoguelikeMod> mods
    array<table> loot
} file

void function RoguelikeShop_Init()
{
    RegisterSignal("EndThisThread")
	AddMenu( "RoguelikeShop", $"resource/ui/menus/roguelike_shop.menu", InitRoguelikeShopMenu )
}

void function Roguelike_OpenShopMenu(int seed)
{
    file.seed = seed
    AdvanceMenu( file.menu )
    
	file.gridData.columns = 7
	file.gridData.rows = 2
	file.gridData.numElements = 16
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = ContentScaledXAsInt( 80 )
	file.gridData.tileHeight = ContentScaledYAsInt( 80 )
	file.gridData.paddingVert = int( ContentScaledX( 8 ) )
	file.gridData.paddingHorz = int( ContentScaledX( 8 ) )
	file.gridData.initCallback = Slot_Init
    
    Grid_InitPage( file.menu, file.gridData )
}

void function InitRoguelikeShopMenu()
{
    file.menu = GetMenu("RoguelikeShop")

	file.gridData.columns = 7
	file.gridData.rows = 2
	file.gridData.numElements = 16
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = ContentScaledXAsInt( 80 )
	file.gridData.tileHeight = ContentScaledYAsInt( 80 )
	file.gridData.paddingVert = int( ContentScaledX( 8 ) )
	file.gridData.paddingHorz = int( ContentScaledX( 8 ) )
	file.gridData.initCallback = Slot_Init
    
    GridMenuInit( file.menu, file.gridData )
    Grid_InitPage( file.menu, file.gridData )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnMenuOpen )
}

void function OnMenuOpen()
{
    EmitUISound("UI_InGame_FD_ArmoryOpen")

    RoguelikeShop_RefreshInventory()
}

void function RerollButton( var button )
{

}

// HACK: uses runData instead of contacting server to change the seed of the shop
// chances this affects someone are roughly the same as me getting bitches (about 1 in 77621.672)
// so we dont care
void function Reroll()
{
    table shopRerolls = GetShopRerollTable()
    table shopPurchased = GetShopPurchasedTable()
    if (file.seed in shopRerolls)
        shopRerolls[file.seed]++
    else
        shopRerolls[file.seed] <- 1
    if (file.seed in shopPurchased)
        delete shopPurchased[file.seed]

    RoguelikeShop_RefreshInventory()
}

int function GetShopSeed()
{
    return file.seed
}

void function SetSlotPurchased( int slot )
{
    table shopPurchased = GetShopPurchasedTable()
    if (!(file.seed in shopPurchased))
    {
        shopPurchased[file.seed] <- (1 << slot)
        return
    }
    shopPurchased[file.seed] = expect int(shopPurchased[file.seed]) | (1 << slot)
}
bool function IsSlotPurchased( int slot )
{
    table shopPurchased = GetShopPurchasedTable()
    if (!(file.seed in shopPurchased))
        return false
    
    return (shopPurchased[file.seed] & (1 << slot)) != 0
}

void function RoguelikeShop_RefreshInventory()
{
    // why is
    if (!IsFullyConnected())
        return
    table runData = Roguelike_GetRunData()
    PRandom rand = NewPRandom(GetShopSeed())
    printt("sTART", rand.seed)
    Grid_InitPage( file.menu, file.gridData )

    array lockedMods = []
    lockedMods.extend(GetAllTitanModsInLootPool(-1))

    array<RoguelikeMod> mods
    foreach (string s in lockedMods)
    {
        mods.append(GetModByName(s))
    }

    bool unlockAll = GetConVarBool("roguelike_unlock_all")
    file.mods.clear()
    file.loot.clear()
    printt(rand.seed, rand.iterations)
    for (int i = 0; i < 1;)
    {
        var slot = Hud_GetChild( file.menu, "ModSlot" + i )

        if (IsSlotPurchased( i ))
        {
            RemoveHover( slot )
            Hud_SetVisible( slot, true )
            
            Hud_SetLocked(Hud_GetChild(slot, "Button"), true)
            ModSlot_DisplayMod( slot, false, null )
            file.mods.append(GetModByName("empty"))
            i++
            continue
        }

        bool has2ndLoadout = Roguelike_GetTitanLoadouts().len() > 1
        int chipSlot = PRandomInt( rand, 1, has2ndLoadout ? 5 : 4 )
        
        int index = PRandomInt( rand, lockedMods.len() )
        
        if (GetLockedTitanModsLeft(chipSlot).len() - i <= 0)
        {
            Hud_SetVisible( slot, false )
            i++
            continue
        }
        if (file.mods.contains(mods[index]) || Roguelike_IsModUnlocked( mods[index] ) 
        || !Roguelike_IsModCompatibleWithSlot( mods[index], chipSlot, true ) )
        {
            continue
        }

        printt(index, rand.seed, rand.iterations)
        RemoveHover( slot )
        if (!("data" in slot.s))
        {
            slot.s.data <- i
            Hud_AddEventHandler( Hud_GetChild(slot, "Button"), UIE_CLICK, ModSlot_Click )
        }

        Hud_SetVisible( slot, true )
        file.mods.append(mods[index])


        AddHover( slot, ModSlot_Hover, HOVER_SIMPLE )
        ModSlot_DisplayMod( Hud_GetChild( file.menu, "ModSlot" + i ), file.mods[i].isTitan, file.mods[i])
        if (Roguelike_GetMoney() < Roguelike_GetModPrice() && !unlockAll)
        {
            Hud_SetLocked(Hud_GetChild(slot, "Button"), true)
        }
        i++
    }
    
    rand = NewPRandom(GetShopSeed() + 0x999)
    for (int i = 0; i < 5; i++)
    {
        var slot = Hud_GetChild( file.menu, "LootSlot" + i )

        table item = Roguelike_GenerateItem(rand, true)
        file.loot.append(item)
        RemoveHover( slot )
        if (IsSlotPurchased( i + 5 ))
        {
            InventorySlot_Display( slot, null )
            Hud_SetLocked(Hud_GetChild(slot, "Button"), true)
            continue
        }
        
        Hud_SetLocked(Hud_GetChild(slot, "Button"), false)
        InventorySlot_Display( slot, file.loot[i])
        if (!("data" in slot.s))
        {
            slot.s.data <- i
            Hud_AddEventHandler( Hud_GetChild(slot, "Button"), UIE_CLICK, LootSlot_Click )
        }
        switch (item.type)
        {
            case "armor_chip":
                AddHover( slot, ArmorChip_GetHoverFunc( file.menu, false, false, false, item ), HOVER_ARMOR_CHIP )
                break
            case "weapon":
                AddHover( slot, RoguelikeWeapon_GetHoverFunc( file.menu, false, false, false, item ), HOVER_WEAPON )
                break
            case "datacore":
                AddHover( slot, RoguelikeDatacore_GetHoverFunc( file.menu, false, false, false, item ), HOVER_WEAPON )
                break
            case "grenade":
                AddHover( slot, RoguelikeGrenade_GetHoverFunc( file.menu, false, false, false, item ), HOVER_WEAPON )
                break
        }

        if (Roguelike_GetMoney() < Roguelike_GetPurchasePrice(item) && !unlockAll)
        {
            Hud_SetLocked(Hud_GetChild(slot, "Button"), true)
        }
    }
}

void function LootSlot_Click( var button )
{
    bool unlockAll = GetConVarBool("roguelike_unlock_all")

    int slot = expect int(Hud_GetParent( button ).s.data)
    table item = file.loot[slot]
    
    int price = Roguelike_GetPurchasePrice(item)

    if (Roguelike_GetMoney() < price && !unlockAll)
        return

    Roguelike_GetInventory().append(item)
    RunStats_ItemObtained()
    Roguelike_GetRunData().maxRarityObtained = maxint(expect int(item.rarity), expect int(Roguelike_GetRunData().maxRarityObtained))
    Roguelike_TakeMoney(price)
    SetSlotPurchased( slot + 5 )
    Roguelike_BackupRun(expect int(Roguelike_GetRunData().startPointIndex))
    EmitUISound("UI_InGame_FD_ArmoryPurchase")
    RoguelikeShop_RefreshInventory()
}

int function Roguelike_GetModPrice()
{
    return SHOP_MOD_PRICE + SHOP_MOD_PRICE_PERLEVEL * GetConVarInt("roguelike_levels_completed")
}

void function ModSlot_Click( var button )
{
    bool unlockAll = GetConVarBool("roguelike_unlock_all")
    int modPrice = Roguelike_GetModPrice()
    if (Roguelike_GetMoney() < modPrice && !unlockAll)
        return

    int slot = expect int(Hud_GetParent( button ).s.data)
    RoguelikeMod mod = file.mods[slot]
    if (mod.uniqueName == "empty")
        return

    Roguelike_UnlockMod(mod)
    RunStats_ModsUnlocked( 1 )
    Roguelike_TakeMoney(modPrice)
    SetSlotPurchased( slot )
    Roguelike_BackupRun(expect int(Roguelike_GetRunData().startPointIndex))
    EmitUISound("UI_InGame_FD_ArmoryPurchase")
    RoguelikeShop_RefreshInventory()
}

void function MoneyDiff( int diff )
{
    Signal( uiGlobal.signalDummy, "EndThisThread")
    EndSignal( uiGlobal.signalDummy, "EndThisThread")
    Hud_SetText( Hud_GetChild( file.menu, "MoneyDiff" ), diff + "$")
    float t = Time()
    while (Time() - t < .5)
    {
        Hud_GetChild( file.menu, "MoneyDiff" ).SetAlpha(GraphCapped(Time() - t, 0.4, .44, 255, 0))
        wait 0.001
    }
    Hud_GetChild( file.menu, "MoneyDiff" ).SetAlpha(0)
}

void function ModSlot_Hover( var slot, var panel )
{
    HoverSimpleData data
    int modIndex = expect int(slot.s.data)
    table runData = Roguelike_GetRunData()
    
    RoguelikeMod mod = file.mods[modIndex]
    int modPrice = Roguelike_GetModPrice()
    
    Hud_SetColor( Hud_GetChild(panel, "TitleStrip"), 40, 40, 40, 255 )
    Hud_SetColor( Hud_GetChild(panel, "BG"), 25,25,25, 255 )
    Hud_SetText( Hud_GetChild(panel, "Title"), mod.name)
    bool unlockAll = GetConVarBool("roguelike_unlock_all")
    string hasEnoughMoney = Roguelike_GetMoney() > modPrice ? "^FFC04000" : "^FF404000"
    data.footerText = "%[A|MOUSE1]%Purchase for " + hasEnoughMoney + modPrice + "$"
    data.title = mod.name
    data.color = GetModColor(mod)
    data.description = Roguelike_GetModDescription(mod)
    ModSlot_UpdateBoxes( mod )
    data.boxes = mod.boxes
    HoverSimple_SetData(data)
}
 
bool function Slot_Init( var button, int elemNum )
{
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar1" ), 1 )
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar2" ), 1 )

    /*if (!("clickCallback" in button.s))
    {
        Hud_AddEventHandler( Hud_GetChild( button, "Button" ), UIE_CLICK, InventorySlot_Click )
        button.s.clickCallback <- true
    }*/

    button.s.canDismantle <- true

    RemoveHover( button )
    array inventory = Roguelike_GetInventory()
    if (elemNum < inventory.len())
    {
        InventorySlot_Display( button, inventory[elemNum] )
        switch (inventory[elemNum].type)
        {
            case "armor_chip":
                AddHover( button, ArmorChip_GetHoverFunc( file.menu, false, false, true ), HOVER_ARMOR_CHIP )
                break
            case "weapon":
                AddHover( button, RoguelikeWeapon_GetHoverFunc( file.menu, false, false, true ), HOVER_WEAPON )
                break
            case "datacore":
                AddHover( button, RoguelikeDatacore_GetHoverFunc( file.menu, false, false, true ), HOVER_WEAPON )
                break
            case "grenade":
                AddHover( button, RoguelikeGrenade_GetHoverFunc( file.menu, false, false, true ), HOVER_WEAPON )
                break
        }
    }
    else
    {
        InventorySlot_Display( button, null )
    }
    return true
}
