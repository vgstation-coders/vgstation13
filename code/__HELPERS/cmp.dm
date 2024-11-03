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

/proc/cmp_initial_name_asc(atom/a, atom/b)
	return sorttext(initial(b.name), initial(a.name))

/proc/cmp_initial_name_dsc(atom/a, atom/b)
	return sorttext(initial(a.name), initial(b.name))

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

/proc/cmp_profile_avg_time_dsc(var/list/a, var/list/b)
	return (b[PROFILE_ITEM_TIME]/(b[PROFILE_ITEM_COUNT] || 1)) - (a[PROFILE_ITEM_TIME]/(a[PROFILE_ITEM_COUNT] || 1))

/proc/cmp_profile_time_dsc(var/list/a, var/list/b)
	return b[PROFILE_ITEM_TIME] - a[PROFILE_ITEM_TIME]

/proc/cmp_profile_count_dsc(var/list/a, var/list/b)
	return b[PROFILE_ITEM_COUNT] - a[PROFILE_ITEM_COUNT]

/proc/cmp_list_by_element_asc(list/a, list/b)
	return a[cmp_field] - b[cmp_field]

/proc/cmp_list_by_element_desc(list/a, list/b)
	return b[cmp_field] - a[cmp_field]

/proc/cmp_list_by_text_element_asc(list/a,list/b)
	return sorttext(b[cmp_field],a[cmp_field])

/proc/cmp_list_by_text_element_desc(list/a,list/b)
	return sorttext(a[cmp_field],b[cmp_field])

/proc/cmp_timer(datum/timer/a, datum/timer/b)
	var/a_when = a.when
	var/b_when = b.when
	if(a_when == b_when)
		return b.id - a.id
	return b_when - a_when

/proc/cmp_microwave_recipe_dsc(datum/recipe/a, datum/recipe/b)
	return b.priority - a.priority
