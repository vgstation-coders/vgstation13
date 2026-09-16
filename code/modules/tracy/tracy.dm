#if TRACY_ENABLED
var/global/datum/tracy/tracy

/// https://github.com/spacestation13/byond-tracy
/// A wrapper for the byond-tracy profiler library.
/// Note: currently the "shutdown" function is not implemented.
/// The only way to shutdown the profiler is to stop the BYOND instance.
/// Definitely don't compile the production build with this enabled.
/// To start a trace, use the "Enable Tracy Profiler" verb or
/// set TRACY_RUN_ON_STARTUP to TRUE in __compile_options.dm

/datum/tracy
	var/enabled = FALSE
	var/error
	var/lib_path

/datum/tracy/New()
	if(!isnull(global.tracy))
		CRASH("byond-tracy: already initialized")
	global.tracy = src
	src.lib_path = world.system_type == MS_WINDOWS ? "prof.dll" : "./libprof.so"
	admin_verbs_debug |= /client/proc/enable_tracy

/datum/tracy/Destroy()
	if(enabled)
		call_ext(lib_path, "shutdown")()
	return ..()

/datum/tracy/proc/enable()
	if(enabled)
		CRASH("byond-tracy: already enabled")
	
	if(!fexists(lib_path))
		CRASH("byond-tracy: [lib_path] not found")
	var/init_result = call_ext(lib_path, "init")("block")
	if(length(init_result) != 0 && init_result[1] == ".") // if first character is ., then it returned the output filename
		enabled = TRUE
		world.log << "byond-tracy: initialized (logfile: [init_result])"
		return TRUE
	else if(init_result == "already initialized")
		enabled = TRUE
		world.log << "byond-tracy: already initialized"
		return TRUE
	else if(init_result != "0")
		error = init_result
		world.log << "byond-tracy: init error: [init_result]"
		return FALSE
	else
		enabled = TRUE
		world.log << "byond-tracy: initialized (no logfile)"
		return TRUE

/client/proc/enable_tracy()
	set category = "Debug"
	set name = "Enable Tracy Profiler"
	set desc = "Starts the Tracy profiler for this server."

	if(!check_rights(R_DEBUG))
		return
	if(!global.tracy)
		to_chat(src, "<span class='warning'>Tracy is not initialized.</span>")
		return
	if(global.tracy.enabled)
		to_chat(src, "<span class='notice'>Tracy is already enabled.</span>")
		return

	if(global.tracy.enable())
		message_admins("[key_name_admin(src)] enabled the Tracy profiler.")
		log_admin("[key_name(src)] enabled the Tracy profiler.")
	else
		to_chat(src, "<span class='warning'>Tracy failed to initialize: [global.tracy.error]</span>")

#endif