// TODO: remove the robot.mmi variable and completely rely on the robot component system

/datum/robot_component
	var/name
	var/installed = COMPONENT_MISSING
	var/powered = FALSE
	var/toggled = TRUE
	var/brute_damage = 0
	var/electronics_damage = 0
	var/vulnerability = 1
	var/energy_consumption = 0
	var/max_damage = 30 //WHY THE FUCK IS THE DEFAULT MAX DAMAGE 30 ARE YOU STUPID
	var/mob/living/silicon/robot/owner
	var/upgraded = FALSE
	var/external_type = null // The actual device object that has to be installed for this.
	var/obj/item/wrapped = null // The wrapped device(e.g. radio), only set if external_type isn't null

/datum/robot_component/New(mob/living/silicon/robot/R)
	src.owner = R

/datum/robot_component/proc/install(var/mob/user,var/obj/item/W)
	if(istype(W,/obj/item/robot_parts/robot_component))
		var/obj/item/robot_parts/robot_component/I = W
		installed = COMPONENT_INSTALLED
		wrapped = I
		electronics_damage = I.electronics_damage
		brute_damage = I.brute_damage
		vulnerability = I.vulnerability
		upgraded = I.isupgrade
		to_chat(user, "<span class='notice'>You install the [I.name].</span>")
		if(owner.can_diagnose())
			to_chat(owner, "<span class='info' style=\"font-family:Courier\">New [I.name] installed.</span>")

/datum/robot_component/proc/uninstall(var/mob/user,var/loud = FALSE)
	if(installed == COMPONENT_INSTALLED)
		installed = FALSE
	if(wrapped)
		to_chat(user, "You remove \the [wrapped].")
		if(owner.can_diagnose())
			to_chat(owner, "<span class='info' style=\"font-family:Courier\">[installed == COMPONENT_BROKEN ? "Destroyed [src]" : "Functional [wrapped.name]"] removed.</span>")
		if(istype(wrapped,/obj/item/robot_parts/robot_component))
			var/obj/item/robot_parts/robot_component/I = wrapped
			I.brute_damage = brute_damage
			I.electronics_damage = electronics_damage
			I.isupgrade = upgraded

/datum/robot_component/proc/destroy()
	var/obj/item/broken_device/G = new/obj/item/broken_device
	G.component = wrapped.type // the broken component now "remembers" the component it used to be, now it's scrap. This is used to fix the scrap into the component it was.
	var/brokenpartname = wrapped.name
	if(ispowercell(wrapped)) //dead cell unlocks the cover
		if(owner.locked)
			owner.locked = FALSE
			owner.visible_message("A click sounds from <span class='name'>[owner]</span>, indicating the automatic cover release failsafe.")
			if(owner.can_diagnose())
				to_chat(owner, "<span class='notice' style=\"font-family:Courier\">Cover auto-unlocked.</span>")
	else
		wrapped = G

	// The thing itself isn't there anymore, but some fried remains are.
	installed = COMPONENT_BROKEN
	if(owner.can_diagnose())
		to_chat(owner, "<span class='alert' style=\"font-family:Courier\">Warning: Critical damage to [brokenpartname] sustained. Component offline.</span>")

/datum/robot_component/proc/take_damage(brute, electronics)
	if(installed != COMPONENT_INSTALLED)
		return

	brute_damage += brute * vulnerability
	electronics_damage += electronics * vulnerability

	if(brute_damage + electronics_damage >= max_damage)
		destroy()

/datum/robot_component/proc/heal_damage(brute, electronics)
	if(installed != COMPONENT_INSTALLED)
		// If it's not installed, can't repair it.
		return FALSE

	brute_damage = max(0, brute_damage - brute)
	electronics_damage = max(0, electronics_damage - electronics)

/datum/robot_component/proc/is_powered()
	return (installed == COMPONENT_INSTALLED) && (brute_damage + electronics_damage < max_damage) && (!energy_consumption || powered)


/datum/robot_component/proc/consume_power()
	if(toggled == FALSE)
		powered = FALSE
		return
	var/obj/item/weapon/cell/cell = owner.get_cell()
	if(cell && cell.charge >= energy_consumption)
		cell.use(energy_consumption)
		powered = TRUE
	else
		powered = FALSE

/datum/robot_component/armour
	name = "armour plating"
	external_type = /obj/item/robot_parts/robot_component/armour
	energy_consumption = 0
	max_damage = 60

/datum/robot_component/actuator
	name = "actuator"
	external_type = /obj/item/robot_parts/robot_component/actuator
	energy_consumption = 0 // seeing as we can move without any charge...
	max_damage = 50

/datum/robot_component/cell
	name = "power cell"
	max_damage = 50

/datum/robot_component/cell/New(mob/living/silicon/robot/R)
	. = ..()
	external_type = R.cell_type

/datum/robot_component/cell/destroy()
	..()
	owner.updateicon()

/datum/robot_component/cell/install(var/mob/user,var/obj/item/W)
	if(istype(W,/obj/item/weapon/cell))
		var/obj/item/weapon/cell/I = W
		to_chat(user, "You insert \the [I].")
		installed = COMPONENT_INSTALLED
		wrapped = I
		electronics_damage = I.electronics_damage
		brute_damage = I.brute_damage
		if(owner.can_diagnose())
			to_chat(owner, "<span class='info' style=\"font-family:Courier\">New power source installed. Type: [I.name]. Charge: [I.charge] out of [I.maxcharge].</span>")
		owner.updateicon()
		if(I.occupant)
			to_chat(I.occupant,"<span class='notice'>You are now inside \the [owner], in control of its targeting.</span>")
			owner.pulsecompromised = 1
			I.occupant.loc = owner
			I.occupant.current_robot = owner
			I.occupant = null
			to_chat(owner, "<span class='danger'>ERRORERRORERROR</span>")
			spawn(2 SECONDS)
				to_chat(owner, "<span class='danger'>ALERT: ELECTRICAL MALEVOLENCE DETECTED, TARGETING SYSTEMS HIJACKED, REPORT ALL UNWANTED ACTIVITY IN VERBAL FORM</span>")

/datum/robot_component/cell/uninstall(var/mob/user,var/loud = FALSE)
	installed = COMPONENT_MISSING
	if(loud)
		user.visible_message("<span class='warning'>[user] removes [owner]'s [wrapped.name].</span>", \
		"<span class='notice'>You remove [owner]'s [wrapped.name].</span>")
	else
		to_chat(user, "You remove \the [wrapped].")
	if(owner.can_diagnose())
		to_chat(owner, "<span class='info' style=\"font-family:Courier\">Cell removed.</span>")
	if(istype(wrapped,/obj/item/weapon/cell))
		var/obj/item/weapon/cell/I = wrapped
		I.electronics_damage = electronics_damage
		I.brute_damage = brute_damage

/datum/robot_component/radio
	name = "radio"
	external_type = /obj/item/robot_parts/robot_component/radio
	energy_consumption = 1
	max_damage = 40

/datum/robot_component/binary_communication
	name = "binary communication device"
	external_type = /obj/item/robot_parts/robot_component/binary_communication_device
	energy_consumption = 0
	max_damage = 30

/datum/robot_component/camera
	name = "camera"
	external_type = /obj/item/robot_parts/robot_component/camera
	energy_consumption = 1
	max_damage = 40

/datum/robot_component/diagnosis_unit
	name = "self-diagnosis unit"
	external_type = /obj/item/robot_parts/robot_component/diagnosis_unit
	energy_consumption = 0
	max_damage = 30

/mob/living/silicon/robot/proc/is_component_functioning(module_name)
	var/datum/robot_component/C = components[module_name]
	return C && C.installed == COMPONENT_INSTALLED && C.toggled && C.is_powered()

/mob/living/silicon/robot/proc/exchange_parts(mob/user, obj/item/weapon/storage/bag/gadgets/part_replacer/W)
	if (W.bluespace || wiresexposed || opened)
		var/shouldplaysound = FALSE
		for(var/V in components)
			var/datum/robot_component/C = components[V]
			if(istype(C.wrapped,/obj/item/weapon/cell))
				var/obj/item/weapon/cell/cell = C.wrapped
				for(var/obj/item/weapon/cell/I2 in W.contents)
					if((I2.rating > cell.rating))
						if(C.wrapped)
							W.handle_item_insertion(C.wrapped, 1)
						C.uninstall(user)
						C.install(user,I2)
						W.remove_from_storage(I2, null)
						I2.forceMove(src)
						shouldplaysound = TRUE //Only play the sound when parts are actually replaced!
						break
			else
				for(var/obj/item/robot_parts/robot_component/I in W.contents)
					if((I.isupgrade && !C.upgraded) && istype(I, C.external_type))
						if(C.wrapped)
							W.handle_item_insertion(C.wrapped, 1)
						C.uninstall(user)
						C.install(user,I)
						W.remove_from_storage(I, null)
						I.forceMove(src)
						shouldplaysound = TRUE //Only play the sound when parts are actually replaced!
						break
		if(shouldplaysound)
			W.play_rped_sound()
		else
			to_chat(user, "<span class='notice'>Following components detected in [src]:</span>")
			for(var/V2 in components)
				var/datum/robot_component/C = components[V2]
				if(C.wrapped)
					to_chat(user, "<span class='notice'>    [C.wrapped.name]</span>")

/obj/item/broken_device
	name = "broken component"
	icon = 'icons/robot_component.dmi'
	icon_state = "broken"
	var/component = null //This remembers which component was it before breaking, so it can be fixed later (i.e nanopaste)

/obj/item/robot_parts/robot_component
	icon = 'icons/robot_component.dmi'
	icon_state = "working"
	var/brute_damage = 0
	var/electronics_damage = 0
	var/vulnerability = 1 //Multiplies the damage taken by this ammount. 0.35 is a MAGIC NUMBER.
	var/isupgrade = FALSE //Set this to true for any parts that are children of the basic ones. Required for auto upgrading with upgrade_components() in \silicon\robot\robot.dm

/obj/item/robot_parts/robot_component/examine(mob/user)
	..()
	if(brute_damage || electronics_damage)
		to_chat(user, "<span class='warning'>It looks[brute_damage ? " dented" : ""][(brute_damage && electronics_damage) ? " and" : ""][electronics_damage ? " charred" : ""].</span>")

/obj/item/robot_parts/robot_component/binary_communication_device
	name = "binary communication device"
	icon_state = "binary_translator"

/obj/item/robot_parts/robot_component/binary_communication_device/reinforced
	name = "reinforced binary communication device"
	icon_state = "ref_binary_translator"
	vulnerability = 0.35
	isupgrade = TRUE

/obj/item/robot_parts/robot_component/actuator
	name = "actuator"
	icon_state = "actuator"

/obj/item/robot_parts/robot_component/actuator/reinforced
	name = "reinforced actuator"
	icon_state = "ref_actuator"
	vulnerability = 0.35
	isupgrade = TRUE

/obj/item/robot_parts/robot_component/armour
	name = "armour plating"
	icon_state = "armor_plating"

/obj/item/robot_parts/robot_component/armour/reinforced
	name = "reinforced armour plating"
	icon_state = "ref_armor_plating"
	vulnerability = 0.35
	isupgrade = TRUE

/obj/item/robot_parts/robot_component/armour/kevlar
	name = "kevlar-reinforced armour plating"
	parent_type = /obj/item/robot_parts/robot_component/armour/reinforced

/obj/item/robot_parts/robot_component/camera
	name = "camera"
	icon_state = "camera"

/obj/item/robot_parts/robot_component/camera/reinforced
	name = "reinforced camera"
	icon_state = "ref_camera"
	vulnerability = 0.35
	isupgrade = TRUE

/obj/item/robot_parts/robot_component/diagnosis_unit
	name = "diagnosis unit"
	icon_state = "diagnosis_unit"

/obj/item/robot_parts/robot_component/diagnosis_unit/reinforced
	name = "reinforced diagnosis unit"
	icon_state = "ref_diagnosis_unit"
	vulnerability = 0.35
	isupgrade = TRUE

/obj/item/robot_parts/robot_component/radio
	name = "radio"
	icon_state = "radio"

/obj/item/robot_parts/robot_component/radio/reinforced
	name = "reinforced radio"
	icon_state = "ref_radio"
	vulnerability = 0.35
	isupgrade = TRUE

/obj/item/broken_device/attackby(var/obj/item/weapon/W, var/mob/user)
	if(istype(W, /obj/item/stack/nanopaste))
		if(do_after(user,src,30))
			var/obj/item/stack/nanopaste/C = W
			new src.component (src.loc)
			to_chat(user, "<span class='notice'>You fix the broken component.</span>")
			C.use(1)
			qdel(src)

//
//Robotic Component Analyzer, basically a health analyzer for robots. Why is this here? FUCKING OLDCODERS
//

/obj/item/device/robotanalyzer
	name = "cyborg analyzer"
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"
	var/mode = 1;

/obj/item/device/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(( clumsy_check(user) || user.getBrainLoss() >= 60) && prob(50))
		to_chat(user, text("<span class='warning'>You try to analyze the floor's vitals!</span>"))
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='warning'>[user] has analyzed the floor's vitals!</span>"), 1)
		user.show_message(text("<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Healthy</span>"), 1)
		user.show_message(text("<span class='notice'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>"), 1)
		user.show_message("<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!istype(M, /mob/living/silicon/robot))
		to_chat(user, "<span class='warning'>You can't analyze non-robotic things!</span>")
		return

	playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
	user.visible_message("<span class='notice'> [user] has analyzed [M]'s components.","<span class='notice'>You have analyzed [M]'s components.")
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	user.show_message("<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.halloss]% functional"]</span>")
	user.show_message("\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>", 1)
	user.show_message("\t Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
	if(M.tod && M.stat == DEAD)
		user.show_message("<span class='notice'>Time of Disable: [M.tod]</span>")

	var/mob/living/silicon/robot/H = M
	var/list/damaged = H.get_damaged_components(1,1,1)
	user.show_message("<span class='notice'>Localized Damage:</span>",1)
	if(length(damaged)>0)
		for(var/datum/robot_component/org in damaged)
			user.show_message(text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
			capitalize(org.name),					\
			(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
			(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
			(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
			(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
			(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
	else
		user.show_message("<span class='notice'>\t Components are OK.</span>",1)
	if(H.emagged && prob(5))
		user.show_message("<span class='warning'>\t ERROR: INTERNAL SYSTEMS COMPROMISED</span>",1)
	src.add_fingerprint(user)
	return
