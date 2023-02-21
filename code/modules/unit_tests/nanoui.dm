/datum/unit_test/nanoui/start()
	var/datum/nanoui/ui
	var/list/uis = flist("nano/templates/")
	var/i = 0
	var/mob/user = new
	for(var/uifile in uis)
		i++
		ui = new(user, src, i, uifile, "", 200, 200)
		var/html = ui.get_html()
		if(findtext(html,"<h2>Template error (does not exist)</h2>"))
			fail("[__FILE__]:[__LINE__]: nanoui test failed: template [uifile] does not exist.")
		if(findtext(html,"<h2>Template error (failed to compile)</h2>"))
			fail("[__FILE__]:[__LINE__]: nanoui test failed: template [uifile] does not compile.")
		qdel(ui)
	qdel(user)
