#define COIN 0
#define CREDIT 1
#define BANK_CARD 2

/datum/artifact_trigger/pay2use
	triggertype = TRIGGER_PAY2USE
	scanned_trigger = SCAN_PHYSICAL
	var/mode
	var/key_attackhand
	var/key_attackby
	var/time_left = 0
	var/toggled = 0
	var/obj/machinery/account_database/linked_db
	var/stored_dosh = 0
	var/coin_value = 10
	var/credit_value = 3 //6 seconds per credit by default

/datum/artifact_trigger/pay2use/New()
	..()
	key_attackhand = my_artifact.on_attackhand.Add(src, "owner_attackhand")
	key_attackby = my_artifact.on_attackby.Add(src, "owner_attackby")
	mode = rand(0,2)
	reconnect_database()
	if(my_effect.chargelevelmax > 30)
		coin_value = my_effect.chargelevelmax
		credit_value = my_effect.chargelevelmax / 5 //5 credits per effect charge


/datum/artifact_trigger/pay2use/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((my_artifact.loc && (DB.z == my_artifact.loc.z)) || (DB.z == STATION_Z))
			if((DB.stat == 0) && DB.activated )//If the database if damaged or not powered, people won't be able to use the app anymore.
				linked_db = DB
				break

/datum/artifact_trigger/pay2use/CheckTrigger()
	if(time_left < 0)
		time_left = 0

	if(!toggled)
		if(time_left)
			if(!my_effect.activated)
				Triggered(0, "MONEY", 0)
			time_left--
		else
			if(my_effect.activated)
				Triggered(0, "NOMONEY", 0)
	else
		if(!my_effect.activated)
			Triggered(0, "MONEYTOGGLE", 0)

/datum/artifact_trigger/pay2use/proc/owner_attackhand(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]

	if(context != "TOUCH" || mode != BANK_CARD)
		return

	else if(mode == BANK_CARD)
		var/dat = "<TT><center><b>[my_artifact.artifact_id]</b></center><hr /><br>" //display the name, and added a horizontal rule
		dat += "<b>Select an item: </b><br><br>" //the rest is just general spacing and bolding

		dat += "2 Minutes - $10 - "
		dat += "<A href='?src=\ref[src];pay2m=1'>Pay</a><BR>"

		dat += "5 Minutes - $20 - "
		dat += "<A href='?src=\ref[src];pay5m=1'>Pay</a><BR>"

		dat += "10 Minutes - $40 - "
		dat += "<A href='?src=\ref[src];pay10m=1'>Pay</a><BR>"

		dat += "30 Minutes - $85 - "
		dat += "<A href='?src=\ref[src];pay30m=1'>Pay</a><BR>"

		dat += "BEST VALUE FOR MONEY<BR>"
		dat += "1 Hour - $150 - "
		dat += "<A href='?src=\ref[src];pay1h=1'>Pay</a><BR>"

		if(stored_dosh > 50)
			dat += "Returning Customer Bonus<BR>"
			dat += "Toggle - $25 - "
			dat += "<A href='?src=\ref[src];toggled=1'>Pay</a><BR>"

		var/datum/browser/popup = new(toucher, "\ref[src]", "[my_artifact.artifact_id]", 575, 400, src)
		popup.set_content(dat)
		popup.open()

/datum/artifact_trigger/pay2use/proc/owner_attackby(var/list/event_args, var/source)
	var/toucher = event_args[1]
	var/context = event_args[2]
	var/obj/item/weapon/item = event_args[3]

	if(context == "MELEE")
		if(iscoin(item))
			var/obj/item/weapon/coin/inserted_coin = item
			if(mode == COIN)
				if(istype(inserted_coin, /obj/item/weapon/coin/iron))
					time_left += coin_value
					my_artifact.visible_message("<span class='info'>Something clicks from within [my_artifact].</span>")
				else if(istype(inserted_coin, /obj/item/weapon/coin/silver))
					time_left += coin_value * 3
				else if(istype(inserted_coin, /obj/item/weapon/coin/plasma))
					time_left += coin_value * 4
				else if(istype(inserted_coin, /obj/item/weapon/coin/gold) || istype(inserted_coin, /obj/item/weapon/coin/uranium))
					time_left += coin_value * 6
				else if(istype(inserted_coin, /obj/item/weapon/coin/diamond))
					time_left += coin_value * 10
				else if(istype(inserted_coin, /obj/item/weapon/coin/phazon) || istype(inserted_coin, /obj/item/weapon/coin/adamantine) || istype(inserted_coin, /obj/item/weapon/coin/mythril))
					toggled = !toggled
					my_artifact.visible_message("<span class='info'>Something clicks from within [my_artifact].</span>")
				else if(istype(item, /obj/item/weapon/coin/clown))
					playsound(get_turf(my_artifact), 'sound/items/bikehorn.ogg', 50, 1)
					toggled = !toggled

				else
					to_chat(toucher, "[bicon(my_artifact)]<span class='warning'>[my_artifact] does not accept this type of coin!</span>")
					return

				my_artifact.visible_message("<span class='info'>[toucher] inserts a coin into [my_artifact].</span>")
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) || [item] inserted to ([my_effect.trigger]) || used by [key_name(toucher)].")

				if(inserted_coin.string_attached)
					if(prob(50))
						to_chat(toucher, "<SPAN CLASS='notice'>You successfully pulled the coin out before the [my_artifact] could swallow it.</SPAN>")
						return
					else
						to_chat(toucher, "<SPAN CLASS='notice'>You weren't able to pull the coin out fast enough, the [my_artifact] ate it, string and all.</SPAN>")

				qdel(item)
			else
				to_chat(toucher, "[bicon(my_artifact)]<span class='warning'>[my_artifact] does not accept coins!</span>")

		else if(istype(item, /obj/item/weapon/spacecash))
			if(mode == CREDIT)
				var/obj/item/weapon/spacecash/dosh = item
				my_artifact.visible_message("<span class='info'>[toucher] inserts a credit chip into [my_artifact].</span>")
				if(prob(90)) //1 in 10 chance to toggle
					time_left += (dosh.get_total() * 3) //6 seconds per credit
					if(toggled)
						toggled = !toggled
						my_artifact.visible_message("<span class='info'>Something clicks from within [my_artifact].</span>")
				else
					my_artifact.visible_message("<span class='info'>Something clicks from within [my_artifact].</span>")
					toggled = !toggled
				my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) || $[dosh.get_total()] [dosh] inserted to ([my_effect.trigger]) || used by [key_name(toucher)].")
				stored_dosh += dosh.get_total()
				qdel(dosh)
			else
				to_chat(toucher, "[bicon(my_artifact)]<span class='warning'>[my_artifact] does not accept credits!</span>")

/datum/artifact_trigger/pay2use/proc/payviacard(var/dosh = 0, var/time = 0, var/mob)

	if(mode == BANK_CARD)
		var/mob/living/M = mob
		var/obj/item/weapon/card/I = M.get_id_card()
		var/bought_time = time / 2

		if (istype(I, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/C = I
			my_artifact.visible_message("<span class='info'>[M] swipes a card through [my_artifact].</span>")

			//we start by checking the ID card's virtual wallet
			var/datum/money_account/D = C.virtual_wallet
			var/using_account = "Virtual Wallet"

			//if there isn't one for some reason we create it, that should never happen but oh well.
			if(!D)
				C.update_virtual_wallet()
				D = C.virtual_wallet

			var/transaction_amount = dosh

			//if there isn't enough money in the virtual wallet, then we check the bank account connected to the ID
			if(D.money < transaction_amount)
				if(linked_db)
					D = linked_db.attempt_account_access(C.associated_account_number, 0, 2, 0)
				else
					D = null
				using_account = "Bank Account"
				if(!D)								//first we check if there IS a bank account in the first place
					to_chat(M, "[bicon(my_artifact)]<span class='warning'>You don't have that much money on your virtual wallet!</span>")
					to_chat(M, "[bicon(my_artifact)]<span class='warning'>Unable to access your bank account.</span>")
					return 0
				else if(D.security_level > 0)		//next we check if the security is low enough to pay directly from it
					to_chat(M, "[bicon(my_artifact)]<span class='warning'>You don't have that much money on your virtual wallet!</span>")
					to_chat(M, "[bicon(my_artifact)]<span class='warning'>Lower your bank account's security settings if you wish to pay directly from it.</span>")
					return 0
				else if(D.money < transaction_amount)//and lastly we check if there's enough money on it, duh
					to_chat(M, "[bicon(my_artifact)]<span class='warning'>You don't have that much money on your bank account!</span>")
					return 0

			//transfer the money
			D.money -= transaction_amount
			stored_dosh += transaction_amount

			to_chat(M, "[bicon(my_artifact)]<span class='notice'>Remaining balance ([using_account]): [D.money]$</span>")

			//create an entry on the buy's account's transaction log
			var/datum/transaction/T = new()
			T.target_name = "[my_artifact.artifact_id]"
			T.purpose = "Purchase of [dosh * 2] seconds of activation."
			T.amount = "-[transaction_amount]"
			T.source_terminal = my_artifact.artifact_id
			T.date = current_date_string
			T.time = worldtime2text()
			D.transaction_log.Add(T)

			// Vend the item
			if(bought_time > 0)
				time_left += bought_time
			else
				toggled = !toggled

			my_artifact.investigation_log(I_ARTIFACT, "|| effect [my_effect.artifact_id]([my_effect]) || [C] used to deposit $[dosh] and activate ([my_effect.trigger]) || used by [key_name(M)].")

/datum/artifact_trigger/pay2use/Topic(href, href_list)
	if(..())
		return
	if(href_list["pay2m"])
		payviacard(10, 120, usr) //(credits paid, time given in seconds, usr)
	if(href_list["pay5m"])
		payviacard(20, 300, usr)
	if(href_list["pay10m"])
		payviacard(40, 600, usr)
	if(href_list["pay30m"])
		payviacard(85, 1800, usr)
	if(href_list["pay1h"])
		payviacard(500, 3600, usr)
	if(href_list["toggled"])
		payviacard(25, 0, usr)

/datum/artifact_trigger/pay2use/Destroy()
	my_artifact.on_attackhand.Remove(key_attackhand)
	my_artifact.on_attackby.Remove(key_attackby)
	linked_db = null
	..()