#define RUNE_STAND	1

/datum/rune_spell/friendly_cult
	name = "Friendly Cult Spell"
	desc = "How nice!"
	invocation = "Lo'Rom Ip'Som"
	
	runeset_identifier = "friendly_cult"
	
/datum/rune_spell/friendly_cult/New(var/mob/user, var/obj/holder, var/use = "ritual", var/mob/target)
	spell_holder = holder
	activator = user
	if(use == "ritual")
		pre_cast()
	
/datum/rune_spell/friendly_cult/pre_cast() 
	if(istype(spell_holder,/obj/effect/rune))
		if((rune_flags & RUNE_STAND) && (activator.loc != spell_holder.loc))
			abort(RITUALABORT_STAND)
		else
			invoke(activator,invocation)
			cast()

	
	
	
/datum/rune_spell/friendly_cult/conjurecookie
	name = "Conjure Cookie"
	desc = "This simple rune summons a bowl of cookies filled with O+, Nar-Sie approved cookies."
	invocation = "H'drok v'loso, mir'konos vorbot!"
	word1 = /datum/runeword/friendly_cult/friend
	word2 = /datum/runeword/friendly_cult/love
	word3 = /datum/runeword/friendly_cult/cookie
	cost_invoke = 5

/datum/rune_spell/friendly_cult/conjurecookie/cast()
	var/obj/effect/rune/R = spell_holder
	if(spell_holder && pay_blood())
		R.one_pulse()
		spell_holder.visible_message("<span class='rose'>The blood drops merge into each other, and a basket of cookies takes their place.</span>")
		var/turf/T = get_turf(spell_holder)
		new /obj/item/weapon/reagent_containers/food/snacks/cookiebowl/cult(T)
	qdel(src)

/datum/rune_spell/friendly_cult/conjurepamphlet
	name = "Conjure Pamphlet"
	desc = "This rune summons a pamphlet containing 10 reasons why Nar-Sie can improve your life. Really, just give it a read!"
	invocation = "H'drok v'loso, mir'konos vorbot!"
	word1 = /datum/runeword/friendly_cult/empower
	word2 = /datum/runeword/friendly_cult/friend
	word3 = /datum/runeword/friendly_cult/together
	cost_invoke = 5

/datum/rune_spell/friendly_cult/conjurepamphlet/cast()
	var/obj/effect/rune/R = spell_holder
	if(spell_holder && pay_blood())
		R.one_pulse()
		spell_holder.visible_message("<span class='rose'>The blood drops merge into each other, and a cultist pamphlet takes their place.</span>")
		var/turf/T = get_turf(spell_holder)
		new /obj/item/weapon/friendly_pamphlet(T)
	qdel(src)
	
/datum/rune_spell/friendly_cult/harmalarm
	name = "Harm Alarm"
	desc = "This rune floods everyone's senses with a blast of pure friendly energy. Maybe the humans will finally stop harming each other."
	invocation = "Fuu mo'jin!"
	word1 = /datum/runeword/friendly_cult/tolerance
	word2 = /datum/runeword/friendly_cult/peace
	word3 = /datum/runeword/friendly_cult/together
	cost_invoke = 20

/datum/rune_spell/friendly_cult/harmalarm/cast()
	var/obj/effect/rune/R = spell_holder
	if(spell_holder && pay_blood())
		R.one_pulse()
		new/obj/effect/cult_ritual/friendly_stun(R.loc)


/obj/effect/cult_ritual/friendly_stun
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = ""
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	mouse_opacity = 0
	var/stun_duration = 5

/obj/effect/cult_ritual/friendly_stun/New(turf/loc,var/type=1)
	..()
	playsound(src, 'sound/effects/stun_rune.ogg', 75, 0, 0)
	flick("rune_stun",src)
	spawn(10)
		src.visible_message("<span class='big danger'>HUMAN HARM</span>")
		visible_message("<span class='warning'>The rune explodes in a bright flash of friendly energies.</span>")
		playsound(src, 'sound/AI/harmalarm.ogg', 70, 3, 1)
		for(var/mob/living/L in viewers(src))
			if(iscarbon(L))
				shadow(L,loc,"rune_stun")
				var/mob/living/carbon/C = L
				C.flash_eyes(visual = 1)
				if(C.earprot() || C.is_deaf())
					continue
				to_chat(C, "<span class='danger'>A telepathic siren pierces your hearing!</span>")
				C.stuttering += 5
				C.ear_deaf += 1
				C.dizziness += 5
				C.confused +=  5
				C.Jitter(5)
		qdel(src)

#undef RUNE_STAND
