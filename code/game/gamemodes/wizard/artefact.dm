///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	var/charged = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/rendtype = /obj/effect/rend

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	anchored = 1.0
	var/mobsleft = 20
	var/mobtype = /mob/living/simple_animal/hostile/creature

/obj/effect/rend/New()
	processing_objects.Add(src)

/obj/effect/rend/Destroy()
	processing_objects.Remove(src)
	..()

/obj/effect/rend/process()
	for(var/mob/M in loc)
		if(M.stat != DEAD)
			return
	new mobtype(loc)
	mobsleft--
	if(mobsleft <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/I, mob/user)
	if(isholyweapon(I))
		visible_message("<span class='danger'>[I] strikes a blow against \the [src], banishing it!</span>")
		qdel(src)
		return
	..()

/obj/item/weapon/veilrender/attack_self(mob/user)
	if(charged > 0)
		create_rend(user)
		charged--
	else
		to_chat(user, "<span class='warning'>The unearthly energies that powered the blade are now dormant.</span>")

/obj/item/weapon/veilrender/proc/create_rend(mob/user)
	new rendtype(get_turf(user))
	visible_message("<span class='danger'>[src] hums with power as \the [user] deals a blow to reality itself!</span>")

/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	rendtype = /obj/effect/rend/cow

/obj/item/weapon/veilrender/vealrender/create_rend(mob/user)
	new rendtype(get_turf(user))
	visible_message("<span class='danger'>[src] hums with power as \the [user] deals a blow to hunger itself!</span>")

/obj/effect/rend/cow
	desc = "Reverberates with the sound of ten thousand moos."
	mobtype = /mob/living/simple_animal/cow

/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 7
	throw_range = 15
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	to_chat(user, "<span class='notice'>You can see...everything!</span>")
	visible_message("<span class='danger'>[usr] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)
	user.mind.isScrying = 1
	return


//necromancy moved to code\modules\projectiles\guns\energy\special.dm --Sonix


#define CLOAKINGCLOAK "cloakingcloak"

/obj/item/weapon/cloakingcloak
	name = "cloak of cloaking"
	desc = "A silk cloak that will hide you from anything with eyes."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "cloakingcloak"
	w_class = W_CLASS_MEDIUM
	force = 0
	flags = FPRINT | TWOHANDABLE
	var/event_key

/obj/item/weapon/cloakingcloak/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(iscarbon(holder) && wielded)
		var/mob/living/carbon/C = holder
		if(C.m_intent == "run" && prob(10))
			if(C.Slip(4, 5))
				step(C, C.dir)
				C.visible_message("<span class='warning'>\The [C] trips over \his [name] and appears out of thin air!</span>","<span class='warning'>You trip over your [name] and become visible again!</span>")

/obj/item/weapon/cloakingcloak/update_wield(mob/user)
	..()
	if(user)
		user.update_inv_hands()
		if(wielded)
			user.visible_message("<span class='danger'>\The [user] throws \the [src] over \himself and disappears!</span>","<span class='notice'>You throw \the [src] over yourself and disappear.</span>")
			event_key = user.on_moved.Add(src, "mob_moved")
			user.alpha = 1	//to cloak immediately instead of on the next Life() tick
			user.alphas[CLOAKINGCLOAK] = 1
		else
			user.visible_message("<span class='warning'>\The [user] appears out of thin air!</span>","<span class='notice'>You take \the [src] off and become visible again.</span>")
			user.on_moved.Remove(event_key)
			event_key = null
			user.alpha = initial(user.alpha)
			user.alphas.Remove(CLOAKINGCLOAK)


/obj/item/weapon/glow_orb
	name = "inert stone"
	desc = "A peculiar fist-sized stone which hums with dormant energy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "glow_stone_dormant"
	w_class = W_CLASS_TINY
	force = 0
	var/prime_time = 2 SECONDS
	var/crit_failure = 0
	var/activating = 0

/obj/item/weapon/glow_orb/attack_self(mob/user)
	if(crit_failure)
		to_chat(user, "<span class = 'warning'>\The [src] is vibrating erratically!</span>")
		return
	if(activating)
		to_chat(user, "<span class = 'warning'>\The [src] hums with energy as it begins to glow brighter.</span>")
		return
	if(iswizard(user) || isapprentice(user))
		to_chat(user, "<span class = 'notice'>You prime the glow-stone, it will transform in [prime_time/10] seconds.</span>")
		activate()
		return
	if (clumsy_check(user) && prob(50))
		to_chat(user, "<span class = 'notice'>Ooh, shiny!</span>")
		failure()
		return
	if(prob(65))
		to_chat(user, "<span class = 'notice'>You find what appears to be an on button, and press it.</span>")
		activate()
	else
		if(prob(5))
			visible_message("<span class = 'warning'>\The [src] ticks [pick("ominously","forebodingly", "harshly")].</span>")
			if(prob(50))
				failure()
		to_chat(user, "<span class = 'notice'>You fiddle with \the [src], but find nothing of interest.</span>")

/obj/item/weapon/glow_orb/proc/activate()
	activating = 1
	spawn(prime_time)
		if(crit_failure) //Damn it clown
			return
		if(ismob(loc))
			var/mob/M = loc
			M.drop_from_inventory(src)
		playsound(src, 'sound/weapons/orb_activate.ogg', 50,1)
		flick("glow_stone_activate", src)
		spawn(10)
			new/mob/living/simple_animal/hostile/glow_orb(get_turf(src))
			qdel(src)

/obj/item/weapon/glow_orb/proc/failure()
	visible_message("<span class = 'notice'>\The [src] begins to glow increasingly in a brilliant manner...</span>")
	crit_failure = 1
	spawn(1 SECONDS)
		visible_message("<span class = 'warning>...and vibrate violently!</span>")
	playsound(src,'sound/weapons/inc_tone.ogg', 50, 1)
	spawn(2 SECONDS)
		explosion(loc, 0, 1, 2, 3)
		qdel(src)

/obj/item/phylactery
	name = "strange stone"
	desc = "A stone, decorated with masterly crafted silver, adorned with silver in the shape of a human skull. It hums with malignancy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "phylactery_empty_noglow"
	var/charges = 0
	var/soulbound
	var/z_bound
	var/mob/bound_soul

/obj/item/phylactery/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/S = I
		var/mob/living/simple_animal/shade/sacrifice = locate() in S
		if(sacrifice)
			visible_message("<span class = 'warning'>The soul within \the [I] is released unto \the [src].</span>")
			S.name = initial(S.name)
			charges++
			update_icon()
			qdel(sacrifice)
	else
		..()

/obj/item/phylactery/Destroy()
	if(bound_soul.on_death)
		bound_soul.on_death.Remove(soulbound)
		bound_soul.on_z_transition.Remove(z_bound)
	z_bound = null
	soulbound = null
	if(bound_soul)
		to_chat(bound_soul, "<span class = 'warning'><b>You feel your form begin to unwind!</b></span>")
		spawn(rand(5 SECONDS, 15 SECONDS))
			bound_soul.dust()
			bound_soul = null
	..()


/obj/item/phylactery/update_icon()
	if(soulbound)
		if(charges >= 1)
			icon_state = "phylactery"
		else
			icon_state = "phylactery_empty"
	else
		icon_state = "phylactery_empty_noglow"

/obj/item/phylactery/attack_self(mob/user)
	if(!soulbound && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/organ/external/E = H.get_active_hand_organ()
		if(locate(/datum/wound) in E.wounds)
			to_chat(user, "<span class = 'warning'>You bind your life essence to \the [src].</span>")
			bind(user)
			charges++
			update_icon()
	else
		..()

/obj/item/phylactery/proc/revive_soul(list/arguments)
	if(charges <= 0)
		unbind()
		return
	var/mob/living/original = arguments["user"]
	if(original.mind)
		var/mob/living/carbon/human/H = new /mob/living/carbon/human/lich(src)
		H.real_name = original.real_name
		H.flavor_text = original.flavor_text
		for(var/spell/S in original.spell_list)
			original.remove_spell(S)
			H.add_spell(S)
		H.Paralyse(30)
		original.mind.transfer_to(H)
		unbind()
		bind(H)
		if(!arguments["body_destroyed"])
			original.dust()
		var/release_time = rand(60 SECONDS, 120 SECONDS)/charges
		to_chat(H, "<span class = 'notice'>\The [src] will permit you exit in [release_time/10] seconds.</span>")
		spawn(release_time)
			to_chat(H, "<span class = 'notice'>\The [src] permits you exit from it.</span>")
			H.forceMove(get_turf(src))
	charges--
	update_icon()

/obj/item/phylactery/proc/unbind()
	if(bound_soul.on_death)
		bound_soul.on_death.Remove(soulbound)
	if(bound_soul.on_z_transition)
		bound_soul.on_z_transition.Remove(z_bound)
	z_bound = null
	soulbound = null
	bound_soul = null
	update_icon()

/obj/item/phylactery/proc/bind(var/mob/to_bind)
	soulbound = to_bind.on_death.Add(src, "revive_soul")
	z_bound = to_bind.on_z_transition.Add(src, "z_block")
	bound_soul = to_bind

/obj/item/phylactery/proc/z_block(list/arguments)
	var/mob/user = arguments["user"]
	if(user != bound_soul)
		unbind()
		return
	if(is_holder_of(user, src))
		return //We're in their pocket, you ash-happy bottle of soul!
	var/turf/T = get_turf(src)
	if(arguments["to_z"] != T.z)
		to_chat(user, "<span class = 'warning'><b>As you stray further and further away from \the [src], you feel your form unravel!</b></span>")
		spawn(rand(5 SECONDS, 15 SECONDS)) //Mr. Wizman, I don't feel so good
			if(user.gcDestroyed)
				return
			T = get_turf(src)
			if(user.z != T.z || is_holder_of(user, src))
				user.dust()