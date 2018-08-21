/obj/item/weapon/card/debit
	name = "\improper debit card"
	desc = "A flimsy piece of plastic with cheap near field circuitry backed by digits representing funds in a bank account."
	icon = 'icons/obj/card.dmi'
	icon_state = "debit"
	melt_temperature = MELTPOINT_PLASTIC
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_PLASTIC = 10)
	w_type = RECYK_MISC
	var/to_cut = 0.8

/obj/item/weapon/card/debit/New(var/new_loc, var/account_number)
	. = ..(new_loc)
	associated_account_number = account_number

/obj/item/weapon/card/debit/examine(var/mob/user)
	. = ..()
	if(user.Adjacent(src) || istype(user, /mob/dead))
		if(associated_account_number)
			to_chat(user, "<span class='notice'>The account number on the card reads [associated_account_number].</span>")
		else
			to_chat(user, "<span class='warning'>The account number appears to be scratched off.</span>")

/obj/item/weapon/card/debit/attack_self(var/mob/user)
	if(user.attack_delayer.blocked())
		return
	user.visible_message("[user] flashes their: [bicon(src)] [name]",\
		"You flash your debit card: [bicon(src)] [name]")
	user.delayNextAttack(1 SECONDS)
	add_fingerprint(user)

/obj/item/weapon/card/debit/attackby(var/obj/O, var/mob/user)
	. = ..()
	if(istype(O, /obj/item))
		var/obj/item/item = O
		if(item.sharpness_flags & SHARP_BLADE && item.sharpness >= to_cut)
			user.visible_message("<span class='warning'>\The [user] cuts \the [src] with \the [item], destroying it.</span>", "<span class='warning'>You destroy \the [src] with \the [item]</span>", "You hear plastic being cut.")
			qdel(src)
			return
		else if(O.is_hot() >= melt_temperature)
			user.visible_message("<span class='warning'>\The [user] melts \the [src] with \the [item], destroying it.</span>", "<span class='warning'>You destroy \the [src] with \the [item]</span>")
			qdel(src)
			return
		
/obj/item/weapon/card/debit/trader
	name = "\improper Trader Shoal debit card"

/obj/item/weapon/card/debit/trader/New(var/new_loc, var/account_number)
	if(!trader_account)
		trader_account = create_trader_account
	return ..(new_loc, trader_account.account_number)

/obj/item/weapon/card/debit/preferred
	name = "\improper preferred debit card"
	desc = "A sturdy looking metal card containing near field circuitry."
	icon_state = "debit-preferred"
	melt_temperature = MELTPOINT_STEEL
	starting_materials = list(MAT_IRON = 10)
	w_type = RECYK_METAL
	to_cut = 1
	var/examine_held = "<span class='notice'>You feel more important just by holding it</span>"

/obj/item/weapon/card/debit/preferred/examine(var/mob/user)
	. = ..()
	if(src in user.held_items || istype(user, /mob/dead))
		to_chat(user, examine_held)

/obj/item/weapon/card/debit/preferred/elite
	name = "\improper elite debit card"
	desc = "A very sturdy looking metal card containing near field circuitry. Whoever owns it must be really important"
	icon_state = "debit-elite"
	starting_materials = list(MAT_IRON = 20)
	to_cut = 1.5
	examine_held = "<span class='notice'>You feel <b>incredibly</b> important just by holding it</span>"

/obj/item/weapon/card/debit/preferred/department
	name = "\improper department debit card"
	var/department = ""
	var/easter_egg = TRUE

/obj/item/weapon/card/debit/preferred/department/New(var/new_loc, var/desired_department)
	. = ..(new_loc)
	department = desired_department
	if(desired_department)
		set_department_account(desired_department)

/obj/item/weapon/card/debit/preferred/department/initialize()
	if(department)
		set_department_account(department)

/obj/item/weapon/card/debit/preferred/department/examine(var/mob/user)
	if(!associated_account_number && department)
		var/old_name
		if(easter_egg)
			old_name = name
		if(set_department_account(department) && easter_egg)
			to_chat(user, "<span class='sinister'>\The [old_name] glows as numbers and letters begin to etch themselves onto the card.</span> <span class='warning'>Spooky</span>")
	. = ..(user)

/obj/item/weapon/card/debit/preferred/department/proc/set_department_account(var/desired_department)
	if(desired_department in department_accounts)
		var/datum/money_account/department_account = department_accounts[desired_department]
		associated_account_number = department_account.account_number
		name = "\improper [department_account.owner_name] debit card"
		return TRUE
	else
		warning("A debit card \"\ref[src]\" is trying to use a department \"[desired_department]\" that does not exist in the global department_accounts.\n[department_accounts]")
		return FALSE

/obj/item/weapon/card/debit/preferred/department/elite
	desc = "A very sturdy looking metal card containing near field circuitry. Whoever owns it must be really important"
	icon_state = "debit-elite"
	starting_materials = list(MAT_IRON = 20)
	to_cut = 1.5
	examine_held = "<span class='notice'>You feel <b>incredibly</b> important just by holding it</span>"
