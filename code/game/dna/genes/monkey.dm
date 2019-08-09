/datum/dna/gene/monkey
	name = "Monkey"
	flags = GENE_UNNATURAL

/datum/dna/gene/monkey/New()
	block = MONKEYBLOCK

/datum/dna/gene/monkey/can_activate(var/mob/M,var/flags)
	return istype(M, /mob/living/carbon/human) || istype(M,/mob/living/carbon/monkey)

//Human to monkey
/datum/dna/gene/monkey/activate(var/mob/living/M, var/connected, var/flags)
	if(!istype(M,/mob/living/carbon/human))
		//testing("Cannot monkey-ify [M], type is [M.type].")
		return
	var/mob/living/carbon/human/H = M
	var/mob/living/carbon/monkey/O = H.monkeyize()
	H = null
	if (connected) // properly put new monkey inside machine
		var/obj/machinery/dna_scannernew/C = connected
		if(O)
			O.forceMove(C)
			C.occupant = O
			return
		C.occupant = null

//Monkey to human
/datum/dna/gene/monkey/deactivate(var/mob/living/M, var/connected, var/flags)
	if(!istype(M,/mob/living/carbon/monkey))
//		testing("Cannot humanize [M], type is [M.type].")
		return
	var/mob/living/carbon/monkey/Mo = M
	Mo.monkeyizing = 1
	if(!connected)
		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.invisibility = 101
		M.delayNextAttack(50)
		var/atom/movable/overlay/animation = new( M.loc )
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		flick("monkey2h", animation)
		sleep(48)
		animation.master = null
		qdel(animation)

	for (var/mob/living/simple_animal/borer/borer in Mo)
		if (borer.controlling)
			Mo.do_release_control(0)

	var/mob/living/carbon/human/O = new(src)
	if(Mo.greaterform)
		O.set_species(Mo.greaterform)
	Mo.transferImplantsTo(O)

	if (M.dna.GetUIState(DNA_UI_GENDER))
		O.setGender(FEMALE)
	else
		O.setGender(MALE)

	if (M)
		if (M.dna)
			O.dna = M.dna
			M.dna = null

		if (M.suiciding)
			O.suiciding = M.suiciding
			M.suiciding = null

	for(var/datum/disease/D in M.viruses)
		O.viruses += D
		D.affected_mob = O
		M.viruses -= D
	O.virus2 = virus_copylist(M.virus2)
	if (M.immune_system)
		M.immune_system.transfer_to(O)

	//for(var/obj/T in M)
	//	del(T)

	O.forceMove(M.loc)
	Mo.dropBorers() //safer to just drop these like I originally did
	if(M.mind)
		M.mind.transfer_to(O)	//transfer our mind to the human


	for(var/obj/item/W in (Mo.contents))
		Mo.drop_from_inventory(W)
	if (connected) //inside dna thing
		var/obj/machinery/dna_scannernew/C = connected
		O.forceMove(C)
		C.occupant = O
		connected = null

	var/i
	while (!i)
		var/randomname = O.species.makeName(O.gender,O)
		if (findname(randomname))
			continue
		else
			O.real_name = randomname
			i++
	O.UpdateAppearance()
	O.my_appearance.h_style = random_hair_style(O.gender,O.species.name)
	O.my_appearance.f_style = random_facial_hair_style(O.gender,O.species.name)
	O.update_hair()
	O.take_overall_damage(M.getBruteLoss(), M.getFireLoss())
	O.adjustToxLoss(M.getToxLoss())
	O.adjustOxyLoss(M.getOxyLoss())
	O.stat = M.stat
//		O.update_icon = 1	//queue a full icon update at next life() call
	Mo.monkeyizing = 0
	qdel(M)
	M = null
	return
