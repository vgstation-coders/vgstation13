//we need train datums to prevent circular trains infinite looping, please for the love of god someone make a not terrible solution
//frankensteined slightly from pipenet code

/datum/train

	var/list/obj/machinery/cart/members = list()
	var/list/obj/machinery/cart/edges = list() //Used for building networks

/datum/train/Destroy()
	//Null the fuck out of all these references
	for(var/obj/machinery/cart/M in members) //Edges are a subset of members
		if(M.train_net == src)
			M.train_net = null

/datum/train/proc/connect_train(obj/machinery/cart/base, obj/machinery/cart/connecting, mob/user)
	if (connecting.train_net == src)
		to_chat(user,"Cannot connect [connecting] to [base], they are part of the same train network.")
		return 1
	if (connecting.train_net)
		for(var/obj/machinery/cart/C in members)
			if(connecting.train_net.members.Find(C))
				to_chat(user,"Cannot connect [connecting] to [base], loop detected.")
				return 1
		train_merge(connecting)
	else
		connecting.train_net = src
		members += connecting
	return 0

/datum/train/proc/train_merge(obj/machinery/cart/connecting)
	var/datum/train/merged_net = connecting.train_net
	for(var/obj/machinery/cart/C in merged_net.members)
		C.train_net = src
		members += C
	qdel(merged_net)
	merged_net = null

/datum/train/proc/train_rebuild(obj/machinery/cart/base)
	var/list/possible_expansions = list(base)
	members = list(base)

	while(possible_expansions.len>0)
		for(var/obj/machinery/cart/borderline in possible_expansions)

			var/list/result = borderline.connected_carts()

			if(result.len>0)
				for(var/obj/machinery/cart/item in result)
					if(!members.Find(item))
						members += item
						possible_expansions += item

						item.train_net = src


			possible_expansions -= borderline