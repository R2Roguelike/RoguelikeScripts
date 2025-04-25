globalize_all_functions

void function __open( string m )
{
    if (uiGlobal.activeMenu == GetMenu("MainMenu"))
        return
    
    var menu
    try
    {
        menu = GetMenu(m)
        if (menu != null)
            AdvanceMenu(menu)
    }
    catch (ex)
    {
        print(ex)
    }
}

float function EaseOutExpo( float t )
{
    return 1 - pow(1 - t, 5)
}

void function Sequence( float duration, void functionref( float ) update )
{
    float startTime = Time()
    float endTime = Time() + duration
    bool setFinish = false
    while (true)
    {
        if (GraphCapped( Time(), startTime, endTime, 0, 1 ) == 1.0)
            setFinish = true
        update( GraphCapped( Time(), startTime, endTime, 0, 1 ) )
        if (setFinish)
            break
        wait 0
    }
}