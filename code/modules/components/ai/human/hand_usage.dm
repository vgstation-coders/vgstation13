/datum/component/ai/hand_control/RecieveSignal(var/message_type, var/list/args)
	if(iscarbon(container.holder))
		var/mob/living/carbon/M = container.holder
		//testing("Got command: \[[message_type]\]: [json_encode(args)]")
		switch(message_type)
			if(COMSIG_DROP) // list("pickup" = item)
				if(M.get_active_hand())
					M.drop_item()
			if(COMSIG_ACTVHANDBYITEM) // list("target" = item)
				var/obj/item/I = args["target"]
				for(var/j = 1 to M.held_items.len)
					if(M.held_items[j] == I)
						M.active_hand = j
						break
			if(COMSIG_ACTVEMPTYHAND)
				for(var/j = 1 to M.held_items.len)
					if(M.held_items[j] == null)
						M.active_hand = j
						break
			if(COMSIG_THROWAT) // list("target" = atom)
				var/atom/A = args["target"]
				M.throw_mode_on()
				M.ClickOn(A)
				M.throw_mode_off()
			if(COMSIG_ITMATKSELF)
				var/obj/item/I = M.get_active_hand()
				if(I)
					I.attack_self(M)
			if(COMSIG_EQUIPACTVHAND)
				var/obj/item/I = M.get_active_hand()
				if(I)
					M.equip_to_appropriate_slot(I)