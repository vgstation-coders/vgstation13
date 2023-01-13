///////////////IMMUNITY SCANNER///////////////

/obj/item/device/antibody_scanner
	name = "immunity scanner"
	desc = "A hand-held body scanner able to evaluate the immune system of the subject."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	icon_state = "antibody"
	item_state = "immunity"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	origin_tech = Tc_MAGNETS + "=1;" + Tc_BIOTECH + "=1"
	attack_delay = 0


/obj/item/device/antibody_scanner/attack(var/mob/living/L, var/mob/user)
	if(!istype(L))
		//to_chat(user, "<span class='notice'>Incompatible object, scan aborted.</span>")
		return

	if (issilicon(L))
		to_chat(user, "<span class='warning'>Incompatible with silicon lifeforms, scan aborted.</span>")
		return

	playsound(user, 'sound/items/detscan.ogg', 50, 1)
	var/info = ""
	var/icon/scan = icon('icons/virology.dmi',"immunitybg")
	var/display_width = scan.Width()

	var/list/antigens_that_matter = list()
	if (L.immune_system)
		finding_antigens:
			for (var/antibody in L.immune_system.antibodies)
				if (L.immune_system.antibodies[antibody] > 0)
					antigens_that_matter += antibody
					continue
				if (L.virus2.len)
					for (var/ID in L.virus2)
						if(ID in virusDB)
							var/datum/disease2/disease/D = L.virus2[ID]
							if (antibody in D.antigen)
								antigens_that_matter += antibody
								continue finding_antigens

	var/bar_spacing = round(display_width/antigens_that_matter.len)
	var/bar_width = round(bar_spacing/2)
	var/bar_offset = round(bar_width/4)
	var/x_adjustment = 5//Sometimes you have to adjust things manually so they look good. This var moves all the gauges and graduations on the x axis.

	if (L.immune_system)
		var/immune_system = L.immune_system.GetImmunity()
		var/immune_str = immune_system[1]
		var/list/antibodies = immune_system[2]

		info += "Immune System Status: <b>[round(immune_str*100)]%</b>"
		info += "<br>Antibody Concentrations:"

		var/i = 0
		for (var/antibody in antigens_that_matter)
			var/rgb = "#FFFFFF"
			switch (antibody)
				if ("O","A","B","Rh")
					rgb = "#80DEFF"
				if ("Q","U","V")
					rgb = "#81FF9F"
				if ("M","N","P")
					rgb = "#E6FF81"
				if ("X","Y","Z")
					rgb = "#FF9681"
				if ("C")
					rgb = "#F54B4B"
				//add colors for new special antigens here
			scan.DrawBox(rgb,i*bar_spacing+bar_offset+x_adjustment,6,i*bar_spacing+bar_width+bar_offset+x_adjustment,6+antibodies[antibody]*3*immune_str)
			i++

	if (L.virus2.len)
		for (var/ID in L.virus2)
			var/datum/disease2/disease/D = L.virus2[ID]
			scan.DrawBox("#FF0000",6,6+D.strength*3,display_width-5,6+D.strength*3)
			if(ID in virusDB)
				var/subdivision = (D.strength - ((D.robustness * D.strength) / 100)) / D.max_stage
				var/i = 0
				for (var/antigen in antigens_that_matter)
					if (antigen in D.antigen)
						var/box_size = 3
						scan.DrawBox("#FF0000",bar_width-box_size+bar_spacing*i,6+D.strength*3-3,bar_width+box_size+bar_spacing*i,6+D.strength*3+3)
						scan.DrawBox("#FF0000",bar_width+bar_spacing*i,6+D.strength*3,bar_width+bar_spacing*i,6+round(D.strength - D.max_stage * subdivision)*3)
						var/stick_out = 6//how far the graduations go left and right of the gauge
						for (var/j = 1 to D.max_stage)
							var/alt = round(D.strength - j * subdivision)
							scan.DrawBox("#FF0000",i*bar_spacing+bar_offset-stick_out+x_adjustment,6+alt*3,i*bar_spacing+bar_offset+bar_width+stick_out+x_adjustment,6+alt*3)
					i++

	info += "<br><img src='data:image/png;base64,[icon2base64(scan)]'/>"
	info += "<br>"
	info += "<table style='table-layout:fixed;width:560px;text-align:center'>"
	info += "<tr>"
	if (L.immune_system)
		for (var/antibody in antigens_that_matter)
			info += "<th>[antibody]</th>"
	info += "</tr>"
	info += "<tr>"
	if (L.immune_system)
		for (var/antibody in antigens_that_matter)
			info += "<td>[round(L.immune_system.antibodies[antibody]*L.immune_system.strength)]%</th>"
	info += "</tr>"
	info += "</table>"

	if (L.virus2.len)
		for (var/ID in L.virus2)
			var/datum/disease2/disease/D = L.virus2[ID]
			if(ID in virusDB)
				var/datum/data/record/V = virusDB[ID]
				info += "<br><i>[V.fields["name"]][V.fields["nickname"] ? " \"[V.fields["nickname"]]\"" : ""] detected. Strength: [D.strength]. Robustness: [D.robustness]. Antigen: [D.get_antigen_string()]</i>"
			else
				info += "<br><i>Unknown [D.form] detected. Strength: [D.strength]</i>"

	var/datum/browser/popup = new(user, "\ref[src]", name, 600, 600, src)
	popup.set_content(info)
	popup.open()

/obj/item/device/antibody_scanner/preattack(var/atom/A, var/mob/user, proximity_flag)
	if(proximity_flag != 1)
		return
	if (isitem(A))
		var/obj/item/I = A
		playsound(user, 'sound/items/detscan.ogg', 50, 1)
		var/span = "warning"
		if(I.sterility <= 0)
			span = "danger"
		else if (I.sterility >= 100)
			span = "notice"
		to_chat(user,"<span class='[span]'>Scanning \the [I]...sterility level = [I.sterility]%</span>")
		if (istype(I,/obj/item/weapon/virusdish))
			var/obj/item/weapon/virusdish/dish = I
			if (dish.open && dish.contained_virus)
				to_chat(user,"<span class='danger'>However, since its lid has been openned, unprotected contact with the dish can result in infection.</span>")

	. = ..()


///////////////VIRUS DISH///////////////

var/list/virusdishes = list()

/obj/item/weapon/virusdish
	name = "growth dish"
	desc = "A petri dish fit to contain viral, bacteriologic, parasitic, or any other kind of pathogenic culture."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	icon = 'icons/obj/virology.dmi'
	icon_state = "virusdish"
	item_state = "virusdish"
	w_class = W_CLASS_SMALL
	sterility = 100//the outside of the dish is sterile.
	var/growth = 0
	var/info = ""
	var/analysed = FALSE
	var/datum/disease2/disease/contained_virus
	var/open = FALSE
	var/cloud_delay = 8 SECONDS//similar to a mob's breathing
	var/last_cloud_time = 0
	var/mob/last_openner


/obj/item/weapon/virusdish/New(loc)
	..()
	reagents = new(10)
	reagents.my_atom = src
	virusdishes.Add(src)

/obj/item/weapon/virusdish/Destroy()
	contained_virus = null
	processing_objects.Remove(src)
	virusdishes.Remove(src)
	..()

/obj/item/weapon/virusdish/clean_blood()
	..()
	if (open)
		contained_virus = null
		growth = 0
		if (analysed)
			info = ""
			analysed = FALSE
			visible_message("<span class='danger'>The info sticker falls of \the [src].</span>")
		update_icon()

/obj/item/weapon/virusdish/update_icon()
	overlays.len = 0
	if (!contained_virus)
		if (open)
			icon_state = "virusdish1"
		else
			icon_state = "virusdish"
		return
	icon_state = "virusdish-outline"
	var/image/I1 = image(icon,src,"virusdish-bottom")
	I1.color = contained_virus.color
	var/image/I2 = image(icon,src,"pattern-[contained_virus.pattern]")
	I2.color = contained_virus.pattern_color
	var/image/I3 = image(icon,src,"virusdish-[open?"open":"closed"]")
	I3.color = contained_virus.color
	overlays += I1
	if (open)
		overlays += I3
		I2.alpha = growth*255/200+127
		overlays += I2
	else
		overlays += I2
		overlays += I3
		I2.alpha = (growth*255/200+127)*60/100
		overlays += I2
		var/image/I4 = image(icon,src,"virusdish-reflection")
		overlays += I4
	if (analysed)
		overlays += "virusdish-label"
	else if (info != "" && copytext(info, 1, 9) == "OUTDATED")
		overlays += "virusdish-outdated"

/obj/item/weapon/virusdish/attack_hand(var/mob/user)
	..()
	infection_attempt(user,contained_virus,"attack_hand infection")

/obj/item/weapon/virusdish/attack_self(var/mob/user)
	open = !open
	update_icon()
	to_chat(user,"<span class='notice'>You [open?"open":"close"] dish's lid.</span>")
	if (open)
		last_openner = user
		if (contained_virus)
			contained_virus.log += "<br />[timestamp()] Containment Dish openned by [key_name(user)]."
		processing_objects.Add(src)
	else
		if (contained_virus)
			contained_virus.log += "<br />[timestamp()] Containment Dish closed by [key_name(user)]."
		processing_objects.Remove(src)
	infection_attempt(user,contained_virus,"attack_self infection")

/obj/item/weapon/virusdish/attackby(var/obj/item/weapon/W as obj,var/mob/living/carbon/user as mob)
	..()
	if(istype(W,/obj/item/weapon/hand_labeler))
		return
	if(user.a_intent == I_HURT && W.force)
		visible_message("<span class='danger'>The virus dish is smashed to bits!</span>")
		shatter(user)

/obj/item/weapon/virusdish/is_open_container()
	return open

/obj/item/weapon/virusdish/afterattack(var/atom/A, var/mob/user, var/adjacency_flag, var/click_params)
	. = ..()
	if(.)
		return

	if (!adjacency_flag)
		return

	if (open)
		if (istype(A,/obj/structure/reagent_dispensers))
			var/obj/structure/reagent_dispensers/S = A
			if(S.can_transfer(src, user))
				var/tx_amount = transfer_sub(A, src, S.amount_per_transfer_from_this, user)
				if (tx_amount > 0)
					to_chat(user, "<span class='notice'>You fill \the [src] with [tx_amount] units of the contents of \the [A].</span>")
					return tx_amount
		if (istype(A,/obj/item/weapon/reagent_containers))
			var/success = 0
			var/obj/container = A
			if (!container.is_open_container() && istype(container,/obj/item/weapon/reagent_containers) && !istype(container,/obj/item/weapon/reagent_containers/food/snacks))
				return

			if(A.is_open_container())
				success = transfer_sub(src, A, 10, user, log_transfer = TRUE)

			if (success > 0)
				to_chat(user, "<span class='notice'>You transfer [success] units of the solution to \the [A].</span>")

		if (istype(A,/obj/structure/toilet))
			var/obj/structure/toilet/T = A
			if (T.open)
				empty(user,A)
		if (istype(A,/obj/structure/urinal)||istype(A,/obj/structure/sink))
			empty(user,A)

/obj/item/weapon/virusdish/proc/empty(var/mob/user,var/atom/A)
	if (user && A)
		to_chat(user,"<span class='notice'>You empty \the [src]'s reagents into \the [A].</span>")
	reagents.clear_reagents()

/obj/item/weapon/virusdish/process()
	if (!contained_virus || !(contained_virus.spread & SPREAD_AIRBORNE))
		processing_objects.Remove(src)
		return
	if(world.time - last_cloud_time >= cloud_delay)
		last_cloud_time = world.time
		var/list/L = list()
		L["[contained_virus.uniqueID]-[contained_virus.subID]"] = contained_virus
		new /obj/effect/pathogen_cloud/core(get_turf(src), last_openner, virus_copylist(L), FALSE)


/obj/item/weapon/virusdish/random
	name = "growth dish"

/obj/item/weapon/virusdish/random/New(loc)
	..(loc)
	if (loc)//because fuck you /datum/subsystem/supply_shuttle/Initialize()
		contained_virus = get_random_weighted_disease(WDISH)
		var/list/anti = list(
			ANTIGEN_BLOOD	= 1,
			ANTIGEN_COMMON	= 1,
			ANTIGEN_RARE	= 0,
			ANTIGEN_ALIEN	= 0,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 1,
			EFFECT_DANGER_FLAVOR	= 2,
			EFFECT_DANGER_ANNOYING	= 2,
			EFFECT_DANGER_HINDRANCE	= 2,
			EFFECT_DANGER_HARMFUL	= 2,
			EFFECT_DANGER_DEADLY	= 0,
			)
		contained_virus.makerandom(list(50,90),list(10,100),anti,bad,src)
		growth = rand(5, 50)
		name = "growth dish (Unknown [contained_virus.form])"
		update_icon()
	else
		virusdishes.Remove(src)

/obj/item/weapon/virusdish/open
	icon_state = "virusdish1"

/obj/item/weapon/virusdish/open/New(loc)
	..()
	open = TRUE
	update_icon()

/obj/item/weapon/virusdish/random/open
	icon_state = "virusdish1"

/obj/item/weapon/virusdish/random/open/New(loc)
	..()
	open = TRUE
	update_icon()
	processing_objects.Add(src)

/obj/item/weapon/virusdish/throw_impact(atom/hit_atom, var/speed, mob/user)
	if(!..() && isturf(hit_atom))
		visible_message("<span class='danger'>The virus dish shatters on impact!</span>")
		shatter(user)

/obj/item/weapon/virusdish/proc/incubate(var/mutatechance=5,var/growthrate=3)
	if (contained_virus)
		if(!reagents.remove_reagent(VIRUSFOOD,0.2))
			growth = min(growth + growthrate, 100)
		if(!reagents.remove_reagent(WATER,0.2))
			growth = max(growth - growthrate, 0)
		contained_virus.incubate(src,mutatechance)

/obj/item/weapon/virusdish/on_reagent_change()
	if (contained_virus)
		var/datum/reagent/blood/blood = locate() in reagents.reagent_list
		if (blood)
			var/list/L = list()
			L["[contained_virus.uniqueID]-[contained_virus.subID]"] = contained_virus
			blood.data["virus2"] |= filter_disease_by_spread(virus_copylist(L),required = SPREAD_BLOOD)
	..()

/obj/item/weapon/virusdish/proc/shatter(var/mob/user)
	var/obj/effect/decal/cleanable/virusdish/dish = new(get_turf(src))
	dish.pixel_x = pixel_x
	dish.pixel_y = pixel_y
	if (contained_virus)
		dish.contained_virus = contained_virus.getcopy()
	dish.last_openner = key_name(user)
	src.transfer_fingerprints_to(dish)
	playsound(src, "shatter", 70, 1)
	var/image/I1
	var/image/I2
	if (contained_virus)
		I1 = image(icon,src,"brokendish-color")
		I1.color = contained_virus.color
		I2 = image(icon,src,"pattern-[contained_virus.pattern]b")
		I2.color = contained_virus.pattern_color
	else
		I1 = image(icon,src,"brokendish")
	dish.overlays += I1
	if (contained_virus)
		dish.overlays += I2
		contained_virus.log += "<br />[timestamp()] Containment Dish shattered by [key_name(user)]."
		if (contained_virus.spread & SPREAD_AIRBORNE)
			var/strength = contained_virus.infectionchance
			var/list/L = list()
			L["[contained_virus.uniqueID]-[contained_virus.subID]"] = contained_virus
			while (strength > 0)
				new /obj/effect/pathogen_cloud/core(get_turf(src), user, virus_copylist(L), FALSE)
				strength -= 40
	qdel(src)

/obj/item/weapon/virusdish/examine(var/mob/user)
	..()
	if(!contained_virus)
		to_chat(user, "<span class='notice'>This one appears to have been disinfected.</span>")
	if(open)
		to_chat(user, "<span class='notice'>Its lid is open!</span>")
	else
		to_chat(user, "<span class='notice'>Its lid is closed!</span>")
	if(info)
		to_chat(user, "<span class='info'>There is a sticker with some printed information on it. <a href ='?src=\ref[src];examine=1'>(Read it)</a></span>")

/obj/item/weapon/virusdish/Topic(href, href_list)
	if (!isobserver(usr))
		if(..())
			return TRUE
	if(href_list["examine"])
		var/datum/browser/popup = new(usr, "\ref[src]", name, 600, 300, src)
		popup.set_content(info)
		popup.open()

/obj/item/weapon/virusdish/infection_attempt(var/mob/living/perp,var/datum/disease2/disease/D)
	if (open)//If the dish is open, we may get infected by the disease inside on top of those that might be stuck on it.
		var/block = 0
		var/bleeding = 0
		if(attempt_colony(perp,contained_virus, "from exposure to \a [src]."))
			//Spacesuits cover feet, torso, and hands, but are ideal for a colony.
		else if (src in perp.held_items)
			block = perp.check_contact_sterility(HANDS)
			bleeding = perp.check_bodypart_bleeding(HANDS)
			if (!block)
				if (contained_virus.spread & SPREAD_CONTACT)
					perp.infect_disease2(contained_virus, notes="(Contact, from picking up \a [src])")
				else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
					perp.infect_disease2(contained_virus, notes="(Blood, from picking up \a [src])")
		else if (isturf(loc) && loc == perp.loc)//is our perp standing over the open dish?
			if (perp.lying)
				block = perp.check_contact_sterility(FULL_TORSO)
				bleeding = perp.check_bodypart_bleeding(FULL_TORSO)
			else
				block = perp.check_contact_sterility(FEET)
				bleeding = perp.check_bodypart_bleeding(FEET)
			if (!block)
				if (contained_virus.spread & SPREAD_CONTACT)
					perp.infect_disease2(contained_virus, notes="(Contact, from [perp.lying?"lying":"standing"] over a virus dish[last_openner ? " openned by [key_name(last_openner)]" : ""])")
				else if (bleeding && (contained_virus.spread & SPREAD_BLOOD))
					perp.infect_disease2(contained_virus, notes="(Blood, from [perp.lying?"lying":"standing"] over a virus dish[last_openner ? " openned by [key_name(last_openner)]" : ""])")
	..(perp,D)

///////////////GNA DISK///////////////

/obj/item/weapon/disk/disease
	name = "blank GNA disk"
	desc = "A disk for storing the structure of a pathogen's Glycol Nucleic Acid pertaining to a specific symptom."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk_virus"
	var/datum/disease2/effect/effect = null
	var/stage = 1

/obj/item/weapon/disk/disease/premade/New()
	name = "blank GNA disk (stage: [stage])"
	effect = new /datum/disease2/effect

/obj/item/weapon/disk/disease/examine(var/mob/user)
	..()
	if(effect)
		to_chat(user, "<span class='info'>Strength: [effect.multiplier]</span>")
		to_chat(user, "<span class='info'>Occurrence: [effect.chance]</span>")

/////////////TRAITOR STUFF//////////////////

/obj/item/weapon/storage/lockbox/diskettebox/syndisease/New()
	..()
	new /obj/item/weapon/disk/disease/invisible(src)
	new /obj/item/weapon/disk/disease/spoof/premade(src)

	var/list/potential_deadly_symptoms = list()

	for (var/diseasetype in subtypesof(/datum/disease2/effect))
		var/datum/disease2/effect/E = diseasetype
		if (initial(E.restricted))
			continue
		if (initial(E.stage) == 4 && initial(E.badness) == EFFECT_DANGER_DEADLY)
			potential_deadly_symptoms += diseasetype

	for(var/i = 1 to 3)
		if (potential_deadly_symptoms.len < 1)
			break
		var/obj/item/weapon/disk/disease/syndisk = new(src)
		var/effect_type = pick(potential_deadly_symptoms)
		syndisk.effect = new effect_type()
		syndisk.name = "\improper [syndisk.effect.name] GNA disk (Stage: [syndisk.effect.stage])"
		syndisk.stage = syndisk.effect.stage
		potential_deadly_symptoms -= effect_type
	update_icon()

/obj/item/weapon/disk/disease/spoof
	desc = "A disk for storing the structure of a pathogen's Glycol Nucleic Acid pertaining to a specific symptom. <span class='warning'>This one has some strange wiring on its back.</span>"

/obj/item/weapon/disk/disease/spoof/premade/New()
	..()
	var/list/potential_nice_symptoms = list()

	for (var/diseasetype in subtypesof(/datum/disease2/effect))
		var/datum/disease2/effect/E = diseasetype
		if (initial(E.restricted))
			continue
		if (initial(E.stage) == 4 && initial(E.badness) <= EFFECT_DANGER_FLAVOR)
			potential_nice_symptoms += diseasetype

	if (potential_nice_symptoms.len < 1)
		return
	var/effect_type = pick(potential_nice_symptoms)
	effect = new effect_type()
	name = "\improper [effect.name] GNA disk (Stage: [effect.stage])"
	stage = effect.stage

/obj/item/weapon/disk/disease/spoof/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if(istype(target,/obj/item/weapon/disk/disease))
		var/obj/item/weapon/disk/disease/D = target
		effect = D.effect
		to_chat(user,"<span class='notice'>Effect copied.</span>")
		name = "\improper [D.effect.name] GNA disk (Stage: [D.effect.stage])"
		stage = D.effect.stage
		effect.spoof = 1

/obj/item/weapon/disk/disease/invisible
	name = "\improper Waiting Syndrome GNA disk (Stage 1)"
	effect = new /datum/disease2/effect/invisible
	stage = 1

/obj/item/weapon/disk/disease/zombie
	name = "\improper Stubborn Brain Syndrome GNA disk (Stage 4)"
	effect = new /datum/disease2/effect/zombie
	stage = 4
