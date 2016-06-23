/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in oview(1) //Cannot handle giving shit to mobs on your own tile, but it's a small, small loss

	give_item(usr)

/mob/living/carbon/proc/give_item(mob/living/carbon/user)


	if(stat == 2 || user.stat == 2 || client == null)
		return
	if(handcuffed)
		to_chat(user, "<span class='warning'>Those hands are cuffed right now.</span>")
		return //Can't receive items while cuffed
	var/obj/item/I
	if(user.get_active_hand() == null)
		to_chat(user, "You don't have anything in your [user.get_index_limb_name(user.active_hand)] to give to [src].")
		return
	I = user.get_active_hand()
	if(!I)
		return
	if(src == user) //Shouldn't happen
		to_chat(user, "<span class='warning'>You tried to give yourself \the [I], but you didn't want it.</span>")
		return
	if(find_empty_hand_index())
		switch(alert(src, "[user] wants to give you \a [I]?", , "Yes", "No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(user))
					to_chat(user, "<span class='warning'>You need to stay still while giving an object.</span>")
					to_chat(src, "<span class='warning'>[user] moved away.</span>")//What an asshole

					return
				if(user.get_active_hand() != I)
					to_chat(user, "<span class='warning'>You need to keep the item in your hand.</span>")
					to_chat(src, "<span class='warning'>[user] has put \the [I] away!</span>")
					return
				if(!find_empty_hand_index())
					to_chat(src, "<span class='warning'>Your hands are full.</span>")
					to_chat(user, "<span class='warning'>Their hands are full.</span>")
					return
				if(!user.drop_item(I))
					src << "<span class='warning'>[user] can't let go of \the [I]!</span>"
					user << "<span class='warning'>You can't seem to let go of \the [I].</span>"
					return

				put_in_hands(I)
				visible_message("<span class='notice'>[user] handed \the [I] to [src].</span>")
			if("No")
				visible_message("<span class='warning'>[user] tried to hand \the [I] to [src] but \he didn't want it.</span>")
	else
		to_chat(user, "<span class='warning'>[src]'s hands are full.</span>")
