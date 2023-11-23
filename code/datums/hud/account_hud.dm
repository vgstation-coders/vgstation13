//Accounts DB-based HUDs

#define ACCOUNT_DB_OFFLINE (!linked_db.activated || linked_db.stat & (BROKEN|NOPOWER|FORCEDISABLE))

/datum/hud/accountdb
	name = "accounts database hud"
	var/obj/machinery/account_database/linked_db

/datum/hud/accountdb/New()
	..()
	reconnect_db()

/datum/hud/accountdb/proc/reconnect_db()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Will only check for a database at the main Station.
		if(DB.z == map.zMainStation)
			if((DB.stat == 0))//If the database if damaged or not powered, people won't be able to use the machines anymore.
				linked_db = DB
				break

/datum/hud/accountdb/wage
	name = "wage hud"

/datum/hud/accountdb/wage/process_hud(var/mob/M)
	..()
	if(!(M in wage_hud_users))
		wage_hud_users += M
	var/client/C = M.client
	var/image/holder
	var/turf/T
	var/offset = 0
	if(M.hasHUD(HUD_MEDICAL))
		//hardcoded offset so that security huds will move aside for medical huds
		offset = 8
	offset = offset * PIXEL_MULTIPLIER
	T = get_turf(M)

	for(var/mob/living/simple_animal/astral_projection/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hud[ckey(perp.cardjob)]"
		holder.pixel_y = -offset
		C.images += holder

	for(var/mob/living/carbon/human/perp in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(perp, M))
			continue
		holder = perp.hud_list[ID_HUD]
		if(!holder)
			continue
		holder.icon_state = "hudno_id"
		if(perp.head && istype(perp.head,/obj/item/clothing/head/tinfoil)) //Tinfoil hat? Move along.
			holder.pixel_y = -offset
			C.images += holder
			continue
		var/obj/item/weapon/card/id/card = perp.get_id_card()
		if(card)
			holder.icon_state = "hud[ckey(card.GetJobName())]"
			holder.pixel_y = -offset
			C.images += holder

			holder = perp.hud_list[WAGE_HUD]
			var/datum/money_account/account = get_money_account(card.associated_account_number)
			var/cashdisplay = ""
			if(!linked_db) // Catch a missing database before a runtime!
				cashdisplay = html_encode(Gibberish("ERRO",100))
			else if (ACCOUNT_DB_OFFLINE) // Have to call this after the first if because it will runtime if linked_db doesn't exist
				cashdisplay = html_encode(Gibberish("ERRO",100))
			else if(account) //DB exists and is online, do they have an account
				cashdisplay = "$[account.wage_gain]"
			else //They do not have an account on that ID
				cashdisplay = "ERR"
			holder.maptext = "<span class='maptext very_small black_outline' style='text-align: left; vertical-align: bottom; color: white;'>[cashdisplay]</span>"
			C.images += holder



/datum/hud/accountdb/balance
	name = "account balance hud"
