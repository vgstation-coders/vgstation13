/datum/unit_test/nanoui/start()
	var/datum/nanoui/ui
	var/list/uis = flist("nano/templates/")
	var/i = 0
	var/mob/user = new
	for(var/uifile in uis)
		i++
		ui = new(user, src, i, uifile, "", 200, 200)
		ASSERT(!findtext(ui.get_html(),"<h2>Template error (does not exist)</h2>"))
		ASSERT(!findtext(ui.get_html(),"<h2>Template error (failed to compile)</h2>"))
