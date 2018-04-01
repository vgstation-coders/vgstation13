/mob/living/carbon/human/key_down(_key, client/user)
	if(client.keys_held["Shift"])
		switch(_key)
			if("E") // Put held thing in belt or take out most recent thing from belt
				var/obj/item/thing = get_active_held_item()
				var/obj/item/storage/equipped_belt = get_item_by_slot(slot_belt)
				if(!equipped_belt) // We also let you equip a belt like this
					if(!thing)
						to_chat(user, "<span class='notice'>You have no belt to take something out of.</span>")
						return
					equip_to_slot_if_possible(thing, slot_belt)
					return
				if(!istype(equipped_belt)) // not a storage item
					if(!thing)
						to_chat(user, "<span class='notice'>You have no belt to take something out of.</span>")
					else
						to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
					return
				if(thing) // put thing in belt
					if(equipped_belt.can_be_inserted(thing))
						equipped_belt.handle_item_insertion(thing)
					else
						to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
					return
				if(!equipped_belt.contents.len) // nothing to take out
					to_chat(user, "<span class='notice'>There's nothing in your belt to take out.</span>")
					return
				var/obj/item/stored = equipped_belt.contents[equipped_belt.contents.len]
				if(!stored || stored.on_found(src))
					return
				stored.attack_hand(src) // take out thing from belt
				return
			
			if("B") // Put held thing in backpack or take out most recent thing from backpack
				var/obj/item/thing = get_active_held_item()
				var/obj/item/storage/equipped_backpack = get_item_by_slot(slot_back)
				if(!equipped_backpack) // We also let you equip a backpack like this
					if(!thing)
						to_chat(user, "<span class='notice'>You have no backpack to take something out of.</span>")
						return
					equip_to_slot_if_possible(thing, slot_back)
					return
				if(!istype(equipped_backpack)) // not a storage item
					if(!thing)
						to_chat(user, "<span class='notice'>You have no backpack to take something out of.</span>")
					else
						to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
					return
				if(thing) // put thing in backpack
					if(equipped_backpack.can_be_inserted(thing))
						equipped_backpack.handle_item_insertion(thing)
					else
						to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
					return
				if(!equipped_backpack.contents.len) // nothing to take out
					to_chat(user, "<span class='notice'>There's nothing in your backpack to take out.</span>")
					return
				var/obj/item/stored = equipped_backpack.contents[equipped_backpack.contents.len]
				if(!stored || stored.on_found(src))
					return
				stored.attack_hand(src) // take out thing from backpack
				return

	switch(_key)
		if("E")
			quick_equip()
			return

	return ..()