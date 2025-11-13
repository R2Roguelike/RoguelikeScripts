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
        pin_corner_to_sibling TOP_RIGHT
        pin_to_sibling_corner TOP_RIGHT

        zpos			1
    }

    Mod0Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod0
        pin_corner_to_sibling	BOTTOM_RIGHT
        pin_to_sibling_corner	LEFT
    }
    Mod0Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod0
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	LEFT
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
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	BOTTOM_RIGHT

        zpos			1
    }
    Mod1Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod1
        pin_corner_to_sibling	BOTTOM_RIGHT
        pin_to_sibling_corner	LEFT
    }
    Mod1Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod1
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	LEFT
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
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	BOTTOM_RIGHT

        zpos			1
    }
    Mod2Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod2
        pin_corner_to_sibling	BOTTOM_RIGHT
        pin_to_sibling_corner	LEFT
    }
    Mod2Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod2
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	LEFT
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
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	BOTTOM_RIGHT

        zpos			1
    }
    Mod3Name
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Again!"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

        pin_to_sibling			Mod3
        pin_corner_to_sibling	BOTTOM_RIGHT
        pin_to_sibling_corner	LEFT
    }
    Mod3Desc
    {
        ControlName				Label
        xpos				    8
        ypos				    2
        wide					740
        tall					27
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	1
        labelText				"Gain 100% Core on Flame Core kill."
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_16

        pin_to_sibling			Mod3
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	LEFT
    }
}