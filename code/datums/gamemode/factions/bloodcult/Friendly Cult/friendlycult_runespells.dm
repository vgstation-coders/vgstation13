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
		new/obj/effect/cult_ritual/harm_alarm(R.loc)
	qdel(src)

/obj/effect/cult_ritual/harm_alarm
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = ""
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	mouse_opacity = 0
	var/stun_duration = 5

/obj/effect/cult_ritual/harm_alarm/New(turf/loc,var/type=1)
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
				to_chat(C, "<span class='danger'>A telepathic siren pierces your mind!</span>")
				C.stuttering += 5
				C.ear_deaf += 1
				C.dizziness += 3
				C.confused +=  3
				C.Jitter(5)
		qdel(src)

		
		
		
		
		
/datum/rune_spell/friendly_cult/chain_hug
	name = "Chain Hug"
	desc = "This rune summons a deviant of chain lightning that ricochets off all nearby carbons, hugging them."
	invocation = "H'ug m'ino mer'bos!"
	word1 = /datum/runeword/friendly_cult/hug
	word2 = /datum/runeword/friendly_cult/friend
	word3 = /datum/runeword/friendly_cult/together
	cost_invoke = 8

/datum/rune_spell/friendly_cult/chain_hug/cast()
	var/obj/effect/rune/R = spell_holder
	if(spell_holder && pay_blood())
		R.one_pulse()
		new/obj/effect/cult_ritual/chain_hug(R.loc)
	qdel(src)
	
/obj/effect/cult_ritual/chain_hug
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = ""
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/chain_hug/New(turf/loc,var/type=1)
	..()
	playsound(src, 'sound/effects/stun_rune.ogg', 75, 0, 0)
	flick("rune_stun",src)
	visible_message("<span class='warning'>The rune activates with a flash of light!</span>")
	spawn(5)
		var/mob/living/target = pick(viewers(src))
		if(target)
			var/list/hugged_mobs = list(target)
			bounce(get_turf(src),hugged_mobs)

		
/obj/effect/cult_ritual/chain_hug/proc/bounce(turf/loc, var/list/hugged_mobs)
	var/list/potential_bounces = list()
	for(var/mob/living/M in viewers(loc))
		if(!hugged_mobs.Find(M))
			potential_bounces.Add(M)
	var/mob/living/target
	if(potential_bounces.len)
		target = pick(potential_bounces)
	spawn(3)
		if(target)
			hugged_mobs.Add(target)
			shadow(target,loc,"rune_stun")
			target.visible_message("<span class='notice'>[target] is hugged by a faintly visible set of arms.</span>")
			if(prob(25))
				to_chat(target, "<span class='notice'>That felt pretty good, actually.</span>")
			if(istype(target,/mob/living/carbon))
				target.reagents.add_reagent(PARACETAMOL, 3)
			bounce(get_turf(target),hugged_mobs)			
		else
			qdel(src)
			

			
			
	
/datum/rune_spell/friendly_cult/cultify_lights
	name = "Carmine Influx"
	desc = "This rune sets all lights in view to a carmine shade."
	invocation = "R'ed o'm a'pat'h!"
	word1 = /datum/runeword/friendly_cult/friend
	word2 = /datum/runeword/friendly_cult/empower
	word3 = /datum/runeword/friendly_cult/together
	cost_invoke = 10
	var/obj/effect/cult_ritual/cultify_lights/glow_effect

/datum/rune_spell/friendly_cult/cultify_lights/cast()
	if(spell_holder && pay_blood())
		glow_effect = new /obj/effect/cult_ritual/cultify_lights(spell_holder.loc)
		spell_holder.visible_message("<span class='notice'>A translucent shade of crimson emanates from the rune.</span>")
		for(var/obj/machinery/light/fixture in oview(spell_holder.loc))
			if(fixture.current_bulb)
				qdel(fixture.current_bulb)
			if(fixture.fitting == "tube")
				fixture.current_bulb = new /obj/item/weapon/light/tube/cultist
			else if(fixture.fitting == "bulb") 
				fixture.current_bulb = new /obj/item/weapon/light/bulb/cultist
			fixture.update()
		spawn(30)
			if(spell_holder)
				qdel(spell_holder)
	spawn(30)
		qdel(src)
	
/datum/rune_spell/friendly_cult/cultify_lights/Destroy()
	if(glow_effect)
		qdel(glow_effect)
	..()
	
/obj/effect/cult_ritual/cultify_lights
	anchored = 1
	icon = 'icons/effects/160x160.dmi'
	icon_state = "rune_seer"
	pixel_x = -WORLD_ICON_SIZE*2
	pixel_y = -WORLD_ICON_SIZE*2
	alpha = 190
	layer = ABOVE_OBJ_LAYER
	plane = OBJ_PLANE
	mouse_opacity = 0
	flags = PROXMOVE	
	
	
#undef RUNE_STAND
