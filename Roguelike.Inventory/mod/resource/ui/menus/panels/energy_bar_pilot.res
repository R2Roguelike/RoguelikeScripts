resource/ui/menus/panels/inventory_slot.res
{
    Screen
    {
        ControlName		ImagePanel
        image           "vgui/hud/white"
        wide			70
        tall			70
        visible			1
        scaleImage		1
        fillColor		"0 0 0 0"
        drawColor		"0 0 0 0"
    }
	EnergyBarBG
	{
		ControlName				Label
		xpos					0
		ypos				    0
		wide					74
		tall					 80
		visible					1
		enabled					1
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		labelText				"Survival Chip"
		fgcolor_override		"255 176 0 255"
		textAlignment			south-east
		//fgcolor_override 		"255 255 255 255"
		//bgcolor_override 		"0 0 0 200"
		font					JetBrainsMonoBold_24
		pin_to_sibling "Screen"
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_LEFT
	}
    Icon
    {
        ControlName			ImagePanel

        image			"ui/lightning"

        drawColor	"255 176 0 255"
        scaleImage			1

        wide				16
        tall			    16

		visible			1

        "xpos"			"4"
        "ypos"			"1"
		
		pin_to_sibling "EnergyBarBG"
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	RIGHT
    }
    
}