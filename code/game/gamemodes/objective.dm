//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
var/global/list/all_objectives = list()

var/list/potential_theft_objectives=list(
	"traitor" = typesof(/datum/theft_objective/traitor) - /datum/theft_objective/traitor,
	"special" = typesof(/datum/theft_objective/special) - /datum/theft_objective/special,
	"heist_easy"   = typesof(/datum/theft_objective/number/heist_easy) - /datum/theft_objective/number/heist_easy,
	"heist_hard"   = typesof(/datum/theft_objective/number/heist_hard) - /datum/theft_objective/number/heist_hard,
	//"salvage" = typesof(/datum/theft_objective/number/salvage) - /datum/theft_objective/number/salvage
)


/datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.
	var/blocked = 0                     // Universe fucked, you lost.
	var/list/bad_assassinate_targets = list("AI","Cyborg","Mobile MMI","Trader")

/datum/objective/New(var/text)
	all_objectives |= src
	if(text)
		explanation_text = text

/datum/objective/Destroy()
	all_objectives -= src
	return ..()


/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in ticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && (possible_target.current.stat != DEAD) && !(possible_target.assigned_role in bad_assassinate_targets))
			possible_targets += possible_target
	if(possible_targets.len > 0)
		target = pick(possible_targets)


/datum/objective/proc/find_target_by_role(role, role_type = 0)//Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in ticker.minds)
		if((possible_target != owner) && ishuman(possible_target.current) && (possible_target.current.z != map.zCentcomm) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) && !(possible_target.assigned_role in bad_assassinate_targets))
			target = possible_target
			break



/datum/objective/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/assassinate/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/assassinate/check_completion()
	if(target && target.current && !blocked)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > 6 || !target.current.ckey || isborer(target.current)) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return 1
		return 0
	return 1



/datum/objective/mutiny/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/mutiny/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/mutiny/check_completion()
	if(target && target.current && !blocked)
		if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey)
			return 1
		var/turf/T = get_turf(target.current)
		if(T && (T.z != map.zMainStation))			//If they leave the station they count as dead for this
			return 2
		return 0
	return 1

/datum/objective/mutiny/rp/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate, capture or convert [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/mutiny/rp/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate, capture or convert [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

// less violent rev objectives
/datum/objective/mutiny/rp/check_completion()
	var/rval = 1
	if(target && target.current && !blocked)
		//assume that only carbon mobs can become rev heads for now
		if(target.current.stat == DEAD || target.current:handcuffed || !ishuman(target.current))
			return 1
		// Check if they're converted
		if(istype(ticker.mode, /datum/game_mode/revolution))
			if(target in ticker.mode:head_revolutionaries)
				return 1
		var/turf/T = get_turf(target.current)
		if(T && (T.z != map.zMainStation))			//If they leave the station they count as dead for this
			rval = 2
		return 0
	return rval

/datum/objective/anti_revolution/execute/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/anti_revolution/execute/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/execute/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || !ishuman(target.current))
			return 1
		return 0
	return 1

/datum/objective/anti_revolution/brig
	var/already_completed = 0

/datum/objective/anti_revolution/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [target.assigned_role] for 20 minutes to set an example."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/anti_revolution/brig/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] for 20 minutes to set an example."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/brig/check_completion()
	if(blocked)
		return 0
	if(already_completed)
		return 1

	if(target && target.current)
		if(target.current.stat == DEAD)
			return 0
		if(target.is_brigged(10 * 60 * 10))
			already_completed = 1
			return 1
		return 0
	return 0

/datum/objective/anti_revolution/demote/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role]  has been classified as harmful to Nanotrasen's goals. Demote \him[target.current] to assistant."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/demote/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has been classified as harmful to Nanotrasen's goals. Demote \him[target.current] to assistant."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/demote/check_completion()
	if(blocked)
		return 0
	if(target && target.current && istype(target,/mob/living/carbon/human))
		var/obj/item/weapon/card/id/I = target.current:wear_id
		if(istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/P = I
			I = P.id

		if(!istype(I))
			return 1

		if(I.assignment == "Assistant")
			return 1
		else
			return 0
	return 1

/datum/objective/debrain/find_target() //I want braaaainssss

	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/debrain/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/debrain/check_completion()
	if(blocked)
		return 0
	if(!target)//If it's a free objective.
		return 1
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return 0
	if( !target.current || !isbrain(target.current) )
		return 0
	var/atom/A = target.current
	while(A.loc)			//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return 1
	return 0

/datum/objective/protect/find_target() //The opposite of killing a dude.
	..()
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/protect/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/protect/check_completion()
	if(blocked)
		return 0
	if(!target)			//If it's a free objective.
		return 1
	if(target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || isborer(target.current))
			return 0
		return 1
	return 0

/datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping without any organic life-forms other than yourself."

/datum/objective/hijack/check_completion()
	if(blocked)
		return 0
	if(!owner.current || owner.current.stat)
		return 0
	if(emergency_shuttle.location<2)
		return 0
	if(issilicon(owner.current))
		return 0
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/list/protected_mobs = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/simple_animal/borer)
	// Implemented in response to 21/12/2013 player vote,  .
	// Comment this if you want Borgs and MoMMIs counted.
	// TODO: Check if borgs are subverted. Best I can think of is a fuzzy check for strings used in syndie laws. BYOND can't do regex, sadly. - N3X
	protected_mobs += list(/mob/living/silicon/robot, /mob/living/silicon/robot/mommi)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)
			continue
		if (player.mind && (player.mind != owner))
			if(player.stat != DEAD)			//they're not dead!
				if(get_turf(player) in shuttle)
					return 0
	return 1

/datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."

/datum/objective/block/check_completion()
	if(blocked)
		return 0
	if(!istype(owner.current, /mob/living/silicon))
		return 0
	if(emergency_shuttle.location<2)
		return 0
	if(!owner.current)
		return 0
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot, /mob/living/silicon/robot/mommi, /mob/living/simple_animal/borer)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)
			continue
		if (player.mind)
			if (player.stat != 2)
				if (get_turf(player) in shuttle)
					return 0
	return 1

/datum/objective/silence
	explanation_text = "Do not allow anyone to escape the station.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

/datum/objective/silence/check_completion()
	if(blocked)
		return 0
	if(emergency_shuttle.location<2)
		return 0

	for(var/mob/living/player in player_list)
		if(player == owner.current)
			continue
		if(player.mind)
			if(player.stat != DEAD)
				var/turf/T = get_turf(player)
				if(!T)
					continue
				switch(T.loc.type)
					if(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
						return 0
	return 1

/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."

/datum/objective/escape/check_completion()
	if(blocked)
		return 0
	if(issilicon(owner.current))
		return 0
	if(isbrain(owner.current) || isborer(owner.current))
		return 0
	if(emergency_shuttle.location<2)
		return 0
	if(!owner.current || owner.current.stat ==2)
		return 0
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return 0

	if(istype(location, /turf/simulated/shuttle/floor4)) // Fails tratiors if they are in the shuttle brig -- Polymorph
		if(istype(owner.current, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = owner.current
			if(!H.restrained()) // Technically, traitors will fail the objective if they are time stopped by a wizard
				return 1
		else if(istype(owner.current, /mob/living/carbon)) // I don't think non-humanoid carbons can get the escape objective, but I'm leaving it to be safe
			var/mob/living/carbon/C = owner.current
			if (!C.handcuffed)
				return 1
		return 0

	var/area/check_area = location.loc
	if(istype(check_area, /area/shuttle/escape/centcom))
		return 1
	if(istype(check_area, /area/shuttle/escape_pod1/centcom))
		return 1
	if(istype(check_area, /area/shuttle/escape_pod2/centcom))
		return 1
	if(istype(check_area, /area/shuttle/escape_pod3/centcom))
		return 1
	if(istype(check_area, /area/shuttle/escape_pod5/centcom))
		return 1
	else
		return 0

/datum/objective/die
	explanation_text = "Die a glorious death."

/datum/objective/die/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current) || isborer(owner.current))
		return 1		//Brains no longer win survive objectives. --NEO
	if(issilicon(owner.current) && owner.current != owner.original)
		return 1
	return 0

/datum/objective/survive
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	if(blocked)
		return 0
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current) || isborer(owner.current || issilicon(owner.current)))
		return 0		//Brains no longer win survive objectives. --NEO
	return 1

/datum/objective/siliconsurvive
	explanation_text = "Remain functional until the end."

/datum/objective/siliconsurvive/check_completion()
	if(blocked)
		return 0
	if(!owner.current || owner.current.stat == DEAD || !issilicon(owner.current))
		return 0
	return 1

/datum/objective/multiply
	explanation_text = "Procreate, and protect your spawn."
	var/already_completed=0

/datum/objective/multiply/check_completion()
	if(blocked)
		return 0
	if(already_completed)
		return 1
	if(!owner.current)
		return 0
	var/mob/living/simple_animal/borer/B=owner.current
	if(!istype(B))
		return 0
	if(B.numChildren>0)
		already_completed=1
		return 1
	return 0

// Similar to the anti-rev objective, but for traitors
/datum/objective/brig
	var/already_completed = 0

/datum/objective/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [target.assigned_role] brigged for 10 minutes."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/brig/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] brigged for 10 minutes."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/brig/check_completion()
	if(blocked)
		return 0
	if(already_completed)
		return 1

	if(target && target.current)
		if(target.current.stat == DEAD)
			return 0
		// Make the actual required time a bit shorter than the official time
		if(target.is_brigged(10 * 60 * 5))
			already_completed = 1
			return 1
		return 0
	return 0

// Harm a crew member, making an example of them
/datum/objective/harm
	var/already_completed = 0

/datum/objective/harm/find_target()
	..()
	if(target && target.current)
		explanation_text = "Make an example of [target.current.real_name], the [target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/harm/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Make an example of [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/harm/check_completion()
	if(blocked)
		return 0
	if(already_completed)
		return 1

	if(target && target.current && istype(target.current, /mob/living/carbon/human))
		if(target.current.stat == DEAD)
			return 0

		var/mob/living/carbon/human/H = target.current
		for(var/datum/organ/external/E in H.organs)
			if(!E.is_healthy())
				already_completed = 1
				return 1

		var/datum/organ/external/head/head = H.get_organ(LIMB_HEAD)
		if(head.disfigured)
			return 1
	return 0


/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."

/datum/objective/nuclear/check_completion()
	if(ticker.mode.explosion_in_progress || ticker.mode.station_was_nuked)
		return 1
	return 0

/datum/objective/steal
	var/target_category = "traitor"
	var/datum/theft_objective/steal_target

/datum/objective/steal/find_target()
	var/list/possibleObjectives = potential_theft_objectives[target_category]
	var/loopSanity = possibleObjectives.len

	while(isnull(steal_target) && loopSanity > 0)
		loopSanity--

		var/pickedObjective = pick(possibleObjectives)
		var/datum/theft_objective/objective = new pickedObjective

		if(objective.typepath in map.unavailable_items)
			continue

		if(owner && owner.assigned_role in objective.protected_jobs)
			continue

		steal_target = objective
		explanation_text = format_explanation()
		return

	explanation_text = "Free Objective."

/datum/objective/steal/proc/format_explanation()
	return "Steal [steal_target.name]."

/datum/objective/steal/proc/select_target()
	var/list/possible_items_all = potential_theft_objectives[target_category]+"custom"
	var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_items_all
	if (!new_target)
		return
	if (new_target == "custom")
		var/datum/theft_objective/O=new
		O.typepath = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!O.typepath)
			return
		var/tmp_obj = new O.typepath
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		O.name = copytext(sanitize(input("Enter target name:", "Objective target", custom_name) as text|null),1,MAX_NAME_LEN)
		if (!O.name)
			return
		steal_target = O
		explanation_text = format_explanation()
	else
		steal_target = new new_target
		explanation_text = format_explanation()
	return steal_target

/datum/objective/steal/check_completion()
	if(blocked)
		return 0
	if(!steal_target)
		return 1 // Free Objective
	return steal_target.check_completion(owner)

/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	explanation_text = "Accumulate [target_amount] capture points."
	return target_amount


/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	if(blocked)
		return 0
	var/captured_amount = 0
	var/area/centcom/holding/A = locate()
	for(var/mob/living/carbon/human/M in A)//Humans.
		if(M.stat==2)//Dead folks are worth less.
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
		captured_amount+=0.1
	for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
		if(M.stat==2)
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/alien/humanoid/M in A)//Aliens are worth twice as much as humans.
		if(istype(M, /mob/living/carbon/alien/humanoid/queen))//Queens are worth three times as much as humans.
			if(M.stat==2)
				captured_amount+=1.5
			else
				captured_amount+=3
			continue
		if(M.stat==2)
			captured_amount+=1
			continue
		captured_amount+=2
	if(captured_amount<target_amount)
		return 0
	return 1

/datum/objective/blood/proc/gen_amount_goal(low = 150, high = 400)
	target_amount = rand(low,high)
	target_amount = round(round(target_amount/5)*5)
	explanation_text = "Accumulate atleast [target_amount] units of blood in total."
	return target_amount

/datum/objective/blood/check_completion()
	if(blocked)
		return 0
	if(owner && owner.vampire && owner.vampire.bloodtotal && owner.vampire.bloodtotal >= target_amount)
		return 1
	else
		return 0

/datum/objective/absorb/proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
	target_amount = rand (lowbound,highbound)
	if (ticker)
		var/n_p = 1 //autowin
		if (ticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/new_player/P in player_list)
				if(P.client && P.ready && P.mind!=owner)
					n_p ++
		else if (ticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/P in player_list)
				if(P.client && !(P.mind in ticker.mode.changelings) && P.mind!=owner)
					n_p ++
		target_amount = min(target_amount, n_p)

	explanation_text = "Absorb [target_amount] compatible genomes."
	return target_amount

/datum/objective/absorb/check_completion()
	if(blocked)
		return 0
	if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
		return 1
	else
		return 0



/* Isn't suited for global objectives
/*---------CULTIST----------*/

		eldergod
			explanation_text = "Summon Nar-Sie via the use of an appropriate rune. It will only work if nine cultists stand on and around it."

			check_completion()
				if(eldergod) //global var, defined in rune4.dm
					return 1
				return 0

		survivecult
			var/num_cult

			explanation_text = "Our knowledge must live on. Make sure at least 5 acolytes escape on the shuttle to spread their work on an another station."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				var/cultists_escaped = 0

				var/area/shuttle/escape/centcom/C = /area/shuttle/escape/centcom
				for(var/turf/T in	get_area_turfs(C.type))
					for(var/mob/living/carbon/H in T)
						if(iscultist(H))
							cultists_escaped++

				if(cultists_escaped>=5)
					return 1

				return 0

		sacrifice //stolen from traitor target objective

			proc/find_target() //I don't know how to make it work with the rune otherwise, so I'll do it via a global var, sacrifice_target, defined in rune15.dm
				var/list/possible_targets = call(/datum/game_mode/cult/proc/get_unconvertables)()


				if(possible_targets.len > 0)
					sacrifice_target = pick(possible_targets)

				if(sacrifice_target && sacrifice_target.current)
					explanation_text = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell join blood) and three acolytes to do so."
				else
					explanation_text = "Free Objective"

				return sacrifice_target

			check_completion() //again, calling on a global list defined in rune15.dm
				if(sacrifice_target.current in sacrificed)
					return 1
				else
					return 0

/*-------ENDOF CULTIST------*/
*/

// /vg/; Vox Inviolate for humans :V
/datum/objective/minimize_casualties
	explanation_text = "Minimise casualties."

/datum/objective/minimize_casualties/check_completion()
	if(blocked)
		return 0
	if(owner.kills.len>5)
		return 0
	return 1