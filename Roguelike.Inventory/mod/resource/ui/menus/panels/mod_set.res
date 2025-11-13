resource/ui/menus/panels/mod_set.res
{
    Mod0
    {
        ControlName			CNestedPanel
        controlSettingsFile	"resource/ui/menus/panels/mod_slot.res"
        classname "ModSlot"
        xpos            0
        ypos			0
        wide			 64
        tall			 64
        visible			1
        scaleImage		1
        scriptID        0

        zpos			1
    }
    Mod1
    {
        ControlName			CNestedPanel
        controlSettingsFile	"resource/ui/menus/panels/mod_slot.res"
        classname "ModSlot"
        xpos            0
        ypos			8
        wide			 64
        tall			 64
        visible			1
        scaleImage		1
        scriptID        1

        pin_to_sibling			Mod0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT

        zpos			1
    }
    Mod2
    {
        ControlName			CNestedPanel
        controlSettingsFile	"resource/ui/menus/panels/mod_slot.res"
        classname "ModSlot"
        xpos            0
        ypos			8
        wide			 64
        tall			 64
        visible			1
        scaleImage		1
        scriptID        2

        pin_to_sibling			Mod1
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT

        zpos			1
    }
    Mod3
    {
        ControlName			CNestedPanel
        controlSettingsFile	"resource/ui/menus/panels/mod_slot.res"
        classname "ModSlot"
        xpos            0
        ypos			8
        wide			 64
        tall			 64
        visible			1
        scaleImage		1
        scriptID        3

        pin_to_sibling			Mod2
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT

        zpos			1
    }
}