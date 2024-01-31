//The unsorted chems... Stuff that just didn't fit any of the other categories

//A chemical for curing petrification. It only works after you've been fully petrified
//Items on corpses will survive the process, but the corpses itself will be damaged and uncloneable after unstoning
/datum/reagent/apetrine
	name = "Apetrine"
	id = APETRINE
	description = "Apetrine is a chemical used to partially reverse the post-mortem effects of petritricin."
	color = "#240080" //rgb: 36, 0, 128
	dupeable = FALSE
	density = 7.94
	specheatcap = 1.39

/datum/reagent/apetrine/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	if(istype(O, /obj/structure/closet/statue))
		var/obj/structure/closet/statue/statue = O
		statue.dissolve()
	if(istype(O, /obj/structure/mannequin))
		var/obj/structure/mannequin/statue = O
		statue.dissolve()

/datum/reagent/apetrine/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(istype(M, /mob/living/simple_animal/hostile/mannequin))
		var/mob/living/simple_animal/hostile/mannequin/statue = M
		statue.dissolve()

/datum/reagent/anthracene
	name = "Anthracene"
	id = ANTHRACENE
	description = "Anthracene is a fluorophore which emits a weak green glow."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#00ff00" //rgb: 0, 255, 0
	var/light_intensity = 4
	var/initial_color = null
	density = 3.46
	specheatcap = 512.3
	flags = CHEMFLAG_PIGMENT
	paint_light = PAINTLIGHT_LIMITED

/datum/reagent/anthracene/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(!tick)
		initial_color = M.light_color
		M.light_color = LIGHT_COLOR_GREEN
		M.set_light(light_intensity)

/datum/reagent/anthracene/reagent_deleted()
	if(..())
		return 1

	if(!holder)
		return
	var/atom/A =  holder.my_atom
	A.light_color = initial_color
	A.set_light(0)

/datum/reagent/anthracene/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(method == TOUCH)
		var/init_color = M.light_color
		M.light_color = LIGHT_COLOR_GREEN
		M.set_light(light_intensity)
		spawn(volume * 10)
			M.light_color = init_color
			M.set_light(0)

/datum/reagent/anthracene/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1

	var/init_color = T.light_color
	T.light_color = LIGHT_COLOR_GREEN
	T.set_light(light_intensity)
	spawn(volume * 10)
		T.light_color = init_color
		T.set_light(0)

/datum/reagent/anthracene/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	var/init_color = O.light_color
	O.light_color = LIGHT_COLOR_GREEN
	O.set_light(light_intensity)
	spawn(volume * 10)
		O.light_color = init_color
		O.set_light(0)

/datum/reagent/bumcivilian
	name = "Bumcivilian"
	id = BUMCIVILIAN
	description = "The most basic form of iron, also known as 'brown iron'. It has the unusual property of absorbing sound particles when it is produced by reactions with sulfuric acid."
	color = "#786228" //120, 98, 40
	specheatcap = 0.45
	density = 7.874
	var/mute_duration = 300 //30 seconds

/datum/reagent/calciumcarbonate
	name = "Calcium Carbonate"
	id = CALCIUMCARBONATE
	description = "An odorless, fine, white micro-crystalline powder. Usually obtained by grinding limestone, or egg shells."
	color = "#FFFFFF"
	density = 2.73
	specheatcap = 83.43

/datum/reagent/calciumhydroxide
	name = "Calcium Hydroxide"
	id = CALCIUMHYDROXIDE
	description = "Hydrated lime, non-toxic."
	color = "#FFFFFF"
	density = 2.211
	specheatcap = 87.45

/datum/reagent/calciumoxide
	name = "Calcium Oxide"
	id = CALCIUMOXIDE
	description = "Quicklime. Reacts strongly with water forming calcium hydrate and generating heat in the process"
	color = "#FFFFFF"
	density = 3.34
	specheatcap = 42.09

/datum/reagent/calciumoxide/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((H.species && H.species.flags & NO_BREATHE) || (M_NO_BREATH in H.mutations))
			return
		M.adjustFireLoss(0.5 * REM)
		if(prob(10))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!", "coughs!", "splutters!")]</span>")

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = COLORFUL_REAGENT
	description = "Thoroughly sample the rainbow."
	reagent_state = REAGENT_STATE_LIQUID
	flags = CHEMFLAG_PIGMENT
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")

/datum/reagent/colorful_reagent/special_behaviour()
	color = pick(random_color_list)

/datum/reagent/colorful_reagent/on_mob_life(mob/living/M)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()

/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.color = pick(random_color_list)
	..()

/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume, var/list/splashplosion=list())
	if(..())
		return TRUE

	var/picked_color = pick(random_color_list)

	var/turf/U = get_turf(holder.my_atom)
	if(isfloor(T))
		T.apply_paint_overlay(picked_color, 255)
		if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && !(R in splashplosion) && T.Adjacent(R))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(picked_color, 255, get_dir_cardinal(R,T), "border_splatter")
				else if (iswall(R) && !(R in splashplosion))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(picked_color, 255, get_dir_cardinal(R,T), "wall_splatter")
	else if(iswall(T))
		if (T == U)
			T.apply_paint_overlay(picked_color, 255, list(), id == NANOPAINT)//if we're on top somehow, paint the whole tile
		else if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && (R in splashplosion))
					if (get_dir(T,U) & direction)
						T.apply_paint_stroke(picked_color, 255, get_dir_cardinal(T,R), "wall_splatter")
		else
			T.apply_paint_stroke(picked_color, 255, get_dir_cardinal(T,U), "wall_splatter")

/datum/reagent/dsyrup
	name = "Delightful Mix"
	id = DSYRUP
	description = "This syrupy stuff is everyone's favorite tricord additive."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#571212" //like a dark red
	density = 1.00 //basically water
	specheatcap = 4.184

/datum/reagent/ethylcyanoacrylate
	name = "Ethyl Cyanoacrylate"
	id = ETHYLCYANOACRYLATE
	description = "An esther of low viscosity used as an intermediate component of glue production."
	color = "#DDDDDD"
	alpha = 50

/datum/reagent/glycerol
	name = "Glycerol"
	id = GLYCEROL
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#808080" //rgb: 128, 128, 128
	density = 4.84
	specheatcap = 1.38

//Just for fun
var/list/procizine_calls = list()
var/list/procizine_args = list()
var/procizine_name = ""
var/procizine_overdose = 0
var/procizine_metabolism = 0
var/procizine_color = "#C8A5DC"
var/procizine_addictive = FALSE
var/procizine_tolerance = 0

/client/proc/set_procizine_call()
	set name = "Set Procizine Call"
	set category = "Fun"
	if(!check_rights(R_DEBUG))
		return

	var/ourproc = input("Proc path to call on target reaction, eg: /proc/fake_blood (To make effective, add the reagent procizine to the atom)","Path:", null) as text|null
	if(!ourproc)
		return

	procizine_calls["life"] = ourproc

	var/argnum = input("Number of arguments","Number:",0) as num|null

	var/list/ourargs = list()
	ourargs.len = !argnum && (argnum!=0) ? 0 : argnum // Expand to right length

	var/i
	for(i = 1, i < argnum + 1, i++) // Lists indexed from 1 forwards in byond
		ourargs[i] = variable_set(src)

	procizine_args["life"] = ourargs.Copy()

	var/static/list/other_call_types = list("plant","mob","object","turf","mob dropper","object dropper","removal","overdose","withdrawal")
	var/goahead = alert("Do you wish to customise this further? (The previous input will only be used for mob life)", "Advanced procizine calls", "Yes", "No") == "Yes"
	for(var/calltype in other_call_types)
		if(goahead)
			ourproc = input("Proc path to call on [calltype] reaction, eg: /proc/fake_blood (To make effective, add the reagent procizine to the atom)","Path:", null) as text|null

			argnum = input("Number of arguments","Number:",0) as num|null
			ourargs.len = !argnum && (argnum!=0) ? 0 : argnum // Expand to right length

			for(i = 1, i < argnum + 1, i++) // Lists indexed from 1 forwards in byond
				ourargs[i] = variable_set(src)

		procizine_calls[calltype] = ourproc
		procizine_args[calltype] = ourargs.Copy()

/client/proc/set_procizine_properties()
	set name = "Set Procizine Properties"
	set category = "Fun"
	if(!check_rights(R_DEBUG))
		return

	procizine_name = input(src, "Reagent name","Procizine attributes", procizine_name) as text|null
	procizine_overdose = input(src, "Overdose threshold","Procizine attributes", procizine_overdose) as num|null
	procizine_metabolism = input(src, "Custom metabolism","Procizine attributes", procizine_metabolism) as num|null
	procizine_addictive = alert(src, "Is addictive?","Procizine attributes", "Yes", "No") == "Yes"
	procizine_tolerance = input(src, "Tolerance increase per metabolisation","Procizine attributes", procizine_metabolism) as num|null
	procizine_color = input(src, "Reagent color", "Procizine attributes") as color|null

/datum/reagent/procizine
	name = "Procizine"
	id = PROCIZINE
	description = "It is a mystery!"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#C8A5DC" //rgb: 200, 165, 220
	density = ARBITRARILY_LARGE_NUMBER
	specheatcap = ARBITRARILY_LARGE_NUMBER
	var/list/procnames
	var/list/procargs

/datum/reagent/procizine/New()
	..()
	procnames = procizine_calls.Copy()
	procargs = procizine_args.Copy()
	name = procizine_name && procizine_name != "" ? procizine_name : initial(name)
	overdose_am = procizine_overdose
	custom_metabolism = procizine_metabolism || REAGENTS_METABOLISM
	color = procizine_color || initial(color)
	addictive = procizine_addictive
	tolerance_increase = procizine_tolerance

/datum/reagent/procizine/proc/call_proc(var/atom/A, var/call_type)
	if(procnames[call_type] && hascall(A, procnames[call_type]))
		call(A,procnames[call_type])(arglist(procargs[call_type]))

/datum/reagent/procizine/on_mob_life(var/mob/living/carbon/M)
	if(..())
		return 1
	call_proc(M,"life")

/datum/reagent/procizine/on_plant_life(obj/machinery/portable_atmospherics/hydroponics/T)
	..()
	call_proc(T,"plant")

/datum/reagent/procizine/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1
	call_proc(M,"mob")

/datum/reagent/procizine/reaction_turf(var/turf/simulated/T, var/volume)
	if(..())
		return 1
	call_proc(T,"turf")

/datum/reagent/procizine/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1
	call_proc(O,"object")

/datum/reagent/procizine/reaction_dropper_mob(var/mob/living/M)
	. = ..()
	call_proc(M,"mob dropper")

/datum/reagent/procizine/reaction_dropper_obj(var/obj/O)
	. = ..()
	call_proc(O,"object dropper")

/datum/reagent/procizine/reagent_deleted()
	call_proc(holder.my_atom,"removal")

/datum/reagent/procizine/on_overdose(mob/living/M)
	call_proc(holder.my_atom,"overdose")

/datum/reagent/procizine/on_withdrawal(mob/living/M)
	if(..())
		return 1
	call_proc(holder.my_atom,"withdrawal")

/datum/reagent/punctualite
	name = "Punctualite"
	id = PUNCTUALITE
	description = "Nicknamed mad chemist's alarm clock. Explodes on the turn of the hour when within a living creature."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#8d8791" //rgb: 200, 165, 220
	custom_metabolism = 0 //Wouldn't be much fun if it all got metabolized beforehand
	var/currentHour = 0 //The hour it was introduced into the system so it doesn't blow right away

/datum/reagent/punctualite/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	if(prob(5) && prob(5)) //0.25% chance per tick
		var/mob/living/carbon/human/earProtMan = null
		if(ishuman(M))
			earProtMan = M
		if(!M.is_deaf() && !earProtMan || !earProtMan.earprot())
			if(prob(50))
				to_chat(M, "<span class='notice'>You hear a ticking sound</span>")
			else
				to_chat(M, "<span class='notice'>You hear a tocking sound</span>")
	if((floor(world.time / (1 HOURS)) + 1) > currentHour)
		if(!currentHour)
			currentHour = floor(world.time / (1 HOURS)) + 1
		else
			punctualiteExplode(M)
			currentHour = floor(world.time / (1 HOURS)) + 1

/datum/reagent/punctualite/proc/punctualiteExplode(var/mob/living/H)
	var/bigBoom = 0
	var/medBoom = 0
	var/litBoom = 0
	bigBoom = min(floor(volume/150), 2) //Max breach is 2, twice a welder tank
	medBoom = min(floor(volume/50), 4)
	litBoom = min(floor(volume/20), 7)
	explosion(get_turf(H), bigBoom, medBoom, litBoom)

/datum/reagent/saltwater
	name = "Salt Water"
	id = SALTWATER
	description = "It's water mixed with salt. It's probably not healthy to drink."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF" //rgb: 255, 255, 255
	density = 1.122
	specheatcap = 6.9036

/datum/reagent/saltwater/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(ishuman(M) && prob(20))
		var/mob/living/carbon/human/H = M
		H.vomit()
		M.adjustToxLoss(2 * REM)

/datum/reagent/saltwater/saline
	name = "Saline"
	id = SALINE
	description = "A solution composed of salt, water, and ammonia. Used in pickling and preservation"
	reagent_state = REAGENT_STATE_LIQUID
	color = "#DEF7F5" //rgb: 192, 227, 233
	alpha = 64
	density = 0.622
	specheatcap = 99.27

/datum/reagent/self_replicating
	id = EXPLICITLY_INVALID_REAGENT_ID
	var/whitelisted_ids = list()

/datum/reagent/self_replicating/post_transfer(var/datum/reagents/donor)
	..()
	holder.convert_all_to_id(id, whitelisted_ids)

/datum/reagent/self_replicating/on_introduced(var/data)
	..()
	holder.convert_all_to_id(id, whitelisted_ids)

/datum/reagent/self_replicating/midazoline
	name = "Midazoline"
	id = MIDAZOLINE
	description = "Chrysopoeia, the artificial production of gold, was one of the defining ambitions of ancient alchemy. Turns out, all it took was a little plasma. Converts all other reagents into Midazoline, except for Mercury, which will convert Midazoline into itself."
	reagent_state = REAGENT_STATE_SOLID
	color = "#F7C430" //rgb: 247, 196, 48
	density = 19.3
	specheatcap = 0.129
	whitelisted_ids = list(MERCURY)

/datum/reagent/sodium_silicate
	name = "Sodium Silicate"
	id = SODIUMSILICATE
	description = "A white powder, commonly used in cements."
	reagent_state = REAGENT_STATE_SOLID
	color = "#E5E5E5"
	density = 2.61
	specheatcap = 111.8

/datum/reagent/temp_hearer/
	id = EXPLICITLY_INVALID_REAGENT_ID
	data = list("stored_phrase" = null)

/datum/reagent/temp_hearer/on_introduced(var/data)
	. = ..()
	var/obj/item/weapon/reagent_containers/RC = holder.my_atom
	if(!istype(RC))
		return
	if(!RC.virtualhearer)
		RC.addHear(/mob/virtualhearer/one_time)

/datum/reagent/temp_hearer/proc/parent_heard(var/datum/speech/speech, var/rendered_speech="")
	if(!data["stored_phrase"])
		set_phrase(sanitize(speech.message))
		var/atom/container = holder.my_atom
		if(container.is_open_container() || ismob(container))
			container.visible_message("<span class='notice'>[bicon(container)] The solution fizzles for a moment.</span>", "You hear something fizzling for a moment.", "<span class='notice'>[bicon(container)] \The [container] replies something, but you can't hear them.</span>")
			if(!(container.flags & SILENTCONTAINER))
				playsound(container, 'sound/effects/bubbles.ogg', 20, -3)

/datum/reagent/temp_hearer/proc/set_phrase(var/phrase)
	data["stored_phrase"] = phrase

/datum/reagent/temp_hearer/locutogen
	name = "Locutogen"
	id = LOCUTOGEN
	description = "Sound-activated solution. Permanently stores the first soundwaves it 'hears' into a long polymer chain, which reacts into a crude form of speech into the ears of a live host. Tastes sweet."
	reagent_state = REAGENT_STATE_LIQUID
	custom_metabolism = 0.01
	color = "#8E18A9" //rgb: 142, 24, 169
	density = 1.58
	specheatcap = 1.44

/datum/reagent/temp_hearer/locutogen/on_mob_life(var/mob/living/M)
	if(..())
		return 1

	if(!M.isUnconscious() && data["stored_phrase"])
		to_chat(M, "You hear a voice in your head saying: <span class='bold'>'[data["stored_phrase"]]'</span>.")
		M.reagents.del_reagent(LOCUTOGEN)
