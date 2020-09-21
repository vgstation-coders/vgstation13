/obj/item/switchtool
	name = "switchtool"
	icon = 'icons/obj/switchtool.dmi'
	icon_state = "switchtool"
	desc = "A multi-deployable, multi-instrument, finely crafted multi-purpose tool. The envy of engineers everywhere."
	flags = FPRINT
	siemens_coefficient = 1
	force = 3
	w_class = W_CLASS_SMALL
	var/deploy_sound = "sound/weapons/switchblade.ogg"
	var/undeploy_sound = "sound/weapons/switchblade.ogg"
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	starting_materials = list(MAT_IRON = 15000)
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MATERIALS + "=9;" + Tc_BLUESPACE + "=5"
	var/hmodule = null

	//the colon separates the typepath from the name
	var/list/obj/item/stored_modules = list("/obj/item/screwdriver:screwdriver" = null,
											"/obj/item/wrench:wrench" = null,
											"/obj/item/wirecutters:wirecutters" = null,
											"/obj/item/crowbar:crowbar" = null,
											"/obj/item/chisel:chisel" = null,
											"/obj/item/device/multitool:multitool" = null)
	var/obj/item/deployed //what's currently in use
	var/removing_item = /obj/item/screwdriver //the type of item that lets you take tools out

/obj/item/switchtool/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target, /obj/item/storage)) //we place automatically
		return
	if(deployed)
		if(!deployed.preattack(target, user))
			if(proximity_flag)
				target.attackby(deployed, user)
			deployed.afterattack(target, user, proximity_flag, click_parameters)
		if(deployed.loc != src)
			for(var/module in stored_modules)
				if(stored_modules[module] == deployed)
					stored_modules[module] = null
			undeploy()
		return TRUE

/obj/item/switchtool/New()
	..()
	for(var/module in stored_modules) //making the modules
		var/new_type = text2path(get_module_type(module))
		stored_modules[module] = new new_type(src)

/obj/item/switchtool/examine(mob/user)
	..()
	to_chat(user, "This one is capable of holding [get_formatted_modules()].")

/obj/item/switchtool/attack_self(mob/user)
	if(!user)
		return

	if(deployed)
		edit_deploy(0)
		to_chat(user, "You store \the [deployed].")
		undeploy()
	else
		choose_deploy(user)

/obj/item/switchtool/attackby(var/obj/item/used_item, mob/user)
	if(istype(used_item, removing_item) && deployed) //if it's the thing that lets us remove tools and we have something to remove
		return remove_module(user)
	if(add_module(used_item, user))
		return TRUE
	else
		return ..()

/obj/item/switchtool/proc/get_module_type(var/module)
	return copytext(module, 1, findtext(module, ":"))

/obj/item/switchtool/proc/get_module_name(var/module)
	return copytext(module, findtext(module, ":") + 1)

//makes the string list of modules ie "a screwdriver, a knife, and a clown horn"
//does not end with a full stop, but does contain commas
/obj/item/switchtool/proc/get_formatted_modules()
	var/counter = 0
	var/module_string = ""
	for(var/module in stored_modules)
		counter++
		if(counter == stored_modules.len)
			module_string += "and \a [get_module_name(module)]"
		else
			module_string += "\a [get_module_name(module)], "
	return module_string

/obj/item/switchtool/proc/add_module(var/obj/item/used_item, mob/user)
	if(!used_item || !user)
		return FALSE

	for(var/module in stored_modules)
		var/type_path = text2path(get_module_type(module))
		if(istype(used_item, type_path))
			if(stored_modules[module])
				to_chat(user, "\The [src] already has a [get_module_name(module)].")
				return FALSE
			else
				if(user.drop_item(used_item, src))
					stored_modules[module] = used_item
					to_chat(user, "You successfully load \the [used_item] into \the [src]'s [get_module_name(module)] slot.")
					return TRUE

/obj/item/switchtool/proc/remove_module(mob/user)
	edit_deploy(0)
	deployed.forceMove(get_turf(user))
	for(var/module in stored_modules)
		if(stored_modules[module] == deployed)
			stored_modules[module] = null
			break
	to_chat(user, "You successfully remove \the [deployed] from \the [src].")
	playsound(src, "sound/items/screwdriver.ogg", 10, 1)
	undeploy()
	return TRUE

/obj/item/switchtool/proc/undeploy()
	playsound(src, undeploy_sound, 10, 1)
	edit_deploy(0)
	deployed = null
	overlays.len = 0
	w_class = initial(w_class)
	update_icon()

/obj/item/switchtool/proc/deploy(var/module)
	if(!(module in stored_modules))
		return FALSE
	if(!stored_modules[module])
		return FALSE
	if(deployed)
		return FALSE

	playsound(src, deploy_sound, 10, 1)
	deployed = stored_modules[module]
	hmodule = get_module_name(module)
	overlays += hmodule
	w_class = max(w_class, deployed.w_class)
	update_icon()
	return TRUE

/obj/item/switchtool/proc/edit_deploy(var/doedit)
	if(doedit) //Makes the deployed item take on the features of the switchtool for attack animations and text. Other bandaid fixes for snowflake issues can go here.
		sharpness = deployed.sharpness
		deployed.name = name
		deployed.icon = icon
		deployed.icon_state = icon_state
		deployed.overlays = overlays
		deployed.cant_drop = TRUE
	else //Revert the changes to the deployed item.
		sharpness = initial(sharpness)
		deployed.name = initial(deployed.name)
		deployed.icon = initial(deployed.icon)
		deployed.icon_state = initial(deployed.icon_state)
		deployed.overlays = initial(deployed.overlays)
		deployed.cant_drop = FALSE

/obj/item/switchtool/proc/choose_deploy(mob/user)
	var/list/potential_modules = list()
	for(var/module in stored_modules)
		if(stored_modules[module])
			if(get_module_name(module) == stored_modules[module].name) //same name so listing actually name in parentheses is redundant
				potential_modules += "[get_module_name(module)]"
			else
				potential_modules += "[get_module_name(module)] \[[stored_modules[module].name]\]"

	if(!potential_modules.len)
		to_chat(user, "No modules to deploy.")
		return

	else if(potential_modules.len == 1)
		for(var/m in stored_modules)
			if(stored_modules[m])
				deploy(m)
				edit_deploy(1)
				return TRUE
		return

	else
		var/chosen_module = input(user,"What do you want to deploy?", "[src]", "Cancel") as anything in potential_modules
		if(chosen_module != "Cancel")
			var/true_module = ""
			for(var/checkmodule in stored_modules)
				if(findtext(chosen_module, " \[") && get_module_name(checkmodule) == copytext(chosen_module, 1, findtext(chosen_module, " \[")))
					// bracket in name
					true_module = checkmodule
					break
				else if(get_module_name(checkmodule) == chosen_module)
					// no bracket in name
					true_module = checkmodule
					break
			if(deploy(true_module))
				to_chat(user, "You deploy \the [deployed].")
				edit_deploy(1)
			return TRUE
		return

/obj/item/switchtool/surgery
	name = "surgeon's switchtool"

	icon_state = "surg_switchtool"
	desc = "A switchtool containing most of the necessary items for impromptu surgery. For the surgeon on the go."

	origin_tech = Tc_MATERIALS + "=4;" + Tc_BLUESPACE + "=3;" + Tc_BIOTECH + "=3"
	stored_modules = list("/obj/item/scalpel:scalpel" = null,
						"/obj/item/circular_saw:circular saw" = null,
						"/obj/item/surgicaldrill:surgical drill" = null,
						"/obj/item/cautery:cautery" = null,
						"/obj/item/hemostat:hemostat" = null,
						"/obj/item/retractor:retractor" = null,
						"/obj/item/bonesetter:bone setter" = null,
						"/obj/item/FixOVein:fixovein" = null,
						"/obj/item/bonegel:bonegel"= null)

/obj/item/switchtool/surgery/undeploy()
	playsound(src, undeploy_sound, 10, 1)
	edit_deploy(0)
	if(istype(deployed, /obj/item/scalpel/laser))
		var/obj/item/scalpel/laser/L = deployed
		L.icon_state += (L.cauterymode) ? "_on" : "_off" //since edit_deploy(0) reverts icon_state to its initial value ("scalpel_laser1(or 2)") which doesn't actually exist
	else if(istype(deployed, /obj/item/retractor/manager))
		var/obj/item/retractor/manager/M = deployed
		M.icon_state += "_off"
	deployed = null
	overlays.len = 0
	w_class = initial(w_class)
	update_icon()

/obj/item/switchtool/swiss_army_knife
	name = "swiss army knife"
	sharpness_flags = 0
	icon_state = "s_a_k"
	desc = "Crafted by the Space Swiss for everyday use in military campaigns. Nonpareil."

	stored_modules = list("/obj/item/screwdriver:screwdriver" = null,
						"/obj/item/wrench:wrench" = null,
						"/obj/item/wirecutters:wirecutters" = null,
						"/obj/item/crowbar:crowbar" = null,
						"/obj/item/kitchen/utensil/knife/large:knife" = null,
						"/obj/item/kitchen/utensil/fork:fork" = null,
						"/obj/item/hatchet:hatchet" = null,
						"/obj/item/lighter/zippo:Zippo lighter" = null,
						"/obj/item/match/strike_anywhere:strike-anywhere match" = null,
						"/obj/item/pen:pen" = null)

/obj/item/switchtool/swiss_army_knife/undeploy()
	if(istype(deployed, /obj/item/lighter))
		var/obj/item/lighter/lighter = deployed
		lighter.lit = 0
	..()

/obj/item/switchtool/swiss_army_knife/deploy(var/module)
	..()
	if(istype(deployed, /obj/item/lighter))
		var/obj/item/lighter/lighter = deployed
		lighter.lit = 1
		..()

/obj/item/switchtool/swiss_army_knife/choose_deploy(mob/user)
	. = ..()
	if(. && deployed)
		sharpness_flags = deployed.sharpness_flags
	
/obj/item/switchtool/swiss_army_knife/undeploy()
	. = ..()
	sharpness_flags = 0

/obj/item/switchtool/switchblade
	name = "switchblade"
	icon_state = "switchblade"
	desc = "Half switch. Half blade. Half comb."
	stored_modules = list("/obj/item/kitchen/utensil/knife:knife" = null,
						"/obj/item/pocket_mirror/comb:comb" = null)

#define BT 1
#define ENGI 2
#define CB 4
#define SYNDI 8
#define NT 16
#define PS 32

//Unique RD switchtool, modules cannot be removed nor inserted to upgrade, but require techdisks to aquire new modules.
/obj/item/switchtool/holo
	name = "holo switchtool"
	icon = 'icons/obj/Htool_cyan.dmi'
	icon_state = "holo_switchtool"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_cyan.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_cyan.dmi')
	item_state = "Hswitchtool"
	desc = "A switchtool that can take on the form of nearly any tool. Its experimental hardlight emitter requires tech disks to help define its shape."
	var/brightness_max = 4
	var/brightness_min = 2
	deploy_sound = "sound/weapons/switchsound.ogg"
	undeploy_sound = "sound/weapons/switchsound.ogg"
	light_color =  LIGHT_COLOR_CYAN
	mech_flags = MECH_SCAN_ILLEGAL
	removing_item = null
	var/has_tech = 0
	var/hcolor = "CYAN"
	starting_materials = null

	stored_modules = list(//scalpel and flashlight are available to start and the scalpel is logically a laser one but the basic kind.
						"/obj/item/device/flashlight:flashlight" = null,
						"/obj/item/scalpel/laser:basic laser scalpel" = null)

//Checks the research type and level for the respective field, then adds them all to the stored modules while also filling the slot with that tool.
/obj/item/switchtool/holo/add_module(var/obj/item/D, mob/user)
	if(istype(D, /obj/item/disk/tech_disk))
		var/alreadyhas
		var/obj/item/disk/tech_disk/T = D
		var/datum/tech/disk_tech = T.stored
		if(istype(disk_tech, /datum/tech/biotech) && disk_tech.level >= 3)
			if(!(has_tech & BT))
				stored_modules["/obj/item/circular_saw:circular saw"] = new /obj/item/circular_saw(src)
				stored_modules["/obj/item/surgicaldrill:surgical drill"] = new /obj/item/surgicaldrill(src)
				stored_modules["/obj/item/cautery/laser:basic laser cautery"] = new /obj/item/cautery(src)
				stored_modules["/obj/item/hemostat:hemostat"] = new /obj/item/hemostat(src)
				stored_modules["/obj/item/retractor:retractor"] = new /obj/item/retractor(src)
				stored_modules["/obj/item/bonesetter:bone setter"] = new /obj/item/bonesetter(src)
				to_chat(user, "The holo switchtool has medical designs now!")
				has_tech |= BT
				return TRUE
			alreadyhas = "Biotech"
		if(istype(disk_tech, /datum/tech/engineering) && disk_tech.level >= 3)
			if(!(has_tech & ENGI))
				stored_modules["/obj/item/screwdriver:screwdriver"] = new /obj/item/screwdriver(src)
				stored_modules["/obj/item/wrench:wrench"] = new /obj/item/wrench(src)
				stored_modules["/obj/item/wirecutters:wirecutters"] = new /obj/item/wirecutters(src)
				stored_modules["/obj/item/crowbar:crowbar"] = new /obj/item/crowbar(src)
				stored_modules["/obj/item/device/multitool:multitool"] = new /obj/item/device/multitool(src)
				stored_modules["/obj/item/weldingtool/experimental:experimental welding tool"] = new /obj/item/weldingtool/experimental(src)
				to_chat(user, "The holo switchtool has engineering designs now!")
				has_tech |= ENGI
				return TRUE
			alreadyhas = "Engineering"
		if(istype(disk_tech, /datum/tech/combat) && disk_tech.level >= 5)
			if(!(has_tech & CB))
				stored_modules["/obj/item/shield/energy:energy combat shield"] = new /obj/item/shield/energy(src)
				to_chat(user, "The holo switchtool has a defensive design now!")
				has_tech |= CB
				return TRUE
			alreadyhas = "Combat"
		if(istype(disk_tech, /datum/tech/syndicate) && disk_tech.level >= 3)
			if(!(has_tech & SYNDI))
				stored_modules["/obj/item/melee/energy/sword/activated:energy sword"] = new /obj/item/melee/energy/sword/activated(src)
				to_chat(user, "The holo switchtool has an offensive design now!")
				has_tech |= SYNDI
				return TRUE
			alreadyhas = "Syndicate"
		if(istype(disk_tech, /datum/tech/nanotrasen) && disk_tech.level >= 5)
			if(!(has_tech & NT))
				stored_modules["/obj/item/melee/energy/hfmachete/activated:high-frequency machete"] = new /obj/item/melee/energy/hfmachete/activated(src)
				to_chat(user, "The holo switchtool has a secret offensive design now!")
				has_tech |= NT
				return TRUE
			alreadyhas = "Nanotrasen"
	//Joke module about power[clean/creep], this is dumb but exists.
	//How does a UV light clean even? It just sterilizes. I guess it works because it's like suit storages with their UV suit cleaner.
		if(istype(disk_tech, /datum/tech/powerstorage) && disk_tech.level >= 4)
			if(!(has_tech & PS))
				stored_modules["/obj/item/soap/holo:UV sterilizer"] = new /obj/item/soap/holo(src)
				to_chat(user, "The holo switchtool has a power clean design now!")
				has_tech |= PS
				return TRUE
			alreadyhas = "Power Storage"

		if(alreadyhas)
			to_chat(user, "The holo switchtool already has [alreadyhas] technology!")

#undef BT
#undef ENGI
#undef CB
#undef SYNDI
#undef NT
#undef PS

/obj/item/switchtool/holo/verb/togglecolor()
	set name = "Toggle Color"
	set category = "Object"

	if(hcolor == "CYAN")
		hcolor = "PINK"
		colorchange()
	else if(hcolor == "PINK")
		hcolor = "GREEN"
		colorchange()
	else if(hcolor == "GREEN")
		hcolor = "ORANGE"
		colorchange()
	else if(hcolor == "ORANGE")
		hcolor = "CYAN"
		colorchange()

/obj/item/switchtool/holo/proc/colorchange()
	if(hcolor == "CYAN")
		icon = 'icons/obj/Htool_cyan.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_cyan.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_cyan.dmi')
		light_color =  LIGHT_COLOR_CYAN
	else if(hcolor == "PINK")
		icon = 'icons/obj/Htool_pink.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_pink.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_pink.dmi')
		light_color =  LIGHT_COLOR_PINK
	else if(hcolor == "GREEN")
		icon = 'icons/obj/Htool_green.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_green.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_green.dmi')
		light_color =  LIGHT_COLOR_GREEN
	else if(hcolor == "ORANGE")
		icon = 'icons/obj/Htool_orange.dmi'
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/HTool_orange.dmi', "right_hand" = 'icons/mob/in-hand/right/HTool_orange.dmi')
		light_color =  LIGHT_COLOR_ORANGE

	if(istype(loc, /mob))
		var/mob/M = loc
		M.update_inv_hands()
	update_icon()
	set_light()

//for the inhand sprite changes
/obj/item/switchtool/holo/update_icon()
	if(deployed)
		item_state = "[hmodule]"
	else
		item_state = "Hswitchtool"

	if(istype(loc, /mob))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/switchtool/holo/IsShield()
	if(istype(deployed, /obj/item/shield/energy))
		return TRUE
	else
		return FALSE

//All modules make small amounts of light, flashlight making more.
/obj/item/switchtool/holo/deploy(var/module)
	if(!..())
		return FALSE
	set_light(brightness_min)
	hmodule = capitalize(hmodule)
	overlays += "[hmodule]"
	edit_deploy(1)
	update_icon()
	if(istype(deployed, /obj/item/device/flashlight))
		set_light(brightness_max)

//Since you can't turn off the welder inside the tool, I'm using the unused welder that very slowly regens fuel, 5 fuel per process().
//It can be refulled manually, but since it starts active you will blow up welder tanks if deployed and then put to a tank.
	if(istype(deployed, /obj/item/weldingtool/experimental))
		var/obj/item/weldingtool/experimental/weldingtool = deployed
		weldingtool.setWelding(1)

/obj/item/switchtool/holo/undeploy()
	if(istype(deployed, /obj/item/weldingtool/experimental))
		var/obj/item/weldingtool/experimental/weldingtool = deployed
		weldingtool.setWelding(0)
	..()
	set_light(0)

//switchtools maxed out intended for testing/spawning and maybe as loot. Don't forget to add any more tools added to these lists later
/obj/item/switchtool/holo/maxed
	stored_modules = list(
						"/obj/item/device/flashlight:flashlight" = null,
						"/obj/item/scalpel/laser:basic laser scalpel" = null,
						"/obj/item/circular_saw:circular saw" = null,
						"/obj/item/surgicaldrill:surgical drill" = null,
						"/obj/item/cautery/laser:basic laser cautery" = null,
						"/obj/item/hemostat:hemostat" = null,
						"/obj/item/retractor:retractor" = null,
						"/obj/item/bonesetter:bone setter" = null,
						"/obj/item/screwdriver:screwdriver" = null,
						"/obj/item/wrench:wrench" = null,
						"/obj/item/wirecutters:wirecutters" = null,
						"/obj/item/crowbar:crowbar" = null,
						"/obj/item/device/multitool:multitool" = null,
						"/obj/item/weldingtool/experimental:experimental welding tool" = null,
						"/obj/item/soap/holo:UV sterilizer" = null,
						"/obj/item/shield/energy:energy combat shield" = null,
						"/obj/item/melee/energy/sword/activated:energy sword" = null,
						"/obj/item/melee/energy/hfmachete/activated:high-frequency machete" = null
						)

/obj/item/switchtool/holo/maxed/add_module()
	return

/obj/item/switchtool/surgery/maxed
	stored_modules = list(
						"/obj/item/scalpel/laser/tier2:scalpel" = null,
						"/obj/item/circular_saw/plasmasaw:circular saw" = null,
						"/obj/item/surgicaldrill/diamond:surgical drill" = null,
						"/obj/item/cautery/laser/tier2:cautery" = null,
						"/obj/item/hemostat/pico:hemostat" = null,
						"/obj/item/retractor/manager:retractor" = null,
						"/obj/item/bonesetter/bone_mender:bone setter" = null,
						"/obj/item/FixOVein/clot:fixovein" = null,
						"/obj/item/bonegel:bonegel" = null)

/obj/item/switchtool/engineering
	name = "\improper Engineering switchtool"
	desc = "A switchtool designed specifically to be the perfect companion for an Engineer."
	stored_modules = list(
		"/obj/item/crowbar:crowbar" = null,
		"/obj/item/screwdriver:screwdriver" = null,
		"/obj/item/weldingtool/hugetank:welding tool" = null,
		"/obj/item/wirecutters:wirecutters" = null,
		"/obj/item/wrench:wrench" = null,
		"/obj/item/device/multitool:multitool" = null,
		"/obj/item/stack/cable_coil/persistent:cable coil" = null,
		"/obj/item/device/t_scanner:T-ray scanner" = null,
		"/obj/item/device/analyzer/scope:atmospheric analysis scope" = null,
		"/obj/item/solder/pre_fueled:soldering iron" = null,
		"/obj/item/device/silicate_sprayer:silicate sprayer" = null
		)

/obj/item/switchtool/engineering/deploy(var/module)
	if(!..())
		return FALSE
	if(iswelder(deployed))
		var/obj/item/weldingtool/W = deployed
		W.welding = 1
		W.status = 1
	if(istype(deployed, /obj/item/device/t_scanner))
		var/obj/item/device/t_scanner/T = deployed
		T.attack_self()

/obj/item/switchtool/engineering/undeploy()
	if(istype(deployed, /obj/item/device/t_scanner))
		var/obj/item/device/t_scanner/T = deployed
		T.attack_self()
	..()

/obj/item/switchtool/engineering/mech
	stored_modules = list(
		"/obj/item/crowbar:crowbar" = null,
		"/obj/item/screwdriver:screwdriver" = null,
		"/obj/item/weldingtool/hugetank/mech:welding tool" = null,
		"/obj/item/wirecutters:wirecutters" = null,
		"/obj/item/wrench:wrench" = null,
		"/obj/item/device/multitool:multitool" = null,
		"/obj/item/stack/cable_coil/persistent:cable coil" = null,
		"/obj/item/device/t_scanner:T-ray scanner" = null,
		"/obj/item/device/analyzer/scope:atmospheric analysis scope" = null,
		"/obj/item/solder/pre_fueled:soldering iron" = null,
		"/obj/item/device/silicate_sprayer:silicate sprayer" = null
		)
