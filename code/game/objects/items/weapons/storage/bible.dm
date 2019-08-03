/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage/bibles.dmi'
	icon_state = "bible"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/books.dmi', "right_hand" = 'icons/mob/in-hand/right/books.dmi')
	item_state = "bible"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	force = 2.5 //A big book, solely used for non-Chaplains trying to use it on people
	flags = FPRINT
	attack_verb = list("whacks", "slaps", "slams", "forcefully blesses")
	var/mob/affecting = null
	var/datum/religion/my_rel = new /datum/religion
	actions_types = list(/datum/action/item_action/convert)
	rustle_sound = "pageturn"

	autoignition_temperature = 522 // Kelvin
	fire_fuel = 2

/obj/item/weapon/storage/bible/suicide_act(mob/living/user)
	user.visible_message("<span class='danger'>[user] is farting on \the [src]! It looks like \he's trying to commit suicide!</span>")
	user.emote("fart")
	spawn(10) //Wait for it
		user.fire_stacks += 5
		user.IgniteMob()
		user.audible_scream()
		return SUICIDE_ACT_FIRELOSS //Set ablaze and burned to crisps

//"Special" Bible with a little gift on introduction
/obj/item/weapon/storage/bible/booze

	autoignition_temperature = 0 //Not actually paper
	fire_fuel = 0

/obj/item/weapon/storage/bible/booze/New()
	. = ..()
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)

//Even more "Special" Bible with a nicer gift on introduction
/obj/item/weapon/storage/bible/traitor_gun

	autoignition_temperature = 0 //Not actually paper
	fire_fuel = 0

/obj/item/weapon/storage/bible/traitor_gun/New()
	. = ..()
	new /obj/item/weapon/gun/projectile/luger/small(src)
	new /obj/item/ammo_storage/magazine/mc9mm(src)

//What happens when you slap things with the Bible in general
/obj/item/weapon/storage/bible/attack(mob/living/M as mob, mob/living/user as mob)

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	var/datum/role/vampire/V = isvampire(user)

	if (!my_rel.leadsThisReligion(user)) //The user is not the leader of this religon. BLASPHEMY !
		//Using the Bible as a member of the occult will get you smithed, aka holy cleansing fire. You'd have to be stupid to remotely consider it
		if(V) //Vampire trying to use it
			to_chat(user, "<span class='danger'>[my_rel.deity_name] channels through \the [src] and sets you ablaze for your blasphemy!</span>")
			user.fire_stacks += 5
			user.IgniteMob()
			user.audible_scream()
			V.smitecounter += 50 //Once we are extinguished, we will be quite vulnerable regardless
		else if(isanycultist(user)) //Cultist trying to use it
			to_chat(user, "<span class='danger'>[my_rel.deity_name] channels through \the [src] and sets you ablaze for your blasphemy!</span>")
			user.fire_stacks += 5
			user.IgniteMob()
			user.audible_scream()
		else //Literally anyone else than a Cultist using it, at this point it's just a big book
			..() //WHACK
		return 1 //Non-religious leaders can't use the holy book, at least not properly

	if(clumsy_check(user) && prob(50)) //Using it while clumsy, let's have some fun
		user.visible_message("<span class='warning'>\The [src] slips out of [user]'s hands and hits \his head.</span>",
		"<span class='warning'>\The [src] slips out of your hands and hits your head.</span>")
		user.apply_damage(10, BRUTE, LIMB_HEAD)
		user.Stun(5)
		return 1

	//From this point onwards we are done with the user, let's check whoever is on the receiving end
	//Let us also note that if we made it this far, the user IS a religious leader. No need to check
	//Worthy of note, blessings are done on craniums. I guess this is the best way to send the message across

	if(M == user) //We are trying to smack ourselves
		return 1 //That's dumb, don't do it

	if(ishuman(M)) //We're forced to do two ishuman() code paragraphs because this one blocks the others
		var/mob/living/carbon/human/H = M
		if(istype(H.head, /obj/item/clothing/head/helmet) || istype(H.head, /obj/item/clothing/head/hardhat) || istype(H.head, /obj/item/clothing/head/fedora) || istype(H.head, /obj/item/clothing/head/legacy_culthood)) //Blessing blocked
			user.visible_message("<span class='warning'>[user] [pick(attack_verb)] [H]'s head with \the [src], but their headgear blocks the hit.</span>",
			"<span class='warning'>You try to bless [H]'s head with \the [src], but their headgear blocks the blessing. Blasphemy!</span>")
			return 1 //That's it. Helmets are very haram

	if(M.stat == DEAD) //Our target is dead. RIP in peace
		user.visible_message("<span class='warning'>[user] [pick(attack_verb)] [M]'s lifeless body with \the [src].</span>",
		"<span class='warning'>You bless [M]'s lifeless body with \the [src], trying to conjure [my_rel.deity_name]'s mercy on them.</span>")
		playsound(src, "punch", 25, 1, -1)

		//TODO : Way to bring people back from death if they are your followers
		return 1 //Otherwise, there's so little we can do

	//Our target is alive, prepare the blessing
	user.visible_message("<span class='warning'>[user] [pick(attack_verb)] [M]'s head with \the [src].</span>",
	"<span class='warning'>You bless [M]'s head with \the [src]. In the name of [my_rel.deity_name], bless thee!</span>")
	playsound(src, "punch", 25, 1, -1)

	if(ishuman(M)) //Only humans can be vampires or cultists.
		var/mob/living/carbon/human/H = M
		V = isvampire(M)
		if(V && (VAMP_MATURE in V.powers) && my_rel.leadsThisReligion(user)) //The user is a "mature" Vampire, fuck up his vampiric powers and hurt his head
			to_chat(H, "<span class='warning'>[my_rel.deity_name]'s power nullifies your own!</span>")
			if(V.nullified < 5) //Don't actually reduce their debuff if it's over 5
				V.nullified = min(5, V.nullified + 2)
			V.smitecounter += 10 //Better get out of here quickly before the problem shows. Ten hits and you are literal toast
			return 1 //Don't heal the mob
		var/datum/role/thrall/T = isthrall(H)
		if(T && my_rel.leadsThisReligion(user))
			T.Drop(TRUE) // Remove the thrall using the Drop() function to leave the role.
			return 1 //That's it, game over

		bless_mob(user, H) //Let's outsource the healing code, because we can

//Bless thee. Heals followers fairly, potentially heals everyone a bit (or gives them brain damage)
/obj/item/weapon/storage/bible/proc/bless_mob(mob/living/carbon/human/user, mob/living/carbon/human/H)
	var/datum/organ/internal/brain/sponge = H.internal_organs_by_name["brain"]
	if(sponge && sponge.damage >= 60) //Massive brain damage
		to_chat(user, "<span class='warning'>[H] responds to \the [src]'s blessing with drooling and an empty stare. [my_rel.deity_name]'s teachings appear to be lost on this poor soul.</span>")
		return //Brainfart
	//TODO: Put code for followers right here
	if(prob(20)) //1/5 chance of adding some brain damage. You can't just heal people for free
		H.adjustBrainLoss(5)
	if(prob(50)) //1/2 chance of healing at all
		for(var/datum/organ/external/affecting in H.organs)
			if(affecting.heal_damage(5, 5)) //5 brute and burn healed per bash. Not wonderful, but it can help if someone has Alkyzine handy
				H.UpdateDamageIcon()
	return //Nothing else to add

//We're done working on mobs, let's check if we're blessing something else
/obj/item/weapon/storage/bible/afterattack(var/atom/A, var/mob/user, var/proximity_flag)
	if(!proximity_flag)
		return
	user.delayNextAttack(5)
	if(my_rel.leadsThisReligion(user)) //Make sure we still are a religious leader, just in case
		if(A.reagents && A.reagents.has_reagent(WATER)) //Blesses all the water in the holder
			user.visible_message("<span class='notice'>[user] blesses \the [A].</span>",
			"<span class='notice'>You bless \the [A].</span>")
			//Ugly but functional conversion proc
			var/water2holy = A.reagents.get_reagent_amount(WATER)
			A.reagents.del_reagent(WATER)
			A.reagents.add_reagent(HOLYWATER, water2holy)

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(src, "rustle", 50, 1, -5)
	. = ..()

/obj/item/weapon/storage/bible/pickup(mob/living/user as mob)
	if(my_rel.leadsThisReligion(user)) //We are the religious leader, yes we are
		to_chat(user, "<span class ='notice'>You feel [my_rel.deity_name]'s holy presence as you pick up \the [src].</span>")
	if(ishuman(user)) //We are checking for antagonists, only humans can be antagonists
		var/mob/living/carbon/human/H = user
		var/datum/role/vampire/V = isvampire(H)
		var/datum/role/cultist/C = isanycultist(H)
		if(V && (!(VAMP_UNDYING in V.powers))) //We are a Vampire, we aren't very smart
			to_chat(H, "<span class ='danger'>[my_rel.deity_name]'s power channels through \the [src]. You feel extremely uneasy as you grab it!</span>")
			V.smitecounter += 10
		if(C) //We are a Cultist, we aren't very smart either, but at least there will be no consequences for us
			to_chat(H, "<span class ='danger'>[my_rel.deity_name]'s power channels through \the [src]. You feel uneasy as you grab it, but Nar-Sie protects you from its influence!</span>")

// Action : convert people

/datum/action/item_action/convert
	name = "Convert people"
	desc = "Convert someone next to you."

/datum/action/item_action/convert/Trigger()
	var/obj/item/weapon/storage/bible/B = target

	if (owner.incapacitated() || owner.lying || owner.locked_to || !ishigherbeing(owner)) // Sanity
		return FALSE
	if (!owner.mind.faith)
		to_chat(usr, "<span class='warning'> You do not have a religion to convert people to.</span>")
		return FALSE

	var/list/mob/moblist = list()
	for (var/mob/living/carbon/human/H in range(1, owner))
		moblist += H
	moblist -= owner

	var/mob/living/subject = input(owner, "Who do you wish to convert?", "Religious converting") as null|mob in moblist

	if (!subject)
		to_chat(owner, "<span class='warning'>No target selected.</span>")
		return FALSE

	if (subject.incapacitated() || subject.lying || subject.locked_to || !ishigherbeing(subject) || !subject.mind) // Sanity
		to_chat(owner, "<span class='warning'> \The [subject] does not seem receptive to conversion.</span>")
	else
		owner.mind.faith.convertAct(owner, subject, B) // usr = preacher ; target = subject
		return TRUE
