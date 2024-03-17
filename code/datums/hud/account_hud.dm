//Accounts DB-based HUDs

//vscode complained about this sharing the name from cargo.dm but it wouldn't work unless it's here too
#define HUD_ACCOUNT_DB_OFFLINE (!linked_db.activated || linked_db.stat & (BROKEN|NOPOWER|FORCEDISABLE))

/datum/visioneffect/accountdb
	name = "accounts database hud"
	var/obj/machinery/account_database/linked_db

/datum/visioneffect/accountdb/New()
	..()
	reconnect_db()

/datum/visioneffect/accountdb/proc/reconnect_db()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Will only check for a database at the main Station.
		if(DB.z == map.zMainStation)
			if((DB.stat == 0))//If the database if damaged or not powered, people won't be able to use the machines anymore.
				linked_db = DB
				return TRUE
	return FALSE

/datum/visioneffect/accountdb/wage
	name = "wage hud"

/datum/visioneffect/accountdb/wage/process_hud(var/mob/M)
	..()
	if(!M.client)
		return
	if(!(M in wage_hud_users))
		wage_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	T = get_turf(M)

	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			continue
		var/obj/item/weapon/card/id/card = perp.get_id_card()
		if(card)
			holder = perp.hud_list[WAGE_HUD]
			var/datum/money_account/account = get_money_account(card.associated_account_number)
			var/cashdisplay = ""
			if(!linked_db) // Catch a missing database before a runtime!
				cashdisplay = html_encode(Gibberish("ERRO",100))
			else if (HUD_ACCOUNT_DB_OFFLINE) // Have to call this after the first if because it will runtime if linked_db doesn't exist
				cashdisplay = html_encode(Gibberish("ERRO",100))
			else if(account) //DB exists and is online, do they have an account
				cashdisplay = "$[account.wage_gain]"
			else //They do not have an account on that ID
				cashdisplay = "ERR"
			holder.maptext = "<span class='maptext very_small black_outline' style='text-align: left; vertical-align: bottom; color: white;'>[cashdisplay]</span>"
			C.images += holder

/datum/visioneffect/accountdb/balance
	name = "account balance hud"
	var/povertyline = 150 // can configure this on the fly, static overlay will update next process_hud call (usually on life.dm)

/datum/visioneffect/accountdb/balance/process_hud(var/mob/M)
	..()
	if(!M.client)
		return
	var/client/C = M.client
	var/image/holder
	var/turf/T
	var/icon/S
	T = get_turf(M)
	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			S = getStaticIcon(getFlatIcon(perp))
			C.images += image(S, perp, "hudstatic")
			continue
		var/obj/item/weapon/card/id/card = perp.get_id_card()
		if(card)
			holder = perp.hud_list[WAGE_HUD]
			if(!holder)
				continue
			var/datum/money_account/bankacc = get_money_account(card.associated_account_number)
			var/datum/money_account/virtualacc = card.virtual_wallet
			var/cashdisplay = "ERR"
			var/cash = 0
			if(!linked_db) // Catch a missing database before a runtime!
				cashdisplay = html_encode(Gibberish("ERRO",100))
			else if (HUD_ACCOUNT_DB_OFFLINE) // Have to call this after the first if because it will runtime if linked_db doesn't exist
				cashdisplay = html_encode(Gibberish("ERRO",100))
			else //not an error case
				if(virtualacc)
					cash += virtualacc.money
				if(bankacc)
					cash += bankacc.money
				cashdisplay = "$[cash]"
			if(cash < povertyline)
				S = getStaticIcon(getFlatIcon(perp))
				C.images += image(S, perp, "hudstatic")
			holder.maptext = "<span class='maptext yell black_outline' style='text-align: center; vertical-align: top; color: white;'>[cashdisplay]</span>"
			C.images += holder
