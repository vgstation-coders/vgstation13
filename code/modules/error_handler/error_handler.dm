/var/list/error_last_seen = list()
// error_cooldown items will either be positive (cooldown time) or negative (silenced error)
//  If negative, starts at -1, and goes down by 1 each time that error gets skipped
/var/list/error_cooldown = list()
/var/total_runtimes = 0
/var/total_runtimes_skipped = 0
// The ifdef needs to be down here, since the error viewer references total_runtimes
#ifdef DEBUG
/world/Error(var/exception/e)
	if (!istype(e)) // Something threw an unusual exception
		world.log << "\[[time_stamp()]] Uncaught exception: [e]"
		return ..()

	if (!global.error_last_seen) // A runtime is occurring too early in start-up initialization
		return ..()

	global.total_runtimes++

	var/erroruid = "[e.file][e.line]"
	var/last_seen = global.error_last_seen[erroruid]
	var/cooldown = global.error_cooldown[erroruid] || 0
	if (last_seen == null) // A new error!
		global.error_last_seen[erroruid] = world.time
		last_seen = world.time

	if (cooldown < 0)
		global.error_cooldown[erroruid]-- // Used to keep track of skip count for this error
		global.total_runtimes_skipped++
		return // Error is currently silenced, skip handling it

	// Handle cooldowns and silencing spammy errors
	var/silencing = 0
	// Each occurrence of a unique error adds to its "cooldown" time...
	cooldown = max(0, cooldown - (world.time - last_seen)) + ERROR_COOLDOWN
	// ... which is used to silence an error if it occurs too often, too fast
	if (cooldown > ERROR_MAX_COOLDOWN)
		cooldown = -1
		silencing = 1
		spawn (0)
			usr = null
			sleep(ERROR_SILENCE_TIME)
			var/skipcount = abs(global.error_cooldown[erroruid]) - 1
			global.error_cooldown[erroruid] = 0
			if (skipcount > 0)
				world.log << "\[[time_stamp()]] Skipped [skipcount] runtimes in [e.file],[e.line]."

	global.error_last_seen[erroruid] = world.time
	global.error_cooldown[erroruid] = cooldown

	// The detailed error info needs some tweaking to make it look nice
	var/list/usrinfo = null
	if (istype(usr)) // First, try to make better usr info lines
		usrinfo = list("  usr: [usr] ([usr.ckey]) ([usr.type])")
		var/turf/t = get_turf(usr)
		if (istype(t))
			usrinfo += "  usr.loc: [usr.loc] ([t.x],[t.y],[t.z]) ([usr.loc.type])"

		else if (usr.loc)
			usrinfo += "  usr.loc: [usr.loc] (0,0,0) ([usr.loc.type])"

	// The proceeding mess will almost definitely break if error messages are ever changed
	// I apologize in advance
	var/list/splitlines = splittext(e.desc, "\n")
	var/list/desclines = list()
	if (splitlines.len > 2) // If there aren't at least three lines, there's no info
		for (var/line in splitlines)
			if (length(line) < 3 || findtext(line, "source file:") || findtext(line, "usr.loc:"))
				continue

			if (findtext(line, "usr:"))
				if (usrinfo)
					desclines.Add(usrinfo)
					usrinfo = null

				continue // Our usr info is better, replace it

			if (copytext(line, 1, 3) != "  ")
				desclines += ("  " + line) // Pad any unpadded lines, so they look pretty
			else
				desclines += line

	if (usrinfo) // If this isn't null, it hasn't been added yet
		desclines.Add(usrinfo)

	if (silencing)
		desclines += "  (This error will now be silenced for [ERROR_SILENCE_TIME / 600] minutes)"

	// Now to actually output the error info...
	world.log << "\[[time_stamp()]] Runtime in [e.file],[e.line]: [e]"

	for (var/line in desclines)
		world.log << line

	if (global.error_cache)
		global.error_cache.log_error(e, desclines)

#endif
