/proc/cmp_numeric_dsc(a,b)
	return b - a

/proc/cmp_numeric_asc(a,b)
	return a - b

/proc/cmp_text_asc(a,b)
	return sorttext(b,a)

/proc/cmp_text_dsc(a,b)
	return sorttext(a,b)

/proc/cmp_name_asc(atom/a, atom/b)
	return sorttext(b.name, a.name)

/proc/cmp_name_dsc(atom/a, atom/b)
	return sorttext(a.name, b.name)

var/cmp_field = "name"
/proc/cmp_records_asc(datum/data/record/a, datum/data/record/b)
	return sorttext((b ? b.fields[cmp_field] : ""), (a ? a.fields[cmp_field] : a))

/proc/cmp_records_dsc(datum/data/record/a, datum/data/record/b)
	return sorttext(a.fields[cmp_field], b.fields[cmp_field])

/proc/cmp_ckey_asc(client/a, client/b)
	return sorttext(b.ckey, a.ckey)

/proc/cmp_ckey_dsc(client/a, client/b)
	return sorttext(a.ckey, b.ckey)

/proc/cmp_subsystem_init(datum/subsystem/a, datum/subsystem/b)
	return b.init_order - a.init_order

/proc/cmp_subsystem_display(datum/subsystem/a, datum/subsystem/b)
	if(a.display_order == b.display_order)
		return sorttext(b.name, a.name)
	return a.display_order - b.display_order

/proc/cmp_subsystem_priority(datum/subsystem/a, datum/subsystem/b)
	return a.priority - b.priority

var/atom/cmp_dist_origin=null
/proc/cmp_dist_asc(var/atom/a, var/atom/b)
	return get_dist_squared(cmp_dist_origin, a) - get_dist_squared(cmp_dist_origin, b)
	
/proc/cmp_dist_desc(var/atom/a, var/atom/b)
	return get_dist_squared(cmp_dist_origin, b) - get_dist_squared(cmp_dist_origin, a)
