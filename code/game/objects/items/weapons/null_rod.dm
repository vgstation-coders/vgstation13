/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = W_CLASS_TINY
	mech_flags = MECH_SCAN_ILLEGAL // FUCK MECHANICS
	var/reskinned = FALSE
	var/reskin_selectable = TRUE // set to FALSE if a subtype is meant to not normally be available as a reskin option (fluff ones will get re-added through their list)
	var/list/fluff_transformations = list() //does it have any special transformations only accessible to it? Should only be subtypes of /obj/item/weapon/nullrod
	var/fluff_pickup = "pulverize"

/obj/item/weapon/nullrod/suicide_act(var/mob/living/user)
	user.visible_message("<span class='danger'>[user] is impaling \himself with \the [src]! It looks like \he's trying to commit suicide.</span>")
	return (SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_FIRELOSS)

/obj/item/weapon/nullrod/attack(mob/M as mob, mob/living/user as mob)

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	M.assaulted_by(user)

	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	if(!ishigherbeing(user) && !isbadmonkey(user)) //Fucks sakes
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(clumsy_check(user) && prob(50))
		user.visible_message("<span class='warning'>\The [src] slips out of [user]'s hands and hits \his head.</span>",
		"<span class='warning'>\The [src] slips out of your hands and hits your head.</span>")
		user.apply_damage(10, BRUTE, LIMB_HEAD)
		user.Stun(5)
		return

	if(ishuman(M)) //Typecasting, only humans can be vampires
		var/mob/living/carbon/human/H = M

		var/datum/role/vampire/V = isvampire(H)

		if(V && isReligiousLeader(user)) //Fuck up vampires by smiting the shit out of them. Shock and Awe!
			if(locate(/datum/power/vampire/mature) in V.current_powers)
				to_chat(H, "<span class='warning'>\The [src]'s power violently interferes with your own!</span>")
				if(V.nullified < 5) //Don't actually reduce their debuff if it's over 5
					V.nullified = min(5, V.nullified + 2)
				V.smitecounter += 30 //Smite the shit out of him. Four strikes and he's out

	. = ..() //Whack their shit regardless. It's an obsidian rod, it breaks skulls

/obj/item/weapon/nullrod/afterattack(var/atom/A, var/mob/user, var/prox_flag, var/params)
	if(!prox_flag)
		return
	if(istype(A, /turf/simulated/floor))
		if (user.a_intent != I_HELP) //We assume the user is fighting
			to_chat(user, "<span class='notice'>You swing \the [src] in front of you.</span>")
			return
		var/atom/movable/overlay/animation = anim(target = A, a_icon = 'icons/effects/96x96.dmi', a_icon_state = "nullcheck", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE, offY = -WORLD_ICON_SIZE, plane = ABOVE_LIGHTING_PLANE)
		animation.alpha = 0
		animate(animation, alpha = 255, time = 2)
		animate(alpha = 0, time = 3)
		user.delayNextAttack(8)
		to_chat(user, "<span class='notice'>You hit \the [A] with \the [src].</span>")
		var/found = 0
		for(var/obj/effect/rune/R in range(1,A))
			found = 1
			R.reveal()
		if (found)
			to_chat(user, "<span class='warning'>Arcane markings suddenly glow from underneath a thin layer of dust!</span>")
		found = 0
		for(var/obj/structure/cult/S in range(1,A))
			found = 1
			S.reveal()
		if (found)
			to_chat(user, "<span class='warning'>A structure suddenly emerges from the ground!</span>")
		call(/obj/effect/rune_legacy/proc/revealrunes)(src)//revealing legacy runes as well because why not

/obj/item/weapon/nullrod/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	target.arcane_message(user)
	return ..()

/atom/proc/arcane_message(mob/user)
	if(arcanetampered)
		to_chat(user, "<span class='sinister'>\The [src] has an arcane aura to it!</span>")
		if(contents.len)
			to_chat(user, "<span class='sinister'>And inside \the [src]...</span>")
			for(var/atom/A in src)
				. |= A.arcane_message(user)
			if(!.)
				to_chat(user, "<span class='notice'>Nothing of note.</span>")
		. = 1


/obj/item/weapon/nullrod/pickup(mob/living/user as mob)
	if(user.mind)
		if(isReligiousLeader(user))
			to_chat(user, "<span class='notice'>\The [src] is teeming with divine power. You feel like you could [fluff_pickup] a horde of undead with this.</span>")
		if(ishuman(user)) //Typecasting, only humans can be vampires
			var/datum/role/vampire/V = isvampire(user)
			if(V && !(locate(/datum/power/vampire/undying) in V.current_powers))
				V.smitecounter += 60
				to_chat(user, "<span class='danger'>You feel an unwanted presence as you pick up the rod. Your body feels like it is burning from the inside!</span>")

/obj/item/weapon/nullrod/attack_self(mob/user)
	if(reskinned)
		return
	if(isReligiousLeader(user))
		reskin_holy_weapon(user)

/obj/item/weapon/nullrod/proc/reskin_holy_weapon(mob/living/M)
	var/list/holy_weapons_list = typesof(/obj/item/weapon/nullrod)
	for(var/entry in holy_weapons_list)
		var/obj/item/weapon/nullrod/variant = entry
		if(!initial(variant.reskin_selectable))
			holy_weapons_list -= variant
	if(fluff_transformations.len)
		for(var/thing in fluff_transformations)
			holy_weapons_list += thing
	var/list/display_names = list()
	for(var/V in holy_weapons_list)
		var/atom/A = V
		display_names += initial(A.name)

	var/choice = input(M,"What theme would you like for your holy weapon?","Holy Weapon Theme") as null|anything in display_names
	if(!src || !choice || !in_range(M, src) || M.incapacitated() || reskinned)
		return

	var/index = display_names.Find(choice)
	var/A = holy_weapons_list[index]

	var/obj/item/weapon/nullrod/holy_weapon = new A

	feedback_set_details("chaplain_weapon","[choice]")

	if(holy_weapon)
		visible_message("<span class='notice'>[M.name] invokes the power of [ticker.Bible_deity_name] to transform \the [src] into \a [holy_weapon.name]!</span>")
		holy_weapon.reskinned = TRUE
		M.drop_item(src, force_drop = TRUE)
		M.put_in_active_hand(holy_weapon)
		qdel(src)

/obj/item/weapon/nullrod/sword
	name = "holy avenger"
	desc = "DEUS VULT!"
	icon_state = "avenger"
	item_state = "avenger"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	w_class = W_CLASS_LARGE
	slot_flags = SLOT_BACK|SLOT_BELT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	fluff_pickup = "dice"

/obj/item/weapon/nullrod/sword/IsShield()
	return prob(10) //Only TRIES to block 10% of the attacks. SO MANY LAYERS OF RNG but hey.

/obj/item/weapon/nullrod/sword/cult //Muh cult religion.
	name = "cult blade"
	desc = "Spread the glory of the blood god!"
	icon_state = "cultblade"
	item_state = "cultblade"

/obj/item/weapon/nullrod/sword/katana //*tips fedora*
	name = "saint katana"
	desc = "This weapon can cut clean through plasteel because its blade was folded over a thousand times, making it vastly superior to any other holy weapon."
	icon_state = "katana"
	item_state = "katana"
	fluff_pickup = "bisect"


/obj/item/weapon/nullrod/toolbox //Syndicate/Robust religion
	name = "nullbox"
	desc = "The holder of nothingness. If your holy book isn't working, try this one instead."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "toolbox_syndi"
	item_state = "toolbox_syndi"
	hitsound = 'sound/weapons/toolbox.ogg'
	attack_verb = list("robusts", "batters", "staves in")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/toolbox_ihl.dmi', "right_hand" = 'icons/mob/in-hand/right/toolbox_ihr.dmi')
	w_class = W_CLASS_LARGE
	fluff_pickup = "robust"

/obj/item/weapon/nullrod/crozius //The Imperial Creed
	name = "\improper Crozius Arcanum"
	desc = "Repent! For tomorrow you die!"
	icon_state = "crozius"
	item_state = "crozius"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	attack_verb = list("mauls", "batters", "bashes")
	w_class = W_CLASS_LARGE

/obj/item/weapon/nullrod/spear //Ratvar? How!
	name = "divine brass spear"
	desc = "A holy, bronze weapon of ancient design."
	hitsound = 'sound/weapons/bladeslice.ogg'
	icon_state = "clockwork0"
	item_state = "clockwork0"
	attack_verb = list("stabs", "pokes", "pierces", "cuts")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	w_class = W_CLASS_LARGE
	flags = TWOHANDABLE | FPRINT
	fluff_pickup = "skewer"

/obj/item/weapon/nullrod/spear/update_wield(var/mob/user)
	icon_state = "clockwork[wielded ? 1 : 0]"
	item_state = icon_state
	if(user)
		user.update_inv_hands()

/obj/item/weapon/nullrod/spear/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/weapon/nullrod/staff //Wizard religion
	name = "staff of nullmancy"
	desc = "A wicked looking staff that pulses with holy energy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostaff"
	item_state = "necrostaff"
	w_class = W_CLASS_LARGE
	fluff_pickup = "banish"

/obj/item/weapon/nullrod/chain //Comdom religion
	name = "heavenly chain"
	desc = "A holy tool used by chaplains to placate the heretic masses."
	icon_state = "chain"
	item_state = "chain"
	hitsound = "sound/weapons/whip.ogg"
	slot_flags = SLOT_BELT
	w_class = W_CLASS_MEDIUM
	attack_verb = list("flogs", "whips", "lashes", "disciplines")
	fluff_pickup = "dominate"

/obj/item/weapon/nullrod/honk //CLown religion
	name = "honk rod"
	desc = "A holy rod for honking people with."
	icon = 'icons/obj/weapons.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "honkbaton"
	item_state = "honkbaton"
	w_class = W_CLASS_MEDIUM
	hitsound = 'sound/items/bikehorn.ogg'
	attack_verb = list("HONKS")
	fluff_pickup = "prank"

/obj/item/weapon/nullrod/baguette //Mime religion
	name = "french rod"
	desc = "It's not edible food."
	icon = 'icons/obj/food.dmi'
	icon_state = "baguette"
	item_state = "baguette"
	w_class = W_CLASS_MEDIUM
	fluff_pickup = "retreat from"

/obj/item/weapon/nullrod/cane
	name = "blessed cane"
	desc = "A holy cane used by chaplains. Not very good at supporting body weight."
	icon_state = "cane"
	item_state = "stick"
	w_class = W_CLASS_SMALL
	attack_verb = list("bludgeons", "whacks", "disciplines", "thrashes")

/obj/item/weapon/nullrod/morningstar
	name = "septerion morningstar"
	desc = "A ritualistic mace with a round, spiky end. Very heavy."
	icon_state = "morningstar"
	item_state = "morningstar"
	hitsound = 'sound/weapons/heavysmash.ogg'
	w_class = W_CLASS_LARGE
	attack_verb = list("bashes", "smashes", "pulverizes")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	fluff_pickup = "smite"


/obj/item/weapon/nullrod/vampkiller
	name = "holy whip"
	desc = "A brutal looking, holy weapon consisting of a morning star head attached to a chain lash. The chain on this one seems a bit shorter than described in legend."
	icon_state = "vampkiller"
	item_state = "vampkiller"
	hitsound = 'sound/weapons/vampkiller.ogg'
	w_class = W_CLASS_MEDIUM
	attack_verb = list("bashes", "smashes", "pulverizes")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	fluff_pickup = "smite"
	slot_flags = SLOT_BELT


/obj/item/weapon/nullrod/mosinnagant
	name = "mosin nagant"
	desc = "Many centuries later, it's still drenched in cosmoline, just like the Murdercube intended. This one cannot be fired."
	icon = 'icons/obj/biggun.dmi'
	icon_override = "mosinlarge"
	icon_state = "mosinlarge"
	item_state = "mosinlarge"
	slot_flags = SLOT_BELT | SLOT_BACK
	w_class = W_CLASS_LARGE
	attack_verb = list("bashes", "smashes", "buttstrokes")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')

/obj/item/weapon/nullrod/mosinnagant/attackby(var/obj/item/A, mob/living/user)
	..()
	if(istype(A, /obj/item/tool/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>You begin to shorten the barrel of \the [src].</span>")
		if(do_after(user, src, 30))
			new /obj/item/weapon/nullrod/mosinnagant/obrez(get_turf(src))
			qdel(src)
			to_chat(user, "<span class='warning'>You shorten the barrel of \the [src]!</span>")

/obj/item/weapon/nullrod/mosinnagant/obrez
	name = "obrez"
	desc = "Holding this makes you feel like you want to obtain an SKS and go deeper in space. This one cannot be fired."
	icon = 'icons/obj/biggun.dmi'
	icon_override = "obrezlarge"
	icon_state = "obrezlarge"
	item_state = "obrezlarge"
	slot_flags = SLOT_BELT
	w_class = W_CLASS_MEDIUM
	attack_verb = list("bashes", "smashes", "pistol-whips", "clubs")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')

/obj/item/weapon/nullrod/mosinnagant/obrez/attackby(var/obj/item/A, mob/living/user)
    if (istype(A, /obj/item/tool/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
        return
    else
        return ..()

/obj/item/weapon/nullrod/loop //loop religion
	name = "rewind rifle"
	desc = "The incarnation of looping in gun form. The shooting mechanism has been replaced with looping machinery and will only fire when the Loop happens."
	icon = 'icons/obj/gun.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	icon_state = "xcomlasergun"
	item_state = "xcomlasergun"
	w_class = W_CLASS_MEDIUM
	hitsound = 'sound/effects/fall.ogg'
	attack_verb = list("loops")
	fluff_pickup = "loop"

// The chaos blade, a ghost role talking sword. Unlike the nullrod skins this thing works as a proper shield and has sharpness.
/obj/item/weapon/nullrod/sword/chaos
	name = "chaos blade"
	desc = "Considered a 'cursed blade' legend says that anyone that tries to wield it end corrupted by chaos. It has three yellow eyes, two near the base of the hilt and one at the pommel, and a decorative jewel between its eyes."
	icon_state = "talking_sword"
	item_state = "talking_sword"
	sharpness_flags = SHARP_TIP |SHARP_BLADE
	sharpness = 1.5
	var/datum/recruiter/recruiter = null
	var/possessed = FALSE
	var/awakening = FALSE
	var/last_ping_time = 0
	var/ping_cooldown = 5 SECONDS
	reskin_selectable = FALSE //No fun allowed.

/obj/item/weapon/nullrod/sword/chaos/attack_self(mob/living/user)
	if(possessed)
		return

	awaken()


/obj/item/weapon/nullrod/sword/chaos/proc/awaken()
	if(awakening)
		return
	awakening = TRUE
	icon_state = "[initial(icon_state)]_a"
	visible_message("<span class='notice'>\The [name] shakes vigorously!</span>")
	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = name
		recruiter.role = ROLE_BORER //Uses the borer pref because preferences are scary and i don't want to touch them.
		recruiter.jobban_roles = list("pAI") // pAI/Borers share the same jobban check so here we go too.

	// Role set to Yes or Always
	recruiter.player_volunteering = new /callback(src, nameof(src::recruiter_recruiting()))
	// Role set to No or Never
	recruiter.player_not_volunteering = new /callback(src, nameof(src::recruiter_not_recruiting()))

	recruiter.recruited = new /callback(src, nameof(src::recruiter_recruited()))

	recruiter.request_player()

/obj/item/weapon/nullrod/sword/chaos/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\The [name] is awakening. You have been added to the list of potential ghosts. ([controls])</span>")

/obj/item/weapon/nullrod/sword/chaos/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class='recruit'>\The [src] is awakening. ([controls])</span>")


/obj/item/weapon/nullrod/sword/chaos/proc/recruiter_recruited(mob/dead/observer/player)
	if(player)
		possessed = TRUE
		QDEL_NULL(recruiter)
		awakening = FALSE
		visible_message("<span class='notice'>\The [name] awakens!</span>")
		var/mob/living/simple_animal/shade/sword/S = new(src)
		S.real_name = name
		S.name = name
		S.ckey = player.ckey
		S.universal_speak = TRUE
		S.universal_understand = TRUE
		S.status_flags |= GODMODE //Make sure they can NEVER EVER leave the blade.
		to_chat(S, "<span class='info'>You open your eyes and find yourself in a strange, unknown location with no recollection of your past.</span>")
		to_chat(S, "<span class='info'>Despite being a sword, you have the ability to speak, as well as an abnormal desire for slicing and killing evil beings.</span>")
		to_chat(S, "<span class='info'>Unable to do anything by yourself, you need a wielder. Find someone with a strong will and become their strength so you may finally satiate your desires.</span>")
		var/input = copytext(sanitize(input(S, "What should i call myself?","Name") as null|text), TRUE, MAX_MESSAGE_LEN)

		if(src && input)
			name = input
			S.real_name = input
			S.name = input
	else
		awakening = FALSE
		icon_state = initial(icon_state)
		visible_message("<span class='notice'>\The [name] calms down.</span>")

/obj/item/weapon/nullrod/sword/chaos/Destroy()
	for(var/mob/living/simple_animal/shade/sword/S in contents)
		to_chat(S, "You were destroyed!")
		qdel(S)
	if(recruiter)
		QDEL_NULL(recruiter)
	..()

/obj/item/weapon/nullrod/sword/chaos/attack_ghost(var/mob/dead/observer/O)
	if(possessed)
		return
	if(last_ping_time + ping_cooldown <= world.time)
		last_ping_time = world.time
		awaken()
	else
		to_chat(O, "\The [name]'s power is low. Try again in a few moments.")

/obj/item/weapon/nullrod/sword/chaos/IsShield()
	return TRUE
