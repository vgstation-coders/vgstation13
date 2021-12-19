/obj/item/weapon/reagent_containers/food/snacks/somabass
	name = "soma bass"
	desc = "Although technically fulfilling the criteria to be considered a living being, the soma bass is often considered undead outside of astro-ichthyolgist circles."
	icon = ''
	icon_state = "soma_bass"
	food_flags = FOOD_ANIMAL	//Technically there's no meat. It's alive though so I guess vegan illegal

/obj/item/weapon/reagent_containers/food/snacks/somabass/angler_effect(obj/item/weapon/bait/baitUsed)
	var/baitToLich = 0
	baitToLich = round(1, baitUsed.catchPower/20)
	reagents.add_reagents(LICHISOL, baitToLich)

/obj/item/weapon/reagent_containers/food/snacks/somabass/New()
	..()
	reagents.add_reagent(BONEMARROW, 3)
	bitesize = 2

/datum/reagent/lichisol
	name = "lichisol"
	id = LICHISOL
	description = "Although the effects of lichisol are mostly understood by modern science the chemical has not shown signs of slowing in regards to inspiring ghost stories, religious awakenings, and existential dread."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#211d22"
	custom_metabolism = 0.1
	dupeable = FALSE
	var/list/savedDamage = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0, CLONE = 0, BRAIN = 0)
	var/list/pooledDamage = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0, CLONE = 0, BRAIN = 0)

/datum/reagent/lichisol/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume)
	if(..())
		return 1
	if(M.stat == DEAD)
		lichRevive(M)
	else if(ishuman(M))
		recordDamages(M)
		lichSetHealth(M)

/datum/reagent/lichisol/proc/lichRevive(var/mob/living/ourLich)
	if(isanimal(ourLich) && volume >= 1)
		holder.remove_reagent(LICHISOL, 1)
		if(revAnimalCheck(ourLich))
			revAnimal(ourLich)
	if(ishuman(ourLich) && volume >= 5)
		holder.remove_reagent(LICHISOL, 5)
		if(revHumanCheck(ourLich))
			revHuman(ourLich)

/datum/reagent/lichisol/proc/revAnimalCheck(mob/living/simple_animal/ourLich)
	if(ourLich.mob_property_flags & MOB_NO_LAZ)
		return FALSE
	return TRUE

/datum/reagent/lichisol/proc/revHumanCheck(mob/living/carbon/human/ourLich)	//Altered version of defib checks. Sanities are hard.
	var/datum/organ/external/head/head = ourLich.get_organ(LIMB_HEAD)
	if(!head || head.status & ORGAN_DESTROYED)
		return FALSE
	if(!ourLich.has_brain())
		return FALSE
	if(ourLich.suiciding)
		return FALSE
	return TRUE

/datum/reagent/lichisol/proc/revHuman(mob/living/carbon/human/ourLich)
	if(ourLich.mind && !ourLich.client)
		var/mob/dead/observer/ghost = mind_can_reenter(ourLich.mind)
		if(ghost)
			var/mob/ghostmob = ghost.get_top_transmogrification()
			if(ghostmob)
				ghostmob << 'sound/effects/adminhelp.ogg'
				to_chat(ghostmob, "<span class='interface big'><span class='bold'>Your corpse has been given a dose of lichisol, it's trying to revive!</span> \
					(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[ghost];reentercorpse=1'>click here!</a>)</span>")
				ourLich.visible_message("<span class='warning'>[ourLich]'s body twitches slightly, giving off the subtlest signs of life!</span>"
	spawn(5 SECONDS)
		if(!ourLich.client)
			ourLich.visible_message("<span class='warning'>[ourLich]'s body becomes still and completely lifeless.</span>"
			return
		recordDamages(ourLich)
		lichRevive(ourLich)
		//ourLich.resurrect()

//Compares the previous amount of damage to the current and tallies the difference.
//This proc disgusts me and I'm sorry.
/datum/reagent/lichisol/proc/recordDamages(mob/living/carbon/human/ourLich)
	pooledDamage[BRUTE] += ourLich.getBruteLoss() - savedDamage[BRUTE]
	savedDamage[BRUTE] = ourLich.getBruteLoss()
	pooledDamage[BURN] += ourLich.getFireLoss() - savedDamage[BURN]
	savedDamage[BURN] = ourLich.getFireLoss()
	pooledDamage[TOX] += ourLich.getToxLoss() - savedDamage[TOX]
	savedDamage[TOX] = ourLich.getToxLoss()
	pooledDamage[OXY] += ourLich.getOxyLoss() - savedDamage[OXY]
	savedDamage[OXY] = ourLich.getOxyLoss()
	pooledDamage[CLONE] += ourLich.getCloneLoss() - savedDamage[CLONE]
	savedDamage[CLONE] = ourLich.getCloneLoss()
	pooledDamage[BRAIN] += ourLich.getBrainLoss() - savedDamage[BRAIN]
	savedDamage[BRAIN] = ourLich.getBrainLoss()

/datum/reagent/lichisol/proc/lichRevive(mob/living/carbon/human/ourLich)
	if(!revHumanCheck(ourLich))
		return FALSE
	ourLich.resurrect()
	ourLich.timeofdeath = 0
	ourLich.tod = null	//These are different, apparently
	ourLich.stat = UNCONSCIOUS
	ourLich.regenerate_icons()
	ourLich.apply_effect(10, EYE_BLUR)
	ourLich.apply_effect(10, PARALYZE)
	ourLich.update_canmove()
	has_been_shade.Remove(ourLich.mind)
	lichSetHealth(ourLich)

/datum/reagent/lichisol/proc/lichSetHealth(mob/living/carbon/human/ourLich)
	ourLich.oxyloss = 0
	ourLich.toxloss = 0
	ourLich.fireloss = 0
	ourLich.cloneloss = 0
	ourLich.brainloss = 0
	ourLich.bruteloss = ourLich.maxHealth + (ourLich.maxHealth/2))	//Will generally be 150 damage, ie: in crit and halfway dead
	ourLich.updatehealth()

/datum/reagent/lichisol/proc/lichDamageDebt(mob/living/carbon/human/ourLich)


