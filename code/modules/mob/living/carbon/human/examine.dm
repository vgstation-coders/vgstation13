#define JITTER_MEDIUM 100
#define JITTER_HIGH 300

/mob/living/carbon/human/examine(mob/user)
	var/list/obscured = check_obscured_slots()
	var/skipgloves = 0
	//var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipface = 0

/*



	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEEYES
		skipears = head.flags_inv & HIDEEARS
		skipface = head.flags_inv & HIDEFACE


*/

	if(wear_mask)
		skipface |= check_hidden_head_flags(HIDEFACE)

	// crappy hacks because you can't do \his[src] etc. I'm sorry this proc is so unreadable, blame the text macros :<
	var/t_He = "It" //capitalised for use at the start of each line.
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"
	var/t_s = "s"
	var/t_es = "es"

	var/msg = "<span class='info'>*---------*\nThis is "

	if((slot_w_uniform in obscured) && skipface)
		t_He = "They"
		t_his = "their"
		t_him = "them"
		t_has = "have"
		t_is = "are"
		t_s = ""
		t_es = ""
	else
		switch(gender)
			if(MALE)
				t_He = "He"
				t_his = "his"
				t_him = "him"
			if(FEMALE)
				t_He = "She"
				t_his = "her"
				t_him = "her"

	var/distance = get_dist(user,src)
	if(istype(user, /mob/dead/observer) || !istype(user) || user.stat == 2) // ghosts can see anything
		distance = 1

	msg += "<EM>[src.name]</EM>!\n"

	//uniform
	if(w_uniform && !(slot_w_uniform in obscured) && w_uniform.is_visible())
		if(w_uniform.blood_DNA && w_uniform.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(w_uniform)] [w_uniform.gender==PLURAL?"some":"a"] blood-stained [w_uniform.name]! [format_examine(w_uniform, "Examine")][w_uniform.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(w_uniform)] \a [w_uniform]. [format_examine(w_uniform, "Examine")][w_uniform.description_accessories()]\n"

	//head
	if(head && head.is_visible())
		if(head.blood_DNA && head.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] blood-stained [head.name] on [t_his] head! [format_examine(head, "Examine")][head.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(head)] \a [head] on [t_his] head. [format_examine(head, "Examine")][head.description_accessories()]\n"

	//suit/armour
	if(wear_suit && wear_suit.is_visible())
		if(wear_suit.blood_DNA && wear_suit.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(wear_suit)] [wear_suit.gender==PLURAL?"some":"a"] blood-stained [wear_suit.name]!  [format_examine(wear_suit, "Examine")][wear_suit.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(wear_suit)] \a [wear_suit]. [format_examine(wear_suit, "Examine")][wear_suit.description_accessories()]\n"

		//suit/armour storage
		if(s_store)
			if(s_store.blood_DNA && s_store.blood_DNA.len)
				msg += "<span class='warning'>[t_He] [t_is] carrying [bicon(s_store)] [s_store.gender==PLURAL?"some":"a"] blood-stained [s_store.name] on [t_his] [wear_suit.name]!  [format_examine(s_store, "Examine")]</span>\n"
			else
				msg += "[t_He] [t_is] carrying [bicon(s_store)] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back && back.is_visible())
		if(back.blood_DNA && back.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] blood-stained [back] on [t_his] back! [format_examine(back, "Examine")][back.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(back)] \a [back] on [t_his] back. [format_examine(back, "Examine")][back.description_accessories()]\n"

	//hands
	for(var/obj/item/I in held_items)
		if(I.is_visible())
			if(I.blood_DNA && I.blood_DNA.len)
				msg += "<span class='warning'>[t_He] [t_is] holding [bicon(I)] [I.gender==PLURAL?"some":"a"] blood-stained [I.name] in [t_his] [get_index_limb_name(is_holding_item(I))]!  [format_examine(I, "Examine")]</span>\n"
			else
				msg += "[t_He] [t_is] holding [bicon(I)] \a [I] in [t_his] [get_index_limb_name(is_holding_item(I))]. [format_examine(I, "Examine")]\n"

	//gloves
	if(gloves && !(slot_gloves in obscured) && gloves.is_visible())
		if(gloves.blood_DNA && gloves.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(gloves)] [gloves.gender==PLURAL?"some":"a"] blood-stained [gloves.name] on [t_his] hands! [format_examine(gloves, "Examine")][gloves.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(gloves)] \a [gloves] on [t_his] hands. [format_examine(gloves, "Examine")][gloves.description_accessories()]\n"
	else if(blood_DNA && blood_DNA.len && !(slot_gloves in obscured))
		msg += "<span class='warning'>[t_He] [t_has] blood-stained hands!</span>\n"

	//handcuffed?
	if((handcuffed && handcuffed.is_visible()) || (mutual_handcuffs && mutual_handcuffs.is_visible()))
		if(istype(handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] handcuffed!</span>\n"

	//belt
	if(belt && belt.is_visible())
		if(belt.blood_DNA && belt.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(belt)] [belt.gender==PLURAL?"some":"a"] blood-stained [belt.name] about [t_his] waist! [format_examine(belt, "Examine")][belt.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(belt)] \a [belt] about [t_his] waist. [format_examine(belt, "Examine")][belt.description_accessories()]\n"

	//shoes
	if(shoes && !(slot_shoes in obscured) && shoes.is_visible())
		if(shoes.blood_DNA && shoes.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(shoes)] [shoes.gender==PLURAL?"some":"a"] blood-stained [shoes.name] on [t_his] feet! [format_examine(shoes, "Examine")][shoes.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(shoes)] \a [shoes] on [t_his] feet. [format_examine(shoes, "Examine")][shoes.description_accessories()]\n"

	//mask
	if(wear_mask && !(slot_wear_mask in obscured) && wear_mask.is_visible())
		if(wear_mask.blood_DNA && wear_mask.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] blood-stained [wear_mask.name] on [t_his] face! [format_examine(wear_mask, "Examine")][wear_mask.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(wear_mask)] \a [wear_mask] on [t_his] face. [format_examine(wear_mask, "Examine")][wear_mask.description_accessories()]\n"

	//eyes
	if(glasses && !(slot_glasses in obscured) && glasses.is_visible())
		if(glasses.blood_DNA && glasses.blood_DNA.len)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(glasses)] [glasses.gender==PLURAL?"some":"a"] blood-stained [glasses] covering [t_his] eyes! [format_examine(glasses, "Examine")][glasses.description_accessories()]</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(glasses)] \a [glasses] covering [t_his] eyes. [format_examine(glasses, "Examine")][glasses.description_accessories()]\n"

	//ears
	if(ears && !(slot_ears in obscured) && ears.is_visible())
		msg += "[t_He] [t_has] [bicon(ears)] \a [ears] on [t_his] ears. [format_examine(ears, "Examine")][ears.description_accessories()]\n"

	//ID
	if(wear_id)
		/*var/id
		if(istype(wear_id, /obj/item/device/pda))
			var/obj/item/device/pda/pda = wear_id
			id = pda.owner
		else if(istype(wear_id, /obj/item/weapon/card/id)) //just in case something other than a PDA/ID card somehow gets in the ID slot :[
			var/obj/item/weapon/card/id/idcard = wear_id
			id = idcard.registered_name
		if(id && (id != real_name) && (get_dist(src, user) <= 1) && prob(10))
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(wear_id)] \a [wear_id] yet something doesn't seem right...</span>\n"
		else
			*/
		msg += "[t_He] [t_is] wearing [bicon(wear_id)] \a [wear_id]. [format_examine(wear_id, "Examine")]\n"

	switch(jitteriness)
		if(JITTER_HIGH to INFINITY)
			msg += "<span class='danger'>[t_He] [t_is] convulsing violently!</span>\n"
		if(JITTER_MEDIUM to JITTER_HIGH)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		if(1 to JITTER_MEDIUM)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"

	if(getOxyLoss() > 30 && !skipface)
		msg += "<span class='info'>[t_He] [t_has] a bluish discoloration to their skin.</span>\n"
	if(getToxLoss() > 30 && !skipface)
		msg += "<span class='warning'>[t_He] looks sickly.</span>\n"
	if((radiation > 30 || rad_tick > 200) && !skipface && !(species.flags & RAD_ABSORB))
		msg += "<span class='blob'>[t_He] [t_has] reddish blotches on [t_his] skin.</span>\n"
	//splints
	for(var/organ in list(LIMB_LEFT_LEG,LIMB_RIGHT_LEG,LIMB_LEFT_ARM,LIMB_RIGHT_ARM))
		var/datum/organ/external/o = get_organ(organ)
		if(o && o.status & ORGAN_SPLINTED)
			msg += "<span class='warning'>[t_He] [t_has] a splint on [t_his] [o.display_name]!</span>\n"

	if(suiciding)
		msg += "<span class='warning'>[t_He] appear[t_s] to have committed suicide... there is no hope of recovery.</span>\n"

	if(M_DWARF in mutations)
		msg += "[t_He] [t_is] a short, sturdy creature fond of drink and industry.\n"

	if (isUnconscious())
		msg += "<span class='warning'>[t_He] [t_is]n't responding to anything around [t_him] and seem[t_s] to be asleep.</span>\n"
		if((isDead() || src.health < config.health_threshold_crit) && distance <= 3)
			msg += "<span class='warning'>[t_He] do[t_es] not appear to be breathing.</span>\n"

		if(ishuman(user) && !user.isUnconscious() && distance <= 1)
			user.visible_message("<span class='info'>[user] checks [src]'s pulse.</span>")

			spawn(15)
				if(user && distance <= 1 && (!istype(user) || !user.isUnconscious()))
					if(pulse == PULSE_NONE || (status_flags & FAKEDEATH))
						to_chat(user, "<span class='deadsay'>[t_He] [t_has] no pulse[mind ? "" : " and [t_his] soul has departed"]...</span>")
					else
						to_chat(user, "<span class='deadsay'>[t_He] [t_has] a pulse!</span>")

	msg += "<span class='warning'>"

	if(nutrition < 100)
		if(hardcore_mode_on && eligible_for_hardcore_mode(src))
			msg += "<span class='danger'>[t_He] [t_is] severely malnourished.</span>\n"
		else
			msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= 500)
		msg += "[t_He] [t_is] quite chubby.\n"

	msg += "</span>"

	if(show_client_status_on_examine || isAdminGhost(user))
		if(has_brain() && stat != DEAD)
			if(!key)
				msg += "<span class='deadsay'>[t_He] [t_is] totally catatonic. The stresses of life in deep space must have been too much for [t_him]. Any recovery is unlikely.</span>\n"
			else if(!client)
				msg += "[t_He] [t_has] a vacant, braindead stare...\n"

	// Religions
	if (ismob(user) && user.mind && user.mind.faith && user.mind.faith.leadsThisReligion(user) && mind)
		if (src.mind.faith == user.mind.faith)
			msg += "<span class='notice'>You recognise [t_him] as a follower of [user.mind.faith.name].</span><br/>"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	for(var/datum/organ/external/temp in organs)
		if(temp)
			if(!temp.is_existing())
				is_destroyed["[temp.display_name]"] = 1
				wound_flavor_text["[temp.display_name]"] = "<span class='danger'>[t_He] [t_is] missing [t_his] [temp.display_name].</span>\n"
				continue
			if(temp.status & ORGAN_PEG)
				if(!(temp.brute_dam + temp.burn_dam))
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a peg [temp.display_name]!</span>\n"
					continue
				else
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a peg [temp.display_name], it has"
				if(temp.brute_dam)
					switch(temp.brute_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some marks"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of damage"," severe cracks and splintering")
				if(temp.brute_dam && temp.burn_dam)
					wound_flavor_text["[temp.display_name]"] += " and"
				if(temp.burn_dam)
					switch(temp.burn_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some burns"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of burns"," severe charring")
				wound_flavor_text["[temp.display_name]"] += "!</span>\n"
			else if(temp.status & ORGAN_ROBOT)
				if(!(temp.brute_dam + temp.burn_dam))
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a robot [temp.display_name]!</span>\n"
					continue
				else
					wound_flavor_text["[temp.display_name]"] = "<span class='warning'>[t_He] [t_has] a robot [temp.display_name], it has"
				if(temp.brute_dam)
					switch(temp.brute_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some dents"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of dents"," severe denting")
				if(temp.brute_dam && temp.burn_dam)
					wound_flavor_text["[temp.display_name]"] += " and"
				if(temp.burn_dam)
					switch(temp.burn_dam)
						if(0 to 20)
							wound_flavor_text["[temp.display_name]"] += " some burns"
						if(21 to INFINITY)
							wound_flavor_text["[temp.display_name]"] += pick(" a lot of burns"," severe melting")
				wound_flavor_text["[temp.display_name]"] += "!</span>\n"
			else if(temp.wounds.len > 0)
				var/list/wound_descriptors = list()
				for(var/datum/wound/W in temp.wounds)
					if(W.internal && !temp.open)
						continue // can't see internal wounds
					var/this_wound_desc = W.desc
					if(W.bleeding())
						this_wound_desc = "bleeding [this_wound_desc]"
					else if(W.bandaged)
						this_wound_desc = "bandaged [this_wound_desc]"
					if(W.germ_level > 600)
						this_wound_desc = "badly infected [this_wound_desc]"
					else if(W.germ_level > 330)
						this_wound_desc = "lightly infected [this_wound_desc]"
					if(this_wound_desc in wound_descriptors)
						wound_descriptors[this_wound_desc] += W.amount
						continue
					wound_descriptors[this_wound_desc] = W.amount
				if(wound_descriptors.len)
					var/list/flavor_text = list()
					var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
					"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
					for(var/wound in wound_descriptors)
						switch(wound_descriptors[wound])
							if(1)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has][prob(10) && !(wound in no_exclude)  ? " what might be" : ""] a [wound]"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a [wound]"
							if(2)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has][prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
							if(3 to 5)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has] several [wound]s"
								else
									flavor_text += " several [wound]s"
							if(6 to INFINITY)
								if(!flavor_text.len)
									flavor_text += "<span class='warning'>[t_He] [t_has] a bunch of [wound]s"
								else
									flavor_text += " a ton of [wound]\s"
					var/flavor_text_string = ""
					for(var/text = 1, text <= flavor_text.len, text++)
						if(text == flavor_text.len && flavor_text.len > 1)
							flavor_text_string += ", and"
						else if(flavor_text.len > 1 && text > 1)
							flavor_text_string += ","
						flavor_text_string += flavor_text[text]
					flavor_text_string += " on [t_his] [temp.display_name].</span><br>"
					wound_flavor_text["[temp.display_name]"] = flavor_text_string
				else
					wound_flavor_text["[temp.display_name]"] = ""
				if(temp.status & ORGAN_BLEEDING)
					is_bleeding["[temp.display_name]"] = 1
			else
				wound_flavor_text["[temp.display_name]"] = ""

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	var/display_chest = 0
	var/display_shoes = 0
	var/display_gloves = 0
	if(wound_flavor_text["head"] && (is_destroyed["head"] || (!skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))))
		msg += wound_flavor_text["head"]
	else if(is_bleeding["head"])
		msg += "<span class='warning'>[src] has blood running down [t_his] face!</span>\n"
	if(wound_flavor_text["chest"] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	else if(is_bleeding["chest"])
		display_chest = 1
	if(wound_flavor_text["left arm"] && (is_destroyed["left arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left arm"]
	else if(is_bleeding["left arm"])
		display_chest = 1
	if(wound_flavor_text["left hand"] && (is_destroyed["left hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["left hand"]
	else if(is_bleeding["left hand"])
		display_gloves = 1
	if(wound_flavor_text["right arm"] && (is_destroyed["right arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right arm"]
	else if(is_bleeding["right arm"])
		display_chest = 1
	if(wound_flavor_text["right hand"] && (is_destroyed["right hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["right hand"]
	else if(is_bleeding["right hand"])
		display_gloves = 1
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["groin"]
	else if(is_bleeding["groin"])
		display_chest = 1
	if(wound_flavor_text["left leg"] && (is_destroyed["left leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left leg"]
	else if(is_bleeding["left leg"])
		display_chest = 1
	if(wound_flavor_text["left foot"]&& (is_destroyed["left foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["left foot"]
	else if(is_bleeding["left foot"])
		display_shoes = 1
	if(wound_flavor_text["right leg"] && (is_destroyed["right leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right leg"]
	else if(is_bleeding["right leg"])
		display_chest = 1
	if(wound_flavor_text["right foot"]&& (is_destroyed["right foot"] || (!shoes  && !skipshoes)))
		msg += wound_flavor_text["right foot"]
	else if(is_bleeding["right foot"])
		display_shoes = 1
	if(display_chest)
		msg += "<span class='danger'>[src] has blood soaking through from under [t_his] clothing!</span>\n"
	if(display_shoes)
		msg += "<span class='danger'>[src] has blood running from [t_his] shoes!</span>\n"
	if(display_gloves)
		msg += "<span class='danger'>[src] has blood running from under [t_his] gloves!</span>\n"

	for(var/implant in get_visible_implants(1))
		msg += "<span class='warning'><b>[src] has \a [implant] sticking out of [t_his] flesh!</span>\n"

	if(!is_destroyed["head"])
		if(getBrainLoss() >= 60)
			msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

		if(distance <= 3)
			if(!has_brain())
				msg += "<span class='notice'><b>[t_He] [t_has] had [t_his] brain removed.</b></span>\n"

	var/butchery = "" //More information about butchering status, check out "code/datums/helper_datums/butchering.dm"
	if(butchering_drops && butchering_drops.len)
		for(var/datum/butchering_product/B in butchering_drops)
			butchery = "[butchery][B.desc_modifier(src, user)]"
	if(butchery)
		msg += "<span class='warning'>[butchery]</span>\n"

	if(istype(user) && user.hasHUD(HUD_SECURITY))
		var/perpname = get_identification_name(get_face_name())
		var/criminal = "None"

		var/datum/data/record/sec_record = data_core.find_security_record_by_name(perpname)
		if(sec_record)
			criminal = sec_record.fields["criminal"]

			msg += {"<span class = 'deptradio'>Criminal status:</span> <a href='?src=\ref[src];criminal=1'>\[[criminal]\]</a>
<span class = 'deptradio'>Security records:</span> <a href='?src=\ref[src];secrecord=`'>\[View\]\n</a>"}
			if(!isjustobserver(user))
				msg += "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>\n"
			msg += {"[wpermit(src) ? "<span class = 'deptradio'>Has weapon permit.</span>\n" : ""]"}

	if(istype(user) && user.hasHUD(HUD_MEDICAL))
		var/perpname = get_identification_name(get_face_name())
		var/medical = "None"

		var/datum/data/record/gen_record = data_core.find_general_record_by_name(perpname)
		if(gen_record)
			medical = gen_record.fields["p_stat"]

		msg += {"<span class = 'deptradio'>Physical status:</span> <a href='?src=\ref[src];medical=1'>\[[medical]\]</a>\n
			<span class = 'deptradio'>Medical records:</span> <a href='?src=\ref[src];medrecord=`'>\[View\]\n</a>"}
		for (var/ID in virus2)
			if (ID in virusDB)
				var/datum/data/record/v = virusDB[ID]
				msg += "<br><span class='warning'>[v.fields["name"]][v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""] detected in subject.</span>\n"
		if(!isjustobserver(user))
			msg += "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>\n"

	if(flavor_text && can_show_flavor_text())
		msg += "[print_flavor_text()]\n"

	msg += "*---------*</span>"

	to_chat(user, msg)
	if(istype(user))
		user.heard(src)

#undef JITTER_MEDIUM
#undef JITTER_HIGH
