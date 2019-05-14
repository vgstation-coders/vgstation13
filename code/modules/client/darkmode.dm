// Darkmode based off of Kmc2000's PR here: https://github.com/tgstation/tgstation/pull/43072

//There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.

/client/proc/white_theme()
	//Main windows
	winset(src, "mainwindow", 		"background-color = [COLOR_WHITEMODE_BACKGROUND]")
	winset(src, "outputwindow", 	"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "browseroutput", 	"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "mainvsplit", 		"background-color = [COLOR_WHITEMODE_BACKGROUND]")

	//Buttons
	winset(src, "textb", 					"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "infob", 					"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "wikib", 					"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "forumb", 				"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "rulesb", 				"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "changelog", 			"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "mapb", 					"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "github",		 			"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "special_button", "background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	//Status and verb tabs
	winset(src, "info", 					"background-color = [COLOR_WHITEMODE_INFOBACKGROUND];tab-background-color = [COLOR_WHITEMODE_BACKGROUND];\
		text-color = [COLOR_WHITEMODE_TEXT];tab-text-color = [COLOR_WHITEMODE_TEXT];prefix-color = [COLOR_WHITEMODE_TEXT];suffix-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "infowindow", 		"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "rpane", 					"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "rpanewindow", 		"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	//Say, OOC, me Buttons etc.
	winset(src, "oocbutton", 			"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "mebutton", 			"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "saybutton", 			"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")
	winset(src, "hotkey_toggle", 	"background-color = [COLOR_WHITEMODE_BACKGROUND];text-color = [COLOR_WHITEMODE_TEXT]")

/client/proc/dark_theme()
	//Main windows
	winset(src, "mainwindow", 		"background-color = [COLOR_DARKMODE_BACKGROUND]")
	winset(src, "outputwindow", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "browseroutput", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mainvsplit", 		"background-color = [COLOR_DARKMODE_BACKGROUND]")

	//Buttons
	winset(src, "textb", 					"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "infob", 					"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "wikib", 					"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "forumb", 				"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "rulesb", 				"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "changelog", 			"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mapb", 					"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "github", 				"background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "special_button", "background-color = [COLOR_DARKMODE_BUTTONBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	//Status and verb tabs
	winset(src, "info", 					"background-color = [COLOR_DARKMODE_DARKBACKGROUND];tab-background-color = [COLOR_DARKMODE_BACKGROUND];\
		text-color = [COLOR_DARKMODE_TEXT];tab-text-color = [COLOR_DARKMODE_TEXT];prefix-color = [COLOR_DARKMODE_TEXT];suffix-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "infowindow", 		"background-color = [COLOR_DARKMODE_DARKBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "rpane", 					"background-color = [COLOR_DARKMODE_DARKBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "rpanewindow", 		"background-color = [COLOR_DARKMODE_DARKBACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	//Say, OOC, me Buttons etc.
	winset(src, "oocbutton", 			"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "mebutton", 			"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "saybutton", 			"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")
	winset(src, "hotkey_toggle", 	"background-color = [COLOR_DARKMODE_BACKGROUND];text-color = [COLOR_DARKMODE_TEXT]")

	to_chat(src, "<span class='bnotice'>Thank you for helping to test the darkmode color preset. There will probably be bugs. \
		Do not hesitate to GITHUB REPORT any black/purple colored messages that are unreadable in the darkmode background, or to give feedback on the half-assed color pallete. Nothing here is final.</span>")
