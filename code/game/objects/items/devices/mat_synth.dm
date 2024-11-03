#define MAX_MATSYNTH_MATTER 60
#define MAT_SYNTH_ROBO 50

#define MAT_COST_COMMON		1
#define MAT_COST_MEDIUM		5
#define MAT_COST_RARE		15

var/static/list/mat2type = list(
	MAT_IRON = /obj/item/stack/sheet/metal,
	MAT_GLASS = /obj/item/stack/sheet/glass/glass,
	MAT_SILVER = /obj/item/stack/sheet/mineral/silver,
	MAT_GOLD = /obj/item/stack/sheet/mineral/gold,
	MAT_DIAMOND = /obj/item/stack/sheet/mineral/diamond,
	MAT_PLASMA = /obj/item/stack/sheet/mineral/plasma,
	MAT_URANIUM = /obj/item/stack/sheet/mineral/uranium,
	MAT_PLASTIC = /obj/item/stack/sheet/mineral/plastic,
	MAT_MYTHRIL = /obj/item/stack/sheet/mineral/mythril,
	MAT_CLOWN = /obj/item/stack/sheet/mineral/clown,
	MAT_PHAZON = /obj/item/stack/sheet/mineral/phazon,
)

/obj/item/device/material_synth
	name = "material synthesizer"
	desc = "A device capable of producing very little material with a great deal of investment. Use wisely."
	icon = 'icons/obj/device.dmi'
	icon_state = "mat_synthoff"

	flags = FPRINT
	siemens_coefficient = 1
	w_class = W_CLASS_MEDIUM
	origin_tech = Tc_ENGINEERING + "=4;" + Tc_MATERIALS + "=5;" + Tc_POWERSTORAGE + "=3"

	var/mode = 1 //0 is material selection, 1 is material production

	var/obj/item/stack/sheet/active_material = /obj/item/stack/sheet/metal
	var/list/materials_scanned = list("metal" = /obj/item/stack/sheet/metal,
									  "glass" = /obj/item/stack/sheet/glass/glass,
									  "reinforced glass" = /obj/item/stack/sheet/glass/rglass,
									  "plasteel" = /obj/item/stack/sheet/plasteel)

	var/list/can_scan = list(/obj/item/stack/sheet/metal,
							/obj/item/stack/sheet/glass/,
							/obj/item/stack/sheet/wood,
							/obj/item/stack/sheet/plasteel,
							/obj/item/stack/sheet/mineral)
	var/list/cant_scan = list()
	var/matter = 0

/obj/item/device/material_synth/preloaded
	matter = MAX_MATSYNTH_MATTER

/obj/item/device/material_synth/preloaded/admin
	materials_scanned = list("metal" = /obj/item/stack/sheet/metal,
							 "glass" = /obj/item/stack/sheet/glass/glass,
							 "reinforced glass" = /obj/item/stack/sheet/glass/rglass,
							 "plasteel" = /obj/item/stack/sheet/plasteel,
							 "plasma glass" = /obj/item/stack/sheet/glass/plasmaglass,
							 "reinforced plasma glass" = /obj/item/stack/sheet/glass/plasmarglass,
							 "silver" = /obj/item/stack/sheet/mineral/silver,
							 "gold" = /obj/item/stack/sheet/mineral/gold,
							 "diamond" = /obj/item/stack/sheet/mineral/diamond,
							 "plasma" = /obj/item/stack/sheet/mineral/plasma,
							 "uranium" = /obj/item/stack/sheet/mineral/uranium,
							 "plastic" = /obj/item/stack/sheet/mineral/plastic,
							 "mythril" = /obj/item/stack/sheet/mineral/mythril,
							 "bananium" = /obj/item/stack/sheet/mineral/clown,
							 "phazon" = /obj/item/stack/sheet/mineral/phazon,
							 "telecrystal" = /obj/item/stack/sheet/mineral/telecrystal,
							 "sandstone" = /obj/item/stack/sheet/mineral/sandstone,
							 "bricks" = /obj/item/stack/sheet/mineral/brick)

/obj/item/device/material_synth/robot/engiborg //Cyborg version, has less materials but can make rods n shit as well as scan.
	materials_scanned = list("metal" = /obj/item/stack/sheet/metal,
							 "glass" = /obj/item/stack/sheet/glass/glass,
							 "reinforced glass" = /obj/item/stack/sheet/glass/rglass,
							 "floor tiles" = /obj/item/stack/tile/metal,
							 "metal rods" = /obj/item/stack/rods)
	cant_scan = list(/obj/item/stack/sheet/mineral/clown, /obj/item/stack/sheet/mineral/phazon)

/obj/item/device/material_synth/robot/mommi //MoMMI version, a few more materials to start with.
	materials_scanned = list("metal" = /obj/item/stack/sheet/metal,
							 "glass" = /obj/item/stack/sheet/glass/glass,
							 "reinforced glass" = /obj/item/stack/sheet/glass/rglass,
							 "plasteel" = /obj/item/stack/sheet/plasteel,
							 "plasma glass" = /obj/item/stack/sheet/glass/plasmaglass,
							 "reinforced plasma glass" = /obj/item/stack/sheet/glass/plasmarglass)

/obj/item/device/material_synth/robot/soviet
	materials_scanned = list("metal" = /obj/item/stack/sheet/metal,
							"glass" = /obj/item/stack/sheet/glass/glass,
							 "reinforced glass" = /obj/item/stack/sheet/glass/rglass,
							 "plasteel" = /obj/item/stack/sheet/plasteel,
							 "plasma glass" = /obj/item/stack/sheet/glass/plasmaglass,
							 "reinforced plasma glass" = /obj/item/stack/sheet/glass/plasmarglass,
							 "silver" = /obj/item/stack/sheet/mineral/silver,
							 "gold" = /obj/item/stack/sheet/mineral/gold,
							 "diamond" = /obj/item/stack/sheet/mineral/diamond,
							 "plasma" = /obj/item/stack/sheet/mineral/plasma,
							 "uranium" = /obj/item/stack/sheet/mineral/uranium,
							 "plastic" = /obj/item/stack/sheet/mineral/plastic)

/obj/item/device/material_synth/update_icon()
	icon_state = "mat_synth[mode ? "on" : "off"]"

/obj/item/device/material_synth/proc/get_mat_cost(var/per_unit)
	if (per_unit < 2000)
		return MAT_COST_RARE
	else if (per_unit < 3750)
		return MAT_COST_MEDIUM
	else
		return MAT_COST_COMMON

/obj/item/device/material_synth/proc/create_material(mob/user, var/material)
	var/obj/item/stack/sheet/material_type = material

	if (material_type && matter >= 1)
		var/modifier = get_mat_cost(initial(active_material.perunit))
		var/unit_can_produce
		var/tospawn

		unit_can_produce = round(matter / modifier)

		if (unit_can_produce >= 1)
			tospawn = input(user, "How many sheets of [initial(material_type.name)] do you want to synthesize? (0 - [unit_can_produce])", "Material Synthesizer") as num
			tospawn = clamp(round(tospawn, 1), 0, unit_can_produce)

			if (tospawn >= 1 && TakeCost(tospawn, modifier, user))
				var/obj/item/stack/sheet/spawned_sheet = new material_type(get_turf(src))
				spawned_sheet.amount = tospawn


		else
			to_chat(user, "<span class='warning'>\The [src] matter is not enough to create the selected material!</span>")
	else if (matter >= 1)
		to_chat(user, "<span class='warning'>You must select a sheet type first!</span>")
	else
		to_chat(user, "<span class='warning'>\The [src] is empty!</span>")


/obj/item/device/material_synth/robot/create_material(mob/user, var/material)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R && R.cell)
			if(R.cell.charge)
				var/obj/item/stack/sheet/material_type = material
				if(material_type)
					var/modifier = get_mat_cost(initial(active_material.perunit))
					var/amount = input(user, "How many sheets of [initial(material_type.name)] do you want to synthesize? (0 - 50)", "Material Synthesizer") as num
					amount = clamp(round(amount, 1), 0, 50)
					if(amount)
						if(TakeCost(amount, modifier, R))
							var/obj/item/stack/sheet/inside_sheet = (locate(material_type) in R.module.modules)
							var/newsheet = FALSE
							if(!inside_sheet)
								inside_sheet = new material_type(R.module)
								R.module.modules += inside_sheet
								newsheet = TRUE
							if((inside_sheet.amount + (amount*(!newsheet))) <= inside_sheet.max_amount) // only add amount if no new sheet
								inside_sheet.amount += amount-(inside_sheet.amount*newsheet) // make equal to amount if no new sheet
								to_chat(R, "<span class='notice'>Added [amount] of [initial(material_type.name)] to the stack.</span>")
							else
								if(inside_sheet.amount <= inside_sheet.max_amount)
									var/transfer_amount = min(inside_sheet.max_amount - inside_sheet.amount, amount)
									inside_sheet.amount += (transfer_amount-newsheet) // minus one if new sheet
									amount -= transfer_amount
								if(amount >= 1 && (inside_sheet.amount >= inside_sheet.max_amount))
									to_chat(R, "<span class='warning'>Dropping [amount] sheets, you cannot hold anymore [initial(material_type.name)].</span>")
									var/obj/item/stack/sheet/dropped_sheet = new material_type(get_turf(src))
									dropped_sheet.amount = amount-newsheet // minus one if new sheet
							R.module.rebuild()
							R.hud_used.update_robot_modules_display()
						else
							to_chat(R, "<span class='warning'>You can't make that much [initial(material_type.name)] without shutting down!</span>")
				else
					to_chat(R, "<span class='warning'>You need to select a sheet type first!</span>")
			else
				to_chat(R, "<span class='warning'>Your cell has no charge to use this with!</span>")
		else
			to_chat(R, "<span class='warning'>You need a cell to use this!</span>")

/obj/item/device/material_synth/preloaded/admin/create_material(mob/user, var/material)
	var/obj/item/stack/sheet/material_type = material

	if (material_type)
		var/tospawn = input(user, "How many sheets of [initial(material_type.name)] do you want to synthesize?", "Material Synthesizer") as num

		if (tospawn >= 1)
			var/obj/item/stack/sheet/spawned_sheet = new material_type(get_turf(src))
			spawned_sheet.amount = tospawn
	else
		to_chat(user, "<span class='warning'>You must select a sheet type first!</span>")

/obj/item/device/material_synth/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return 0 // not adjacent
	if(istype(target,/obj/machinery/r_n_d/fabricator))
		var/obj/machinery/r_n_d/fabricator/F = target
		for(var/mat in F.materials.storage)
			if((mat in mat2type) && F.materials.storage[mat])
				var/obj/item/stack/sheet/S = mat2type[mat]
				if(S in cant_scan)
					to_chat(user, "<span class='warning'>Your [src.name] does not contain this functionality to scan [initial(S.name)].</span>")
				else if(initial(S.name) in materials_scanned)
					to_chat(user, "<span class='warning'>You have already scanned [initial(S.name)].</span>")
				else
					materials_scanned["[initial(S.name)]"] = S
					to_chat(user, "<span class='notice'>You successfully scan [initial(S.name)] into \the [src]'s material banks.</span>")
		return 1
	if(is_type_in_list(target, can_scan) && !is_type_in_list(target, cant_scan))
		for(var/matID in materials_scanned)
			if(materials_scanned[matID] == target.type)
				to_chat(user, "<span class='warning'>You have already scanned \the [target].</span>")
				return
		materials_scanned["[initial(target.name)]"] = target.type
		to_chat(user, "<span class='notice'>You successfully scan \the [target] into \the [src]'s material banks.</span>")
		return 1
	else if(istype(target, /obj/item/stack/sheet)) //We can't scan it, but, only display an error when trying to scan a sheet.
		to_chat(user, "<span class='warning'>Your [src.name] does not contain this functionality to scan this type of material.</span>")
	return ..()

/obj/item/device/material_synth/examine(mob/user)
	..()
	if(istype(src, /obj/item/device/material_synth/robot))
		to_chat(user, "It's been set to draw power from a power cell.")
	else
		to_chat(user, "It currently holds [matter]/[MAX_MATSYNTH_MATTER] matter-units.")

/obj/item/device/material_synth/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item/stack/rcd_ammo))
		var/obj/item/stack/rcd_ammo/RA = O
		if(matter + 10 > MAX_MATSYNTH_MATTER)
			to_chat(user, "<span class='warning'>\The [src] can't take any more material right now.</span>")
			return
		else
			matter += 10
			playsound(src, 'sound/machines/click.ogg', 20, 1)
			RA.use(1)
			to_chat(user, "<span class='notice'>The material synthetizer now holds [matter]/[MAX_MATSYNTH_MATTER] matter-units.</span>")
	return ..()

/obj/item/device/material_synth/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		var/matter_rng = rand(5, 25)
		if(matter >= matter_rng)
			var/obj/item/device/spawn_item = pick(existing_typesof(/obj/item/device)) //we make any kind of device. It's a surprise!
			user.visible_message("<span class='warning'>\The [src] pops and fizzles, before creating... \a [initial(spawn_item.name)]?</span>", \
									"<span class='warning'>\The [src] pops and fizzles, before creating... \a [initial(spawn_item.name)]?</span>", \
									"<span class='warning'>You hear a loud popping noise.</span>")
			sleep(10)
			new spawn_item(get_turf(src))
			matter -= matter_rng
			return 1
		else
			visible_message("<span class='danger'>The lack of matter in \the [src] shorts out the device!</span>")
			explosion(src.loc, 0, 0, 1, 2) //traitors - fuck them, am I right?
			qdel(src)
	else
		to_chat(user, "<span class='warning'>You don't think you can do that again.</span>")

/obj/item/device/material_synth/preloaded/admin/emag_act(mob/user)
	var/obj/item/device/spawn_item = pick(existing_typesof(/obj/item/device)) //we make any kind of device. It's a surprise!
	user.visible_message("<span class='warning'>\The [src] pops and fizzles, before creating... \a [initial(spawn_item.name)]?</span>", \
							"<span class='warning'>\The [src] pops and fizzles, before creating... \a [initial(spawn_item.name)]?</span>", \
							"<span class='warning'>You hear a loud popping noise.</span>")
	new spawn_item(get_turf(src))
	return 1

/obj/item/device/material_synth/attack_self(mob/user)
	if(materials_scanned.len)
		var/selection = materials_scanned[input("Select the material you'd like to synthesize", "Change Material Type") as null|anything in materials_scanned]
		if(selection)
			active_material = selection
			to_chat(user, "<span class='notice'>You switch \the [src] to synthesize [initial(active_material.name)]</span>")
		else
			active_material = null
			return
	else
		to_chat(user, "<span class='warning'>ERROR: NO MATERIAL DATA FOUND</span>")
		return 0
	create_material(user, active_material)

/obj/item/device/material_synth/proc/TakeCost(var/spawned, var/modifier, mob/user)
	if(spawned && matter >= round(spawned*modifier))
		matter -= round(spawned * modifier)
		return 1
	return 0

/obj/item/device/material_synth/robot/TakeCost(var/spawned, var/modifier, mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		return R.cell.use(spawned * modifier * MAT_SYNTH_ROBO)
	return
