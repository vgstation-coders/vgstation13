// What in the name of god is this?
// You'd think it'd be some form of process for the HTML interface module.
// But it isn't?
// It's some form of proc queue but ???
// Does anything even *use* this?

var/datum/subsystem/html_ui/SShtml_ui

var/list/html_machines = list() // For checking when we should update a mob based on race specific conditions


/datum/subsystem/html_ui
	name = "HTMLUI"
	wait = 1.7 SECONDS
	flags = SS_NO_INIT | SS_NO_TICK_CHECK | SS_FIRE_IN_LOBBY

	var/list/update = list()


/datum/subsystem/html_ui/New()
	NEW_SS_GLOBAL(SShtml_ui)


/datum/subsystem/html_ui/fire(resumed = FALSE)
	if (update.len)
		var/list/L = list()
		var/key

		for (var/datum/procqueue_item/item in update)
			key = "[item.ref]_[item.procname]"

			if (item.args)
				key += "("
				var/first = 1
				for (var/a in item.args)
					if (!first)
						key += ","
					key += "[a]"
					first = 0
				key += ")"

			if (!(key in L))
				if (item.args)
					call(item.ref, item.procname)(arglist(item.args))
				else
					call(item.ref, item.procname)()

				L.Add(key)

		update.Cut()


/datum/subsystem/html_ui/proc/queue(ref, procname, ...)
	var/datum/procqueue_item/item = new
	item.ref = ref
	item.procname = procname

	if (args.len > 2)
		item.args = args.Copy(3)

	update.Insert(1, item)


/datum/procqueue_item
	var/ref
	var/procname
	var/list/args
