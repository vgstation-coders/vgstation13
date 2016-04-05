/var/datum/controller/process/tgui/tgui_process

/datum/controller/process/tgui
	schedule_interval = 1 SECONDS

/datum/controller/process/tgui/setup()
	name = "tgui"

	global.tgui_basehtml = file2text("tgui/tgui.html")
	tgui_process = src

/datum/controller/process/tgui/doWork()
	for(var/thing in global.processing_tguis)
		var/datum/tgui/ui = thing
		if(ui && ui.user && ui.src_object)
			ui.process()
			continue

		global.processing_tguis.Remove(ui)
