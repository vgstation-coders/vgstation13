/*
 -- Vampires --
 */

#define MAX_BLOOD_PER_TARGET 200

/datum/role/vampire
	id = VAMPIRE
	name = VAMPIRE
	special_role = VAMPIRE
	disallow_job = FALSE
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain")
	logo_state = "vampire-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM,GREET_ADMINTOGGLE, GREET_MASTER)
	required_pref = VAMPIRE
	protected_traitor_prob = PROB_PROTECTED_RARE
	default_admin_voice = "Vampire Overlord"
	admin_voice_style = "danger"

	var/ismenacing = FALSE
	var/iscloaking = FALSE

	var/nullified = 0
	var/smitecounter = 0

	var/list/saved_appearances = list()
	var/datum/human_appearance/initial_appearance

	var/reviving = FALSE
	var/draining = FALSE
	var/blood_usable = STARTING_BLOOD
	var/blood_total = STARTING_BLOOD

	var/list/feeders = list()

	var/static/list/roundstart_powers = list(/datum/power/vampire/hypnotise, /datum/power/vampire/glare, /datum/power/vampire/rejuvenate)

	var/list/image/cached_images = list()

	stat_datum_type = /datum/stat/role/vampire

/datum/role/vampire/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id, var/override = FALSE)
	..()
	var/datum/faction/vampire/vamp_fac
	if(!fac)
		vamp_fac = new
		vamp_fac.addMaster(src)
	else if (istype(fac, /datum/faction/vampire))
		vamp_fac = fac
		vamp_fac.addMaster(src)
	wikiroute = role_wiki[VAMPIRE]

/datum/role/vampire/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		if (GREET_ADMINTOGGLE)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>Your powers are awoken. Your lust for blood grows... You are a Vampire!</span></B>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Vampire!<br/></span>")
			to_chat(antag.current, "To drink blood from somebody, just bite their head (switch to harm intent, enable biting and attack the victim in the head with an empty hand).")
			to_chat(antag.current, "Drink blood to gain new powers and use coffins to regenerate your body if injured.")
			to_chat(antag.current, "You are weak to holy things and starlight.")
			to_chat(antag.current, "Don't go into space and avoid the Chaplain, the chapel, and especially Holy Water.")
			to_chat(antag.current, "You will easily recognise the wearers of holy artifacts. Your powers will stop working against them as you go stronger.")
	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	antag.current << sound('sound/effects/vampire_intro.ogg')

/datum/role/vampire/OnPostSetup()
	. = ..()
	update_vamp_hud()
	ForgeObjectives()
	for(var/type_VP in roundstart_powers)
		var/datum/power/vampire/VP = new type_VP
		VP.add_power(src)

	if(faction && istype(faction, /datum/faction/vampire) && faction.leader == src)
		var/datum/faction/vampire/V = faction
		V.name_clan(src)

	var/mob/living/carbon/human/H = antag.current
	initial_appearance = H.my_appearance.Copy()
	initial_appearance.name = H.real_name

/datum/role/vampire/RemoveFromRole(var/datum/mind/M)
	var/list/vamp_spells = getAllVampSpells()
	for(var/spell/spell in antag.current.spell_list)
		if (is_type_in_list(spell, vamp_spells))
			antag.current.remove_spell(spell)
	if(antag.current.client && antag.current.hud_used)
		if(antag.current.hud_used.vampire_blood_display)
			antag.current.client.screen -= list(antag.current.hud_used.vampire_blood_display)
	..()

/datum/role/vampire/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/dat = ..()
	dat += "  - <a href='?src=\ref[src]&mind=\ref[antag]&giveblood=1'>Give blood</a>"
	return dat

/datum/role/vampire/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	..()
	if (!usr.client.holder)
		return FALSE
	if (href_list["giveblood"])
		var/amount = input("How much would you like to give?", "Giving blood") as null|num
		if (!amount)
			return FALSE
		give_blood(amount)

/datum/role/vampire/proc/give_blood(var/amount)
	blood_total += amount
	blood_usable += amount
	check_vampire_upgrade()
	update_vamp_hud()

// -- Not sure if this is meant to work like that.
// I just put what I expect to see in the "The vampires were..."
/datum/role/vampire/GetScoreboard()
	. = "Total blood collected: <b>[blood_total]</b><br/>"
	. += ..() // Who he was, his objectives...

/datum/role/vampire/ForgeObjectives()
	if(!antag.current.client.prefs.antag_objectives)
		AppendObjective(/datum/objective/freeform/vampire)
		return

	AppendObjective(/datum/objective/acquire_blood)

	AppendObjective(/datum/objective/target/assassinate/delay_medium)// 10 minutes

	AppendObjective(/datum/objective/target/steal)

	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in objectives.objectives)) // Objectives (the objective holder).objectives (the objective list)
				AppendObjective(/datum/objective/escape)
		else
			if (!(locate(/datum/objective/survive) in objectives.objectives))
				AppendObjective(/datum/objective/survive)
	return

// -- Vampire mechanics --

/datum/role/vampire/proc/can_suck(var/mob/living/carbon/human/H)
	var/mob/living/M = antag.current
	var/datum/butchering_product/teeth/vampire_teeth = locate(/datum/butchering_product/teeth) in M.butchering_drops

	if(M.lying || M.incapacitated())
		to_chat(M, "<span class='warning'> You cannot do this while on the ground!</span>")
		return FALSE

	if(H.check_body_part_coverage(MOUTH))
		to_chat(M, "<span class='warning'>Remove their mask!</span>")
		return FALSE

	if(vampire_teeth?.amount == 0)
		to_chat(M, "<span class='warning'>You cannot suck blood with no teeth!</span>")
		return FALSE

	if(ishuman(M))
		var/mob/living/carbon/human/vamp_H = M
		if(H.check_body_part_coverage(MOUTH))
			if(vamp_H.species.breath_type == GAS_OXYGEN)
				to_chat(H, "<span class='warning'>Remove your mask!</span>")
				return FALSE
			else
				to_chat(H, "<span class='notice'>With practiced ease, you shift aside your mask for each gulp of blood.</span>")
	return TRUE


/datum/role/vampire/proc/handle_bloodsucking(var/mob/living/carbon/human/target)
	draining = target

	var/mob/assailant = antag.current
	var/targetref = "\ref[target]"
	var/blood = 0
	var/blood_total_before = blood_total
	var/blood_usable_before = blood_usable
	assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Bit [key_name(target)] in the neck and draining their blood.</font>")
	target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been bit in the neck by [key_name(assailant)].</font>")
	log_attack("[key_name(assailant)] bit [key_name(target)] in the neck")

	to_chat(antag.current, "<span class='danger'>You latch on firmly to \the [target]'s neck.</span>")
	target.show_message("<span class='userdanger'>\The [assailant] latches on to your neck!</span>")

	if(!iscarbon(assailant))
		target.LAssailant = null
	else
		target.LAssailant = assailant
		target.assaulted_by(assailant)
	while(do_mob(assailant, target, 5 SECONDS))
		if(!isvampire(assailant))
			to_chat(assailant, "<span class='warning'>Your fangs have disappeared!</span>")
			draining = null
			return FALSE
		if(target.species.anatomy_flags & NO_BLOOD)
			to_chat(assailant, "<span class='warning'>Not a drop of blood here.</span>")
			draining = null
			return FALSE
		if(!target.mind)
			to_chat(assailant, "<span class='warning'>This blood is lifeless and has no power.</span>")
			draining = null
			return FALSE
		if(!target.vessel.get_reagent_amount(BLOOD))
			to_chat(assailant, "<span class='warning'>They've got no blood left to give.</span>")
			break
		if (!(targetref in feeders))
			feeders[targetref] = 0
		if(target.stat < DEAD) //alive
			blood = min(20, target.vessel.get_reagent_amount(BLOOD)) // if they have less than 20 blood, give them the remnant else they get 20 blood
			if (feeders[targetref] < MAX_BLOOD_PER_TARGET)
				blood_total += blood
			else
				to_chat(assailant, "<span class='warning'>Their blood quenches your thirst but won't let you become any stronger. You need to find new prey.</span>")
			blood_usable += blood
			target.adjustBruteLoss(1)
			var/datum/organ/external/head/head_organ = target.get_organ(LIMB_HEAD)
			head_organ.add_autopsy_data("sharp teeth", 1)
		else
			blood = min(10, target.vessel.get_reagent_amount(BLOOD)) // The dead only give 10 blood
			if (feeders[targetref] < MAX_BLOOD_PER_TARGET)
				blood_total += blood
			else
				to_chat(assailant, "<span class='warning'>Their blood quenches your thirst but won't let you become any stronger. You need to find new prey.</span>")
		feeders[targetref] += blood
		if(blood_total_before != blood_total)
			to_chat(assailant, "<span class='notice'>You have accumulated [blood_total] [blood_total > 1 ? "units" : "unit"] of blood[blood_usable_before != blood_usable ?", and have [blood_usable] left to use." : "."]</span>")
		check_vampire_upgrade()
		target.vessel.remove_reagent(BLOOD,30)
		update_vamp_hud()

	draining = null
	to_chat(assailant, "<span class='notice'>You stop draining \the [target] of blood.</span>")
	return TRUE

/datum/role/vampire/proc/check_vampire_upgrade()

	for (var/i in subtypesof(/datum/power/vampire))
		var/datum/power/vampire/VP_type = i
		if (blood_total > initial(VP_type.cost) && !(locate(VP_type) in current_powers))
			var/datum/power/vampire/VP = new VP_type
			VP.add_power(src)

	var/mob/living/carbon/human/H = antag.current
	if (!istype(H))
		return

	// Vision-related changes.
	if (locate(/datum/power/vampire/vision) in current_powers)
		H.change_sight(adding = SEE_MOBS)

	if (locate(/datum/power/vampire/mature) in current_powers)
		H.change_sight(adding = SEE_TURFS|SEE_OBJS)
		H.dark_plane.alphas["vampire_vision"] = 255
		H.see_in_dark = 8

/datum/role/vampire/proc/is_mature_or_has_vision()
	return (locate(/datum/power/vampire/vision) in current_powers) || (locate(/datum/power/vampire/mature) in current_powers)

/datum/role/vampire/proc/handle_enthrall(var/datum/mind/enthralled)
	if (!istype(enthralled))
		return FALSE
	return new/datum/role/thrall(M = enthralled, fac = src.faction, master = src) // Creating a new thrall
/*
-- Life() related procs --
*/

/datum/role/vampire/process()
	..()
	var/mob/living/carbon/human/H = antag?.current
	if (!istype(H))
		return FALSE // The life() procs only work on humans.
	handle_cloak(H)
	handle_menace(H)
	handle_smite(H)
	if(istype(H.loc, /turf/space))
		H.check_sun()
	if(istype(H.loc, /obj/structure/closet/coffin))
		H.adjustBruteLoss(-4)
		H.adjustFireLoss(-4)
		H.adjustToxLoss(-4)
		H.adjustOxyLoss(-4)
		smitecounter = 0
		nullified -= 5
		for(var/datum/organ/internal/I in H.internal_organs)
			if(I && I.damage > 0)
				I.damage = max(0, I.damage - 4)
			if(I)
				I.status &= ~ORGAN_BROKEN
				I.status &= ~ORGAN_SPLINTED
				I.status &= ~ORGAN_BLEEDING
		for(var/datum/organ/external/O in H.organs)
			O.status &= ~ORGAN_BROKEN
			O.status &= ~ORGAN_SPLINTED
			O.status &= ~ORGAN_BLEEDING
	nullified = max(0, nullified - 1)

/datum/role/vampire/update_perception()
	var/mob/living/carbon/human/H = antag.current
	if (locate(/datum/power/vampire/mature) in current_powers)
		H.dark_plane.alphas["vampire_vision"] = 255
		H.see_in_dark = 8

/datum/role/vampire/proc/handle_cloak(var/mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(H.stat != DEAD)
		iscloaking = FALSE
	if(!iscloaking)
		H.alphas["vampire_cloak"] = 255
		H.color = "#FFFFFF"
		return FALSE

	if((T.get_lumcount() * 10) <= 2)
		H.alphas["vampire_cloak"] = round((255 * 0.15))
		if(locate(/datum/power/vampire/shadow) in current_powers)
			H.color = "#000000"
		return TRUE
	else
		if(locate(/datum/power/vampire/shadow) in current_powers)
			H.alphas["vampire_cloak"] = round((255 * 0.15))
		else
			H.alphas["vampire_cloak"] = round((255 * 0.80))

/datum/role/vampire/proc/handle_menace(var/mob/living/carbon/human/H)
	if(H.stat == DEAD)
		ismenacing = FALSE
	if(!ismenacing)
		return FALSE

	var/turf/T = get_turf(H)

	if(T.get_lumcount() > 2)
		ismenacing = 0
		return FALSE

	var/mob/M = antag.current
	var/radius = 6

	for(var/mob/living/carbon/C in oviewers(radius, M))
		if(prob(35))
			continue //to prevent fearspam
		var/datum/role/thrall/role_thrall = isthrall(C)
		if (role_thrall && role_thrall.master == src)
			continue // We don't terrify our underlings
		if (C.vampire_affected(antag) <= 0)
			continue
		C.stuttering += 20
		C.Jitter(20)
		C.Dizzy(20)
		to_chat(C, "<span class='sinister'>Your heart is filled with dread, and you shake uncontrollably.</span>")

/datum/role/vampire/proc/handle_smite(var/mob/living/carbon/human/H)
	var/smitetemp = 0
	var/vampcoat = istype(H.wear_suit, /obj/item/clothing/suit/storage/draculacoat) //coat reduces smiting
	if(check_holy(H)) //if you're on a holy tile get ready for pain
		smitetemp += (vampcoat ? 1 : 5)
		if(prob(35))
			to_chat(H, "<span class='danger'>This ground is blessed. Get away, or splatter it with blood to make it safe for you.</span>")

	if((locate(/datum/power/vampire/mature) in current_powers) && (istype(get_area(H), /area/chapel))) //stay out of the chapel unless you want to turn into a pile of ashes
		nullified = max(5, nullified + 2)
		if(prob(35))
			to_chat(H, "<span class='sinister'>You feel yourself growing weaker.</span>")
		/*smitetemp += (vampcoat ? 5 : 15)
		if(prob(35))
			to_chat(src, "<span class='sinister'>Burn, wretch.</span>")
		*/

	if(!nullified) //Checks to see if you can benefit from your vamp current_powers here
		if(!(locate(/datum/power/vampire/mature) in current_powers))
			smitetemp -= 1
		if(!(locate(/datum/power/vampire/shadow) in current_powers))
			var/turf/T = get_turf(H)
			if((T.get_lumcount() * 10) < 2)
				smitetemp -= 1

		if(!(locate(/datum/power/vampire/undying) in current_powers))
			smitetemp -= 1

	if(smitetemp <= 0) //if you weren't smote by the tile you're on, remove a little holy
		smitetemp = -1

	smitecounter = max(0, (smitecounter + smitetemp))

	// At any rate
	if (smitecounter && H.real_name != initial_appearance.name)
		H.switch_appearance(initial_appearance) // Reveal us as who we are
		H.real_name = initial_appearance.name

	switch(smitecounter)
		if(1 to 30) //just dizziness
			H.dizziness = max(5, H.dizziness)
			if(prob(35))
				to_chat(H, "<span class='warning'>You feel sick.</span>")
		if(30 to 60) //more dizziness, and occasional disorientation
			H.dizziness = max(5, H.dizziness + 1)
			remove_blood(1)
			if(prob(35))
				H.confused = max(5, H.confused)
				to_chat(H, "<span class='warning'>You feel very sick.</span>")
		if(60 to 90) //this is where you start barfing and losing your current_powers
			H.dizziness = max(10, H.dizziness + 3)
			nullified = max(20, nullified)
			remove_blood(2)
			if(prob(8))
				H.vomit()
			if(prob(35))
				H.confused = max(5, H.confused)
				to_chat(H, "<span class='warning'>You feel extremely sick. Get to a coffin as soon as you can.</span>")
		if(90 to 100) //previous effects, and skin starts to smoulder
			H.dizziness = max(10, H.dizziness + 6)
			nullified = max(20, nullified + 1)
			remove_blood(5)
			H.confused = max(10, H.confused)
			H.adjustFireLoss(1)
			if(prob(35))
				H.visible_message("<span class='danger'>[H]'s skin sizzles!</span>", "<span class='danger'>Your skin sizzles!</span>")
		if(100 to (INFINITY)) //BONFIRE
			H.dizziness = max(50, H.dizziness + 8)
			nullified = max(50, nullified + 10)
			remove_blood(10)
			H.confused = max(10, H.confused)
			if(!H.on_fire)
				to_chat(H, "<span class='danger'>Your skin catches fire!</span>")
			else if(prob(35))
				to_chat(H, "<span class='danger'>The holy flames continue to burn your flesh!</span>")
			H.fire_stacks += 5
			H.IgniteMob()

/datum/role/vampire/proc/remove_blood(var/amount)
	blood_usable = max(0, blood_usable - amount)
	update_vamp_hud()

/datum/role/vampire/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	. = ..()
	current_powers.Cut()
	if (issilicon(new_character) || isbrain(new_character)) // No, borgs shouldn't be able to spawn bats
		logo_state = "" // Borgos don't get the vampire icon.
	else
		logo_state = initial(logo_state)
		check_vampire_upgrade()

/datum/role/vampire/handle_reagent(var/reagent_id)
	switch(reagent_id)
		if (HOLYWATER,INCENSE_HAREBELLS)
			var/mob/living/carbon/human/H = antag.current
			if (!istype(H))
				return
			if(locate(/datum/power/vampire/mature) in current_powers)
				to_chat(H, "<span class='danger'>A freezing liquid permeates your bloodstream. Your vampiric powers fade and your insides burn.</span>")
				H.take_organ_damage(0, 5) //FIRE, MAGIC FIRE THAT BURNS ROBOTIC LIMBS TOO!
				smitecounter += 10 //50 units to catch on fire. Generally you'll get fucked up quickly
			else
				to_chat(H, "<span class='warning'>A freezing liquid permeates your bloodstream. You're still too human to be smited!</span>")
				smitecounter += 2 //Basically nothing, unless you drank multiple bottles of holy water (250 units to catch on fire !)

/*
	Commented out for now.

/datum/role/vampire/handle_splashed_reagent(var/reagent_id)
	switch (reagent_id)
		if (HOLYWATER)
			var/mob/living/carbon/human/H = antag.current
			if (!istype(H))
				return
			if(!(locate(/datum/power/vampire/undying) in current_powers))
				if(method == TOUCH)
					if(H.wear_mask)
						to_chat(H, "<span class='warning'>Your mask protects you from the holy water!</span>")
						return

					if(H.head)
						to_chat(H, "<span class='warning'>Your helmet protects you from the holy water!</span>")
						return

					if(H.acidable())
						if(prob(15) && volume >= 30)
							var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD)
							if(head_organ)
								if(!(locate(/datum/power/vampire/mature) in current_powers))
									to_chat(H, "<span class='danger'>A freezing liquid covers your face. Its melting!</span>")
									smitecounter += 60 //Equivalent from metabolizing all this holy water normally
									if(head_organ.take_damage(30, 0))
										H.UpdateDamageIcon(1)
									head_organ.disfigure("burn")
									H.audible_scream()
								else
									to_chat(H, "<span class='warning'>A freezing liquid covers your face. Your vampiric current powers protect you!</span>")
									smitecounter += 12 //Ditto above

						else
							if(!(locate(/datum/power/vampire/mature) in current_powers))
								to_chat(H, "<span class='danger'>You are doused with a freezing liquid. You're melting!</span>")
								H.take_organ_damage(min(15, volume * 2)) //Uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
								smitecounter += volume * 2
							else
								to_chat(H, "<span class='warning'>You are doused with a freezing liquid. Your vampiric current powers protect you!</span>")
								smitecounter += volume * 0.4
				else
					if(H.acidable())
						H.take_organ_damage(min(15, volume * 2))
						smitecounter += 5

*/

/*
-- Helpers --
*/

/datum/role/vampire/update_antag_hud()
	update_vamp_hud()

/datum/role/vampire/proc/update_vamp_hud()
	var/mob/M = antag.current
	if(M && M.client && M.hud_used)
		if(!M.hud_used.vampire_blood_display)
			M.hud_used.vampire_hud()
			//hud_used.human_hud(hud_used.ui_style)
		M.hud_used.vampire_blood_display.maptext_width = WORLD_ICON_SIZE*2
		M.hud_used.vampire_blood_display.maptext_height = WORLD_ICON_SIZE
		M.hud_used.vampire_blood_display.maptext = "<div align='left' valign='top' style='position:relative; top:0px; left:6px'>U:<font color='#33FF33'>[blood_usable]</font><br> T:<font color='#FFFF00'>[blood_total]</font></div>"

/mob/living/carbon/human/proc/check_sun()
	var/ax = x
	var/ay = y

	for(var/i = 1 to 20)
		ax += sun.dx
		ay += sun.dy

		var/turf/T = locate( round(ax,0.5),round(ay,0.5),z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)
			break

		if(T.density)
			return

	if(prob(45))
		switch(health)
			if(80 to 100)
				to_chat(src, "<span class='warning'>Your skin flakes away...</span>")
				adjustFireLoss(1)
			if(60 to 80)
				to_chat(src, "<span class='warning'>Your skin sizzles!</span>")
				adjustFireLoss(1)
			if((-INFINITY) to 60)
				if(!on_fire)
					to_chat(src, "<span class='danger'>Your skin catches fire!</span>")
				else
					to_chat(src, "<span class='danger'>You continue to burn!</span>")
				fire_stacks += 5
				IgniteMob()
		audible_scream()
	else
		switch(health)
			if((-INFINITY) to 60)
				fire_stacks++
				IgniteMob()
	adjustFireLoss(3)

/*
 -- Thralls --
 */

/datum/role/thrall
	id = THRALL
	name = "thrall"
	special_role = "thrall"
	logo_state = "thrall-logo"

	var/datum/role/vampire/master

/datum/role/thrall/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id, var/override = FALSE, var/datum/role/vampire/master)
	. = ..()
	if(!istype(master))
		return FALSE
	src.master = master
	message_admins("[key_name(M)] was enthralled by [key_name(master.antag)]. [formatJumpTo(get_turf(M.current))]")
	log_admin("[key_name(M)] was enthralled by [key_name(master.antag)]. [formatJumpTo(get_turf(M.current))]")
	update_faction_icons()
	Greet(TRUE)
	ForgeObjectives()
	AnnounceObjectives()
	OnPostSetup()

/datum/role/thrall/Greet(var/you_are = TRUE)
	var/dat
	if (you_are)
		dat = "<span class='danger'>You are a Thrall!</br> You are slaved to <b>[master.antag.current]</b> [faction?"under the [faction.name].":"."]</span>"
	dat += {""}
	to_chat(antag.current, dat)
	to_chat(antag.current, "<B>You must complete the following tasks:</B>")
	antag.current << sound('sound/effects/vampire_intro.ogg')

/datum/role/thrall/ForgeObjectives()
	var/datum/objective/target/protect/P = new(auto_target = FALSE)
	P.set_target(master.antag)
	AppendObjective(P)

/datum/role/thrall/Drop(var/deconverted = FALSE)
	var/mob/M = antag.current
	message_admins("[key_name(M)] was dethralled, his master was [key_name(master.antag)]. [formatJumpTo(get_turf(antag.current))]")
	log_admin("[key_name(M)] was dethralled, his master was [key_name(master.antag)]. [formatJumpTo(get_turf(antag.current))]")
	if (deconverted)
		M.visible_message("<span class='big danger'>[M] suddenly becomes calm and collected again, \his eyes clear up.</span>",
		"<span class='big notice'>Your blood cools down and you are inhabited by a sensation of untold calmness.</span>")
	update_faction_icons()
	return ..()

/datum/role/thrall/handle_reagent(var/reagent_id)
	switch (reagent_id)
		if (HOLYWATER)
			var/mob/living/carbon/human/H = antag.current
			if (!istype(H))
				return
			if (prob(35)) // 35% chance of dethralling
				Drop(TRUE)
