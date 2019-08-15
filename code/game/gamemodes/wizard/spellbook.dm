#define STARTING_USES 5 * Sp_BASE_PRICE

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state ="spellbook"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/books.dmi', "right_hand" = 'icons/mob/in-hand/right/books.dmi')
	item_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	flags = FPRINT

	var/list/all_spells = list()
	var/list/offensive_spells = list()
	var/list/defensive_spells = list()
	var/list/utility_spells = list()
	var/list/misc_spells = list()

	//Unlike the list above, the available_artifacts list builds itself from all subtypes of /datum/spellbook_artifact
	var/static/list/available_artifacts = list()

	var/static/list/available_potions = list(
		/obj/item/potion/healing = Sp_BASE_PRICE,
		/obj/item/potion/transform = Sp_BASE_PRICE*0.75,
		/obj/item/potion/toxin = Sp_BASE_PRICE*0.75,
		/obj/item/potion/mana = Sp_BASE_PRICE*0.5,
		/obj/item/potion/invisibility/major = Sp_BASE_PRICE*0.5,
		/obj/item/potion/stoneskin = Sp_BASE_PRICE*0.5,
		/obj/item/potion/speed/major = Sp_BASE_PRICE*0.5,
		/obj/item/potion/zombie = Sp_BASE_PRICE*0.5,
		/obj/item/potion/mutation/truesight/major = Sp_BASE_PRICE*0.25,
		/obj/item/potion/mutation/strength/major = Sp_BASE_PRICE*0.25,
		/obj/item/potion/speed = Sp_BASE_PRICE*0.25,
		/obj/item/potion/random = Sp_BASE_PRICE*0.2,
		/obj/item/potion/sword = Sp_BASE_PRICE*0.1,
		/obj/item/potion/deception = Sp_BASE_PRICE*0.1,
		/obj/item/potion/levitation = Sp_BASE_PRICE*0.1,
		/obj/item/potion/fireball = Sp_BASE_PRICE*0.1,
		/obj/item/potion/invisibility = Sp_BASE_PRICE*0.1,
		/obj/item/potion/light = Sp_BASE_PRICE*0.05,
		/obj/item/potion/fullness = Sp_BASE_PRICE*0.05,
		/obj/item/potion/transparency = Sp_BASE_PRICE*0.05,
		/obj/item/potion/paralysis = Sp_BASE_PRICE*0.05,
		/obj/item/potion/mutation/strength = Sp_BASE_PRICE*0.05,
		/obj/item/potion/mutation/truesight = Sp_BASE_PRICE*0.05,
		/obj/item/potion/teleport = Sp_BASE_PRICE*0.05)

	var/uses = STARTING_USES
	var/max_uses = STARTING_USES

	var/op = 1

/obj/item/weapon/spellbook/admin
	uses = 30 * Sp_BASE_PRICE
	op = 0

/obj/item/weapon/spellbook/New()
	..()

	available_artifacts = typesof(/datum/spellbook_artifact) - /datum/spellbook_artifact

	for(var/wizard_spell in getAllWizSpells())
		var/spell/S = new wizard_spell
		all_spells += wizard_spell
		if (!S.holiday_required.len || (Holiday in S.holiday_required))
			if(S.specialization == OFFENSIVE)
				offensive_spells += wizard_spell
			if(S.specialization == DEFENSIVE)
				defensive_spells += wizard_spell
			if(S.specialization == UTILITY)
				utility_spells += wizard_spell
			if(S.specialization == SPELL_SPECIALIZATION_DEFAULT)
				misc_spells += wizard_spell

	for(var/T in available_artifacts)
		available_artifacts.Add(new T) //Create a new object with the path T
		available_artifacts.Remove(T) //Remove the path from the list
	//Result is a list full of /datum/spellbook_artifact objects

//Menu
#define buy_href_link(obj, price, txt) ((price > uses) ? "Price: [price] point\s" : "<a href='?src=\ref[src];spell=[obj];buy=1'>[txt]</a>")
#define book_background_color "#F1F1D4"
#define book_window_size "550x600"

/obj/item/weapon/spellbook/attack_self(var/mob/user)
	if(!user)
		return

	if(user.is_blind())
		to_chat(user, "<span class='info'>You open \the [src] and run your fingers across the parchment. Suddenly, the pages coalesce in your mind!</span>")

	user.set_machine(src)

	var/dat
	dat += "<head><title>Spellbook ([uses] REMAINING)</title></head><body style=\"background-color:[book_background_color]\">"
	dat += "<h1>A Wizard's Catalogue Of Spells And Artifacts</h1><br>"
	dat += "<h2>[uses] point\s remaining (<a href='?src=\ref[src];refund=1'>Get a refund</a>)</h2><br>"
	dat += "<em>This book contains a list of many useful things that you'll need in your journey.</em><br>"
	dat += "<span style=\"color:blue\"><strong>KNOWN SPELLS:</strong></span><br><br>"

	var/list/shown_spells = all_spells.Copy()
	var/list/shown_offensive_spells = offensive_spells.Copy()
	var/list/shown_defensive_spells = defensive_spells.Copy()
	var/list/shown_utility_spells = utility_spells.Copy()
	var/list/shown_misc_spells = misc_spells.Copy()

	//Draw known spells first
	for(var/spell/spell in user.spell_list)
		if(shown_spells.Find(spell.type)) //User knows a spell from the book
			shown_spells.Remove(spell.type)

			//FORMATTING

			//<b>Fireball</b> - 10 seconds<br>
			//Requires robes to cast
			//speed: 1/5 (upgrade) | power: 0/1 (upgrade)

			var/spell_name = spell.name
			var/spell_cooldown = get_spell_cooldown_string(spell.charge_max, spell.charge_type)

			dat += "<strong>[spell_name]</strong>[spell_cooldown]<br>"

			//Get spell properties
			var/list/properties = get_spell_properties(spell.spell_flags, user)
			var/property_data
			for(var/P in properties)
				property_data += "[P] "

			if(property_data)
				dat += "<span style=\"color:blue\">[property_data]</span><br>"

			//Get the upgrades
			var/upgrade_data = ""

			for(var/upgrade in spell.spell_levels)
				var/lvl = spell.spell_levels[upgrade]
				var/max = spell.level_max[upgrade]

				//If maximum upgrade level is 0, skip
				if(!max)
					continue

				upgrade_data += "<a href='?src=\ref[src];spell=\ref[spell];upgrade_type=[upgrade];upgrade_info=1'>[upgrade]</a>: [lvl]/[max] (<a href='?src=\ref[src];spell=\ref[spell];upgrade_type=[upgrade];upgrade=1'>upgrade ([spell.get_upgrade_price(upgrade)] points)</a>)  "

			if(upgrade_data)
				dat += "[upgrade_data]<br><br>"
			dat+= "<br>"

//FORMATTING
//<b>Fireball</b> - 10 seconds (buy for 1 spell point)
//<i>(Description)</i>
//Requires robes to cast

//I truly am sorry for this terrible copypaste, but there was no other way. - B2MTTF
	if(shown_offensive_spells.len)
		dat += "<span style=\"color:red\"><strong>OFFENSIVE SPELLS:</strong></span><br><br>"
		for(var/spell_path in shown_offensive_spells)
			var/spell/abstract_spell = spell_path
			var/spell_name = initial(abstract_spell.name)
			var/spell_cooldown = get_spell_cooldown_string(initial(abstract_spell.charge_max), initial(abstract_spell.charge_type))
			var/spell_price = get_spell_price(abstract_spell)
			dat += "<strong>[spell_name]</strong>[spell_cooldown] ([buy_href_link(spell_path, spell_price, "buy for [spell_price] point\s")])<br>"
			dat += "<em>[initial(abstract_spell.desc)]</em><br>"
			var/flags = initial(abstract_spell.spell_flags)
			var/list/properties = get_spell_properties(flags, user)
			var/property_data
			for(var/P in properties)
				property_data += "[P] "
			if(property_data)
				dat += "<span style=\"color:blue\">[property_data]</span><br>"
			dat += "<br>"

	if(shown_defensive_spells.len)
		dat += "<span style=\"color:blue\"><strong>DEFENSIVE SPELLS:</strong></span><br><br>"
		for(var/spell_path in shown_defensive_spells)
			var/spell/abstract_spell = spell_path
			var/spell_name = initial(abstract_spell.name)
			var/spell_cooldown = get_spell_cooldown_string(initial(abstract_spell.charge_max), initial(abstract_spell.charge_type))
			var/spell_price = get_spell_price(abstract_spell)
			dat += "<strong>[spell_name]</strong>[spell_cooldown] ([buy_href_link(spell_path, spell_price, "buy for [spell_price] point\s")])<br>"
			dat += "<em>[initial(abstract_spell.desc)]</em><br>"
			var/flags = initial(abstract_spell.spell_flags)
			var/list/properties = get_spell_properties(flags, user)
			var/property_data
			for(var/P in properties)
				property_data += "[P] "
			if(property_data)
				dat += "<span style=\"color:blue\">[property_data]</span><br>"
			dat += "<br>"

	if(shown_utility_spells.len)
		dat += "<span style=\"color:green\"><strong>UTILITY SPELLS:</strong></span><br><br>"
		for(var/spell_path in shown_utility_spells)
			var/spell/abstract_spell = spell_path
			var/spell_name = initial(abstract_spell.name)
			var/spell_cooldown = get_spell_cooldown_string(initial(abstract_spell.charge_max), initial(abstract_spell.charge_type))
			var/spell_price = get_spell_price(abstract_spell)
			dat += "<strong>[spell_name]</strong>[spell_cooldown] ([buy_href_link(spell_path, spell_price, "buy for [spell_price] point\s")])<br>"
			dat += "<em>[initial(abstract_spell.desc)]</em><br>"
			var/flags = initial(abstract_spell.spell_flags)
			var/list/properties = get_spell_properties(flags, user)
			var/property_data
			for(var/P in properties)
				property_data += "[P] "
			if(property_data)
				dat += "<span style=\"color:blue\">[property_data]</span><br>"
			dat += "<br>"

	if(shown_misc_spells.len)
		dat += "<span style=\"color:orange\"><strong>MISCELLANEOUS SPELLS:</strong></span><br><br>"
		for(var/spell_path in shown_misc_spells)
			var/spell/abstract_spell = spell_path
			var/spell_name = initial(abstract_spell.name)
			var/spell_cooldown = get_spell_cooldown_string(initial(abstract_spell.charge_max), initial(abstract_spell.charge_type))
			var/spell_price = get_spell_price(abstract_spell)
			dat += "<strong>[spell_name]</strong>[spell_cooldown] ([buy_href_link(spell_path, spell_price, "buy for [spell_price] point\s")])<br>"
			dat += "<em>[initial(abstract_spell.desc)]</em><br>"
			var/flags = initial(abstract_spell.spell_flags)
			var/list/properties = get_spell_properties(flags, user)
			var/property_data
			for(var/P in properties)
				property_data += "[P] "
			if(property_data)
				dat += "<span style=\"color:blue\">[property_data]</span><br>"
			dat += "<br><br>"

	dat += "<hr><span style=\"color:purple\"><strong>ARTIFACTS AND BUNDLES<sup>*</sup></strong></span><br><small>* Non-refundable</small><br><br>"

	for(var/datum/spellbook_artifact/A in available_artifacts)
		if(!A.can_buy(user))
			continue

		var/artifact_name = A.name
		var/artifact_desc = A.desc
		var/artifact_price = A.price

		//FORMATTING:
		//<b>Staff of Change</b> (buy for 1 point)
		//<i>(description)</i>

		dat += "<strong>[artifact_name]</strong> ([buy_href_link("\ref[A]", artifact_price, "buy for [artifact_price] point\s")])<br>"
		dat += "<em>[artifact_desc]</em><br><br>"

	dat += "<hr><span style=\"color:green\"><strong>POTIONS<sup>*</sup></strong></span><br><small>* Non-refundable</small><br><br>"

	for(var/P in available_potions)
		var/obj/item/potion/potion = P
		var/potion_name = initial(potion.name)
		var/potion_desc = initial(potion.desc)
		var/potion_price = available_potions[P]

		dat += "<strong>[potion_name]</strong> ([buy_href_link(P, potion_price, "buy for [potion_price] point\s")])<br>"
		dat += "<em>[potion_desc]</em><br><br>"

	dat += "</body>"

	user << browse(dat, "window=spellbook;size=[book_window_size]")
	onclose(user, "spellbook")

/obj/item/weapon/spellbook/proc/get_spell_properties(flags, mob/user)
	var/list/properties = list()

	if(flags & NEEDSCLOTHES)
		var/new_prop = "Requires wizard robes to cast."

		//If user has the robeless spell, strike the text out
		if(user)
			var/is_robeless = locate(/spell/passive/noclothes) in user.spell_list
			if(is_robeless)
				new_prop = "<s>[new_prop]</s>"

		properties.Add(new_prop)

	if(flags & STATALLOWED)
		properties.Add("Can be cast while unconscious.")

	return properties

/obj/item/weapon/spellbook/proc/get_spell_cooldown_string(charges, charge_type)
	if(charges == 0)
		return

	switch(charge_type)
		if(Sp_CHARGES)
			return " - [charges] charge\s"
		if(Sp_RECHARGE)
			return " - cooldown: [(charges/10)]s"

/obj/item/weapon/spellbook/proc/get_spell_price(spell/spell_type)
	if(ispath(spell_type, /spell))
		return initial(spell_type.price)
	else if(istype(spell_type))
		return spell_type.price
	else
		return 0

/obj/item/weapon/spellbook/proc/use(amount)
	if(uses >= amount)
		uses -= amount

		return 1


/obj/item/weapon/spellbook/proc/refund(mob/user)
	if(!istype(get_area(user), /area/wizard_station))
		to_chat(user, "<span class='notice'>No refunds once you leave your den.</span>")
		return

	for(var/spell/S in user.spell_list)
		if(S.refund_price <= 0)
			continue

		to_chat(user, "<span class='info'>You forget [S.name] and receive [S.refund_price] additional spell points.</span>")

		user.remove_spell(S)
		uses += S.refund_price

		//stat collection: spellbook purchases
		var/datum/role/wizard/W = user.mind.GetRole(WIZARD)
		if(istype(W) && istype(W.stat_datum, /datum/stat/role/wizard))
			var/datum/stat/role/wizard/WD = W.stat_datum
			WD.spellbook_purchases.Add("REFUND-" + S.name)

		return 1

/obj/item/weapon/spellbook/Topic(href, href_list)
	if(..())
		return

	var/mob/living/L = usr
	if(!istype(L))
		return

	if(L.mind.special_role == "apprentice")
		to_chat(L, "If you got caught sneaking a peak from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not.")
		return

	if(href_list["refund"])
		refund(usr)

		attack_self(usr)

	if(href_list["buy"])
		var/buy_type = text2path(href_list["spell"])

		if(ispath(buy_type, /spell)) //Passed a spell typepath
			if(locate(buy_type) in usr.spell_list)
				to_chat(usr, "<span class='notice'>You already know that spell. Perhaps you'd like to upgrade it instead?</span>")

			else if(buy_type in all_spells)
				var/spell/S = buy_type
				if(use(initial(S.price)))
					var/spell/added = new buy_type
					added.refund_price = added.price
					add_spell(added, L)
					to_chat(usr, "<span class='info'>You have learned [added.name].</span>")
					feedback_add_details("wizard_spell_learned", added.abbreviation)
					var/datum/role/wizard/W = usr.mind.GetRole(WIZARD)
					if(istype(W) && istype(W.stat_datum, /datum/stat/role/wizard))
						var/datum/stat/role/wizard/WD = W.stat_datum
						WD.spellbook_purchases.Add(added.name)

		else if(ispath(buy_type, /obj/item/potion))
			if(buy_type in available_potions)
				if(use(available_potions[buy_type]))
					var/atom/item = new buy_type(get_turf(usr))
					feedback_add_details("wizard_spell_learned", "PT")
					var/datum/role/wizard/W = usr.mind.GetRole(WIZARD)
					if(istype(W) && istype(W.stat_datum, /datum/stat/role/wizard))
						var/datum/stat/role/wizard/WD = W.stat_datum
						WD.spellbook_purchases.Add(item.name)

		else //Passed an artifact reference
			var/datum/spellbook_artifact/SA = locate(href_list["spell"])

			if(istype(SA) && (SA in available_artifacts))
				if(SA.can_buy(usr) && use(SA.price))
					SA.purchased(usr)
					if(SA.one_use)
						available_artifacts.Remove(SA)
					feedback_add_details("wizard_spell_learned", SA.abbreviation)
					var/datum/role/wizard/W = usr.mind.GetRole(WIZARD)
					if(istype(W) && istype(W.stat_datum, /datum/stat/role/wizard))
						var/datum/stat/role/wizard/WD = W.stat_datum
						WD.spellbook_purchases.Add(SA.name)

		attack_self(usr)

	if(href_list["upgrade"])
		var/upgrade_type = href_list["upgrade_type"]
		var/spell/spell = locate(href_list["spell"])

		if(istype(spell) && spell.can_improve(upgrade_type))
			var/price = spell.get_upgrade_price(upgrade_type)
			if(use(price))
				spell.refund_price += price
				var/temp = spell.apply_upgrade(upgrade_type)

				if(temp)
					to_chat(usr, "<span class='info'>[temp]</span>")

		attack_self(usr)

	if(href_list["upgrade_info"])
		var/upgrade_type = href_list["upgrade_type"]
		var/spell/spell = locate(href_list["spell"])

		if(istype(spell))
			var/info = spell.get_upgrade_info(upgrade_type, spell.spell_levels[upgrade_type] + 1)
			if(info)
				to_chat(usr, "<span class='info'>[info]</span>")
			else
				to_chat(usr, "<span class='notice'>\The [src] doesn't contain any information about this.</span>")

#undef buy_href_link
#undef book_background_color
#undef book_window_size