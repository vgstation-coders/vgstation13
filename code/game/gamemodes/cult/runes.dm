/obj/effect/rune/cultify()
	return

/obj/effect/rune/proc/findNullRod(var/atom/target)
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		nullblock = 1
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-WORLD_ICON_SIZE,-WORLD_ICON_SIZE,MOB_LAYER+1,'sound/instruments/piano/Ab7.ogg',anim_plane = EFFECTS_PLANE)
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			findNullRod(A)
	return 0

/obj/effect/rune/proc/invocation(var/animation_icon)
	if(c_animation) // if you've more than one, it won't go away
		return
	c_animation = new /atom/movable/overlay(src.loc)
	c_animation.name = "cultification"
	c_animation.setDensity(FALSE)
	c_animation.anchored = 1
	c_animation.icon = 'icons/effects/effects.dmi'
	c_animation.plane = EFFECTS_PLANE
	c_animation.master = src.loc
	c_animation.icon_state = "[animation_icon]"
	flick("cultification",c_animation)
	spawn(10)
		if(c_animation)
			c_animation.master = null
			qdel(c_animation)
			c_animation = null

/////////////////////////////////////////FIRST RUNE
/obj/effect/rune/proc/teleport(var/key)
	var/mob/living/user = usr
	var/allrunesloc[]
	allrunesloc = new/list()
	var/index = 0
//	var/tempnum = 0
	for(var/obj/effect/rune/R in rune_list)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["self"] && R.word3 == key && R.z != map.zCentcomm)
			index++
			allrunesloc.len = index
			allrunesloc[index] = R.loc
	if(index >= 5)
		to_chat(user, "<span class='warning'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric</span>")
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	if(allrunesloc && index != 0)
		if(istype(src,/obj/effect/rune))
			user.say("Sas[pick("'","`")]so c'arta forbici!")//Only you can stop auto-muting
		else
			user.whisper("Sas[pick("'","`")]so c'arta forbici!")
		if(universe.name != "Hell Rising")
			user.visible_message("<span class='warning'> [user] disappears in a flash of red light!</span>", \
			"<span class='warning'>You feel a sharp pain as your body gets dragged through the dimension of Nar-Sie!</span>", \
			"<span class='warning'>You hear a sickening crunch and sloshing of viscera.</span>")
		else
			user.visible_message("<span class='warning'> [user] disappears in a flash of red light!</span>", \
			"<span class='warning'>You feel a sharp pain as your body gets dragged through a tunnel of viscera !</span>", \
			"<span class='warning'>You hear a sickening crunch and sloshing of viscera.</span>")

		if(istype(src,/obj/effect/rune))
			invocation("rune_teleport")

		user.forceMove(allrunesloc[rand(1,index)])
		return
	if(istype(src,/obj/effect/rune))
		return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
	else
		call(/obj/effect/rune/proc/fizzle)()
		return


/obj/effect/rune/proc/itemport(var/key)
//	var/allrunesloc[]
//	allrunesloc = new/list()
//	var/index = 0
//	var/tempnum = 0
	var/culcount = 0
	var/runecount = 0
	var/obj/effect/rune/IP = null
	var/mob/living/user = usr
	var/swapping[] = null
	for(var/obj/effect/rune/R in rune_list)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["other"] && R.word3 == key)
			IP = R
			runecount++
	if(runecount >= 2)
		to_chat(user, "<span class='warning'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric</span>")
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=2)
		user.say("Sas[pick("'","`")]so c'arta forbici tarem!")

		nullblock = 0
		for(var/turf/T1 in range(src,1))
			findNullRod(T1)
		if(nullblock)
			user.visible_message("<span class='warning'>A nearby holy item seems to be blocking the transfer.</span>")
			return

		for(var/turf/T2 in range(IP,1))
			findNullRod(T2)
		if(nullblock)
			user.visible_message("<span class='warning'>A holy item seems to be blocking the transfer on the other side.</span>")
			return

		user.visible_message("<span class='warning'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='warning'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='warning'>You smell ozone.</span>")

		swapping = list()
		for(var/obj/O in IP.loc)//filling a list with all the teleportable atoms on the other rune
			if(!O.anchored)
				swapping += O
		for(var/mob/M in IP.loc)
			swapping += M

		for(var/obj/O in src.loc)//sending the items on the rune to the other rune
			if(!O.anchored)
				O.forceMove(IP.loc)
		for(var/mob/M in src.loc)
			M.forceMove(IP.loc)

		for(var/obj/O in swapping)//bringing the items previously marked from the other rune to our rune
			O.forceMove(src.loc)
		for(var/mob/M in swapping)
			M.forceMove(src.loc)

		swapping = 0
		return
	return fizzle()


/////////////////////////////////////////SECOND RUNE

/obj/effect/rune/proc/tomesummon()
	if(istype(src,/obj/effect/rune))
		usr.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	else
		usr.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	usr.visible_message("<span class='warning'>Rune disappears with a flash of red light, and in its place now a book lies.</span>", \
	"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.</span>", \
	"<span class='warning'>You hear a pop and smell ozone.</span>")
	if(istype(src,/obj/effect/rune))
		new /obj/item/weapon/tome(src.loc)
		src.invocation("tome_spawn")
	else
		new /obj/item/weapon/tome(usr.loc)
	qdel(src)
	stat_collection.cult_tomes_created++
	return

/////////////////////////////////////////THIRD RUNE

/obj/effect/rune/proc/convert()

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	for(var/mob/living/carbon/M in src.loc)
		if(iscultist(M))
			to_chat(usr, "<span class='warning'>You cannot convert what is already a follower of Nar-Sie.</span>")
			return 0
		if(M.stat==DEAD)
			to_chat(usr, "<span class='warning'>You cannot convert the dead.</span>")
			return 0
		if(!M.mind)
			to_chat(usr, "<span class='warning'>You cannot convert that which has no soul</span>")
			return 0
		if(cult_round && (M.mind == cult_round.sacrifice_target))
			to_chat(usr, "<span class='warning'>The Geometer of blood wants this mortal for himself.</span>")
			return 0
		usr.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
		nullblock = 0
		for(var/turf/T in range(M,1))
			findNullRod(T)
		if(nullblock)
			usr.visible_message("<span class='warning'>Something is blocking the conversion!</span>")
			return 0
		invocation("rune_convert")
		M.visible_message("<span class='warning'>[M] writhes in pain as the markings below \him glow a bloody red.</span>", \
		"<span class='danger'>AAAAAAHHHH!.</span>", \
		"<span class='warning'>You hear an anguished scream.</span>")
		if(is_convertable_to_cult(M.mind) && !jobban_isbanned(M, "cultist"))//putting jobban check here because is_convertable uses mind as argument
			ticker.mode.add_cultist(M.mind)
			M.mind.special_role = "Cultist"
			to_chat(M, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
			to_chat(M, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
			to_chat(M, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")
			M.add_language(LANGUAGE_CULT)
			log_admin("[usr]([ckey(usr.key)]) has converted [M] ([ckey(M.key)]) to the cult at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.loc.x];Y=[M.loc.y];Z=[M.loc.z]'>([M.loc.x], [M.loc.y], [M.loc.z])</a>")
			add_attacklogs(usr, M, "converted to the Cult of Nar'Sie!")
			stat_collection.cult_converted++
			if(M.client)
				spawn(600)
					if(M && !M.client)
						var/turf/T = get_turf(M)
						message_admins("[M] ([ckey(M.key)]) ghosted/disconnected less than a minute after having been converted to the cult! ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
						log_admin("[M]([ckey(M.key)]) ghosted/disconnected less than a minute after having been converted to the cult! ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			return 1
		else
			if(is_convertable_to_cult(M.mind) && jobban_isbanned(M, "cultist")) //Not implanted, but cultbanned
				var/turf/T = get_turf(M)
				T.turf_animation('icons/effects/effects.dmi',"rune_teleport")
				M.unequip_everything() //Piñata
				//death(M) //toggles SPS from going off or not.
				sleep(1) //Ensure everything has time to drop without getting deleted
				qdel(M)
				ticker.mode:grant_runeword(usr) //Chance to get a rune word for sacrificing a live player is 100%, so.
				if (cult_round)
					cult_round.revivecounter ++
				to_chat(usr, "<span class='danger'>The ritual didn't work! Looks like this person just isn't suited to be part of our cult.</span>")
				to_chat(usr, "<span class='notice'>Instead, the ritual has taken the lifeforce of this heretic, to be used for our benefit later.</span>")
			else if(M.knockdown)
				to_chat(usr, "<span class='danger'>The ritual didn't work! Either something is disrupting it, or this person just isn't suited to be part of our cult.</span>")
				to_chat(usr, "<span class='danger'>You have to restrain [M] before the talisman's effects wear off!</span>")
			else
				to_chat(usr, "<span class='danger'>The ritual didn't work! Either something is disrupting it, or this person just isn't suited to be part of our cult.</span>")
				to_chat(usr, "<span class='danger'>[M] now knows the truth! Stop \him!</span>")
			to_chat(M, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
			to_chat(M, "<span class='danger'>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs.</span>")
			return 0

	usr.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
	usr.show_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 1, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	to_chat(usr, "<span class='notice'>You remembered the words correctly, but the rune isn't working. Maybe your ritual is missing something important.</span>")

/////////////////////////////////////////FOURTH RUNE

/obj/effect/rune/proc/tearreality()
	if(summoning)
		return

	var/list/active_cultists=list()
	var/ghostcount = 0

	for(var/mob/M in range(1,src))
		if(iscultist(M) && !M.stat)
			active_cultists.Add(M)
			if (istype(M, /mob/living/carbon/human/manifested))
				ghostcount++

	if(universe.name == "Hell Rising")
		for(var/mob/M in active_cultists)
			to_chat(M, "<span class='warning'>This plane of reality has already been torn into Nar-Sie's realm.</span>")
		return

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	if(ticker.mode.eldergod)
		// Sanity checks
		// Are we permitted to spawn Nar-Sie?

		if(!cult_round || cult_round.narsie_condition_cleared)//if the game mode wasn't cult to begin with, there won't be need to complete a first objective to prepare the summoning.
			if(active_cultists.len >= 9)
				if(z != map.zMainStation || Holiday == APRIL_FOOLS_DAY)
					for(var/mob/M in active_cultists)
						to_chat(M, "<span class='danger'>YOU HAVE A TERRIBLE FEELING. IS SOMETHING WRONG WITH THE RITUAL?</span>")//You get one warning

				summoning = 1
				log_admin("NAR-SIE SUMMONING: [active_cultists.len] are summoning Nar-Sie at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>). [6 + (ghostcount * 5)] seconds remaining.")
				message_admins("NAR-SIE SUMMONING: [active_cultists.len] are summoning Nar-Sie at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>). [6 + (ghostcount * 5)] seconds remaining.")
				updatetear(6 + (ghostcount * 5))	//the summoning takes 6 seconds by default , but for each manifested ghost around it takes 5 more seconds.
				return								//with 8 manifested ghosts summoned by a single human, it'd take 46 seconds, which would cause 46*8 = 368 brute damage over time to the human.
													//no more lone human summoning nar-sie all by himself (as all the ghosts would die as soon as he goes uncounscious)
		else
			for(var/mob/M in active_cultists)
				to_chat(M, "<span class='sinister'>The Geometer of Blood has required of you to perform a certain task. This place cannot welcome him until this task has been cleared.</span>")
			return

	else
		for(var/mob/M in active_cultists)
			to_chat(M, "<span class='danger'>Nar-Sie has lost interest in this universe.</span>")//narsie won't appear if a supermatter cascade has started

		return

	return fizzle()


/obj/effect/rune/proc/updatetear(var/currentCountdown)
	if(!summoning)
		summonturfs = list()
		return
	summonturfs = list()
	var/list/active_cultists=list()
	for(var/mob/M in range(1,src))
		if(iscultist(M) && !M.stat)
			active_cultists.Add(M)
			var/turf/T = get_turf(M)
			summonturfs += T
			if(!(locate(/obj/effect/summoning) in T))
				var/obj/effect/summoning/S = new(T)
				S.init(src)


	if(active_cultists.len < 9)
		summoning = 0
		summonturfs = list()
		for(var/mob/M in active_cultists)
			to_chat(M, "<span class='warning'>The ritual has been disturbed. All summoners need to stay by the rune.</span>")
		return

	if(currentCountdown <= 0)
		if(z != map.zMainStation || Holiday == APRIL_FOOLS_DAY)//No more summonings on the Asteroid!
			for(var/mob/M in active_cultists)
				M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
			summonturfs = list()
			summoning = 0
			for(var/mob/M in active_cultists)
				if(Holiday != APRIL_FOOLS_DAY)
					to_chat(M, "<span class='sinister'>THE GEOMETER OF BLOOD IS HIGHLY DISAPOINTED WITH YOUR INABILITY TO PERFORM THE RITUAL IN ITS REQUESTED LOCATION.</span>")
				else
					to_chat(M, "<span class='heavy_brass'>You fool.</span>")
					new /obj/machinery/singularity/narsie/large/clockwork(src.loc)
				M.gib()
		else
			for(var/mob/M in active_cultists)
				// Only chant when Nar-Sie spawns
				M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
			ticker.mode.eldergod = 0
			summonturfs = list()
			summoning = 0
			new /obj/machinery/singularity/narsie/large(src.loc)
			stat_collection.cult_narsie_summoned = TRUE
		return

	currentCountdown--

	sleep(10)

	updatetear(currentCountdown)
	return

/obj/effect/summoning
	name = "summoning"
	icon = 'icons/effects/effects.dmi'
	icon_state = "summoning"
	mouse_opacity = 1
	density = 0
	flags = 0
	var/obj/effect/rune/summon_target = null

/obj/effect/summoning/New()
	..()
	spawn(10)
		update()

/obj/effect/summoning/proc/update()
	if(summon_target && (locate(get_turf(src)) in summon_target.summonturfs))
		sleep(10)
		update()
		return
	else
		qdel(src)

/obj/effect/summoning/proc/init(var/obj/effect/rune/S)
	summon_target = S

/////////////////////////////////////////FIFTH RUNE

/obj/effect/rune/proc/emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
	if(istype(src,/obj/effect/rune))
		usr.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	else
		usr.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	playsound(U, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(U)
	if(T)
		T.hotspot_expose(700,125,surfaces=1)
	var/rune = src // detaching the proc - in theory
	empulse(U, (range_red - 2), range_red)
	qdel(rune)
	return

/////////////////////////////////////////SIXTH RUNE

/obj/effect/rune/proc/drain()
	var/drain = 0
	var/list/drain_turflist = list()
	for(var/obj/effect/rune/R in rune_list)
		if(R.word1==cultwords["travel"] && R.word2==cultwords["blood"] && R.word3==cultwords["self"])
			for(var/mob/living/carbon/D in R.loc)
				if(D.stat!=2)
					nullblock = 0
					for(var/turf/T in range(D,1))
						findNullRod(T)
					if(!nullblock)
						var/bdrain = rand(1,25)
						to_chat(D, "<span class='warning'>You feel weakened.</span>")
						D.take_overall_damage(bdrain, 0)
						drain += bdrain
						drain_turflist += get_turf(R)
	if(!drain)
		return fizzle()
	usr.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	usr.visible_message("<span class='warning'>Blood flows from the rune into [usr]!</span>", \
	"<span class='warning'>The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.</span>", \
	"<span class='warning'>You hear a liquid flowing.</span>")

	var/mob/living/user = usr

	spawn()
		for(var/i = 0;i < 2;i++)
			for(var/turf/T in drain_turflist)
				make_tracker_effects(T, user, 1, "soul", 3, /obj/effect/tracker/drain)
				sleep(1)

	if(user.bhunger)
		user.bhunger = max(user.bhunger-2*drain,0)
	if(drain>=50)
		user.visible_message("<span class='warning'>[user]'s eyes give off eerie red glow!</span>", \
		"<span class='warning'>...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.</span>", \
		"<span class='warning'>You hear a heartbeat.</span>")
		user.bhunger += drain
		src = user
		spawn()
			for (,user.bhunger>0,user.bhunger--)
				sleep(50)
				user.take_overall_damage(3, 0)
		return
	user.heal_organ_damage(drain%5, 0)
	drain-=drain%5
	for (,drain>0,drain-=5)
		sleep(2)
		user.heal_organ_damage(5, 0)
	return






/////////////////////////////////////////SEVENTH RUNE

/obj/effect/rune/proc/seer()
	if(usr.loc==src.loc)
		if(usr.seer==1)
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium viortia.")
			to_chat(usr, "<span class='warning'>The world beyond fades from your vision.</span>")
			usr.see_invisible = SEE_INVISIBLE_LIVING
			usr.seer = 0
		else if(usr.see_invisible!=SEE_INVISIBLE_LIVING)
			to_chat(usr, "<span class='warning'>The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision.</span>")
			usr.see_invisible = SEE_INVISIBLE_OBSERVER
			usr.seer = 0
		else
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
			to_chat(usr, "<span class='warning'>The world beyond opens to your eyes.</span>")
			usr.see_invisible = SEE_INVISIBLE_OBSERVER
			usr.seer = 1
		return
	usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
	usr.show_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 1, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	to_chat(usr, "<span class='notice'>You remembered the words correctly, but the rune isn't reacting. Maybe you should position yourself differently.</span>")

/////////////////////////////////////////EIGHTH RUNE

/obj/effect/rune/proc/raise()
	var/mob/living/carbon/human/corpse_to_raise
	var/mob/living/carbon/human/body_to_sacrifice

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	var/is_sacrifice_target = 0
	for(var/mob/living/carbon/human/M in src.loc)
		if(M.stat == DEAD)
			if(cult_round && (M.mind == cult_round.sacrifice_target))
				is_sacrifice_target = 1
			else
				corpse_to_raise = M
				if(M.key)
					M.ghostize(1)	//kick them out of their body
				break
	if(!corpse_to_raise)
		if (cult_round && cult_round.revivecounter)
			to_chat(usr, "<span class='notice'>Enough lifeforce haunts this place to return [cult_round.revivecounter] of ours to the mortal plane.</span>")
		if(is_sacrifice_target)
			to_chat(usr, "<span class='warning'>The Geometer of blood wants this mortal for himself.</span>")
		return fizzle()


	is_sacrifice_target = 0
	find_sacrifice:
		for(var/obj/effect/rune/R in rune_list)
			if(R.word1==cultwords["blood"] && R.word2==cultwords["join"] && R.word3==cultwords["hell"])
				for(var/mob/living/carbon/human/N in R.loc)
					if(cult_round && (N.mind) && (N.mind == cult_round.sacrifice_target))
						is_sacrifice_target = 1
					else
						if(N.stat!= DEAD)
							nullblock = 0
							for(var/turf/T in range(N,1))
								findNullRod(T)
							if(nullblock)
								return fizzle()
							else
								body_to_sacrifice = N
								break find_sacrifice

	if(!body_to_sacrifice && (!cult_round || !cult_round.revivecounter))
		if (is_sacrifice_target)
			to_chat(usr, "<span class='warning'>The Geometer of blood wants that corpse for himself.</span>")
		else
			to_chat(usr, "<span class='warning'>The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used.</span>")
		return fizzle()

	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in loc)
		if (jobban_isbanned(O, "cultist"))
			continue
		if(!O.client)
			continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			continue
		ghost = O
		break

	if(!ghost)
		to_chat(usr, "<span class='warning'>You require a restless spirit which clings to this world. Beckon their prescence with the sacred chants of Nar-Sie.</span>")
		return fizzle()

	corpse_to_raise.revive()

	corpse_to_raise.key = ghost.key	//the corpse will keep its old mind! but a new player takes ownership of it (they are essentially possessed)
									//This means, should that player leave the body, the original may re-enter
	usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	if (body_to_sacrifice)
		corpse_to_raise.visible_message("<span class='warning'>[corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.</span>", \
		"<span class='warning'>Life? I'm alive? I live, again!.</span>", \
		"<span class='warning'>You hear a faint, slightly familiar whisper.</span>")
		body_to_sacrifice.visible_message("<span class='warning'>[body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!</span>", \
		"<span class='sinister'>You are engulfed in pain as your blood boils, tearing you apart.</span>", \
		"<span class='sinister'>You hear a thousand voices, all crying in pain.</span>")
		body_to_sacrifice.gib()
	if(cult_round)
		if (cult_round.revivecounter && !body_to_sacrifice)
			corpse_to_raise.visible_message("<span class='warning'>A dark mass begins to form above [corpse_to_raise], Gaining mass steadily before penetrating deep into \his heart. [corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.</span>", \
			"<span class='warning'>Life? I'm alive? I live, again!</span>", \
			"<span class='warning'>You hear a faint, slightly familiar whisper.</span>")
			cult_round.revivecounter --

//	if(cult_round)
//		cult_round.add_cultist(corpse_to_raise.mind)
//	else
//		ticker.mode.cult |= corpse_to_raise.mind

	to_chat(corpse_to_raise, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
	to_chat(corpse_to_raise, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
	return





/////////////////////////////////////////NINETH RUNE

/obj/effect/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/effect/rune/R in orange(rad,src))
		if(R!=src)
			R.invisibility=INVISIBILITY_OBSERVER
		S=1
	if(S)
		if(istype(src,/obj/effect/rune))
			usr.say("Kla[pick("'","`")]atu barada nikt'o!")
			for (var/mob/V in viewers(src))
				V.show_message("<span class='warning'>The rune turns into gray dust, veiling the surrounding runes.</span>")
			qdel(src)
		else
			usr.whisper("Kla[pick("'","`")]atu barada nikt'o!")
			to_chat(usr, "<span class='warning'>Your talisman turns into gray dust, veiling the surrounding runes.</span>")
			for (var/mob/V in orange(1,src))
				if(V!=usr)
					V.show_message("<span class='warning'>Dust emanates from [usr]'s hands for a moment.</span>")

		return
	if(istype(src,/obj/effect/rune))
		return	fizzle()
	else
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////TENTH RUNE

/obj/effect/rune/proc/ajourney() //some bits copypastaed from admin tools - Urist
	if(usr.loc==src.loc)
		var/mob/living/carbon/human/L = usr
		usr.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
		usr.visible_message("<span class='warning'>[usr]'s eyes glow blue as \he freezes in place, absolutely motionless.</span>", \
		"<span class='warning'>The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry...</span>", \
		"<span class='warning'>You hear only complete silence for a moment.</span>")
		usr.ghostize(1)
		L.ajourn = src
		ajourn = L
		while(L)
			if(L.key)
				L.ajourn=null
				ajourn = null
				return
			else
				L.take_organ_damage(10, 0)
			sleep(100)
	return fizzle()

/////////////////////////////////////////ELEVENTH RUNE

/obj/effect/rune/proc/manifest()
	var/obj/effect/rune/this_rune = src
	src = null
	if(usr.loc != this_rune.loc || istype(usr,/mob/living/carbon/human/manifested))
		return this_rune.fizzle()
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in this_rune.loc)
		if(!O.client)
			continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			continue
		ghost = O
		break
	if(!ghost)
		return this_rune.fizzle()
	if(jobban_isbanned(ghost, "cultist"))
		return this_rune.fizzle()

	usr.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")

	var/mob/living/carbon/human/manifested/D = new(this_rune.loc)
	D.key = ghost.key
	D.icon = null
	D.invisibility = 101
	D.canmove = 0
	var/atom/movable/overlay/animation = null

	usr.visible_message("<span class='warning'> A shape forms in the center of the rune. A shape of... a man.<BR>The world feels blurry as your soul permeates this temporary body.</span>", \
	"<span class='warning'> A shape forms in the center of the rune. A shape of... a man.</span>", \
	"<span class='warning'>You hear liquid flowing.</span>")

	animation = new(D.loc)
	animation.plane = EFFECTS_PLANE
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = this_rune
	flick("appear-hm", animation)
	sleep(5)
	D.invisibility = 0
	sleep(10)
	D.real_name = "Unknown"
	var/chose_name = 0
	for(var/obj/item/weapon/paper/P in this_rune.loc)
		if(P.info)
			D.real_name = copytext(P.info, 1, MAX_NAME_LEN)
			chose_name = 1
			break
	if(!chose_name)
		D.real_name = "[pick(first_names_male)] [pick(last_names)]"
	D.status_flags &= ~GODMODE

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")
	if(cult_round)
		cult_round.add_cultist(D.mind)
	else
		ticker.mode.cult += D.mind

	ticker.mode.update_cult_icons_added(D.mind)
	D.canmove = 1
	animation.master = null
	qdel(animation)

	D.mind.special_role = "Cultist"
	to_chat(D, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
	to_chat(D, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
	to_chat(D, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")

	D.add_language(LANGUAGE_CULT)


	var/mob/living/user = usr
	while(this_rune && user && user.stat==CONSCIOUS && user.client && user.loc==this_rune.loc)
		user.take_organ_damage(1, 0)
		sleep(30)
	if(D)
		D.visible_message("<span class='warning'>[D] slowly dissipates into dust and bones.</span>", \
		"<span class='warning'>You feel pain, as bonds formed between your soul and this homunculus break.</span>", \
		"<span class='warning'>You hear faint rustle.</span>")
		D.dust()
	return

/////////////////////////////////////////TWELFTH RUNE

/obj/effect/rune/proc/talisman()//only tome, communicate, hide, reveal, emp, teleport, deafen, blind, stun and armor runes can be imbued
	var/obj/item/weapon/paper/newtalisman
	var/papers[] = new()
	for(var/obj/item/weapon/paper/O in src.loc)
		papers += O
	var/unsuitable_newtalisman = 0
	for(var/obj/item/weapon/paper/P in papers)
		if(!(P.info || istype(P, /obj/item/weapon/paper/talisman)))
			newtalisman = P
			break
		else if(P.info && papers.len == 1)
			unsuitable_newtalisman = 1
	if (!newtalisman)
		if (unsuitable_newtalisman)
			to_chat(usr, "<span class='warning'>The blank is tainted. It is unsuitable.</span>")
		return fizzle()

	if (istype(newtalisman, /obj/item/weapon/paper/nano))//I mean, cult and technology don't mix well together right?
		to_chat(usr, "<span class='warning'>This piece of technologically advanced paper is unsuitable.</span>")
		return fizzle()

	var/obj/effect/rune/imbued_from
	var/obj/item/weapon/paper/talisman/T
	for(var/obj/effect/rune/R in orange(1,src))
		if(R==src)
			continue
		if(R.word1==cultwords["travel"] && R.word2==cultwords["self"])  //teleport
			T = new(src.loc)
			T.imbue = "[R.word3]"
			imbued_from = R
			break
		if(R.word1==cultwords["see"] && R.word2==cultwords["blood"] && R.word3==cultwords["hell"]) //tome
			T = new(src.loc)
			T.imbue = "newtome"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["technology"]) //emp
			T = new(src.loc)
			T.imbue = "emp"
			imbued_from = R
			break
		if(R.word1==cultwords["hide"] && R.word2==cultwords["see"] && R.word3==cultwords["blood"]) //conceal
			T = new(src.loc)
			T.imbue = "conceal"
			imbued_from = R
			break
		if(R.word1==cultwords["hell"] && R.word2==cultwords["destroy"] && R.word3==cultwords["other"]) //armor
			T = new(src.loc)
			T.imbue = "armor"
			imbued_from = R
			break
		if(R.word1==cultwords["blood"] && R.word2==cultwords["see"] && R.word3==cultwords["hide"]) //reveal
			T = new(src.loc)
			T.imbue = "revealrunes"
			imbued_from = R
			break
		if(R.word1==cultwords["hide"] && R.word2==cultwords["other"] && R.word3==cultwords["see"]) //deafen
			T = new(src.loc)
			T.imbue = "deafen"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["other"]) //blind
			T = new(src.loc)
			T.imbue = "blind"
			imbued_from = R
			break
		if(R.word1==cultwords["self"] && R.word2==cultwords["other"] && R.word3==cultwords["technology"]) //communicate
			T = new(src.loc)
			T.imbue = "communicate"
			imbued_from = R
			break
		if(R.word1==cultwords["join"] && R.word2==cultwords["hide"] && R.word3==cultwords["technology"]) //stun
			T = new(src.loc)
			T.imbue = "runestun"
			imbued_from = R
			break
	if (imbued_from)
		T.uses = talisman_charges(T.imbue)
		for (var/mob/V in viewers(src))
			V.show_message("<span class='warning'>The runes turn into dust, which then forms into an arcane image on the paper.</span>", 1)
		usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		qdel(imbued_from)
		qdel(newtalisman)
		invocation("rune_imbue")
	else
		usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		usr.show_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 1, "<span class='warning'>You hear a faint fizzle.</span>", 2)
		to_chat(usr, "<span class='notice'>You remembered the words correctly, but the rune isn't working properly. Maybe you're missing something in the ritual.</span>")

/////////////////////////////////////////THIRTEENTH RUNE

/obj/effect/rune/proc/mend()
	var/mob/living/user = usr
	src = null
	user.say("Uhrast ka'hfa heldsagen ver[pick("'","`")]lot!")
	user.take_overall_damage(200, 0)
	runedec+=10
	user.visible_message("<span class='warning'>[user] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.</span>", \
	"<span class='warning'>In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood.</span>", \
	"<span class='warning'>You hear faint rustle.</span>")
	for(,user.stat==2)
		sleep(600)
		if (!user)
			return
	runedec-=10
	return


/////////////////////////////////////////FOURTEETH RUNE

// returns 0 if the rune is not used. returns 1 if the rune is used.
/obj/effect/rune/proc/communicate()
	. = 1 // Default output is 1. If the rune is deleted it will return 1
	var/mob/user = usr
	var/input = stripped_input(user, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)
		if (istype(src))
			fizzle()
			return 0
		else
			return 0
	if(istype(src,/obj/effect/rune))
		user.say("O bidai nabora se[pick("'","`")]sma!")
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!")

	if(istype(src,/obj/effect/rune))
		user.say("[input]")
	else
		user.whisper("[input]")
	for(var/datum/mind/H in ticker.mode.cult)
		if (H.current)
			to_chat(H.current, "<span class='game say'><b>[user.real_name]</b>'s voice echoes in your head, <B><span class='sinister'>[input]</span></B></span>")//changed from red to purple - Deity Link


	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "<span class='game say'><b>[user.real_name]</b> communicates, <span class='sinister'>[input]</span></span>")

	log_cultspeak("[key_name(user)] Cult Communicate Rune: [input]")

	qdel(src)
	return 1

/////////////////////////////////////////FIFTEENTH RUNE

/obj/effect/rune/proc/sacrifice()
	var/list/mob/living/cultsinrange = list()
	var/ritualresponse = ""
	var/sacrificedone = 0

	//how many cultists do we have near the rune
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			cultsinrange += C
			C.say("Barhah hra zar[pick("'","`")]garis!")

	//checking for null rods
	nullblock = 0
	for(var/turf/T in range(src,1))
		findNullRod(T)
	if(nullblock)
		to_chat(usr, "<span class='warning'>The presence of a null rod is perturbing the ritual.</span>")
		return

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	for(var/atom/A in loc)
		if(iscultist(A))
			continue
		var/satisfaction = 0
//Humans and Animals
		if(istype(A,/mob/living/carbon) || istype(A,/mob/living/simple_animal))//carbon mobs and simple animals
			var/mob/living/M = A
			if (cult_round && (M.mind == cult_round.sacrifice_target))
				if(cultsinrange.len >= 3)
					cult_round.sacrificed += M.mind
					M.gib()
					sacrificedone = 1
					invocation("rune_sac")
					ritualresponse += "The Geometer of Blood gladly accepts this sacrifice, your objective is now complete."
					spawn(10)	//so the messages for the new phase get received after the feedback for the sacrifice
						cult_round.additional_phase()
				else
					ritualresponse += "You need more cultists to perform the ritual and complete your objective."
			else
				if(M.stat != DEAD)
					if(cultsinrange.len >= 3)
						if(M.mind)				//living players
							ritualresponse += "The Geometer of Blood gladly accepts this sacrifice."
							satisfaction = 100
							if(cult_round)
								cult_round.revivecounter ++
						else					//living NPCs
							ritualresponse += "The Geometer of Blood accepts this being in sacrifice. Somehow you get the feeling that beings with souls would make a better offering."
							satisfaction = 50
						sacrificedone = 1
						invocation("rune_sac")
						M.gib()
					else
						ritualresponse += "The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
				else
					if(M.mind)					//dead players
						ritualresponse += "The Geometer of Blood accepts this sacrifice."
						satisfaction = 50
						if(cult_round)
							cult_round.revivecounter ++
					else						//dead NPCs
						ritualresponse += "The Geometer of Blood accepts your meager sacrifice."
						satisfaction = 10
					sacrificedone = 1
					invocation("rune_sac")
					M.gib()
//Borgs and MoMMis
		else if(istype(A, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/B = A
			var/obj/item/device/mmi/O = locate() in B
			if(O)
				if(cult_round && (O.brainmob.mind == cult_round.sacrifice_target))
					if(cultsinrange.len >= 3)
						cult_round.sacrificed += O.brainmob.mind
						ritualresponse += "The Geometer of Blood accepts this sacrifice, your objective is now complete."
						sacrificedone = 1
						invocation("rune_sac")
						B.dust()
						spawn(10)	//so the messages for the new phase get received after the feedback for the sacrifice
							cult_round.additional_phase()
					else
						ritualresponse += "You need more cultists to perform the ritual and complete your objective."
				else
					if(B.stat != DEAD)
						if(cultsinrange.len >= 3)
							ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
							sacrificedone = 1
							invocation("rune_sac")
							B.dust()
						else
							ritualresponse += "That machine is still working, you will need more cultists chanting for the sacrifice to destroy it."
					else
						ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
						sacrificedone = 1
						invocation("rune_sac")
						B.dust()
//MMI
		else if(istype(A, /obj/item/device/mmi))
			var/obj/item/device/mmi/I = A
			var/mob/living/carbon/brain/N = I.brainmob
			if(N)//the MMI has a player's brain in it
				if(cult_round && (N.mind == cult_round.sacrifice_target))
					ritualresponse += "You need to place that brain back inside a body before you can complete your objective."
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
					sacrificedone = 1
					invocation("rune_sac")
					I.on_fire = 1
					I.ashify()
//Brain & Head
		else if(istype(A, /obj/item/organ/internal/brain))
			var/obj/item/organ/internal/brain/R = A
			var/mob/living/carbon/brain/N = R.brainmob
			if(N)//the brain is a player's
				if(cult_round && (N.mind == cult_round.sacrifice_target))
					ritualresponse += "You need to place that brain back inside a body before you can complete your objective."
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that brain."
					sacrificedone = 1
					invocation("rune_sac")
					R.on_fire = 1
					R.ashify()

		else if(istype(A, /obj/item/organ/external/head/)) //Literally the same as the brain check
			var/obj/item/organ/external/head/H = A
			var/mob/living/carbon/brain/N = H.brainmob
			if(N)//the brain is a player's
				if(cult_round && (N.mind == cult_round.sacrifice_target))
					ritualresponse += "You need to place that head back on a body before you can complete your objective."
				else
					ritualresponse += "The Geometer of Blood accepts to destroy the head."
					sacrificedone = 1
					invocation("rune_sac")
					H.on_fire = 1
					H.ashify()
//Carded AIs
		else if(istype(A, /obj/item/device/aicard))
			var/obj/item/device/aicard/D = A
			var/mob/living/silicon/ai/T = locate() in D
			if(T)//there is an AI on the card
				if(cult_round && (T.mind == cult_round.sacrifice_target))//what are the odds this ever happens?
					cult_round.sacrificed += T.mind
					ritualresponse += "With a sigh, the Geometer of Blood accepts this sacrifice, your objective is now complete."//since you cannot debrain an AI.
					spawn(10)	//so the messages for the new phase get received after the feedback for the sacrifice
						cult_round.additional_phase()
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that piece of technological garbage."
				sacrificedone = 1
				invocation("rune_sac")
				D.on_fire = 1
				D.ashify()

		else
			continue

//feedback
		for(var/mob/living/C in cultsinrange)
			if(ritualresponse != "")
				to_chat(C, "<span class='sinister'>[ritualresponse]</span>")
				if(prob(satisfaction))
					ticker.mode:grant_runeword(C)

	if(!sacrificedone)
		for(var/mob/living/C in cultsinrange)
			to_chat(C, "<span class='warning'>There is nothing fit for sacrifice on the rune.</span>")

/////////////////////////////////////////SIXTEENTH RUNE

/obj/effect/rune/proc/revealrunes(var/obj/W as obj)
	var/go=0
	var/rad
	var/S=0
	if(istype(W,/obj/effect/rune))
		rad = 6
		go = 1
	if (istype(W,/obj/item/weapon/paper/talisman))
		rad = 4
		go = 1
	if (istype(W,/obj/item/weapon/nullrod))
		rad = 1
		go = 1
	if(go)
		for(var/obj/effect/rune/R in orange(rad,src))
			if(R!=src)
				R:visibility=15
			S=1
	if(S)
		if(istype(W,/obj/item/weapon/nullrod))
			to_chat(usr, "<span class='warning'>Arcane markings suddenly glow from underneath a thin layer of dust!</span>")
			return
		if(istype(W,/obj/effect/rune))
			usr.say("Nikt[pick("'","`")]o barada kla'atu!")
			for (var/mob/V in viewers(src))
				V.show_message("<span class='warning'>The rune turns into red dust, revealing the surrounding runes.</span>", 1)
			qdel(src)
			return
		if(istype(W,/obj/item/weapon/paper/talisman))
			usr.whisper("Nikt[pick("'","`")]o barada kla'atu!")
			to_chat(usr, "<span class='warning'>Your talisman turns into red dust, revealing the surrounding runes.</span>")
			for (var/mob/V in orange(1,usr.loc))
				if(V!=usr)
					V.show_message("<span class='warning'>Red dust emanates from [usr]'s hands for a moment.</span>", 1)
			return
		return
	if(istype(W,/obj/effect/rune))
		return	fizzle()
	if(istype(W,/obj/item/weapon/paper/talisman))
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////SEVENTEENTH RUNE

/obj/effect/rune/proc/wall()
	usr.say("Khari[pick("'","`")]d! Eske'te tannin!")
	setDensity(!density)
	var/mob/living/user = usr
	user.take_organ_damage(2, 0)
	if(src.density)
		to_chat(usr, "<span class='warning'>Your blood flows into the rune, and you feel that the very space over the rune thickens.</span>")
	else
		to_chat(usr, "<span class='warning'>Your blood flows into the rune, and you feel as the rune releases its grasp on space.</span>")
	return

/////////////////////////////////////////EIGHTTEENTH RUNE

/obj/effect/rune/proc/freedom()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C

	var/list/possible_targets = list()
	for(var/mob/living/carbon/cultistarget in (cultists - users))
		if (cultistarget.handcuffed)
			possible_targets += cultistarget
		else if (cultistarget.legcuffed)
			possible_targets += cultistarget
		else if (istype(cultistarget.wear_mask, /obj/item/clothing/mask/muzzle))
			possible_targets += cultistarget
		else if (istype(cultistarget.loc, /obj/structure/closet))
			var/obj/structure/closet/closet = cultistarget.loc
			if(closet.welded)
				possible_targets += cultistarget
		else if (istype(cultistarget.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/secure_closet = cultistarget.loc
			if (secure_closet.locked)
				possible_targets += cultistarget
		else if (istype(cultistarget.loc, /obj/machinery/dna_scannernew))
			var/obj/machinery/dna_scannernew/dna_scannernew = cultistarget.loc
			if (dna_scannernew.locked)
				possible_targets += cultistarget

	if(!possible_targets.len)
		to_chat(user, "<span class='warning'>None of the cultists are currently under restraints.</span>")
		return fizzle()

	if(users.len>=2)
		var/mob/living/carbon/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in possible_targets
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(!(cultist.locked_to || \
			cultist.handcuffed || \
			istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
			(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
			(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
			(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
		))
			to_chat(user, "<span class='warning'>The [cultist] is already free.</span>")
			return
		cultist.unlock_from()
		if (cultist.handcuffed)
			cultist.drop_from_inventory(cultist.handcuffed)
		if (cultist.legcuffed)
			cultist.drop_from_inventory(cultist.legcuffed)
		if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
			cultist.u_equip(cultist.wear_mask, 1)
		if(istype(cultist.loc, /obj/structure/closet))
			var/obj/structure/closet/closet = cultist.loc
			if(closet.welded)
				closet.welded = 0
		if(istype(cultist.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/secure_closet = cultist.loc
			if (secure_closet.locked)
				secure_closet.locked = 0
		if(istype(cultist.loc, /obj/machinery/dna_scannernew))
			var/obj/machinery/dna_scannernew/dna_scannernew = cultist.loc
			if (dna_scannernew.locked)
				dna_scannernew.locked = 0
		var/rune_damage = 20 / (users.len)
		for(var/mob/living/carbon/C in users)
			C.take_overall_damage(rune_damage, 0)
			C.say("Khari[pick("'","`")]d! Gual'te nikka!")
		to_chat(cultist, "<span class='warning'>You feel a tingle as you find yourself freed from your restraints.</span>")
		qdel(src)
	else
		var/text = "<span class='sinister'>The following cultists are currently under restraints:</span>"
		for(var/mob/living/carbon/cultist in possible_targets)
			text += "<br><b>[cultist]</b>"
		to_chat(user, text)
		user.say("Khari[pick("'","`")]d!")
		return

	return fizzle()

/////////////////////////////////////////NINETEENTH RUNE

/obj/effect/rune/proc/cultsummon()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C
	if(users.len>=2)
		cultists-=users
		var/list/mob/living/carbon/annotated_cultists = new
		var/status = ""
		var/list/visible_mobs = viewers(user)
		for(var/mob/living/carbon/C in cultists)
			status = ""
			if(C in visible_mobs)
				status = "(Present)"
			else if(C.isDead())
				status = "(Dead)"
			annotated_cultists["[C.name] [status]"] = C
		var/choice = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in annotated_cultists
		var/mob/living/carbon/cultist = annotated_cultists[choice]
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(cultist.locked_to || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
			to_chat(user, "<span class='warning'>You cannot summon the [cultist], for his shackles of blood are strong</span>")
			return fizzle()
		var/turf/T = get_turf(cultist)
		T.turf_animation('icons/effects/effects.dmi',"rune_teleport")
		cultist.forceMove(src.loc)
		cultist.lying = 1
		cultist.regenerate_icons()
		to_chat(T, visible_message("<span class='warning'>[cultist] suddenly disappears in a flash of red light!</span>"))
		var/rune_damage = 30 / (users.len)
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")
				C.take_overall_damage(rune_damage, 0)
				if(C != cultist)
					to_chat(C, "<span class='warning'>Your body take its toll as you drag your fellow cultist through dimensions.</span>")
				else
					to_chat(C, "<span class='warning'>You feel a sharp pain as your body gets dragged through dimensions.</span>")
		user.visible_message("<span class='warning'>The rune disappears with a flash of red light, and in its place now a body lies.</span>", \
		"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.</span>", \
		"<span class='warning'>You hear a pop and smell ozone.</span>")
		qdel(src)
	else
		var/text = "<span class='sinister'>The following individuals are living and conscious followers of the Geometer of Blood:</span>"
		for(var/mob/living/L in player_list)
			if(L.stat != DEAD)
				if(L.mind in ticker.mode.cult)
					text += "<br><b>[L]</b>"
		to_chat(user, text)
		user.say("N'ath reth!")
		return

	return fizzle()

/////////////////////////////////////////TWENTIETH RUNES

/obj/effect/rune/proc/deafen()
	var/affected = 0
	for(var/mob/living/carbon/C in range(7,src))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.ear_deaf += 50
		C.show_message("<span class='notice'>The world around you suddenly becomes quiet.</span>")
		affected++
		if(prob(1))
			C.sdisabilities |= DEAF
	if(affected)
		usr.say("Sti[pick("'","`")] kaliedir!")
		to_chat(usr, "<span class='warning'>The world becomes quiet as the deafening rune dissipates into fine dust.</span>")
		qdel(src)
	else
		return fizzle()

/obj/effect/rune/proc/blind()
	var/affected = 0
	for(var/mob/living/carbon/C in viewers(src))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.eye_blurry += 50
		C.eye_blind += 20
		if(prob(5))
			C.disabilities |= NEARSIGHTED
			if(prob(10))
				C.sdisabilities |= BLIND
		to_chat(C, "<span class='warning'>Suddenly you see red flash that blinds you.</span>")
		affected++
	if(affected)
		usr.say("Sti[pick("'","`")] kaliesin!")
		to_chat(usr, "<span class='warning'>The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust.</span>")
		qdel(src)
	else
		return fizzle()


/obj/effect/rune/proc/bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
/*
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
*/
	var/culcount = 0 //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
//	var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=3)
		for(var/mob/living/carbon/M in viewers(usr))
			if(iscultist(M))
				continue
			nullblock = 0
			for(var/turf/T in range(M,1))
				findNullRod(T)
			if(nullblock)
				continue
			M.take_overall_damage(51,51)
			to_chat(M, "<span class='warning'>Your blood boils!</span>")
			if(prob(5))
				spawn(5)
					M.gib()
		for(var/obj/effect/rune/R in view(src))
			if(prob(10))
				explosion(R.loc, -1, 0, 1, 5)
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("Dedo ol[pick("'","`")]btoh!")
				C.take_overall_damage(15, 0)
		qdel(src)
	else
		return fizzle()
	return

// WIP rune, I'll wait for Rastaf0 to add limited blood.

/obj/effect/rune/proc/burningblood()
	var/culcount = 0
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount >= 5)
		for(var/obj/effect/rune/R in rune_list)
			if(R.blood_DNA == src.blood_DNA)
				for(var/mob/living/M in orange(2,R))
					M.take_overall_damage(0,15)
					if (R.invisibility>M.see_invisible)
						to_chat(M, "<span class='warning'>Aargh it burns!</span>")
					else
						to_chat(M, "<span class='warning'>The rune suddenly ignites, burning you!</span>")
					var/turf/T = get_turf(R)
					T.hotspot_expose(700,125,surfaces=1)
		for(var/obj/effect/decal/cleanable/blood/B in world)
			if(B.blood_DNA == src.blood_DNA)
				for(var/mob/living/M in orange(1,B))
					M.take_overall_damage(0,5)
					to_chat(M, "<span class='warning'>The blood suddenly ignites, burning you!</span>")
					var/turf/T = get_turf(B)
					T.hotspot_expose(700,125,surfaces=1)
					qdel(B)
		qdel(src)

//////////             Rune 24 (counting burningblood, which kinda doesnt work yet.)

/obj/effect/rune/proc/runestun(var/mob/living/T as mob)///When invoked as rune, flash and stun everyone around.
	usr.say("Fuu ma[pick("'","`")]jin!")
	for(var/mob/living/L in viewers(src))

		nullblock = 0
		for(var/turf/TU in range(L,1))
			findNullRod(TU)
		if(!nullblock)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.flash_eyes(visual = 1)
				if(C.stuttering < 1 && (!(M_HULK in C.mutations)))
					C.stuttering = 1
				C.Knockdown(1)
				C.Stun(1)
				C.visible_message("<span class='warning'>The rune explodes in a bright flash.</span>")

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Knockdown(5)
				S.visible_message("<span class='warning'>BZZZT... The rune has exploded in a bright flash.</span>")
	qdel(src)
	return

/////////////////////////////////////////TWENTY-FIFTH RUNE

/obj/effect/rune/proc/armor()
	var/mob/living/user = usr
	if(!istype(src,/obj/effect/rune))
		usr.whisper("Sa tatha najin")
		if(ishuman(user))
			var/mob/living/carbon/human/P = user
			usr.visible_message("<span class='warning'> In flash of red light, a set of armor appears on [usr].</span>", \
			"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
			var/datum/game_mode/cult/mode_ticker = ticker.mode
			if(isplasmaman(P))
				P.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/plasmaman/cultist(P), slot_head)
				P.equip_to_slot_or_del(new /obj/item/clothing/suit/space/plasmaman/cultist(P), slot_wear_suit)
			else if((istype(mode_ticker) && mode_ticker.narsie_condition_cleared) || (universe.name == "Hell Rising"))
				user.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/cult(user), slot_head)
				user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/cult(user), slot_wear_suit)
			else
				user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
				user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
			user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
			user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
			//the above update their overlay icons cache but do not call update_icons()
			//the below calls update_icons() at the end, which will update overlay icons by using the (now updated) cache
			user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))	//put in hands or on floor
		else if(ismonkey(user))
			var/mob/living/carbon/monkey/K = user
			K.visible_message("<span class='warning'> The rune disappears with a flash of red light, [K] now looks like the cutest of all followers of Nar-Sie...</span>", \
			"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor. Might not offer much protection due to its size though.</span>")
			K.equip_to_slot_or_drop(new /obj/item/clothing/monkeyclothes/cultrobes, slot_w_uniform)
			K.equip_to_slot_or_drop(new /obj/item/clothing/head/culthood/alt, slot_head)
			K.equip_to_slot_or_drop(new /obj/item/weapon/storage/backpack/cultpack, slot_back)
			K.put_in_hands(new /obj/item/weapon/melee/cultblade(K))
		return
	else
		usr.say("Sa tatha najin")
		for(var/mob/living/M in src.loc)
			if(iscultist(M))
				if(ishuman(M))
					var/mob/living/carbon/human/P = user
					M.visible_message("<span class='warning'> In flash of red light, and a set of armor appears on [M]...</span>", \
					"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
					var/datum/game_mode/cult/mode_ticker = ticker.mode
					if(isplasmaman(P))
						P.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/plasmaman/cultist(P), slot_head)
						P.equip_to_slot_or_del(new /obj/item/clothing/suit/space/plasmaman/cultist(P), slot_wear_suit)
					else if((istype(mode_ticker) && mode_ticker.narsie_condition_cleared) || (universe.name == "Hell Rising"))
						M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/cult(M), slot_head)
						M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/cult(M), slot_wear_suit)
					else
						M.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(M), slot_head)
						M.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(M), slot_wear_suit)
					M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), slot_shoes)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(M), slot_back)
					M.put_in_hands(new /obj/item/weapon/melee/cultblade(M))
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					K.visible_message("<span class='warning'> The rune disappears with a flash of red light, [K] now looks like the cutest of all followers of Nar-Sie...</span>", \
					"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor. Might not offer much protection due to its size though.</span>")
					K.equip_to_slot_or_drop(new /obj/item/clothing/monkeyclothes/cultrobes, slot_w_uniform)
					K.equip_to_slot_or_drop(new /obj/item/clothing/head/culthood/alt, slot_head)
					K.equip_to_slot_or_drop(new /obj/item/weapon/storage/backpack/cultpack, slot_back)
					K.put_in_hands(new /obj/item/weapon/melee/cultblade(K))
				else if(isconstruct(M))
					var/construct_class
					if(universe.name == "Hell Rising")
						var/list/construct_types = list("Artificer", "Wraith", "Juggernaut", "Harvester")
						construct_class = input("Please choose which type of construct you wish [M] to become.", "Construct Transformation") in construct_types
						switch(construct_class)
							if("Juggernaut")
								var/mob/living/simple_animal/construct/armoured/C = new /mob/living/simple_animal/construct/armoured (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now a Juggernaut. Though slow, your shell can withstand extreme punishment, create temporary walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Wraith")
								var/mob/living/simple_animal/construct/wraith/C = new /mob/living/simple_animal/construct/wraith (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are a now Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Artificer")
								var/mob/living/simple_animal/construct/builder/C = new /mob/living/simple_animal/construct/builder (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now an Artificer. You are incredibly weak and fragile, but you are able to construct new floors and walls, to break some walls apart, to repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Harvester")
								var/mob/living/simple_animal/construct/harvester/C = new /mob/living/simple_animal/construct/harvester (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now an Harvester. You are as fast and powerful as Wraiths, but twice as durable.<br>No living (or dead) creature can hide from your eyes, and no door or wall shall place itself between you and your victims.<br>Your role consists of neutralizing any non-cultist living being in the area and transport them to Nar-Sie. To do so, place yourself above an incapacited target and use your \"Harvest\" spell.")
								ticker.mode.update_cult_icons_added(C.mind)
					else
						var/list/construct_types = list("Artificer", "Wraith", "Juggernaut")
						construct_class = input("Please choose which type of construct you wish [M] to become.", "Construct Transformation") in construct_types
						switch(construct_class)
							if("Juggernaut")
								var/mob/living/simple_animal/construct/armoured/C = new /mob/living/simple_animal/construct/armoured (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now a Juggernaut. Though slow, your shell can withstand extreme punishment, create temporary walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Wraith")
								var/mob/living/simple_animal/construct/wraith/C = new /mob/living/simple_animal/construct/wraith (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are a now Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Artificer")
								var/mob/living/simple_animal/construct/builder/C = new /mob/living/simple_animal/construct/builder (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now an Artificer. You are incredibly weak and fragile, but you are able to construct new floors and walls, to break some walls apart, to repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>")
								ticker.mode.update_cult_icons_added(C.mind)
								for(var/spell/S in C.spell_list)
									if(S.charge_type & Sp_RECHARGE)
										if(S.charge_counter == S.charge_max) //Spell is fully charged - let the proc handle everything
											S.take_charge()
										else //Spell is on cooldown and already recharging - there's no need to call S.process(), just reset charges to 0
											S.charge_counter = 0
				qdel(src)
				return
			else
				to_chat(usr, "<span class='warning'>Only the followers of Nar-Sie may be given their armor.</span>")
				to_chat(M, "<span class='warning'>Only the followers of Nar-Sie may be given their armor.</span>")
	to_chat(user, "<span class='note'>You have to be standing on top of the rune.</span>")
	return
