resource/ui/menus/panels/vgui_button.res
{
    BG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 135"
		scaleImage			1

		wide                384
		tall				512

		"xpos"			"0"
		"ypos"			"0"
    }

	GoldBorder
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 0"
		scaleImage			1

		wide                256
		tall				128
		visible 0

		"xpos"			"0"
		"ypos"			"0"

		border			GoldBorder
	}

	Label
	{
		ControlName			Label
		xpos				-1
		ypos				-8

		visible				1
		wide                490
		tall				64
		labelText			"Scorch"
		allCaps				1
		font				GothicExpanded_56
		auto_wide_tocontents	0
		auto_tall_tocontents    1
		textAlignment		center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				BG
		pin_corner_to_sibling		TOP
		pin_to_sibling_corner		TOP
	}

	Overlay
	{
		ControlName			ImagePanel

		image			"vgui/hud/white"
		xpos				0
		ypos				0
		scaleImage			1

		visible				0
		wide                64
		tall				64
		textAlignment		center

		pin_to_sibling				BG
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}
	Lock
	{
		ControlName			ImagePanel

		image			"ui/lock"
		xpos				0
		ypos				0
		scaleImage			1

		visible				0
		wide                64
		tall				64
		textAlignment		center

		pin_to_sibling				BG
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}

	Value
	{
		ControlName			Label
		xpos				0
		ypos				-72

		visible				1
		wide                490
		tall				256
		wrap				1
		labelText			"yapyapyapyapyapyapyapyap"
		allCaps				0
		font				JetBrainsMono_24
		//auto_wide_tocontents	1
		auto_tall_tocontents    1
		textAlignment		north-west
		fgcolor_override 	"225 225 225 255"

		pin_to_sibling				BG
		pin_corner_to_sibling		TOP
		pin_to_sibling_corner		TOP
	}

	Button
	{
		ControlName				RuiButton
		xpos					0
		wide                %100
		tall				%100
		visible					1
		enabled					1
		scaleImage				1
		labelText				""
		rui						""
	}
}