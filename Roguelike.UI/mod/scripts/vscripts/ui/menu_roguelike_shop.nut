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
    
    GridMenuInit( file.menu, file.gridData )
    Grid_InitPage( file.menu, file.gridData )
}

void function InitRoguelikeShopMenu()
{
    file.menu = GetMenu("RoguelikeShop")

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
    table shopRerolls = GetShopRerollTable()
    int rerolls = expect int(file.seed in shopRerolls ? shopRerolls[file.seed] : 0)
    int rand = file.seed
    rand += 0x9e3779b9 * rerolls // jump ahead
    return rand
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
    lockedMods.extend(GetAllLockedTitanMods())

    array<RoguelikeMod> mods
    foreach (string s in lockedMods)
    {
        mods.append(GetModByName(s))
    }

    bool unlockAll = GetConVarBool("roguelike_unlock_all")
    file.mods.clear()
    file.loot.clear()
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

        int index = PRandomInt( rand, lockedMods.len() )
        
        if (GetLockedPilotModsLeft().len() + GetLockedTitanModsLeft().len() - i <= 0)
        {
            Hud_SetVisible( slot, false )
            i++
            continue
        }
        if (file.mods.contains(mods[index]) || Roguelike_IsModUnlocked( mods[index] ))
        {
            continue
        }

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
        if (Roguelike_GetMoney() < 1500 && !unlockAll)
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
    Roguelike_TakeMoney(price)
    SetSlotPurchased( slot + 5 )
    EmitUISound("UI_InGame_FD_ArmoryPurchase")
    RoguelikeShop_RefreshInventory()
}

void function ModSlot_Click( var button )
{
    bool unlockAll = GetConVarBool("roguelike_unlock_all")
    if (Roguelike_GetMoney() < SHOP_MOD_PRICE && !unlockAll)
        return

    int slot = expect int(Hud_GetParent( button ).s.data)
    RoguelikeMod mod = file.mods[slot]
    if (mod.uniqueName == "empty")
        return

    Roguelike_UnlockMod(mod)
    RunStats_ModsUnlocked( 1 )
    Roguelike_TakeMoney(SHOP_MOD_PRICE)
    SetSlotPurchased( slot )
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
    int modIndex = expect int(slot.s.data)
    table runData = Roguelike_GetRunData()
    
    RoguelikeMod mod = file.mods[modIndex]

    Hud_SetText( Hud_GetChild(panel, "Title"), mod.name)
    bool unlockAll = GetConVarBool("roguelike_unlock_all")
    string hasEnoughMoney = Roguelike_GetMoney() > SHOP_MOD_PRICE ? "^FFC04000" : "^FF404000"
    Hud_SetText( Hud_GetChild(panel, "FooterText"), "%[A|MOUSE1]%Purchase for " + hasEnoughMoney + SHOP_MOD_PRICE + "$" )
    Hud_SetText( Hud_GetChild(panel, "Description"), format("Energy Cost: ^FF800000%i^FFFFFFFF\n\n%s", mod.cost, FormatDescription(mod.description)) )
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
