/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "captain"
	siemens_coefficient = 0
	_color = "captain"
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/centcom
	desc = "Regal green gloves, with a nice gold trim. Lordy."
	name = "nanotrasen leader's gloves"
	icon_state = "centcom"
	item_state = "centcom"
	siemens_coefficient = 0
	_color = "centcom"
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "black"
	siemens_coefficient = 1.0
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are somewhat fire and impact-resistant."
	name = "\improper SWAT Gloves"
	icon_state = "black"
	item_state = "black"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "black"
	item_state = "black"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "latex"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	_color = "medical"				//matches cmo stamp
	species_fit = list(VOX_SHAPED)
	sterility = 100

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botany gloves"
	icon_state = "leather"
	item_state = "leather"
	permeability_coefficient = 0.9
	siemens_coefficient = 0.9
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/batmangloves
	desc = "Used for handling all things bat related."
	name = "batgloves"
	icon_state = "bmgloves"
	item_state = "bmgloves"
	_color = "bmgloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/bikergloves
	name = "Biker's Gloves"
	icon_state = "biker-gloves"
	item_state = "biker-gloves"
	_color = "bikergloves"

/obj/item/clothing/gloves/megagloves
	desc = "Uncomfortably bulky armored gloves."
	name = "DRN-001 Gloves"
	icon_state = "megagloves"
	item_state = "megagloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/protogloves
	desc = "Funcionally identical to the DRN-001 model's, but in red!"
	name = "Prototype Gloves"
	icon_state = "protogloves"
	item_state = "protogloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/megaxgloves
	desc = "An upgrade to the DRN-001's gauntlets, retains the uncomfortable armor, but comes with white gloves!"
	name = "Maverick Hunter gloves"
	icon_state = "megaxgloves"
	item_state = "megaxgloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/joegloves
	desc = "Large grey gloves, very similar to the Prototype's."
	name = "Sniper Gloves"
	icon_state = "joegloves"
	item_state = "joegloves"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/doomguy
	desc = ""
	name = "Doomguy's gloves"
	icon_state = "doom"
	item_state = "doom"

/obj/item/clothing/gloves/knuckles
	desc = "A pair of classic metal knuckles that are designed to increase tissue damage and bone fractures when punching."
	name = "brass knuckles"
	icon_state = "knuckles"
	item_state = "knuckles"

	attack_verb = list("punches")
	bonus_knockout = 17 //Slight knockout chance increase.
	damage_added = 3 //Add 3 damage to unarmed attacks when worn
	force = 5 //Deal 5 damage if hit with this item in hand

/obj/item/clothing/gloves/knuckles/dexterity_check()
	return 0 //Wearing these knuckles makes you less dexterious (so, for example, you can't use computers)

/obj/item/clothing/gloves/knuckles/spiked
	name = "spiked knuckles"
	desc = "A pair of metal knuckles embedded with dull, but nonetheless painful spikes."
	icon_state = "knuckles_spiked"
	item_state = "knuckles_spiked"

	bonus_knockout = 25
	damage_added = 5
	force = 7

/obj/item/clothing/gloves/anchor_arms
	name = "Anchor Arms"
	desc = "When you're a jerk, everybody loves you."
	icon_state = "anchorarms"
	item_state = "anchorarms"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/neorussian
	name = "neo-Russian gloves"
	desc = "Utilizes a non-slip technology that allows you to never drop your precious bottles of vodka."
	icon_state = "nr_gloves"
	item_state = "nr_gloves"
	heat_conductivity = INS_GLOVES_HEAT_CONDUCTIVITY

/obj/item/clothing/gloves/neorussian/fingerless
	name = "neo-Russian fingerless gloves"
	desc = "For these tense combat situations when you just have to pick your nose."
	icon_state = "nr_fgloves"
	item_state = "nr_fgloves"

//Like powerfist from fallout, but NUCLEAR. It throws people back and adds 50 damage every 15 seconds. Also it irradiates you
/obj/item/clothing/gloves/powerfist
	name = "nuclear powerfists"
	desc = "A pair of nuclear-powered contraptions meant to be worn on your hands, they massively increase force and energy of your punches. The reactor is recharged with uranium, and must cool down after every punch."

	icon_state = "powerfist"

	//Amount of fuel needed for increased damage, and for the knockback. Both increased damage and knockback use this amount, so in practice TWICE this value is used per punch
	//Vial can hold 25 units max
	//12.5 per punch - two punches per full fuel vial
	var/const/fuel_cost = 6.25

	var/last_punch = 0
	var/recharge_time = 10 SECONDS

	var/powered_damage_added = 50
	var/radiation_per_punch = 15
	var/stunforce = 5

	var/obj/item/weapon/reagent_containers/glass/beaker/vial/vial = /obj/item/weapon/reagent_containers/glass/beaker/vial //Vial with the fuel

	var/fuel_overlay
	var/ready_overlay

/obj/item/clothing/gloves/powerfist/full
	vial = /obj/item/weapon/reagent_containers/glass/beaker/vial/uranium

/obj/item/clothing/gloves/powerfist/New()
	..()

	if(ispath(vial))
		vial = new vial(src)

	update_icon()

/obj/item/clothing/gloves/powerfist/Destroy()
	qdel(vial)
	vial = null

	..()

/obj/item/clothing/gloves/powerfist/examine(mob/user)
	..()

	if(!vial)
		to_chat(user, "<span class='info'>There is no fuel container inside.</span>")
	else
		to_chat(user, "<span class='info'>The fuel container is [round(vial.reagents.total_volume / vial.reagents.maximum_volume * 100)]% full.</span>")

	if(is_ready())
		to_chat(user, "<span class='info'>\The [src] are ready.</span>")

/obj/item/clothing/gloves/powerfist/update_icon()
	..()

	overlays.Remove(fuel_overlay)
	overlays.Remove(ready_overlay)

	if(!vial)
		fuel_overlay = null
	else
		var/fuel_amount = vial.reagents.get_reagent_amount(URANIUM)
		switch(fuel_amount)
			if(0)
				fuel_overlay = "powerfist_no_fuel"
			if(0.1 to fuel_cost)
				fuel_overlay = "powerfist_fuel_25"
			if(fuel_cost to fuel_cost*2)
				fuel_overlay = "powerfist_fuel_50"
			if(fuel_cost*2 to fuel_cost*3)
				fuel_overlay = "powerfist_fuel_75"
			else
				fuel_overlay = "powerfist_fuel_100"

	if(!is_ready())
		ready_overlay = null
	else
		ready_overlay = "powerfist_ready"

	if(ready_overlay)
		overlays.Add(ready_overlay)
	if(fuel_overlay)
		overlays.Add(fuel_overlay)

/obj/item/clothing/gloves/powerfist/get_damage_added()
	if(use_fuel(fuel_cost))
		return powered_damage_added

	return ..()

/obj/item/clothing/gloves/powerfist/proc/is_ready()
	return (last_punch + recharge_time < world.time)

/obj/item/clothing/gloves/powerfist/on_punch(mob/user, mob/living/victim)
	if(istype(victim) && use_fuel(fuel_cost))
		to_chat(user, "<span class='notice'>As \the [src] activate, you feel a truly powerful force assisting your punch.</span>")
		playsound(src, 'sound/mecha/mechentry.ogg', 100, 1)

		victim.throw_at(get_edge_target_turf(loc, loc.dir), 5, 1)
		victim.Stun(stunforce)
		victim.Knockdown(stunforce)
		victim.apply_effect(STUTTER, stunforce)

		last_punch = world.time
		update_icon()
		spawn(recharge_time + 10)
			update_icon()

/obj/item/clothing/gloves/powerfist/attack_self(mob/user)
	user.put_in_hands(vial)
	to_chat(user, "<span class='info'>You eject \the [vial] from \the [src].</span>")
	vial = null
	update_icon()

/obj/item/clothing/gloves/powerfist/attackby(obj/item/W, mob/user)
	if(vial)
		return

	if(istype(W, /obj/item/weapon/reagent_containers/glass/beaker/vial))
		if(user.drop_item(W))
			to_chat(user, "<span class='info'>You insert \the [W] into \the [src].</span>")
			W.forceMove(src)
			vial = W
			update_icon()

/obj/item/clothing/gloves/powerfist/proc/use_fuel(amount)
	if(!is_ready())
		return FALSE
	if(!vial || !vial.reagents)
		return FALSE
	if(!vial.reagents.has_reagent(URANIUM, amount))
		return FALSE

	vial.reagents.remove_reagent(URANIUM, amount)

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.apply_radiation(radiation_per_punch, RAD_INTERNAL) //Direct contact with skin

	update_icon()

	return TRUE

/obj/item/clothing/gloves/frankgloves
	desc = "These gloves chill you, thrill you, and fulfill you; like a creature of the night."
	name = "Dr. Frank's gloves"
	icon_state = "frankgloves"
	item_state = "frankgloves"

/obj/item/clothing/gloves/warping_claws
	name = "warping claws"
	desc = "These enchanted blades are capable of cutting through space itself. To use them, equip them and then throw at wherever you wish to go with an empty hand."
	icon_state = "warping_claws"
	item_state = "warping_claws"
	damage_added = 17
	sharpness_added = 2
	hitsound_added = 'sound/weapons/slice.ogg'
	attack_verb_override = "claws"

/obj/item/clothing/gloves/warping_claws/dexterity_check()
	return FALSE

/obj/item/clothing/gloves/warping_claws/on_wearer_threw_item(mob/user, atom/target, atom/movable/thrown)
	if(target && !thrown)
		var/obj/effect/portal/tear/P1 = new (get_turf(user),5 SECONDS)
		var/obj/effect/portal/tear/P2 = new (get_turf(target),5 SECONDS)
		P1.target = P2
		P2.target = P1
		P1.blend_icon(P2)
		P2.blend_icon(P1)
		P1.owner = user
		P2.owner = user
		P1.teleport(user)

/obj/item/clothing/gloves/mining
	name = "fists of the rockernaut"
	desc = "Start 'em up and rock and roll!"
	icon_state = "rockernaut_gloves"
	item_state = "rockernaut_gloves"
	damage_added = 5
	hitsound_added = 'sound/weapons/heavysmash.ogg'

/obj/item/clothing/gloves/mining/dexterity_check()
	return FALSE

/obj/item/clothing/gloves/mining/Touch(var/atom/A, mob/user, proximity)
	if(proximity && istype(A, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = A
		if(do_after(user, A, max(M.minimum_mine_time,4 SECONDS*M.mining_difficulty)))
			playsound(get_turf(src), hitsound_added, 100, 1, vary = 0)
			user.do_attack_animation(M, src)
			M.GetDrilled(0)

/obj/item/clothing/gloves/mining/attack_icon()
	return image(icon = 'icons/mob/attackanims.dmi', icon_state = "rockernaut")