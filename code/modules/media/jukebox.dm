./sound/turntable/test
	file = 'TestLoop1.ogg'
	falloff = 2
	repeat = 1

/mob/var/music = 0

/obj/machinery/party/turntable
	name = "Jukebox"
	desc = "A jukebox is a partially automated music-playing device, usually a coin-operated machine, that will play a patron's selection from self-contained media."
	icon = 'ss13_dark_alpha7_old.dmi'
	icon_state = "Jukeboxalt"
	var/playing = 0
	anchored = 1
	density = 1
	var/list/songs = list ("Jawa Bar"='Cantina.ogg',
		"Lonely Assistant Blues"='AGrainOfSandInSandwich.ogg',
		"Chinatown"='chinatown.ogg',
		"Wade In The Water"='WadeInTheWater.ogg',
		"Blue Theme"='BlueTheme.ogg',
		"Beyond The Sea"='BeyondTheSea.ogg',
		"The Assassination of Jesse James"='TheAssassinationOfJesseJames.ogg',
		"Everyone Has Their Vices"='EveryoneHasTheirVices.ogg',
		"The Way You Look Tonight"='TheWayYouLookTonight.ogg',
		"They Were All Dead"='TheyWereAllDead.ogg',
		"Onizukas Blues"='OnizukasBlues.ogg',
		"Ragtime Piano"='TheEntertainer.ogg',
		"It Had To Be You"='ItHadToBeYou.ogg',
		"Janitorial Blues"='KyouWaYuuhiYarou.ogg',
		"Lujon"='Lujon.ogg',
		"Another Day's Work"='AnotherDaysWork.ogg',
		"Razor Walker"='RazorWalker.ogg',
		"Mute Beat"='MuteBeat.ogg',
		"Groovy Times"='GroovyTime.ogg',
		"Under My Skin"='IveGotYouUnderMySkin.ogg',
		"That`s All"='ThatsAll.ogg',
		"The Folks On The Hill"='TheFolksWhoLiveOnTheHill.ogg')


/obj/machinery/party/mixer
	name = "mixer"
	desc = "A mixing board for mixing music"
	icon = 'ss13_dark_alpha7_old.dmi'
	icon_state = "mixer"
	density = 0
	anchored = 1


/obj/machinery/party/turntable/New()
	..()
	sleep(2)
	new /sound/turntable/test(src)
	return

/obj/machinery/party/turntable/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/party/turntable/attack_hand(mob/living/user as mob)
	if (..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/t = "<body background=turntable.png ><br><br><br><br><br><br><br><br><br><br><br><br><div align='center'>"
	t += "<A href='?src=\ref[src];off=1'><font color='maroon'>T</font><font color='geen'>urn</font> <font color='red'>Off</font></A>"
	t += "<table border='0' height='25' width='300'><tr>"

	for (var/i = 1, i<=(songs.len), i++)
		var/check = i%2
		t += "<td><A href='?src=\ref[src];on=[i]'><font color='maroon'>[copytext(songs[i],1,2)]</font><font color='purple'>[copytext(songs[i],2)]</font></A></td>"
		if(!check) t += "</tr><tr>"

	t += "</tr></table></div></body>"
	user << browse(t, "window=turntable;size=500x636;can_resize=0")
	onclose(user, "urntable")
	return

/obj/machinery/party/turntable/Topic(href, href_list)
	..()
	if( href_list["on"])
		if(src.playing == 0)
			//world << "Should be working..."
			var/sound/S
			S = sound(songs[songs[text2num(href_list["on"])]])
			S.repeat = 1
			S.channel = 10
			S.falloff = 2
			S.wait = 1
			S.environment = 0

			var/area/A = src.loc.loc:master

			for(var/area/RA in A.related)
				for(var/obj/machinery/party/lasermachine/L in RA)
					L.turnon()
			playing = 1
			while(playing == 1)
				for(var/mob/M in world)
					var/area/location = get_area(M)
					if((location in A.related) && M.music == 0)
						//world << "Found the song..."
						M << S
						M.music = 1
					else if(!(location in A.related) && M.music == 1)
						var/sound/Soff = sound(null)
						Soff.channel = 10
						M << Soff
						M.music = 0
				sleep(10)
			return

	if( href_list["off"] )
		if(src.playing == 1)
			var/sound/S = sound(null)
			S.channel = 10
			S.wait = 1
			for(var/mob/M in world)
				M << S
				M.music = 0
			playing = 0
			var/area/A = src.loc.loc:master
			for(var/area/RA in A.related)
				for(var/obj/machinery/party/lasermachine/L in RA)
					L.turnoff()


/obj/machinery/party/lasermachine
	name = "laser machine"
	desc = "A laser machine that shoots lasers."
	icon = 'ss13_dark_alpha7_old.dmi'
	icon_state = "lasermachine"
	anchored = 1
	var/mirrored = 0

/obj/effects/laser
	name = "laser"
	desc = "A laser..."
	icon = 'ss13_dark_alpha7_old.dmi'
	icon_state = "laserred1"
	anchored = 1
	layer = 4

/obj/item/lasermachine/New()
	..()

/obj/machinery/party/lasermachine/proc/turnon()
	var/wall = 0
	var/cycle = 1
	var/area/A = get_area(src)
	var/X = 1
	var/Y = 0
	if(mirrored == 0)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred1"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 2)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred2"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 3)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred3"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
	if(mirrored == 1)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred1m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 2)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred2m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 3)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred3m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++


/obj/machinery/party/lasermachine/proc/turnoff()
	var/area/A = src.loc.loc
	for(var/area/RA in A.related)
		for(var/obj/effects/laser/F in RA)
			del(F)


/obj/machinery/party/gramophone
	name = "Gramophone"
	desc = "Old-time styley."
	icon = 'icons/obj/musician.dmi'
	icon_state = "gramophone"
	var/playing = 0
	anchored = 1
	density = 1

/obj/machinery/party/gramophone/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/party/gramophone/attack_hand(mob/living/user as mob)

	if (src.playing == 0)

		var/sound/S
		S = sound(pick('Taintedlove.ogg','Soviet.ogg'))
		S.repeat = 1
		S.channel = 10
		S.falloff = 2
		S.wait = 1
		S.environment = 0
		var/area/A = src.loc.loc:master

		for(var/area/RA in A.related)
			playing = 1
			while(playing == 1)
				for(var/mob/M in world)
					if((M.loc.loc in A.related) && M.music == 0)
						M << S
						M.music = 1
					else if(!(M.loc.loc in A.related) && M.music == 1)
						var/sound/Soff = sound(null)
						Soff.channel = 10
						M << Soff
						M.music = 0
				sleep(10)
			return

	else
		(src.playing) = 0
		var/sound/S = sound(null)
		S.channel = 10
		S.wait = 1
		for(var/mob/M in world)
			M << S
			M.music = 0
		playing = 0
		var/area/A = src.loc.loc:master
		for(var/area/RA in A.related)