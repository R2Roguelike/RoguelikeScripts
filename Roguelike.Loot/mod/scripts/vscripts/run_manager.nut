untyped
global function Inventory_Init
global function Roguelike_GenerateLoot
global function Roguelike_StartNewRun
global function Roguelike_GetInventory
global function Roguelike_IsRunActive
global function Roguelike_GetRunData
global function Roguelike_GetMoney
global function Roguelike_AddMoney
global function Roguelike_TakeMoney
global function RunEnded

struct {
    table saveData 
    table runData
    bool isRunActive = false
} file

void function Inventory_Init()
{
    wait 0.1
    if (NSDoesFileExist("save.json"))
        NSLoadJSONFile( "save.json", void function( table t ) : ()
        {
            file.saveData = t
        },
        void function() : ()
        {
            while (uiGlobal.menuStack.len() == 0)
                wait 0
            DialogData dialogData
            dialogData.header = "SAVE LOAD FAILED"
	        dialogData.image = $"ui/menu/common/dialog_error"
            dialogData.forceChoice = true
            dialogData.message = "Loading save data failed. Would you like to try again or choose another save file?"

            AddDialogButton( dialogData, "Retry" )
            AddDialogButton( dialogData, "Delete" )

            AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

            delaythread( 0.1 ) OpenDialog( dialogData )
        }
    )
    
    if (NSDoesFileExist("run_backup.json"))
        NSLoadJSONFile( "run_backup.json", void function( table t ) : ()
        {
            DialogData dialogData
            dialogData.header = "RUN CHECKPOINT AVAILABLE"
            dialogData.forceChoice = true
            dialogData.message = "You quit or crashed mid-run, although a backup was saved. Would you like to continue from the last chapter?"

            AddDialogButton( dialogData, "Yes", void function() : ()
            {
                ExecuteLoadingClientCommands_SetStartPoint( expect string(file.runData.map), expect int(file.runData.startPointIndex) )
                ClientCommand( "map " + expect string(file.runData.map) )
            } )
            AddDialogButton( dialogData, "No", void function() : ()
            {
                file.isRunActive = false
                file.runData = {}
                NSDeleteFile( "run_backup.json" )
            } )

            AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

            file.runData = t
            file.isRunActive = true

            delaythread( 0.1 ) OpenDialog( dialogData )
        }
    )
}

void function RunEnded()
{
    // reset run
    NSDeleteFile( "run_backup.json" )
    file.isRunActive = false
    file.runData = {}
    ClientCommand("disconnect")
}

void function Roguelike_StartNewRun()
{
    table runData = {
        inventory = [],
        length = "short",
        unlockedMods = []
    }

    file.runData = runData
    file.isRunActive = true

    runData.lockedMods <- GetAllLockedMods()
    Roguelike_UnlockMods( 10 ) // have the player start with some amount of mods

    for (int i = 1; i < 5; i++)
    {
        for (int j = 0; j < MOD_SLOTS; j++)
        {
            runData["AC" + i + "_PilotMod" + j] <- 0
            runData["AC" + i + "_TitanMod" + j] <- 0
        }
    }

    // these arrays are to prevent the player from getting
    // 3+ of the same armor chip slot in a row, and to 
    // gurantee the player gets a preferred chip slot
    // eventually.
    runData.chipSlotOrder <- [1,2,3,4]
    runData.chipSlotOrder.randomize()
    runData.chipSlotIndex <- 0

    runData.powerPlayer <- 0
    runData.enemyPower <- 0
    runData.levelsCompleted <- 0

    runData.money <- 0

    runData.AC1 <- ArmorChip_Generate()
    runData.AC1.slot = 1
    runData.AC2 <- ArmorChip_Generate()
    runData.AC2.slot = 2
    runData.AC3 <- ArmorChip_Generate()
    runData.AC3.slot = 3
    runData.AC4 <- ArmorChip_Generate()
    runData.AC4.slot = 4
    runData.map <- "sp_crashsite"
    runData.startPointIndex <- 7

    NSSaveJSONFile( "run_backup.json", runData )
}

void function Roguelike_Reset()
{
    file.runData.clear()
    file.isRunActive = false
}

void function Roguelike_GenerateLoot()
{
    print("GENERATING LOOT")
    int r = RandomInt(3)

    switch (r)
    {
        case 0:
        case 1:
        case 2:
            // TODO
        case 3: 
            file.runData.inventory.append(ArmorChip_Generate())
            return
    }
}

array function Roguelike_GetInventory()
{
    if (!file.isRunActive)
        return []
    return expect array(file.runData.inventory)
}

int function Roguelike_GetMoney()
{
    if (!file.isRunActive)
        return 0

    return expect int(file.runData.money)
}

void function Roguelike_AddMoney( int amt )
{
    if (!file.isRunActive)
        return

    file.runData.money += amt
}

void function Roguelike_TakeMoney( int amt )
{
    if (!file.isRunActive)
        return

    file.runData.money -= amt
}

table function Roguelike_GetRunData()
{
    if (!file.isRunActive)
        return {}
    return file.runData
}

bool function Roguelike_IsRunActive()
{
    return file.isRunActive
} 