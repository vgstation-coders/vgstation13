#define STARTING_USES 5

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state ="spellbook"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	flags = FPRINT

	var/list/available_spells = list(
	/spell/targeted/projectile/magic_missile,
	/spell/targeted/projectile/dumbfire/fireball,
	/spell/lightning,
	/spell/aoe_turf/disable_tech,
	/spell/aoe_turf/smoke,
	/spell/targeted/genetic/blind,
	/spell/targeted/subjugation,
	/spell/targeted/mind_transfer,
	/spell/aoe_turf/conjure/forcewall,
	/spell/aoe_turf/blink,
	/spell/area_teleport,
	/spell/targeted/genetic/mutate,
	/spell/targeted/ethereal_jaunt,
	/spell/aoe_turf/fall,
	/spell/aoe_turf/knock,
	/spell/targeted/equip_item/horsemask,
	/spell/targeted/equip_item/clowncurse,
	/spell/targeted/equip_item/frenchcurse,
	/spell/targeted/shoesnatch,
	/spell/targeted/equip_item/robesummon,
	/spell/targeted/flesh_to_stone,
	/spell/targeted/buttbots_revenge,
	/spell/aoe_turf/conjure/pontiac,
	/spell/noclothes
	)

	//Unlike the list above, the available_artifacts list builds itself from all subtypes of /datum/spellbook_artifact
	var/list/available_artifacts = list()

	var/uses = STARTING_USES
	var/max_uses = STARTING_USES

	var/op = 1

/obj/item/weapon/spellbook/New()
	..()

	available_artifacts = typesof(/datum/spellbook_artifact) - /datum/spellbook_artifact

	for(var/T in available_artifacts)
		available_artifacts.Add(new T) //Create a new object with the path T
		available_artifacts.Remove(T) //Remove the path from the list
	//Result is a list full of /datum/spellbook_artifact objects

/obj/item/weapon/spellbook/proc/get_available_spells()
	return available_spells.Copy()

/obj/item/weapon/spellbook/proc/get_available_artifacts()
	return available_artifacts

/obj/item/weapon/spellbook/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/antag_spawner/contract))
		var/obj/item/weapon/antag_spawner/contract/contract = O
		if(contract.used)
			to_chat(user, "The contract has been used, you can't get your points back now.")
		else
			to_chat(user, "You feed the contract back into the spellbook, refunding your points.")
			src.max_uses++
			src.uses++
			qdel (O)
			O = null

#define buy_href_link(obj, price, txt) ((price > uses) ? "Price: [price] point\s" : "<a href='?src=\ref[src];spell=[obj];buy=1'>[txt]</a>")
#define book_background_color "#F1F1D4"
#define book_window_size "550x600"

/obj/item/weapon/spellbook/attack_self(mob/user = usr)
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
	dat += "<strong>KNOWN SPELLS:</strong><br><br>"

	var/list/shown_spells = get_available_spells()

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

				upgrade_data += "<a href='?src=\ref[src];spell=\ref[spell];upgrade_type=[upgrade];upgrade_info=1'>[upgrade]</a>: [lvl]/[max] (<a href='?src=\ref[src];spell=\ref[spell];upgrade_type=[upgrade];upgrade=1'>upgrade</a>)  "

			if(upgrade_data)
				dat += "[upgrade_data]<br><br>"

	dat += "<strong>UNKNOWN SPELLS:</strong><br><br>"

	//Then draw the unknown spells
	for(var/spell_path in shown_spells)
		var/spell/abstract_spell = spell_path

		//FORMATTING

		//<b>Fireball</b> - 10 seconds (buy for 1 spell point)
		//<i>(Description)</i>
		//Requires robes to cast

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

	dat += "<hr><strong>ARTIFACTS AND BUNDLES<sup>*</sup></strong><br><small>* Non-refundable</small><br><br>"

	for(var/datum/spellbook_artifact/A in available_artifacts)
		if(!A.can_buy())
			continue

		var/artifact_name = A.name
		var/artifact_desc = A.desc
		var/artifact_price = A.price

		//FORMATTING:
		//<b>Staff of Change</b> (buy for 1 point)
		//<i>(description)</i>

		dat += "<strong>[artifact_name]</strong> ([buy_href_link("\ref[A]", artifact_price, "buy for [artifact_price] point\s")])<br>"
		dat += "<em>[artifact_desc]</em><br><br>"

	dat += "</body>"

	user << browse(dat, "window=spellbook;size=[book_window_size]")
	onclose(user, "spellbook")

/obj/item/weapon/spellbook/proc/get_spell_properties(flags, mob/user)
	var/list/properties = list()

	if(flags & NEEDSCLOTHES)
		var/new_prop = "Requires wizard robes to cast."

		//If user has the robeless spell, strike the text out
		if(user)
			var/is_robeless = locate(/spell/noclothes) in user.spell_list
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

/obj/item/weapon/spellbook/proc/use(amount, no_refunds = 0)
	if(uses >= amount)
		uses -= amount
		if(no_refunds)
			max_uses -= amount

		return 1


/obj/item/weapon/spellbook/proc/refund(mob/user)
	if(!istype(get_area(user), /area/wizard_station))
		to_chat(user, "<span class='notice'>No refunds once you leave your den.</span>")
		return

	uses = max_uses
	user.spellremove()
	to_chat(user, "All spells have been removed. You may now memorize a new set of spells.")

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

			else if(buy_type in get_available_spells())
				var/spell/S = buy_type
				if(use(initial(S.price)))
					var/spell/added = new buy_type
					add_spell(added, L)
					to_chat(usr, "<span class='info'>You have learned [added.name].</span>")
					feedback_add_details("wizard_spell_learned", added.abbreviation)

		else //Passed an artifact reference
			var/datum/spellbook_artifact/SA = locate(href_list["spell"])

			if(istype(SA) && (SA in get_available_artifacts()))
				if(SA.can_buy() && use(SA.price, no_refunds = 1))
					SA.purchased(usr)
					feedback_add_details("wizard_spell_learned", SA.abbreviation)

		attack_self(usr)

	if(href_list["upgrade"])
		var/upgrade_type = href_list["upgrade_type"]
		var/spell/spell = locate(href_list["spell"])

		if(istype(spell) && spell.can_improve(upgrade_type))
			if(use(Sp_UPGRADE_PRICE))
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

//Single Use Spellbooks//
/obj/item/weapon/spellbook/proc/add_spell(var/spell/spell_to_add,var/mob/user)
	if(user.mind)
		if(!user.mind.wizard_spells)
			user.mind.wizard_spells = list()
		user.mind.wizard_spells += spell_to_add
	user.add_spell(spell_to_add)

/obj/item/weapon/spellbook/oneuse
	var/spell = /spell/targeted/projectile/magic_missile //just a placeholder to avoid runtimes if someone spawned the generic
	var/spellname = "sandbox"
	var/used = 0
	name = "spellbook of "
	uses = 1
	max_uses = 1
	desc = "This template spellbook was never meant for the eyes of man..."

/obj/item/weapon/spellbook/oneuse/New()
	..()
	name += spellname

/obj/item/weapon/spellbook/oneuse/attack_self(mob/user as mob)
	var/spell/S = new spell(user)
	for(var/spell/knownspell in user.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				if(user.mind.special_role == "apprentice" || user.mind.special_role == "Wizard")
					to_chat(user, "<span class='notice'>You're already far more versed in this spell than this flimsy how-to book can provide.</span>")
				else
					to_chat(user, "<span class='notice'>You've already read this one.</span>")
			return
	if(used)
		recoil(user)
	else
		user.add_spell(S)
		to_chat(user, "<span class='notice'>you rapidly read through the arcane book. Suddenly you realize you understand [spellname]!</span>")
		user.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.real_name] ([user.ckey]) learned the spell [spellname] ([S]).</font>")
		onlearned(user)

/obj/item/weapon/spellbook/oneuse/proc/recoil(mob/user as mob)
	user.visible_message("<span class='warning'>[src] glows in a black light!</span>")

/obj/item/weapon/spellbook/oneuse/proc/onlearned(mob/user as mob)
	used = 1
	user.visible_message("<span class='caution'>[src] glows dark for a second!</span>")

/obj/item/weapon/spellbook/oneuse/attackby()
	return

/obj/item/weapon/spellbook/oneuse/fireball
	spell = /spell/targeted/projectile/dumbfire/fireball
	spellname = "fireball"
	icon_state ="bookfireball"
	desc = "This book feels warm to the touch."

/obj/item/weapon/spellbook/oneuse/fireball/recoil(mob/user as mob)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
	qdel(src)

/obj/item/weapon/spellbook/oneuse/smoke
	spell = /spell/aoe_turf/smoke
	spellname = "smoke"
	icon_state ="booksmoke"
	desc = "This book is overflowing with the dank arts."

/obj/item/weapon/spellbook/oneuse/smoke/recoil(mob/living/user as mob)
	..()
	to_chat(user, "<span class='caution'>Your stomach rumbles...</span>")
	if(user.nutrition)
		user.nutrition = max(user.nutrition - 200,0)

/obj/item/weapon/spellbook/oneuse/blind
	spell = /spell/targeted/genetic/blind
	spellname = "blind"
	icon_state ="bookblind"
	desc = "This book looks blurry, no matter how you look at it."

/obj/item/weapon/spellbook/oneuse/blind/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You go blind!</span>")
	user.eye_blind = 10

/obj/item/weapon/spellbook/oneuse/mindswap
	spell = /spell/targeted/mind_transfer
	spellname = "mindswap"
	icon_state ="bookmindswap"
	desc = "This book's cover is pristine, though its pages look ragged and torn."
	var/mob/stored_swap = null //Used in used book recoils to store an identity for mindswaps

/obj/item/weapon/spellbook/oneuse/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","horses","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/weapon/spellbook/oneuse/mindswap/recoil(mob/user as mob)
	..()
	if(stored_swap in dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		to_chat(user, "<span class='warning'>For a moment you feel like you don't even know who you are anymore.</span>")
		return
	if(stored_swap == user)
		to_chat(user, "<span class='notice'>You stare at the book some more, but there doesn't seem to be anything else to learn...</span>")
		return

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs -= V

	if(stored_swap.mind.special_verbs.len)
		for(var/V in stored_swap.mind.special_verbs)
			stored_swap.verbs -= V

	var/mob/dead/observer/ghost = stored_swap.ghostize(0)
	ghost.spell_list = stored_swap.spell_list

	user.mind.transfer_to(stored_swap)
	stored_swap.spell_list = user.spell_list

	if(stored_swap.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	ghost.mind.transfer_to(user)
	user.key = ghost.key
	user.spell_list = ghost.spell_list

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	to_chat(stored_swap, "<span class='warning'>You're suddenly somewhere else... and someone else?!</span>")
	to_chat(user, "<span class='warning'>Suddenly you're staring at [src] again... where are you, who are you?!</span>")
	stored_swap = null

/obj/item/weapon/spellbook/oneuse/forcewall
	spell = /spell/aoe_turf/conjure/forcewall
	spellname = "forcewall"
	icon_state ="bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."

/obj/item/weapon/spellbook/oneuse/forcewall/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You suddenly feel very solid!</span>")
	var/obj/structure/closet/statue/S = new /obj/structure/closet/statue(user.loc, user)
	S.timer = 30
	user.drop_item()


/obj/item/weapon/spellbook/oneuse/knock
	spell = /spell/aoe_turf/knock
	spellname = "knock"
	icon_state ="bookknock"
	desc = "This book is hard to hold closed properly."

/obj/item/weapon/spellbook/oneuse/knock/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You're knocked down!</span>")
	user.Weaken(20)

/obj/item/weapon/spellbook/oneuse/horsemask
	spell = /spell/targeted/equip_item/horsemask
	spellname = "horses"
	icon_state ="bookhorses"
	desc = "This book is more horse than your mind has room for."

/obj/item/weapon/spellbook/oneuse/horsemask/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		to_chat(user, "<font size='15' color='red'><b>HOR-SIE HAS RISEN</b></font>")
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.canremove = 0		//curses!
		magichead.voicechange = 1	//NEEEEIIGHH
		user.drop_from_inventory(user.wear_mask)
		user.equip_to_slot_if_possible(magichead, slot_wear_mask, 1, 1)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>I say thee neigh</span>")

/obj/item/weapon/spellbook/oneuse/charge
	spell = /spell/aoe_turf/charge
	spellname = "charging"
	icon_state ="bookcharge"
	desc = "This book is made of 100% post-consumer wizard."

/obj/item/weapon/spellbook/oneuse/charge/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>[src] suddenly feels very warm!</span>")
	empulse(src, 1, 1)

/obj/item/weapon/spellbook/oneuse/clown
	spell = /spell/targeted/equip_item/clowncurse
	spellname = "clowning"
	icon_state = "bookclown"
	desc = "This book is comedy gold!"

/obj/item/weapon/spellbook/oneuse/clown/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		to_chat(user, "<span class ='warning'>You suddenly feel funny!</span>")
		var/obj/item/clothing/mask/gas/clown_hat/magicclown = new /obj/item/clothing/mask/gas/clown_hat/stickymagic
		user.flash_eyes(visual = 1)
		user.dna.SetSEState(CLUMSYBLOCK,1)
		genemutcheck(user,CLUMSYBLOCK,null,MUTCHK_FORCED)
		user.update_mutations()
		user.drop_from_inventory(user.wear_mask)
		user.equip_to_slot_if_possible(magicclown, slot_wear_mask, 1, 1)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/mime
	spell = /spell/targeted/equip_item/frenchcurse
	spellname = "miming"
	icon_state = "bookmime"
	desc = "This book is entirely in french."

/obj/item/weapon/spellbook/oneuse/mime/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		to_chat(user, "<span class ='warning'>You suddenly feel very quiet.</span>")
		var/obj/item/clothing/mask/gas/mime/magicmime = new /obj/item/clothing/mask/gas/mime/stickymagic
		user.flash_eyes(visual = 1)
		user.drop_from_inventory(user.wear_mask)
		user.equip_to_slot_if_possible(magicmime, slot_wear_mask, 1, 1)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/shoesnatch
	spell = /spell/targeted/shoesnatch
	spellname = "shoe snatching"
	icon_state = "bookshoe"
	desc = "This book will knock you off your feet."

/obj/item/weapon/spellbook/oneuse/shoesnatch/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/victim = user
		to_chat(user, "<span class ='warning'>Your feet feel funny!</span>")
		var/obj/item/clothing/shoes/clown_shoes/magicshoes = new /obj/item/clothing/shoes/clown_shoes/stickymagic
		user.flash_eyes(visual = 1)
		user.drop_from_inventory(victim.shoes)
		user.equip_to_slot(magicshoes, slot_shoes, 1, 1)
		qdel(src)


/obj/item/weapon/spellbook/oneuse/robesummon
	spell = /spell/targeted/equip_item/robesummon
	spellname = "robe summoning"
	icon_state = "bookrobe"
	desc = "This book is full of helpful fashion tips for apprentice wizards."

/obj/item/weapon/spellbook/oneuse/robesummon/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/victim = user
		to_chat(user, "<span class ='warning'>You suddenly feel very restrained!</span>")
		var/obj/item/clothing/suit/straight_jacket/magicjacket = new/obj/item/clothing/suit/straight_jacket
		user.drop_from_inventory(victim.wear_suit)
		user.equip_to_slot(magicjacket, slot_wear_suit, 1, 1)
		user.flash_eyes(visual = 1)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/disabletech
	spell = /spell/aoe_turf/disable_tech
	spellname = "disable tech"
	icon_state = "bookdisabletech"
	desc = "This book was written with luddites in mind."

/obj/item/weapon/spellbook/oneuse/disabletech/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.contract_disease(new /datum/disease/robotic_transformation(0), 1)
		to_chat(user, "<span class ='warning'>You feel a closer connection to technology...</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/magicmissle
	spell = /spell/targeted/projectile/magic_missile
	spellname = "magic missle"
	icon_state = "bookmm"
	desc = "This book is a perfect prop for LARPers."

/obj/item/weapon/spellbook/oneuse/magicmissle/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.adjustBrainLoss(100)
		to_chat(user, "<span class = 'warning'>You can't cast this spell when it isn't your turn! 	You feel very stupid.</span>")
		qdel(src)


/obj/item/weapon/spellbook/oneuse/mutate
	spell = /spell/targeted/genetic/mutate
	spellname = "mutating"
	icon_state = "bookmutate"
	desc = "All the pages in this book are ripped."

/obj/item/weapon/spellbook/oneuse/mutate/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.dna.SetSEState(HEADACHEBLOCK,1)
		genemutcheck(user,HEADACHEBLOCK,null,MUTCHK_FORCED)
		user.update_mutations()
		to_chat(user, "<span class = 'warning'>You feel like you've been pushing yourself too hard! </span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/subjugate
	spell = /spell/targeted/subjugation
	spellname = "subjugation"
	icon_state = "booksubjugate"
	desc = "This book makes you feel dizzy."

/obj/item/weapon/spellbook/oneuse/subjugate/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.reagents.add_reagent(RUM, 200)
		to_chat(user, "<span class = 'warning'>You feel very drunk all of a sudden.</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/teleport
	spell = /spell/area_teleport
	spellname = "teleportation"
	icon_state = "booktele"
	desc = "This book will really take you places."

/obj/item/weapon/spellbook/oneuse/teleport/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/h = user
		user.flash_eyes(visual = 1)
		for(var/datum/organ/external/l_leg/E in h.organs)
			E.droplimb(1)
		for(var/datum/organ/external/r_leg/E in h.organs)
			E.droplimb(1)
		to_chat(user, "<span class = 'warning'>Your legs fall off!</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/teleport/blink //sod coding different effects for each teleport spell
	spell = /spell/aoe_turf/blink
	spellname = "blinking"

/obj/item/weapon/spellbook/oneuse/teleport/jaunt
	spell = /spell/targeted/ethereal_jaunt
	spellname = "jaunting"

/obj/item/weapon/spellbook/oneuse/buttbot
	spell = /spell/targeted/buttbots_revenge
	spellname = "ass magic"
	icon_state = "bookbutt"

/obj/item/weapon/spellbook/oneuse/buttbot/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/C = user
		if(C.op_stage.butt != 4)
			var/obj/item/clothing/head/butt/B = new(C.loc)
			B.transfer_buttdentity(C)
			C.op_stage.butt = 4
			to_chat(user, "<span class='warning'>Your ass just blew up!</span>")
		playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1)
		C.apply_damage(40, BRUTE, LIMB_GROIN)
		C.apply_damage(10, BURN, LIMB_GROIN)
		qdel(src)

/obj/item/weapon/spellbook/oneuse/lightning
	spell = /spell/lightning
	spellname = "lightning"
	icon_state = "booklightning"

/obj/item/weapon/spellbook/oneuse/lightning/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.apply_damage(25, BURN, LIMB_LEFT_HAND)
		user.apply_damage(25, BURN, LIMB_RIGHT_HAND)
		to_chat(user, "<span class = 'warning'>The book heats up and burns your hands!</span>")
		qdel(src)

/obj/item/weapon/spellbook/oneuse/timestop
	spell = /spell/aoe_turf/fall
	spellname = "time stopping"
	icon_state = "booktimestop"
	desc = "A rare, vintage copy of 'WizzWizz's Magical Adventures."

/obj/item/weapon/spellbook/oneuse/timestop/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user.stunned = 5
		user.flash_eyes(visual = 1)
		to_chat(user, "<span class = 'warning'>You have been turned into a statue!</span>")
		new /obj/structure/closet/statue(user.loc, user) //makes the statue
		qdel(src)
	return


/obj/item/weapon/spellbook/oneuse/timestop/statute //recoil effect is same as timestop effect so this is a child
	spell = /spell/targeted/flesh_to_stone
	spellname = "sculpting"
	icon_state = "bookstatue"
	desc = "This book is as dense as a rock."

// Spell Book Bundles//

/obj/item/weapon/storage/box/spellbook
	name = "Spellbook Bundle"
	desc = "High quality discount spells! This bundle is non-refundable. The end user is solely liable for any damages arising from misuse of these products."

/obj/item/weapon/storage/box/spellbook/New()
	..()
	var/list/possible_books = typesof(/obj/item/weapon/spellbook/oneuse)
	possible_books -= /obj/item/weapon/spellbook/oneuse
	possible_books -= /obj/item/weapon/spellbook/oneuse/charge
	for(var/i =1; i <= 7; i++)
		var/randombook = pick(possible_books)
		var/book = new randombook(src)
		src.contents += book
		possible_books -= randombook
