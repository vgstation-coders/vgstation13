// WIP concept: use the choose_light_range_icon() to get the shaodws/light icons being tied to a specific system
// You could have harsher or softer triangles depending on the system you want to use (for example, Lamprey could have some spooky lighting)
// Need more tweaking ahnd polishing for it to work.

/proc/initialise_lights()
	to_chat(world, "<span class='userdanger'>Lights initialised...</span>")
	world.log << "Lights initialised..."
	if (!lighting_engine)
		lighting_engine = new lighting_system_used

/datum/lighting_system
	/// Name - how it appears to admins
	var/name = "Default lighting system"
	/// Desc - a short description of the lighting engine, what it can do, can't do, etc.
	var/desc = "This is the skeleton lighting engine. It is not meant to be seen."

	/// Enabled - whether or not admins can actually use it as lighting system or not
	/// Set to 0 for abstract types, unfinished systems, and so on
	var/enabled = 0

/datum/lighting_system/proc/choose_light_range_icon(var/two_bordering_walls, var/light_range, var/num)
