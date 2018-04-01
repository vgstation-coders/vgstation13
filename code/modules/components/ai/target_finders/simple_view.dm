/datum/component/ai/target_finder/simple_view/GetTargets()
	ASSERT(container.holder!=null)
	var/list/o = list()
	for(var/atom/A in view(range, container.holder))
		if(is_type_in_list(A, exclude_types))
			continue
		o += A
	return o
