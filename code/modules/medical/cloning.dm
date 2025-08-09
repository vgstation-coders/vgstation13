//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_BIOMASS 150
#define BIOMASS_CHUNK 50

/obj/machinery/cloning/clonepod
	anchored = TRUE
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	var/mob/living/occupant
	//list of mob/living/ that are currently in the pod. Usually only one, but in exceptional circumstances there may be multiple. All are ejected at the same time (when everyone's ready)
	var/list/occupants[0] 
	var/heal_level = 0 //The clone is released once its health reaches this level.
	var/locked = FALSE
	var/frequency = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = FALSE //Need to clean out it if it's full of exploded clone.
	var/working = FALSE //One clone attempt at a time thanks
	var/eject_wait = FALSE //Don't eject them as soon as they are created fuckkk
	var/biomass = 0
	var/time_coeff = 1 //Upgraded via part upgrading
	var/resource_efficiency = 1
	id_tag = "clone_pod"
	var/upgraded = 0 //if fully upgraded with T4 components, it will drastically improve and allow for some stuff
	var/obj/machinery/computer/cloning/cloning_computer = null
	var/list/cloned_records = list() //List of all records this pod has cloned.


	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU | MULTIOUTPUT

	light_color = LIGHT_COLOR_CYAN
	use_auto_lights = 1
	light_range_on = 3
	light_power_on = 2

/obj/machinery/cloning/clonepod/full
	biomass = CLONE_BIOMASS // * 3 - N3X

/obj/machinery/cloning/clonepod/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return "(<a href='?src=\ref[src];set_output_dir=1'>Set Output Direction</a>)"

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/cloning/clonepod/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/clonepod,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/cloning/clonepod/RefreshParts()
	var/total = 0
	var/T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		T += SM.rating //First rank is two times more efficient, second rank is two and a half times, third is three times. For reference, there's TWO scanning modules
		total += SM.rating
	time_coeff = T/2
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/MA in component_parts)
		T += MA.rating //Ditto above
		total += MA.rating
	resource_efficiency = T/2
	T = 0
	if(total >= 16)
		upgraded = 1
		name = "Advanced Cloning Pod"
		desc = "An electronically-lockable pod for growing organic tissue. This one is extremely advanced, and can output perfectly fine clones that do not need treatment of any kind."
	else
		upgraded = 0
		name = initial(name)
		desc = initial(desc)

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/weapon/disk/data
	name = "cloning data disk"
	desc = "A disk for storing DNA data, and to transfer it between a cloning console and a DNA modifier."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "disk_cloning" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/datum/dna2/record/buf=null
	var/list/datum/block_label/labels[DNA_SE_LENGTH] //This is not related to cloning, these are colored tabs for Genetics machinery. Multipurpose floppies, why not?
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/New()
	for(var/i=1;i<=DNA_SE_LENGTH;i++)
		labels[i] = new /datum/block_label

/obj/item/weapon/disk/data/Destroy()
	for(var/datum/block_label/label in labels)
		qdel(label)
	labels.Cut()
	..()

/obj/item/weapon/disk/data/proc/Initialize()
	buf = new
	buf.dna = new

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

/obj/item/weapon/disk/data/demo/New()
	..()
	Initialize()
	buf.types=DNA2_BUF_UE|DNA2_BUF_UI
	//data = "066000033000000000AF00330660FF4DB002690"
	//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
	buf.dna.real_name="God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
	//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
	buf.dna.UpdateUI()

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = TRUE

/obj/item/weapon/disk/data/monkey/New()
	..()
	Initialize()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)


//Find a dead mob with a brain and client.
/proc/find_dead_player(var/find_key)
	if (isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/living/M in player_list)
		//Dead people only thanks!
		if ((M.stat != 2) || (!M.client))
			continue
		//They need a brain!
		if ((istype(M, /mob/living/carbon/human)) && !M.has_brain())
			continue

		if (M.ckey == find_key)
			selected = M
			break
	return selected

//Disk stuff.
/obj/item/weapon/disk/data/attack_self(mob/user as mob)
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/weapon/disk/data/examine(mob/user)
	..()
	to_chat(user, "The write-protect tab is set to [read_only ? "protected" : "unprotected"].")
/obj/machinery/cloning/clonepod/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)
/obj/machinery/cloning/clonepod/attack_paw(mob/user as mob)
	return attack_hand(user)
/obj/machinery/cloning/clonepod/attack_hand(mob/user as mob)
	if(occupants.len == 0 || (stat & (FORCEDISABLE|NOPOWER)))
		return
	if(occupants.len > 0)
		var/lowest_completion = 100
		for(var/mob/living/O in occupants)
			var/completion = 100 * ((O.health + 100) / (heal_level + 100))
			if(completion < lowest_completion)
				lowest_completion = completion
		to_chat(user, "Current clone cycle is [round(lowest_completion)]% complete.")
	return

//Clonepod

//Start growing a human clone in the pod!
//force_clone forcibly clones the mind in the record even if its body isn't dead or it's not currently in its body.
//specifying a mob that's already inside the cloner in copy_progress_from will set the clone's health to match that mob's health
/obj/machinery/cloning/clonepod/proc/growclone(var/datum/dna2/record/R, var/mob/living/copy_progress_from = null, var/do_mind_transfer = TRUE, var/allow_multiple = FALSE, var/force_clone = FALSE)
	if(mess)
		return FALSE
	if(!allow_multiple && working)
		return FALSE
	var/datum/mind/clonemind = locate(R.mind)
	if(!clonemind) //no mind
		return FALSE
	if(!istype(clonemind,/datum/mind)) //not a mind
		return FALSE
	if(!force_clone && clonemind.current)
		if(clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
			return FALSE
	//mind.active is supposed to indicate whether the mind is, you know, active. But it's zero if the player attached to the mind is active but a ghost.
	//Which I suppose makes some kind of sense but is a bit confusing.
	if(clonemind.active)
		if(ckey(clonemind.key) != R.ckey)
			return FALSE
	else
		for(var/mob/G in player_list)
			if(G.ckey == R.ckey)
				if(isobserver(G))
					if(force_clone)
						break
					var/mob/dead/observer/ghost = G
					if(ghost.can_reenter_corpse())
						break
					if((!G.mind.current) && G.mind.body_archive) //If the mind's body was destroyed and that mind has a body archive
						var/datum/dna2/record/D = G.mind.body_archive.data["dna_records"] //Retrieve the DNA records from the mind's body archive
						if((D.id == R.id) || D.ckey == R.ckey) //If the MD5 hash of the mind's real_name matches the record's real_name (stored as the id variable), or if the ckeys match
							break //Proceed with cloning. This set of checks is to allow cloning players with completely destroyed bodies, that nevertheless had cloning data stored
					else
						return FALSE
				else
					if(!G.mind)
						return FALSE
					if(G.mind.current)
						if(!force_clone && G.mind.current.stat != DEAD)
							return FALSE
					if(G.mind != clonemind)
						return FALSE
	
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species, delay_ready_dna = TRUE)
	H.times_cloned = R.times_cloned + 1
	H.talkcount = R.talkcount

	if(isplasmaman(H))
		H.fire_sprite = "Plasmaman" 

	H.dna = R.dna.Clone()
	H.dna.flavor_text = R.dna.flavor_text
	H.dna.species = R.dna.species
	if(H.dna.species != "Human")
		H.set_species(H.dna.species, TRUE)

	H.UpdateAppearance()
	H.set_species(H.dna.species)
	H.update_mutantrace()
	
	if(do_mind_transfer)
		has_been_shade.Remove(clonemind)
		clonemind.transfer_to(H)
	H.ckey = R.ckey

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
		if (L == R.default_language)
			H.default_language = R.default_language
	H.attack_log = R.attack_log
	H.real_name = H.dna.real_name
	H.flavor_text = H.dna.flavor_text

	if(H.mind)
		H.mind.suiciding = FALSE
	H.update_name()

	cloned_records += R.Clone()

	return addclone(H, copy_progress_from)

//Grows a twin of an existing living mob and puts the given mind into it.
//Unless force_clone is TRUE, the mind's body must be dead.
/obj/machinery/cloning/clonepod/proc/growtwin(var/mob/living/original, var/datum/mind/clonemind, var/do_mind_transfer = TRUE, var/allow_multiple = FALSE, var/force_clone = FALSE)
	if(mess)
		return FALSE
	if(!allow_multiple && working)
		return FALSE
	if(!clonemind)
		return FALSE
	if(!istype(clonemind,/datum/mind))
		return FALSE
	if(!force_clone && clonemind.current)
		if(clonemind.current.stat != DEAD)
			return FALSE
	if(!clonemind.active)
		for(var/mob/P in player_list)
			if(P.ckey == ckey(clonemind.key))
				if(!force_clone && !isobserver(P))
					return FALSE
				break
	
	var/original_in_cloner = (original in occupants)
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, original.dna.species, delay_ready_dna = TRUE)
	if(original_in_cloner)
		H.times_cloned = original.times_cloned
	else
		H.times_cloned = original.times_cloned + 1
	H.talkcount = original.talkcount

	if(isplasmaman(H))
		H.fire_sprite = "Plasmaman"
	
	H.dna = original.dna.Clone()
	H.dna.flavor_text = original.dna.flavor_text
	H.dna.species = original.dna.species
	if(H.dna.species != "Human")
		H.set_species(H.dna.species, TRUE)
	
	H.UpdateAppearance()
	H.set_species(H.dna.species)
	H.update_mutantrace()

	if(do_mind_transfer)
		has_been_shade.Remove(clonemind)
		clonemind.transfer_to(H)
	H.key = clonemind.key

	for(var/datum/language/L in original.languages)
		H.add_language(L.name)
		if (L == original.default_language)
			H.default_language = original.default_language
	H.attack_log = original.attack_log
	H.real_name = original.real_name
	H.flavor_text = original.flavor_text

	if(H.mind)
		H.mind.suiciding = FALSE
	H.update_name()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.dna = H.dna.Clone()
	R.ckey = H.ckey
	R.id = copytext(md5(R.dna.real_name), 2, 6)
	R.name = R.dna.real_name
	R.types = DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages = H.languages.Copy()
	R.attack_log = H.attack_log.Copy()
	R.default_language = H.default_language
	R.times_cloned = H.times_cloned
	R.talkcount = H.talkcount
	if (!isnull(H.mind))
		R.mind = "\ref[H.mind]"
	cloned_records += R

	var/mob/living/copy_progress_from = null
	if(original_in_cloner)
		copy_progress_from = original
	return addclone(H, original, copy_progress_from)


//Adds a new clone into the pod. Probably don't call this directly, use growclone or growtwin instead.
//returns the new mob
/obj/machinery/cloning/clonepod/proc/addclone(var/mob/living/carbon/human/H, var/mob/living/copy_progress_from = null)
	if(heal_level == 0)
		heal_level = upgraded ? 100 : rand(10,40) //Randomizes what health the clone is when ejected
	
	//only lock if we're not already working on a clone
	if(!working)
		locked = TRUE
	working = TRUE

	if(!eject_wait)
		spawn(30)
			eject_wait = FALSE
	eject_wait = TRUE

	occupants += H

	if(!connected.emagged)
		icon_state = "pod_1"
	else
		icon_state = "pod_e"

	connected.update_icon()

	isslimeperson(H) ? H.adjustToxLoss(75) : H.adjustCloneLoss(150) // 75 for slime people due to their tox_mod of 2
	H.adjustBrainLoss(upgraded ? 0 : (heal_level + 50 + rand(10, 30))) // The rand(10, 30) will come out as extra brain damage
	H.Paralyse(4)
	H.nobreath = 15
	H.stat = H.status_flags & BUDDHAMODE ? CONSCIOUS : UNCONSCIOUS //There was a bug which allowed you to talk for a few seconds after being cloned, because your stat wasn't updated until next Life() tick. This is a fix for this!

	if(copy_progress_from && (copy_progress_from in occupants))
		var/mob/living/C = copy_progress_from
		H.setToxLoss(C.getToxLoss())
		H.setCloneLoss(C.getCloneLoss())
		H.setOxyLoss(C.getOxyLoss())
		H.setBrainLoss(C.getBrainLoss())

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	to_chat(H, "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>")

	if (H.mind.miming)
		H.add_spell(new /spell/aoe_turf/conjure/forcewall/mime, "grey_spell_ready")
		if (H.mind.miming == MIMING_OUT_OF_CHOICE)
			H.add_spell(new /spell/targeted/oathbreak/)

	// Check for any powers that goes missing after cloning, in case of reviving after ashing
	if (isvampire(H))
		var/datum/role/vampire/V = isvampire(H)
		V.check_vampire_upgrade()
		V.update_vamp_hud()

	return H

//Used for cloning divergent clones
/obj/machinery/cloning/clonepod/proc/clone_divergent_twin(var/mob/living/original, var/datum/mind/clonemind)
    var/mob/living/clone = growtwin(original, clonemind, do_mind_transfer=TRUE, allow_multiple=TRUE, force_clone=TRUE)
    if(!clone)
        return null
    var/datum/mind/new_mind = clone.mind
    var/datum/mind/orig_mind = original.mind
    new_mind.name = orig_mind.name
    //new_mind.memory = orig_mind.memory
    new_mind.assigned_role = orig_mind.assigned_role
    new_mind.body_archive = orig_mind.body_archive
    new_mind.role_alt_title = orig_mind.role_alt_title
    new_mind.miming = orig_mind.miming
    new_mind.faith = orig_mind.faith
    new_mind.initial_account = orig_mind.initial_account
    new_mind.initial_wallet_funds = orig_mind.initial_wallet_funds

    return clone

/obj/machinery/cloning/clonepod/proc/clone_divergent_record(var/datum/dna2/record/orig_record, var/datum/mind/clonemind)
    var/datum/dna2/record/R = new /datum/dna2/record()
    R.dna = orig_record.dna.Clone()
    R.ckey = ckey(clonemind.key)
    R.mind = "\ref[clonemind]"
    R.id = copytext(md5(R.dna.real_name), 2, 6)
    R.name = R.dna.real_name
    R.types = DNA2_BUF_UI | DNA2_BUF_UE | DNA2_BUF_SE
    R.languages = orig_record.languages.Copy()
    R.attack_log = orig_record.attack_log.Copy()
    R.default_language = orig_record.default_language
    R.times_cloned = orig_record.times_cloned
    R.talkcount = orig_record.talkcount

    var/mob/living/carbon/human/clone = growclone(R, copy_progress_from=null, do_mind_transfer=TRUE, allow_multiple=TRUE, force_clone=TRUE)
    var/datum/mind/new_mind = clone.mind
    var/datum/mind/orig_mind = locate(orig_record.mind)
    new_mind.name = orig_mind.name
    //new_mind.memory = orig_mind.memory
    new_mind.assigned_role = orig_mind.assigned_role
    new_mind.body_archive = orig_mind.body_archive
    new_mind.role_alt_title = orig_mind.role_alt_title
    new_mind.miming = orig_mind.miming
    new_mind.faith = orig_mind.faith
    new_mind.initial_account = orig_mind.initial_account
    new_mind.initial_wallet_funds = orig_mind.initial_wallet_funds

    return clone


//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/cloning/clonepod/process()
	if(stat & (FORCEDISABLE|NOPOWER)) //Autoeject if power is lost
		if (occupants.len > 0)
			locked = FALSE
			go_out()
		return

	if(occupants.len > 0)
		use_power(7500)
	else
		use_power(200)

	var/message = null
	var/done_occupants = 0

	for(var/mob/living/O in occupants)
		if(O.loc == src)
			if((O.stat == DEAD) || (O.mind && O.mind.suiciding) || !O.key)  //Autoeject corpses and suiciding dudes.
				done_occupants += 1
				if(!message)
					message = "Clone Rejected: Deceased."
				continue

			O.Paralyse(4)

			var/mob/living/carbon/human/H = O
			if(isvox(H))
				if(O.reagents.get_reagent_amount(NITROGEN) < 30)
					O.reagents.add_reagent(NITROGEN, 60)

			//So clones don't die of oxyloss in a running pod.
			else if(O.reagents.get_reagent_amount(INAPROVALINE) < 30) //Done like this because inaprovaline is toxic to vox
				O.reagents.add_reagent(INAPROVALINE, 60)

			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			O.adjustOxyLoss(-4)
			O.nobreath = 15

			if(O.health < heal_level)
				//Slowly get that clone healed and finished.
				isslimeperson(O) ? O.adjustToxLoss(-1*time_coeff) : O.adjustCloneLoss(-1*time_coeff) //Very slow, new parts = much faster

				//Premature clones may have brain damage.
				O.adjustBrainLoss(-1*time_coeff) //Ditto above
				continue

			else if((O.health >= heal_level) && (!eject_wait))
				done_occupants += 1
				message = "Clone Process Complete."
				continue

		else
			occupants.Remove(O)
			continue

	if(!eject_wait && done_occupants > 0 && done_occupants >= occupants.len)
		connected_message(message)
		locked = FALSE
		go_out()

/obj/machinery/cloning/clonepod/emag_act(mob/user as mob)
	if(occupants.len == 0)
		return
	if(user)
		to_chat(user, "You force an emergency ejection.")
	locked = FALSE
	go_out()
	return

/obj/machinery/cloning/clonepod/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if(occupants.len > 0)
		to_chat(user, "<span class='warning'>You cannot disassemble \the [src], it's occupado.</span>")
		return FALSE
	for(biomass; biomass > 0;biomass -= BIOMASS_CHUNK)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(loc)
	return..()

/obj/machinery/cloning/clonepod/Destroy()
	if(connected)
		if(connected.pod1 == src)
			connected.pod1 = null
		connected = null
	go_out() //Eject everything

	. = ..()

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/cloning/clonepod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	. = ..()
	if(.)
		return .
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (!check_access(W))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		else if ((!locked) || (occupants.len == 0))
			return
		else
			locked = FALSE
			to_chat(user, "System unlocked.")
	if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		if(user.drop_item(W))
			playsound(src, 'sound/machines/juicerfast.ogg', 30, 1)
			to_chat(user, "<span class='notice'>\The [src] processes \the [W].</span>")
			biomass += BIOMASS_CHUNK
			qdel(W)
			return

//Put messages in the connected computer's temp var for display.
/obj/machinery/cloning/clonepod/proc/connected_message(var/message)
	if ((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return FALSE
	if (!message)
		return FALSE

	connected.temp = message
	connected.updateUsrDialog()
	return TRUE

/obj/machinery/cloning/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if (usr.isUnconscious())
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/cloning/clonepod/proc/go_out(var/exit)
	if (locked)
		return

	if(!exit)
		exit = output_turf()

	if (mess) //Clean that mess and dump those gibs!
		mess = FALSE
		working = FALSE //NOW we're done.
		gibs(exit)
		icon_state = "pod_0"
		return

	if (occupants.len == 0)
		return

	var/obj/machinery/conveyor/C = locate() in exit
	for(var/mob/living/O in occupants)
		if (O.client)
			O.client.eye = O.client.mob
			O.client.perspective = MOB_PERSPECTIVE

		O.forceMove(exit)
		if(C && C.operating != 0)
			O << sound('sound/ambience/powerhouse.ogg') //the ride begins

		//do early ejection damage
		var/completion = 10*((O.health + 100) / (heal_level + 100)) //same way completion is calculated for examine text, but out of 10 instead of 100
		var/damage_rolls = 10 - round(completion) - (round(resource_efficiency) - 1) // 1 roll for each 10% missing, each improved pair of manipulators reduces one roll
		var/hits = 0
		while(damage_rolls > 0)
			if(prob(25))//each roll has a 25% chance to give the O a bad time
				hits++
			damage_rolls--

		//apply the damage
		var/mob/living/carbon/human/H = O
		while(hits>0)
			if (hits>=4)
				qdel(pick(H.internal_organs - H.internal_organs_by_name["brain"]))
				hits -= 4
			else //if this pick lands on either torso part, those can't be droplimb'd. Get out of jail free, I guess
				H.organs_by_name[pick(H.organs_by_name)].droplimb(override = 1, no_explode = 1, spawn_limb = 1, display_message = FALSE)
				hits--

		O.updatehealth()
		domutcheck(O) //Waiting until they're out before possible monkeyizing.
		occupants.Remove(O)
		biomass = max(0, biomass - CLONE_BIOMASS/resource_efficiency) //Improve parts to use less biomass


	icon_state = "pod_0"
	eject_wait = FALSE
	heal_level = 0 //so that it will be re-randomized next time
	connected.update_icon()
	working = FALSE //NOW we're done.

	return TRUE

/obj/machinery/cloning/clonepod/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(occupants.len == 0 || (usr in occupants) || (!ishigherbeing(usr) && !isrobot(usr)) || usr.incapacitated() || usr.lying)
		return
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location) || !Adjacent(usr) || !usr.Adjacent(over_location))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(isrobot(usr))
		var/mob/living/silicon/robot/robit = usr
		if(!HAS_MODULE_QUIRK(robit, MODULE_CAN_HANDLE_MEDICAL))
			to_chat(usr, "<span class='warning'>You do not have the means to do this!</span>")
			return

	var/_occupants = occupants.Copy() // occupants is empty after go_out()
	if(go_out(over_location))
		for(var/mob/living/O in _occupants)
			visible_message("[usr] removes \the [O] from \the [src].")
		add_fingerprint(usr)

/obj/machinery/cloning/clonepod/proc/malfunction()
	if(occupants.len > 0)
		connected_message("Critical Error!")
		mess = TRUE
		icon_state = "pod_g"
		for(var/mob/living/O in occupants)
			occupant.ghostize()
			spawn(5)
				qdel(occupant)
	return

/obj/machinery/cloning/clonepod/relaymove(mob/user as mob)
	if (user.stat)
		return
	go_out()
	return

/obj/machinery/cloning/clonepod/emp_act(severity)
	if(prob(100/severity))
		malfunction()
	..()

/obj/machinery/cloning/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/cloning/clonepod/MouseDropTo(obj/item/weapon/reagent_containers/food/snacks/meat/M, mob/living/user)
	var/busy = FALSE
	var/visible_message = FALSE

	if(!istype(M))
		return

	if(issilicon(user))
		return //*buzz

	if(!Adjacent(user) || !user.Adjacent(src) || !user.Adjacent(M) || M.loc == user || !isturf(M.loc) || !isturf(user.loc) || user.loc==null)
		return

	if(user.incapacitated() || user.lying)
		return

	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return

	if(!busy)
		busy = TRUE
		for(var/obj/item/weapon/reagent_containers/food/snacks/meat/meat in M.loc)
			biomass += BIOMASS_CHUNK
			qdel(meat)
			visible_message = TRUE // Prevent chatspam when multiple meat are near

		if(visible_message)
			playsound(src, 'sound/machines/juicer.ogg', 30, 1)
			visible_message("<span class = 'notice'>[src] sucks in and processes the nearby biomass.</span>")
		busy = FALSE

/obj/machinery/cloning/clonepod/kick_act()
	..()

	if(occupants.len > 0 && prob(5))
		visible_message("<span class='notice'>[src] buzzes.</span>","<span class='warning'>You hear a buzz.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		locked = FALSE
		go_out()

/obj/machinery/cloning/clonepod/proc/output_turf()
	if(!output_dir || !isturf(loc))
		return loc

	var/turf/T = get_step(get_turf(src), output_dir)
	if(!T || is_blocked_turf(T))
		return loc
	return T


/*
 *	Diskette Box
 */

/obj/item/weapon/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_kit"

/obj/item/weapon/storage/box/disks/New()
	. = ..()
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)
	new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}
