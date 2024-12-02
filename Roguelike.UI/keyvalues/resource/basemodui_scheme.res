///////////////////////////////////////////////////////////
// Tracker scheme resource file
//
// sections:
//		Colors			- all the colors used by the scheme
//		BaseSettings	- contains settings for app to use to draw controls
//		Fonts			- list of all the fonts used by app
//		Borders			- description of all the borders
//
///////////////////////////////////////////////////////////
#base "fonts/font_scheme.res"

Scheme
{
	InheritableProperties
	{
		ChatBox
		{
			bgcolor_override 		"0 0 0 180"

			chatBorderThickness		3

			chatHistoryBgColor		"24 27 30 0"
			chatEntryBgColor		"24 27 30 0"
			chatEntryBgColorFocused	"24 27 30 0"
		}
	}
	Fonts
	{
	}

	//////////////////// BORDERS //////////////////////////////
	// describes all the border types
	Borders
	{
		BoxBorder
		{
			inset 	"32 32 32 32"
			bordertype				scalable_image
			//backgroundtype			2

			image					"ui/box"
			src_corner_height		32				// pixels inside the image
			src_corner_width		32
			draw_corner_width		32				// screen size of the corners ( and sides ), proportional
			draw_corner_height 		32
		}
		Fonts
		{
			ConsoleText
			{
				1
				{
					name		"Lucida Console"
					tall		22
					weight		500
					antialias	1
				}
			}
			ConsoleTextSmall
			{
				1
				{
					name		"Lucida Console"
					tall		14
					weight		250
					antialias	1
				}
			}
		}
		WhiteBorder
		{
			inset 	"1 1 1 1"

			Left
			{
				1
				{
					color 	"200 200 200 255"
					offset	"0 1"
				}
			}
			Right
			{
				1
				{
					color 	"200 200 200 255"
					offset	"1 0"
				}
			}
			Top
			{
				1
				{
					color 	"200 200 200 255"
					offset 	"0 0"
				}
			}
			Bottom
			{
				1
				{
					color 	"200 200 200 255"
					offset 	"0 0"
				}
			}
		}
	}
}
