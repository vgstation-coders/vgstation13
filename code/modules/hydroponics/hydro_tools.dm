//Analyzer, pestkillers, weedkillers, nutrients, hatchets, cutters.

/obj/item/tool/wirecutters/clippers
	name = "plant clippers"
	desc = "A tool used to take samples from plants."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	icon_state = "plantclippers"
	item_state = "plantclippers"

/obj/item/tool/wirecutters/clippers/New()
	..()
	icon_state = "plantclippers"
	item_state = "plantclippers"

/obj/item/device/analyzer/plant_analyzer
	name = "plant analyzer"
	desc = "A hand-held botanical scanner that reports detailed information about seeds, plants and produce."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"
	var/form_title //Descriptive title of the last plant scanned, example: mutant watermelon (#81)
	var/last_data  //Stores the entire last scan, for printing purposes.
	var/tmp/last_print = 0 //When was the last printing, works as a cooldown to prevent paperspam

/obj/item/device/analyzer/plant_analyzer/afterattack(obj/target, mob/user, flag)
	if(!flag)
		return

	var/datum/seed/grown_seed
	var/datum/reagents/grown_reagents
	if(istype(target,/obj/structure/rack) || istype(target,/obj/structure/table))
		return ..()
	else if(istype(target,/obj/item/weapon/reagent_containers/food/snacks/grown))

		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = target
		grown_seed = SSplant.seeds[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/weapon/grown))

		var/obj/item/weapon/grown/G = target
		grown_seed = SSplant.seeds[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/seeds))

		var/obj/item/seeds/S = target
		grown_seed = S.seed

	else if(istype(target,/obj/machinery/portable_atmospherics/hydroponics))

		var/obj/machinery/portable_atmospherics/hydroponics/H = target
		grown_seed = H.seed
		grown_reagents = H.reagents

	else if(istype(target,/obj/effect/plantsegment))

		var/obj/effect/plantsegment/K = target
		grown_seed = K.seed

	if(!grown_seed)
		to_chat(user, "<span class='warning'>[bicon(src)] [src] can tell you nothing about [target].</span>")
		return

	form_title = "[grown_seed.seed_name] (#[grown_seed.uid])"
	if(loc == user) //Don't show this message if we are not inhand
		user.visible_message("<span class='notice'>[user] runs the scanner over [target].</span>")

	var/dat = list()
	dat += "<h3>Plant data for [form_title]</h3>"

	dat += "<h2>General Data</h2>"

	dat += "<table>"
	dat += "<tr><td><b>Endurance</b></td><td>[round(grown_seed.endurance, 0.01)]</td></tr>"
	dat += "<tr><td><b>Yield</b></td><td>[round(grown_seed.yield, 0.01)]</td></tr>"
	dat += "<tr><td><b>Lifespan</b></td><td>[round(grown_seed.lifespan, 0.01)]</td></tr>"
	dat += "<tr><td><b>Maturation time</b></td><td>[round(grown_seed.maturation, 0.01)]</td></tr>"
	dat += "<tr><td><b>Production time</b></td><td>[round(grown_seed.production, 0.01)]</td></tr>"
	dat += "<tr><td><b>Potency</b></td><td>[round(grown_seed.potency, 0.01)]</td></tr>"
	dat += "</table>"

	if(grown_reagents && grown_reagents.reagent_list && grown_reagents.reagent_list.len)
		dat += "<h2>Reagent Data</h2>"

		dat += "<br>This sample contains: "
		for(var/datum/reagent/R in grown_reagents.reagent_list)
			dat += "<br>- [R.id], [grown_reagents.get_reagent_amount(R.id)] unit(s)"

	dat += "<h2>Other Data</h2>"

	if(grown_seed.harvest_repeat)
		dat += "This plant can be harvested repeatedly.<br>"
		if(grown_seed.harvest_repeat > 1)
			dat += "This plant harvests itself when ready.<br>"

	if(grown_seed.immutable == -1)
		dat += "This plant is highly mutable.<br>"
	else if(grown_seed.immutable > 0)
		dat += "This plant does not possess genetics that are alterable.<br>"

	if(grown_seed.mutants && grown_seed.mutants.len)
		dat += "It exhibits a high degree of potential subspecies mutations.<br>"

	if(grown_seed.products && grown_seed.products.len)
		dat += "The mature plant will produce [grown_seed.products.len == 1 ? "fruit" : "[grown_seed.products.len] varieties of fruit"].<br>"

	if(grown_seed.nutrient_consumption == 0)
		dat += "It does not require nutrients to subsist.<br>"
	else
		dat += "It consumes [grown_seed.nutrient_consumption] units of nutrient per cycle.<br>"

	if(grown_seed.fluid_consumption == 0)
		dat += "It does not require any fluids to subsist.<br>"
	else if(grown_seed.toxin_affinity < 5)
		dat += "It requires [grown_seed.fluid_consumption] units of water per cycle.<br>"
	else if(grown_seed.toxin_affinity > 7)
		dat += "It requires [grown_seed.fluid_consumption] units of toxins per cycle.<br>"
	else if(grown_seed.toxin_affinity >= 5 && grown_seed.toxin_affinity <= 7)
		dat += "it requires [grown_seed.fluid_consumption * 0.5] of both water and toxins per cycle.<br>"

	dat += "It thrives in a temperature of [grown_seed.ideal_heat] Kelvin and can tolerate deviations of up to [grown_seed.heat_tolerance] Kelvin.<br>"

	dat += "It can tolerate pressures between [grown_seed.lowkpa_tolerance] and [grown_seed.highkpa_tolerance] kPa.<br>"

	dat += "It thrives in a light level of [grown_seed.ideal_light] lumen[grown_seed.ideal_light == 1 ? "" : "s"], and can tolerate a deviation of up to [grown_seed.light_tolerance] lumen[grown_seed.light_tolerance == 1 ? "" : "s"] from it.<br>"

	dat += "It has a toxin affinity of [grown_seed.toxin_affinity] "
	if(grown_seed.toxin_affinity < 5)
		dat += "and will get damaged if exposed to them.<br>" 
	else if(grown_seed.toxin_affinity > 7)
		dat += "and will require toxins as a fluid, getting damaged if exposed to water.<br>"
	else if(grown_seed.toxin_affinity >= 5 && grown_seed.toxin_affinity <= 7)
		dat += "and requires both water and toxins, being able somewhat to tolerate either.<br>"

	dat += "It has a pest tolerance of [grown_seed.pest_tolerance]. "
	if(grown_seed.pest_tolerance < 30)
		dat += "It is highly sensitive to them.<br>"
	else if(grown_seed.pest_tolerance > 70)
		dat += "It is remarkably resistant to them.<br>"
	else
		dat += "It is average.<br>"

	dat += "It has a weed tolerance of [grown_seed.weed_tolerance]. "
	if(grown_seed.weed_tolerance < 30)
		dat += "It is highly sensitive to them.<br>"
	else if(grown_seed.weed_tolerance > 70)
		dat += "It is remarkably resistant to them.<br>"
	else
		dat += "It is average.<br>"
		
	if(grown_seed.consume_gasses)
		for(var/gas in grown_seed.consume_gasses)
			dat += "It will consume [gas] from the environment.<br>"
	if(grown_seed.gas_absorb)
		dat += "It will turn absorbed gasses into reagents.<br>"
	if(grown_seed.exude_gasses)
		for(var/gas in grown_seed.exude_gasses)
			dat += "It will exude [gas] into the environment.<br>"

	switch(grown_seed.spread)
		if(1)
			dat += "It is capable of growing beyond the confines of a tray.<br>"
		if(2)
			dat += "It is a robust and vigorous vine that will spread rapidly.<br>"

	if(grown_seed.hematophage)
		dat += "It is a highly specialized hematophage that will only draw nutrients from blood.<br>"

	switch(grown_seed.voracious)
		if(1)
			dat += "It is omnivorous and will eat tray pests and weeds for sustenance.<br>"
		if(2)
			dat	+= "It is carnivorous and poses a significant threat to living things around it.<br>"

	if(grown_seed.alter_temp)
		dat += "It will gradually alter the local room temperature to match its ideal habitat.<br>"

	if(grown_seed.ligneous)
		dat += "It is a ligneous plant with strong and robust stems.<br>"

	if(grown_seed.thorny)
		dat += "It possesses a cover of sharp thorns.<br>"

	if(grown_seed.stinging)
		dat += "It possesses a cover of fine stingers capable of releasing chemicals on touch.<br>"

	if(grown_seed.teleporting)
		dat += "It possesses a high degree of temporal/spatial instability and may cause spontaneous bluespace disruptions.<br>"

	switch(grown_seed.juicy)
		if(1)
			dat += "Its fruit is soft-skinned and abudantly juicy.<br>"
		if(2)
			dat	+= "Its fruit is excessively soft and juicy.<br>"

	if(grown_seed.biolum)
		if(grown_seed.biolum_colour == "#FFFFFF")
			dat += "It is bio-luminescent and glows pure white.<br>" //exception for shardlime
		else
			dat += "It is [grown_seed.biolum_colour ? "<font color='[grown_seed.biolum_colour]'>bio-luminescent</font>" : "bio-luminescent"].<br>"

	if(dat)
		dat = jointext(dat,"")
		last_data = dat
		dat += "<br>\[<a href='?src=\ref[src];print=1'>print report</a>\] \[<a href='?src=\ref[src];clear=1'>clear</a>\]"
		user << browse(dat,"window=plant_analyzer_\ref[src];size=500x600")
	return

/obj/item/device/analyzer/plant_analyzer/attack_self(mob/user as mob)
	if(last_data)
		user << browse(last_data,"window=plant_analyzer_\ref[src];size=400x500")
	else
		to_chat(user, "<span class='notice'>[bicon(src)] No plant scan data in memory.</span>")
	return 0

/obj/item/device/analyzer/plant_analyzer/proc/print_report_verb()
	set name = "Print Plant Report"
	set category = "Object"
	set src in usr

	if (!usr || usr.isUnconscious() || usr.restrained() || !Adjacent(usr))
		return
	print_report(usr)

/obj/item/device/analyzer/plant_analyzer/Topic(href, href_list)
	if(..())
		return
	if(href_list["print"])
		print_report(usr)
	if(href_list["clear"])
		last_data = ""
		usr << browse(null, "window=plant_analyzer")

/obj/item/device/analyzer/plant_analyzer/proc/print_report(var/mob/living/user) //full credits to Zuhayr
	if(!last_data)
		to_chat(user, "<span class='warning'>[bicon(src)] There is no plant scan data to print.</span>")
		return
	if (world.time < last_print + 4 SECONDS)
		to_chat(user, "<span class='warning'>[bicon(src)] \The [src] is not yet ready to print again.</span>")
		return
	last_print = world.time
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	P.name = "paper - [form_title]"
	P.info = "[last_data]"
	if(istype(user,/mob/living/carbon/human))
		user.put_in_hands(P)
	user.visible_message("<span class='notice'>\The [src] spits out a piece of paper.</span>")
	return

//Hatchets and things
/obj/item/weapon/minihoe
	name = "mini hoe"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = FPRINT
	siemens_coefficient = 1
	force = 5.0
	throwforce = 7.0
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 50)
	w_type = RECYK_METAL
	attack_verb = list("slashes", "slices", "cuts", "claws")

/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short wooden handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = FPRINT
	siemens_coefficient = 1
	force = 12.0
	w_class = W_CLASS_SMALL
	starting_materials = list(MAT_IRON = 5000)
	w_type = RECYK_METAL
	throwforce = 15.0
	throw_speed = 4
	throw_range = 4
	sharpness = 1.2
	sharpness_flags = SHARP_BLADE | CHOPWOOD
	origin_tech = Tc_MATERIALS + "=2;" + Tc_COMBAT + "=1"
	attack_verb = list("chops", "tears", "cuts")
	surgerysound = 'sound/items/hatchetsurgery.ogg'

/obj/item/weapon/hatchet/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/hatchet/unathiknife
	name = "dueling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("rips", "tears", "cuts")

/obj/item/weapon/hatchet/metalhandle
	name = "hatchet"
	desc = "A soulless attempt at upgrading the traditional hatchet, clearly a mass produced inferior tool compared to the ones made by elder botanist master-crafstmen."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "lamehatchet"

/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 3
	sharpness = 1.0
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	w_class = W_CLASS_LARGE
	flags = FPRINT
	slot_flags = SLOT_BACK
	origin_tech = Tc_MATERIALS + "=2;" + Tc_COMBAT + "=2"
	attack_verb = list("chops", "slices", "cuts", "reaps")

/obj/item/weapon/scythe/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(istype(A, /obj/effect/plantsegment) || istype(A, /turf/simulated/floor) || istype(A, /obj/effect/biomass) || istype(A, /obj/structure/cable/powercreeper))
		for(var/obj/effect/plantsegment/B in range(user,1))
			if(is_hot() || (is_sharp() && !B.seed.ligneous))
				B.take_damage(force * 4)
			else
				B.take_damage(force)
		for(var/obj/effect/biomass/BM in range(user,1))
			BM.adjust_health(rand(15,45))
		for(var/obj/structure/cable/powercreeper/C in range(user,1))
			C.die()
		user.delayNextAttack(10)

/obj/item/claypot
	name = "clay pot"
	desc = "Plants placed in those stop aging, but cannot be retrieved either."
	icon = 'icons/obj/hydroponics/hydro_tools.dmi'
	icon_state = "claypot-item"
	item_state = "claypot"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	w_class = W_CLASS_MEDIUM
	force = 5.0
	throwforce = 20.0
	throw_speed = 1
	throw_range = 3
	flags = FPRINT
	var/being_potted = FALSE

/obj/item/claypot/attackby(var/obj/item/O,var/mob/user)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown) || istype(O,/obj/item/weapon/grown))
		to_chat(user, "<span class='warning'>You have to transplant the plant into the pot directly from the hydroponic tray, using a spade.</span>")
	else if(isshovel(O))
		to_chat(user, "<span class='warning'>There is no plant to remove in \the [src].</span>")
	else
		to_chat(user, "<span class='warning'>You cannot plant \the [O] in \the [src].</span>")

/obj/item/claypot/throw_impact(atom/hit_atom)
	if(!..() && prob(40))
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 75, 1)
		new/obj/effect/decal/cleanable/clay_fragments(src.loc)
		src.visible_message("<span class='warning'>\The [src.name] has been smashed.</span>","<span class='warning'>You hear a crashing sound.</span>")
		qdel(src)
