/datum/component/ai/target_finder/simple_view/cmd_find_targets()
	var/list/o = list()
	for(var/atom/A in view(range, parent))
		if(is_type_in_list(A, exclude_types))
			continue
		o += A
	return o
