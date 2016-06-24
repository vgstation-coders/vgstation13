// WIRES

/obj/item/weapon/wire/proc/update()
	if (amount > 1)
		icon_state = "spool_wire"
		desc = text("This is just spool of regular insulated wire. It consists of about [] unit\s of wire.", amount)
	else
		icon_state = "item_wire"
		desc = "This is just a simple piece of regular insulated wire."
	return

/obj/item/weapon/wire/attack_self(mob/user as mob)
	if (laying)
		laying = 0
		to_chat(user, "<span class='notice'>You're done laying wire!</span>")
	else
		to_chat(user, "<span class='notice'>You are not using this to lay wire...</span>")
	return


