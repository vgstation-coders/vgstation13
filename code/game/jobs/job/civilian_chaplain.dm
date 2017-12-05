//Due to how large this one is, it gets its own file from civilian.dm
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "The God(s), the Head of Personnel too"
	selection_color = "#dddddd"
	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium)
	pdaslot = slot_belt
	pdatype = /obj/item/device/pda/chaplain
	var/datum/religion/chap_religion = new /datum/religion // He gets the default one

/datum/job/chaplain/equip(var/mob/living/carbon/human/H)
	switch(H.backbag)
		if(2)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack(H), slot_back)
		if(3)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
		if(4)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		if(5)
			H.equip_or_collect(new /obj/item/weapon/storage/backpack/messenger(H), slot_back)
	H.add_language("Spooky") //SPOOK
	H.equip_or_collect(new /obj/item/clothing/under/rank/chaplain(H), slot_w_uniform)
	//H.equip_or_collect(new /obj/item/device/pda/chaplain(H), slot_belt)
	H.equip_or_collect(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
	if(H.backbag == 1)
		H.put_in_hands(new H.species.survival_gear(H))
	else
		H.equip_or_collect(new H.species.survival_gear(H.back), slot_in_backpack)

	var/obj/item/weapon/storage/bible/B // Initialised here because we might need it eslewhere

	spawn(0) //We are done giving earthly belongings, now let's move on to spiritual matters
		var/new_religion = sanitize(stripped_input(H, "You are the crew's Religious Services Chaplain. What religion do you follow and teach? (Please put your ID in your ID slot to prevent errors)", "Name of Religion", chap_religion.name), 1, MAX_NAME_LEN)
		if(!new_religion)
			new_religion = chap_religion.name // If nothing was typed

		var/datum/job/J = H.mind.role_alt_title
		var/choice = FALSE

		for (var/R in typesof(/datum/religion))
			var/datum/religion/rel = new R
			for (var/key in rel.keys)
				if (lowertext(new_religion) == key)
					rel.equip_chaplain(H) // We do the misc things related to the religion
					B = new rel.bible_type
					B.name = rel.bible_name
					B.deity_name = rel.deity_name
					H.put_in_hands(B)
					rel.holy_book = B
					J = (H.gender == FEMALE ? rel.female_adept : rel.male_adept)
					chap_religion = rel
					choice = TRUE
					break // We got our religion ! Abort, abort.
			if (choice)
				break

		if (!choice) // Nothing was found
			chap_religion.name = "[new_religion]"
			chap_religion.deity_name = "[new_religion]"
			chap_religion.bible_name = "The Holy Book of [new_religion]"
			B = new chap_religion.bible_type
			B.name = chap_religion.bible_name
			B.deity_name = chap_religion.deity_name
			H.put_in_hands(B)
			chap_religion.holy_book = B

		//This goes down here due to problems with loading orders that took me 4 hours to identify
		var/obj/item/weapon/card/id/I = null
		if(istype(H.wear_id, /obj/item/weapon/card/id/)) //This prevents people from causing weirdness by putting other things into their slots before chosing their religion
			I = H.wear_id
			if(I.registered_name == H.real_name) //Makes sure the ID is the chaplain's own
				I.assignment = J
				I.name = text("[I.registered_name]'s ID Card ([I.assignment])")
		var/obj/item/device/pda/P = null
		if(istype(H.belt, /obj/item/device/pda)) //This prevents people from causing weirdness by putting other things into their slots before chosing their religion
			P = H.belt
			if(P.owner == H.real_name) //Makes sure the PDA is the chaplain's own
				P.ownjob = J
				P.name = text("PDA-[P.owner] ([P.ownjob])")
		data_core.manifest_modify(H.real_name, J) //Updates manifest
		feedback_set_details("religion_name","[chap_religion.name]")

		//Allow them to change their deity if they believe the deity we gave them sucks
		var/new_deity = copytext(sanitize(input(H, "Would you like to change your deity? Your deity currently is [chap_religion.deity_name] (Leave empty or unchanged to keep deity name)", "Name of Deity", chap_religion.deity_name)), 1, MAX_NAME_LEN)
		if(length(new_deity))
			chap_religion.deity_name = new_deity
			B.deity_name = new_deity

		var/accepted = 0
		var/outoftime = 0
		spawn(200) //20 seconds to choose
			outoftime = 1
		var/new_book_style = "Bible"

		while(!accepted)
			if(!B)
				break //Prevents possible runtime errors
			new_book_style = input(H, "Which bible style would you like?") in list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "Athiest", "[B.name == "clockwork slab" ? "Slab":"Tome"]", "The King in Yellow", "Ithaqua", "Scientology", \
																				   "the bible melts", "Unaussprechlichen Kulten", "Necronomicon", "Book of Shadows", "Torah", "Burning", "Honk", "Ianism", "The Guide")
			switch(new_book_style)
				if("Koran")
					B.icon_state = "koran"
					B.item_state = "koran"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 4
				if("Scrapbook")
					B.icon_state = "scrapbook"
					B.item_state = "scrapbook"
				if("Creeper")
					B.icon_state = "creeper"
					B.item_state = "syringe_kit"
				if("White Bible")
					B.icon_state = "white"
					B.item_state = "syringe_kit"
				if("Holy Light")
					B.icon_state = "holylight"
					B.item_state = "syringe_kit"
				if("Athiest")
					B.icon_state = "athiest"
					B.item_state = "syringe_kit"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 10
				if("Tome")
					B.icon_state = "tome"
					B.item_state = "syringe_kit"
				if("The King in Yellow")
					B.icon_state = "kingyellow"
					B.item_state = "kingyellow"
				if("Ithaqua")
					B.icon_state = "ithaqua"
					B.item_state = "ithaqua"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 5
				if("Scientology")
					B.icon_state = "scientology"
					B.item_state = "scientology"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 8
				if("the bible melts")
					B.icon_state = "melted"
					B.item_state = "melted"
				if("Unaussprechlichen Kulten")
					B.icon_state = "kulten"
					B.item_state = "kulten"
				if("Necronomicon")
					B.icon_state = "necronomicon"
					B.item_state = "necronomicon"
				if("Book of Shadows")
					B.icon_state = "shadows"
					B.item_state = "shadows"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 6
				if("Torah")
					B.icon_state = "torah"
					B.item_state = "torah"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 1
				if("Burning")
					B.icon_state = "burning"
					B.item_state = "syringe_kit"
				if("Honk")
					B.icon_state = "honkbook"
					B.item_state = "honkbook"
				if("Ianism")
					B.icon_state = "ianism"
					B.item_state = "ianism"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 9
				if("The Guide")
					B.icon_state = "guide"
					B.item_state = "guide"
				if("Slab")
					B.icon_state = "slab"
					B.item_state = "slab"
					B.desc = "A bizarre, ticking device... That looks broken."
				else
					//If christian bible, revert to default
					B.icon_state = "bible"
					B.item_state = "bible"
					for(var/area/chapel/main/A in areas)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 2

			H.update_inv_hands() //So that it updates the bible's item_state in his hand

			switch(input(H, "Look at your bible - is this what you want?") in list("Yes", "No"))
				if("Yes")
					accepted = 1
				if("No")
					if(outoftime)
						to_chat(H, "<span class='warning'>Welp, out of time, buddy. You're stuck with that one. Next time choose faster.</span>")
						accepted = 1

		if(ticker)
			ticker.Bible_icon_state = B.icon_state
			ticker.Bible_item_state = B.item_state
			ticker.Bible_name = B.name
			ticker.Bible_deity_name = B.deity_name
		feedback_set_details("religion_deity","[new_deity]")
		feedback_set_details("religion_book","[new_book_style]")
	return 1