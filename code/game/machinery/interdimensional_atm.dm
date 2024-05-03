

/obj/machinery/interdimensional_atm
	name = "Interdimensional Bank Terminal"
	desc = ""
	icon = 'icons/obj/terminals.dmi'
	icon_state = "atm"
	anchored = 1

	machine_flags = PURCHASER //not strictly true, but it connects it to the account

/obj/machinery/interdimensional_atm/New()
	..()


/obj/machinery/interdimensional_atm/attackby(obj/item/I as obj, mob/user as mob)
	if(I.is_wrench(user))
		user.visible_message("<span class='notice'>[user] begins to take apart the [src]!</span>", "<span class='notice'>You begin taking apart the [src].</span>")
		if(do_after(user, src, 40))
			user.visible_message("<span class='notice'>[user] disassembles the [src]!</span>", "<span class='notice'>You disassemble the [src].</span>")
			I.playtoolsound(src, 100)
			new /obj/item/stack/sheet/metal (src.loc,2)
			new /obj/item/bluespace_crystal (src.loc)
			qdel(src)
			return
	if(istype(I,/obj/item/weapon/spacecash))
		attempt_deposit(user, I)

// Attempts to deposit the given amount into the SQL table with the given ckey.
/obj/machinery/interdimensional_atm/proc/attempt_deposit(var/mob/user, var/obj/item/weapon/spacecash/money)
	var/target_ckey = ckey(user.key)

	// First, query the bank database for the ckey's current balance.
	var/datum/DBQuery/get_query = SSdbcore.NewQuery("SELECT COALESCE(MAX(balance), 0) FROM interdimensional_bank WHERE ckey=[target_ckey]")
	var/get_response = get_query.Execute()
	if(!get_response)
		to_chat(usr, get_query.ErrorMsg())
		qdel(get_query)
		return
	var/existing_balance
	if(get_query.NextRow())
		existing_balance = get_query.item[1]
	qdel(get_query)

	// Second, attempt to deposit the money.
	var/multiplier = money.arcanetampered ? rand(0,99) : 100
	var/amount_deposited = round(money.worth * money.amount * (multiplier/100))

	var/datum/DBQuery/deposit_query = SSdbcore.NewQuery("INSERT INTO interdimensional_bank (ckey, balance) VALUES (:ckey, :balance) ON DUPLICATE KEY UPDATE balance = VALUES(:balance);",
		list(
			"ckey" = target_ckey,
			"balance" = existing_balance + amount_deposited
		))
	var/deposit_response = deposit_query.Execute()

	if(!deposit_response)
		to_chat(usr, deposit_query.ErrorMsg())
		qdel(deposit_query)
		return
	else
		if(prob(50))
			playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
		else
			playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
		to_chat(user, "<span class='info'>You insert [amount_deposited] credit\s into \the [src]. Your new balance is [existing_balance + amount_deposited].</span>")
		qdel(money)
		qdel(deposit_query)
