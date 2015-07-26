//DEBUG ITEMS
/obj/item/weapon/clockcheat
	name = "ZOOP"
	desc = "ZOP"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "soulvessel-occupied"

/obj/item/weapon/clockcheat/attack_self(mob/living/user as mob)
	if(!isclockcult(user))
		user << "<span class='clockwork'>Ratvar: \"wyd?\"</span>"
		return 0
	user << "<span class='clockwork'>Ratvar: \"It's lit.\"</span>"
	return 1

/obj/item/weapon/clockcheat/spear
	color = "#ff0000"

/obj/item/weapon/clockcheat/spear/attack_self(mob/living/user as mob)
	if(!..()) return
	user.add_spell(new/spell/targeted/equip_item/clockspear)

/*/obj/item/weapon/clockcheat/revenant
	color = "#ff0000"

/obj/item/weapon/clockcheat/revenant/attack_self(mob/living/user as mob)
	if(!..()) return

	var/mob/living/simple_animal/bound_revenant/R = new
	R.contractor = user.mind*/

/obj/item/weapon/clockcheat/gateway
	color = "#ffff00"

/obj/item/weapon/clockcheat/gateway/attack_self(mob/living/user as mob)
	if(!..()) return

	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/machinery/clockobelisk/C in clockobelisks)
		var/turf/T = get_turf(C)
		if (!T)
			continue
		if(T.z == 2 || T.z > 7)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = C

	if(!L.len)
		user << "<span class='warning'>You can't open a gateway if there's no valid targets.</span>"
		return

	var/gateinfo = input("Choose an active obelisk to warp to.", "Spatial Gateway") in L
	if(!gateinfo) return
	new /obj/machinery/s_gateway(get_turf(user), L[gateinfo])

/obj/item/weapon/clockcheat/compromise
	color = "#0000ff"

/obj/item/weapon/clockcheat/compromise/attack_self(mob/living/user as mob)
	if(!..()) return

	var/list/targets = list()
	for(var/mob/living/target in range(8, user))
		if(target.stat == DEAD)
			continue
		if(!isclockcult(target))
			continue
		targets += target

	var/mob/living/selected = input(user, "Select a cultist to heal.", "Sentinel's Compromise") as null|mob in targets
	var/damage = selected.getBruteLoss() + selected.getFireLoss()

	selected.adjustBruteLoss(selected.getBruteLoss())
	selected.adjustFireLoss(selected.getFireLoss())
	selected.adjustToxLoss(damage * 0.45)

	if(ishuman(selected))
		var/mob/living/carbon/human/H = selected
		for(var/datum/organ/external/O in H.organs)
			if(O.brute_dam || O.burn_dam)
				H.pain(O, (O.brute_dam + O.burn_dam), 1, 1)
				O.heal_damage(O.brute_dam, O.burn_dam, 1, 1)

	user << "<span class='clockwork'>You mend [selected]'s wounds.</span>"
	selected << "<span class='clockwork'>[user] painfully mends your wounds, and a strong desire to vomit arises.</span>"
	if(prob(25))
		if(ishuman(selected))
			var/mob/living/carbon/human/H = selected
			H.vomit()
		selected << "<span class='warning'>...and so, you do.</span>"

/obj/item/weapon/clockcheat/belligerent
	color = "#ff0000"

/obj/item/weapon/clockcheat/belligerent/attack_self(mob/living/user as mob)
	if(!..()) return

	var/turf/castspot = user.loc
	var/holding = user.get_active_hand()
	var/channeldur = 0
	user.color = "#FF0000"
	for(var/i = 0 to 30)
		if(!user || user.stat != CONSCIOUS || user.weakened || user.stunned)
			break
		if(user.loc != castspot)
			break
		if(!(user.get_active_hand() == holding))
			break
		if(!isclockcult(user))
			break
		channeldur++

		for(var/mob/living/carbon/human/H in oview(7))
			if(isclockcult(H))
				continue
			if(H.stat >= UNCONSCIOUS)
				continue

			if(H.m_intent != "walk")
				H.m_intent = "walk"
				if(H.hud_used && H.hud_used.move_intent)
					H.hud_used.move_intent.icon_state = "walking"

			var/turf/T = get_turf(H)
			if(T.c_animation)
				returnToPool(T.c_animation)
				T.c_animation = null
			T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/effects/siphon.ogg',"#FF0000")

			if(prob(25))
				H.adjustBruteLoss((iscultist(H) ? 8 : 4))
				if(iscultist(H) && prob(15))
					H << "<span class='clockwork'>\"Kneel.\"</span>"
			else
				H << "<span class='danger'>A mighty force impedes your movements.</span>"
		sleep(20)

	user << "<span class='warning'>Ratvar's fury overwhelms you, preventing you from moving.</span>"
	var/turf/T = get_turf(user)
	T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/effects/siphon.ogg',"#FF0000")
	user.Stun(channeldur)
	spawn(channeldur)
		user.color = "#FFFFFF"


/obj/item/weapon/clockcheat/voltvoid
	color = "#FF9900"

/obj/item/weapon/clockcheat/voltvoid/attack_self(mob/living/user as mob)
	if(!..()) return

	var/turf/castspot = user.loc
	var/holding = user.get_active_hand()
	user.color = "#FF9900"
	playsound(get_turf(user), 'sound/effects/EMPulse.ogg', 100, 1)
	for(var/i = 0 to 30)
		if(!user || user.stat != CONSCIOUS || user.stunned)
			break
		if(castspot && user.loc != castspot)
			break
		if(!(user.get_active_hand() == holding))
			break
		if(!isclockcult(user))
			break

		var/list/powercells = list()
		for(var/obj/machinery/M in range(9, user))
			powercells += recursive_type_check(M, /obj/item/weapon/cell)
		for(var/obj/mecha/A in range(9,user))
			powercells += recursive_type_check(A, /obj/item/weapon/cell)
		for(var/mob/living/L in range(9,user))
			powercells += recursive_type_check(L, /obj/item/weapon/cell)
			if(istype(L, /mob/living/silicon))
				var/mob/living/silicon/S = L
				S << "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>"

		for(var/obj/item/weapon/cell/PC in powercells)
			if(PC.charge <= 0)
				powercells -= PC
				continue
			PC.use(500)

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/organ/external/O = pick(H.organs)
			if(O.status & ORGAN_ROBOT)
				O.heal_damage(2, 1, 1, 1)
			else
				O.take_damage(0, powercells.len)
		sleep(20)

	user.color = "#FFFFFF"
