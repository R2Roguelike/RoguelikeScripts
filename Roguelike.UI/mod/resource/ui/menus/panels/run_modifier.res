resource/ui/menus/panels/vgui_button.res
{
    BG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 0"
		scaleImage			1

		wide                400
		tall				48

		"xpos"			"0"
		"ypos"			"0"
    }
	Label
	{
		ControlName			Label
		xpos				-1
		ypos				0

		visible				1
		wide                256
		tall				64
		labelText			"Modifier Name"
		allCaps				1
		font				JetBrainsMono_27
		auto_wide_tocontents	1
		auto_tall_tocontents    1
		textAlignment		west
		fgcolor_override 	"200 200 200 255"

		pin_to_sibling				BG
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		LEFT
	}
	Label2
	{
		ControlName			Label
		xpos				-1
		ypos				0

		visible				1
		wide                256
		tall				64
		labelText			" (+0)"
		allCaps				1
		font				JetBrainsMonoBold_27
		auto_wide_tocontents	1
		auto_tall_tocontents    1
		textAlignment		west
		fgcolor_override 	"200 200 200 255"

		pin_to_sibling				Label
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		RIGHT
	}

	Value
	{
		ControlName			Label
		xpos				0
		ypos				0

		visible				1
		wide                64
		tall				64
		labelText			"^80808000-^FFFFFFFF Off ^FFFFFF00+^FFFFFFFF"
		allCaps				1
		font				JetBrainsMonoBold_27
		auto_wide_tocontents	1
		auto_tall_tocontents    1
		textAlignment		east
		fgcolor_override 	"200 200 200 255"

		pin_to_sibling				BG
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}

	Button
	{
		ControlName				RuiButton
		xpos					0
		wide                355
		tall				%100
		visible					1
		enabled					1
		scaleImage				1
		labelText				""
		rui						""
		pin_to_sibling				BG
		pin_corner_to_sibling		LEFT
		pin_to_sibling_corner		LEFT
	}
	Button2
	{
		ControlName				RuiButton
		xpos					0
		wide                45
		tall				%100
		visible					1
		enabled					1
		scaleImage				1
		labelText				""
		rui						""

		pin_to_sibling				BG
		pin_corner_to_sibling		RIGHT
		pin_to_sibling_corner		RIGHT
	}
}