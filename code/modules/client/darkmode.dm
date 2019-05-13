// Darkmode based off of Kmc2000's PR here: https://github.com/tgstation/tgstation/pull/43072

//There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
#define COLOR_DARKMODE_BUTTONBACKGROUND "#494949"
#define COLOR_DARKMODE_TEXT "#a4bad6"

/client/proc/white_theme()
	//Main windows
	winset(src, "mainwindow", 		"background-color = none")
	winset(src, "outputwindow", 	"background-color = none;text-color = #000000")
	winset(src, "browseroutput", 	"background-color = none;text-color = #000000")
	winset(src, "mainvsplit", 		"background-color = none")
	//Buttons
	winset(src, "textb", 			"background-color = none;text-color = #000000")
	winset(src, "infob", 			"background-color = none;text-color = #000000")
	winset(src, "wikib", 			"background-color = none;text-color = #000000")
	winset(src, "forumb", 		"background-color = none;text-color = #000000")
	winset(src, "rulesb", 		"background-color = none;text-color = #000000")
	winset(src, "changelog", 	"background-color = none;text-color = #000000")
	winset(src, "mapb", 			"background-color = none;text-color = #000000")
	winset(src, "github",		 	"background-color = none;text-color = #000000")
	winset(src, "special_button", "background-color = none;text-color = #000000")
	//Status and verb tabs
	winset(src, "info", 			"background-color = #FFFFFF;tab-background-color = none;text-color = #000000;tab-text-color = #000000;prefix-color = #000000;suffix-color = #000000")
	winset(src, "infowindow", "background-color = none;text-color = #000000")
	winset(src, "rpane", 			"background-color = none;text-color = #000000")
	winset(src, "rpanewindow", "background-color = none;text-color = #000000")
	//Say, OOC, me Buttons etc.
	winset(src, "oocbutton", 	"background-color = none;text-color = #000000")
	winset(src, "mebutton", 	"background-color = none;text-color = #000000")
	winset(src, "saybutton", 	"background-color = none;text-color = #000000")
	winset(src, "hotkey_toggle", "background-color = none;text-color = #000000")

/client/proc/dark_theme()
	//Main windows
	winset(src, "mainwindow", 		"background-color = [COLOR_DARKMODE_BACKGROUND]")
	winset(src, "outputwindow", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "browseroutput", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mainvsplit", 		"background-color = [COLOR_DARKMODE_BACKGROUND]")
	//Buttons
	winset(src, "textb", 			"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "infob", 			"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "wikib", 			"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "forumb", 		"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "rulesb", 		"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "changelog", 	"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mapb", 			"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "github", 		"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "special_button", "background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	//Status and verb tabs
	winset(src, "info", 			"background-color = [COLOR_DARKMODE_DARKBACKGROUND];tab-background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT];tab-text-color = [COLOR_DARKMODE_TEXT];prefix-color = [COLOR_DARKMODE_TEXT];suffix-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "infowindow", "background-color = [COLOR_DARKMODE_DARKBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "rpane", 			"background-color = [COLOR_DARKMODE_DARKBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "rpanewindow", "background-color = [COLOR_DARKMODE_DARKBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	//Say, OOC, me Buttons etc.
	winset(src, "oocbutton", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mebutton", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "saybutton", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "hotkey_toggle", "background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
