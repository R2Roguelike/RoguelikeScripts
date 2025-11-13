resource/ui/menus/panels/mod_set.res
{
    Screen
    {
        ControlName		ImagePanel
        image           "vgui/hud/white"
        wide			480
        tall			344
        visible			1
        scaleImage		1
        fillColor		"0 0 0 0"
        drawColor		"0 0 0 0"
    }
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

        pin_to_sibling Screen
        pin_corner_to_sibling TOP_LEFT
        pin_to_sibling_corner TOP_LEFT

        zpos			1
    }

    Mod0Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod0
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	RIGHT
    }
    Mod0Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	RIGHT
    }
    
    Mod1Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod1
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	RIGHT
    }
    Mod1Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod1
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	RIGHT
    }
    Mod1
    {
        ControlName			CNestedPanel
        controlSettingsFile	"resource/ui/menus/panels/mod_slot.res"
        classname "ModSlot"
        xpos            0
        ypos			16
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
        ypos			16
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
    Mod2Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod2
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	RIGHT
    }
    Mod2Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod2
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	RIGHT
    }
    Mod3
    {
        ControlName			CNestedPanel
        controlSettingsFile	"resource/ui/menus/panels/mod_slot.res"
        classname "ModSlot"
        xpos            0
        ypos			16
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
    Mod3Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod3
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	RIGHT
    }
    Mod3Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					74
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod3
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	RIGHT
    }
}