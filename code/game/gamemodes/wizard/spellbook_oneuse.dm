//Single Use Spellbooks//
/obj/item/weapon/spellbook/proc/add_spell(var/spell/spell_to_add,var/mob/user)
	user.add_spell(spell_to_add, iswizard = TRUE)

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

//It crashed clients
/obj/item/weapon/spellbook/oneuse/mindswap/recoil(var/mob/user)
	qdel(src)

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
	user.Knockdown(20)

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

/obj/item/weapon/spellbook/oneuse/mutate/highlander //for highlander uplink bundle
	spell =/spell/targeted/genetic/mutate/highlander
	spellname  = "highlander power"
	icon_state = "bookhighlander"
	desc = "You can hear the bagpipes playing already."

/obj/item/weapon/spellbook/oneuse/disorient
	spell = /spell/targeted/disorient
	spellname = "disorient"
	icon_state = "bookdisorient"
	desc = "This book makes you feel dizzy."

/obj/item/weapon/spellbook/oneuse/disorient/recoil(mob/living/carbon/user as mob)
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
		var/mob/living/carbon/human/H = user
		user.flash_eyes(visual = 1)

		for(var/datum/organ/external/E in H.get_organs(LIMB_LEFT_LEG, LIMB_RIGHT_LEG))
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
		playsound(src, 'sound/effects/superfart.ogg', 50, 1)
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

/obj/item/weapon/spellbook/oneuse/lightning/sith
	spell = /spell/lightning/sith
	spellname = "sith lightning"
	desc = "You can faintly hear it yell 'UNLIMITED POWER'."

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

/obj/item/weapon/spellbook/oneuse/ringoffire
	spell = /spell/aoe_turf/ring_of_fire
	spellname = "ring of fire"
	icon_state = "bookring"
	desc = "The cover of this book is much warmer than the pages within."

/obj/item/weapon/spellbook/oneuse/ringoffire/recoil(mob/living/carbon/user as mob)
	user.adjust_fire_stacks(10)
	user.IgniteMob()
	to_chat(user, "<span class = 'warning'>The book sets you alight!</span>")

/obj/item/weapon/spellbook/oneuse/mirror_of_pain
	spell = /spell/mirror_of_pain
	spellname = "pain mirror"
	icon_state = "bookmirror"
	desc = "The cover of the book seems to stare back at you."

/obj/item/weapon/spellbook/oneuse/mirror_of_pain/recoil(mob/living/carbon/user as mob)
	scramble(1, user, 100)
	to_chat(user, "<span class = 'warning'>Your reflection becomes warped and distorted!</span>")

/obj/item/weapon/spellbook/oneuse/bound_object
	spell = /spell/targeted/bound_object
	spellname = "binding"
	icon_state = "bookbound"
	desc = "This book seems like it's already in your hands."

/obj/item/weapon/spellbook/oneuse/bound_object/recoil(mob/living/carbon/user as mob)
	to_chat(user, "<span class = 'warning'>Your surroundings are drawn to you!</span>")
	var/counter = 0
	for(var/obj/item/I in oview(5))
		if(!I.anchored && counter <= 10)
			sleep(1)
			I.throw_at(user, 16, 2)
			counter++

/obj/item/weapon/spellbook/oneuse/arcane_golem
	spell = /spell/aoe_turf/conjure/arcane_golem
	spellname = "forge arcane golem"
	icon_state = "bookgolem"
	desc = "This book has several completely blank pages."

/obj/item/weapon/spellbook/oneuse/firebreath
	spell = /spell/targeted/projectile/dumbfire/fireball/firebreath
	spellname = "fire breath"
	icon_state = "bookfirebreath"
	desc = "This book's pages are singed."

/obj/item/weapon/spellbook/oneuse/firebreath/recoil(mob/living/carbon/user)
	to_chat(user, "<span class = 'warning'>You burst into flames!</span>")
	user.adjust_fire_stacks(0.5)
	user.IgniteMob()

/obj/item/weapon/spellbook/oneuse/snakes
	spell = /spell/aoe_turf/conjure/snakes
	spellname = "become snakes"
	icon_state = "booksnakes"
	desc = "This book is bound in snake skin."

/obj/item/weapon/spellbook/oneuse/snakes/recoil(mob/living/carbon/user)
	to_chat(user, "<span class = 'warning'>You transform into a snake!</span>")
	user.transmogrify(/mob/living/simple_animal/cat/snek/wizard, TRUE)
	spawn(600)
		user.transmogrify()

/obj/item/weapon/spellbook/oneuse/push
	spell = /spell/targeted/push
	spellname = "dimensional push"
	icon_state = "bookpush"
	desc = "This book seems like it moves away as you get closer to it."

/obj/item/weapon/spellbook/oneuse/push/recoil(mob/living/carbon/user)
	user.drop_item(src, force_drop = 1)	//no taking the transportation device with you
	to_chat(user, "<span class = 'warning'>You are pushed away by \the [src]!</span>")
	var/area/thearea
	var/area/prospective = pick(areas)
	while(!thearea)
		if(prospective.type != /area)
			var/turf/T = pick(get_area_turfs(prospective.type))
			if(T.z != 2)
				thearea = prospective
				break
		prospective = pick(areas)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		to_chat(user, "Oh wait, nothing happened.")
		return

	user.unlock_from()
	var/attempt = null
	var/success = 0
	while(L.len)
		attempt = pick(L)
		success = user.Move(attempt)
		if(!success)
			L.Remove(attempt)
		else
			break
	if(!success)
		user.forceMove(pick(L))

/obj/item/weapon/spellbook/oneuse/pie
	spell = /spell/targeted/projectile/pie
	spellname = "Summon Pastry"
	icon_state = "cooked_bookold"
	desc = "This book smells lightly of lemon meringue."

/obj/item/weapon/spellbook/oneuse/pie/recoil(mob/living/carbon/user)
	..()
	var/pie_to_spawn = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/pie))
	var/turf/T = get_turf(pick(oview(1, user)))
	var/obj/pie = new pie_to_spawn(T)
	spawn()
		pie.throw_at(user, get_dist(pie,user),rand(40,90))

/obj/item/weapon/spellbook/oneuse/ice_barrage
	spell = /spell/targeted/ice_barrage
	spellname = "Ice Barrage"
	desc = "Cold to the touch."
	icon_state = "bookAncient"

/obj/item/weapon/spellbook/oneuse/ice_barrage/recoil(mob/living/carbon/user)
	..()
	playsound(user, 'sound/effects/ice_barrage.ogg', 50, 100, extrarange = 3, gas_modified = 0)
	new /obj/structure/ice_block(user.loc, user, 30 SECONDS)


///// ANCIENT SPELLBOOK /////

/obj/item/weapon/spellbook/oneuse/ancient //the ancient spellbook contains weird and dangerous spells that aren't otherwise available to purchase, only available via the spellbook bundle
	var/list/possible_spells = list(/spell/targeted/disintegrate, /spell/targeted/parrotmorph, /spell/aoe_turf/conjure/spares, /spell/targeted/balefulmutate)
	spell = null
	icon_state = "book"
	desc = "A book of lost and forgotten knowledge"
	spellname = "forgotten knowledge"

/obj/item/weapon/spellbook/oneuse/ancient/New()
	..()
	spell = pick(possible_spells)

/obj/item/weapon/spellbook/oneuse/ancient/recoil(mob/living/carbon/user)
	to_chat(user, "<span class = 'sinister'>You shouldn't attempt to steal ancient knowledge!</span>")
	user.gib()
	qdel(src)

///// WINTER SPELLBOOK /////

/obj/item/weapon/spellbook/oneuse/ancient/winter //the winter spellbook contains spells that would otherwise only be available at christmas
	possible_spells = list(/spell/targeted/wrapping_paper, /spell/targeted/equip_item/clowncurse/christmas, /spell/aoe_turf/conjure/snowmobile, /spell/targeted/equip_item/horsemask/christmas)
	icon_state = "winter"
	desc = "A book of festive knowledge"
	spellname = "winter"

/obj/item/weapon/spellbook/oneuse/ancient/recoil(mob/living/carbon/user)
	to_chat(user, "<span class = 'sinister'>You shouldn't attempt to steal from santa!</span>")
	user.gib()
	qdel(src)