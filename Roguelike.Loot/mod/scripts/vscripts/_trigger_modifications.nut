untyped
// The purpose of this file is to modify
global function TriggerModifications_Init
global function Roguelike_ModifyTrigger

void function TriggerModifications_Init()
{
    // HACK: cant recompile maps. create trigger manually instead
    AddCallback_EntitiesDidLoad( void function() : ()
    {
        if (GetMapName() == "sp_crashsite")
        {
            entity trigger = CreateEntity( "trigger_cylinder" )
            trigger.SetRadius( 1200 )
            trigger.SetAboveHeight( 256 )
            trigger.SetBelowHeight( 256 )
            trigger.SetOrigin( < -2938, -6590, 256 > )
            DispatchSpawn( trigger )
            trigger.SetEnterCallback( void function(entity trigger, entity player) : ()
            {
                if (!IsValid( player ))
                    return
                printt("custom quickdeath")
                player.p.quickDeathOrigin = < -3731, -7870, 1000 >
                player.p.quickDeathAngles = < 0, 45, 0 >
            } )
            trigger.SetLeaveCallback( void function(entity trigger, entity player) : () 
            {
                printt("no custom quickdeath")
                player.p.quickDeathOrigin = null
                player.p.quickDeathAngles = null
            } )
        }
    } )
}

void function Roguelike_ModifyTrigger( entity trigger )
{
    switch (GetMapName())
    {
        case "sp_crashsite":
            ModifyQuickDeathTriggers_sp_crashsite( trigger )
            break
    }
}

void function ModifyQuickDeathTriggers_sp_crashsite( entity trigger )
{
    if (GetEditorClass( trigger ) != "trigger_quickdeath")
        return

    // hardcoded because we arent going to recompile the maps
	array<vector> triggerOriginList = [
		< -2304, -6688, 160>,
		< -3696, -6048, 448>,
		< -2720, -5776, 160>
	]

	foreach (vector v in triggerOriginList)
		if (Distance(trigger.GetOrigin(), v) < 2.0)
		{
			trigger.s.maxZ <- 100 // see TriggerQuickDeathOnTrigger in _trigger_functions_sp.gnut
			break
		}
}