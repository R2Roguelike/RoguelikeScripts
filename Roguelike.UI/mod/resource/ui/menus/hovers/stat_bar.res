resource/ui/menus/hovers/stat_bar.res
{
    Value
    {
        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	0
        labelText				"++25"
        fgcolor_override		"255 255 255 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_36

		wide				40
        tall                32
        wrap                0

		"xpos"			"8"
		"ypos"			"0"
    }
    Label
    {
        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	0
        labelText				"Endurance"
        fgcolor_override		"25 25 25 255"
        textAlignment			WEST
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_20

		wide				240
        tall                32
        wrap                0

		"xpos"			"12"
		"ypos"			"0"
		pin_to_sibling			Value
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
    }

}