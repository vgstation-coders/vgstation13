/datum/lighting_system
	/// Name - how it appears to admins
	var/name = "Default lighting system"
	/// Desc - a short description of the lighting engine, what it can do, can't do, etc.
	var/desc = "This is the skeleton lighting engine. It is not meant to be seen."

	/// Enabled - whether or not admins can actually
	var/enabled = 0

/datum/lighting_system/proc/choose_light_range_icon(var/two_bordering_walls, var/light_range, var/num)
