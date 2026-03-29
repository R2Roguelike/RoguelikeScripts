resource/ui/menus/panels/stat.res
{
    BG
    {
        ControlName			ImagePanel

        image			"vgui/hud/white"

        drawColor	"0 0 0 150"
        scaleImage			1

        wide				344
        tall			    32

        "xpos"			"0"
        "ypos"			"0"
    }

    HeaderTitle
    {

        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	0
        labelText				"HEADER"
        fgcolor_override		"255 225 100 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_27
        allcaps                 1

		wide				 80
        tall                32
        wrap                0

		"xpos"			"0"
		"ypos"			"0"
		pin_to_sibling			BG
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER
    }

    Value
    {

        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	0
        labelText				"45"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_27

		wide				 80
        tall                32
        wrap                0

		"xpos"			"28"
		"ypos"			"0"
		pin_to_sibling			BG
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	CENTER
    }
    Diff
    {

        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	0
        labelText				"-3"
        fgcolor_override		"255 0 0 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18
        wrap                    1

		wide				 160
        tall                32
        wrap                0

		"xpos"			"8"
		"ypos"			"0"
		pin_to_sibling			Value
		pin_corner_to_sibling	LEFT
		pin_to_sibling_corner	RIGHT
    }
    Name
    {

        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	1
        auto_tall_tocontents	0
        labelText				"STAT"
        fgcolor_override		"200 200 200 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18

		wide				 80
        tall                32
        wrap                0

		"xpos"			"20"
		"ypos"			"0"
		pin_to_sibling			BG
		pin_corner_to_sibling	RIGHT
		pin_to_sibling_corner	CENTER
    }
}