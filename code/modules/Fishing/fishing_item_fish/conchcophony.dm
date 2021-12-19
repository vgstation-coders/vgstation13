/obj/item/device/megaphone/conchcophony
	name = "conchcophony"
	desc = "A tough, cone shaped shell.  "
	icon = ''
	icon_state = ""
	var/cacophonyTier = 1
	var/lastConch = 0
	var/conchCooldown = 45 SECONDS
	var/obj/item/device/megaphone/megaConch = null

/obj/item/device/megaphone/conchcophony/angler_effect(obj/item/weapon/bait/baitUsed)
	var/baitToConch = 0
	baitToConch = baitUsed.catchPower/10
	conchCooldown -= min(baitToConch SECONDS, 35 SECONDS)
	baitToConch = round(1, ((baitUsed.catchPower * 0.5) + (baitUsed.catchSizeMult * baitUsed.catchSizeAdd))/20)	//Extremely magic number and I'm sorry
	cacophonyTier = min(baitToConch, 6)	//to-do: Decide if 6 is A) possible and B) Too terrifying


/obj/item/device/megaphone/conchcophony/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/megaphone) && user.drop_item(I, src))
		megaConch = I
		to_chat(user, "<span class='danger'>You stuff \the [megaConch] into the [src] and a primal fear overtakes you. This is a terrible idea. </span>")
		desc += " There is a [megaConch] stuffed inside. How horrifying."

/obj/item/device/megaphone/conchcophony/AltClick(mob/user)
	if(megaConch)
		user.put_in_hands(megaConch)
		megaConch = null

/obj/item/device/megaphone/conchcophony/attack_self(mob/user)
	if(!world.time - lastConch >= conchCooldown)
		to_chat(user, "<span class='notice'>\The [src] is still vibrating from its last use.</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.hasmouth())
			to_chat(user, "<span class='notice'>You need a mouth for that.</span>")
			return
	user.visible_message("<span class='danger'>[user] holds \the [src] to their mouth!</span>")
	if(do_after(user, src, 3 SECONDS))
		lastConch = world.time
		conchHorn(user)

/obj/item/device/megaphone/conchcophony/conchHorn(mob/user)
	playsound(user, 'sound/items/AirHorn.ogg', 100, 1)
	for(var/mob/living/M in hearers(cacophonyTier+1, user))	//Affects the user too
		if(M.is_deaf() || M.earprot())
			continue
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.ear_deaf += cacophonyTier
			C.dizziness += cacophonyTier
			C.jitteriness += cacophonyTier
			if(megaConch)
				C.stunned += 3*cacophonyTier
				C.ear_deaf += 10*cacophonyTier
				C.knockdown += 3*cacophonyTier
		if(isanimal(M))
			var/mob/living/simple_animal/S = M
			S.Stun(cacophonyTier*2)
			S.visible_message("<span class='notice'>\The [S] seems panicked and disoriented by the noise!</span>")
	if(megaConch)
		for(var/obj/structure/window/W in view(cacophonyTier))
			W.shatter()
		explosion(loc,1,1,1,3)
		qdel(src)
