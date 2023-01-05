/datum/component/ai/target_finder/payment
	range = 1

/datum/component/ai/target_finder/payment/cmd_find_targets()
	var/list/o = list()
	for(var/atom/A in view(range, parent))
		if(istype(A,/obj/item/weapon/spacecash))
			o += A
	INVOKE_EVENT(parent,/event/comp_ai_cmd_pay,o)
	return o
