var/list/vLevels = list()

/datum/virtual_level
	/// An admin-facing name used to identify the virtual level. May be duplicate, or changed after instancing.
	var/name = "Sub Map Zone"
	var/id
	/// Z level which contains this virtual level
	var/datum/zLevel/parent_level
	/// The low X boundary of the sub-zone
	var/low_x
	/// The low Y boundary of the sub-zone
	var/low_y
	/// The high X boundary of the sub-zone
	var/high_x
	/// The high Y boundary of the sub-zone
	var/high_y
	/// Distance in the X axis of the sub-zone
	var/x_distance
	/// Distance in the Y axis of the sub-zone
	var/y_distance

/datum/virtual_level/proc/get_relative_coords(atom/A)
	var/rel_x = A.x - low_x + 1
	var/rel_y = A.y - low_y + 1
	return list(rel_x, rel_y)

/proc/addVLevel(var/newname, var/newid, var/datum/zLevel/parent, var/x1, var/y1, var/x2, var/y2)
	var/datum/virtual_level/vlevel = new /datum/virtual_level
	vlevel.name = newname
	vlevel.id = newid
	vlevel.parent_level = parent
	vlevel.low_x = x1
	vlevel.low_y = y2
	vlevel.high_x = x2
	vlevel.high_y = y1
	vlevel.x_distance = x2 - x1
	vlevel.y_distance = y2 - y1
	vLevels |= vlevel
