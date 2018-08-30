var/runedec = 0 // Rune cap ?

/obj/effect/rune_legacy
	desc = "A strange collection of symbols drawn in blood."
	anchored = 1
	icon = 'icons/effects/uristrunes.dmi'
	icon_state = "rune-1"
	var/visibility = 0
	layer = RUNE_LAYER
	plane = ABOVE_TURF_PLANE

	var/dead=0 // For cascade and whatnot.

	var/list/cultwords = list()
	var/datum/faction/cult/narsie/my_cult

	var/word1
	var/word2
	var/word3
	var/image/blood_image

	var/atom/movable/overlay/c_animation = null
	var/nullblock = 0
	var/mob/living/ajourn

	var/summoning = 0
	var/list/summonturfs = list()

/obj/effect/rune_legacy/New()
	..()
	blood_image = image(loc = src)
	blood_image.override = 1
	for(var/mob/living/silicon/ai/AI in player_list)
		if(AI.client)
			AI.client.images += blood_image
	rune_list_legacy.Add(src)
	my_cult = find_active_faction_by_type(/datum/faction/cult/narsie)
	if (!my_cult)
		CRASH("Creating a rune without an active cult")
	cultwords = my_cult.cult_words
	stat_collection.cult_runes_written++

/obj/effect/rune_legacy/Destroy()
	if(istype(ajourn))
		ajourn.ajourn = null
	ajourn = null
	for(var/mob/living/silicon/ai/AI in player_list)
		if(AI.client)
			AI.client.images -= blood_image
	qdel(blood_image)
	blood_image = null
	rune_list_legacy.Remove(src)
	..()

/obj/effect/rune_legacy/examine(mob/user)
	..()
	if(islegacycultist(user) || isobserver(user))
		var/rune_name = my_cult.get_uristrune_name(word1,word2,word3)
		to_chat(user, "A spell circle drawn in blood. It reads: <i>[word1] [word2] [word3]</i>.[rune_name ? " From [pick("your intuition, you are pretty sure that","deep memories, you determine that","the rune's energies, you deduct that","Nar-Sie's murmurs, you know that")] this is \a <b>[rune_name]</b> rune." : ""]")


/obj/effect/rune_legacy/attackby(obj/I, mob/user)
	if(istype(I, /obj/item/weapon/tome_legacy) && islegacycultist(user))
		to_chat(user, "You retrace your steps, carefully undoing the lines of the rune.")
		qdel(src)
		return
	else if(istype(I, /obj/item/weapon/nullrod))
		to_chat(user, "<span class='notice'>You disrupt the vile magic with the deadening field of \the [I]!</span>")
		qdel(src)
		stat_collection.cult_runes_nulled++
		return
	return

/obj/effect/rune_legacy/attack_animal(mob/living/simple_animal/user as mob)
	if(istype(user, /mob/living/simple_animal/construct/harvester))
		attack_hand(user)

/obj/effect/rune_legacy/attack_paw(mob/living/M as mob)
	if(ismonkey(M))
		attack_hand(M)

/obj/effect/rune_legacy/attack_hand(mob/living/user as mob)
	user.delayNextAttack(5)
	if(!islegacycultist(user))
		to_chat(user, "You can't mouth the arcane scratchings without fumbling over them.")
		return
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(user, "You are unable to speak the words of the rune.")
		return
	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle()
//		if(!src.visibility)
//			src.visibility=1
	if(word1 == cultwords["travel"] && word2 == cultwords["self"])
		return teleport(src.word3)
	if(word1 == cultwords["see"] && word2 == cultwords["blood"] && word3 == cultwords["hell"])
		return tomesummon()
	if(word1 == cultwords["hell"] && word2 == cultwords["destroy"] && word3 == cultwords["other"])
		return armor()
	if(word1 == cultwords["join"] && word2 == cultwords["blood"] && word3 == cultwords["self"])
		return convert()
	if(word1 == cultwords["hell"] && word2 == cultwords["join"] && word3 == cultwords["self"])
		return tearreality()
	if(word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["technology"])
		return emp(src.loc,3)
	if(word1 == cultwords["travel"] && word2 == cultwords["blood"] && word3 == cultwords["self"])
		return drain()
	if(word1 == cultwords["see"] && word2 == cultwords["hell"] && word3 == cultwords["join"])
		return seer()
	if(word1 == cultwords["blood"] && word2 == cultwords["join"] && word3 == cultwords["hell"])
		return raise()
	if(word1 == cultwords["hide"] && word2 == cultwords["see"] && word3 == cultwords["blood"])
		return obscure(4)
	if(word1 == cultwords["hell"] && word2 == cultwords["travel"] && word3 == cultwords["self"])
		return ajourney()
	if(word1 == cultwords["hell"] && word2 == cultwords["technology"] && word3 == cultwords["join"])
		return talisman()
	if(word1 == cultwords["hell"] && word2 == cultwords["blood"] && word3 == cultwords["join"])
		return sacrifice()
	if(word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["hide"])
		return revealrunes(src)
	if(word1 == cultwords["destroy"] && word2 == cultwords["travel"] && word3 == cultwords["self"])
		return wall()
	if(word1 == cultwords["travel"] && word2 == cultwords["technology"] && word3 == cultwords["other"])
		return freedom()
	if(word1 == cultwords["join"] && word2 == cultwords["other"] && word3 == cultwords["self"])
		return cultsummon()
	if(word1 == cultwords["hide"] && word2 == cultwords["other"] && word3 == cultwords["see"])
		return deafen()
	if(word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["other"])
		return blind()
	if(word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["blood"])
		return bloodboil()
	if(word1 == cultwords["self"] && word2 == cultwords["other"] && word3 == cultwords["technology"])
		return communicate()
	if(word1 == cultwords["travel"] && word2 == cultwords["other"])
		return itemport(src.word3)
	if(word1 == cultwords["join"] && word2 == cultwords["hide"] && word3 == cultwords["technology"])
		return runestun()
	else
		return fizzle()


/obj/effect/rune_legacy/proc/fizzle()
	stat_collection.cult_runes_fumbled++
	if(istype(src,/obj/effect/rune))
		usr.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
	else
		usr.whisper(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
	for (var/mob/V in viewers(src))
		V.show_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 1, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	return

/obj/effect/rune_legacy/proc/check_icon(var/mob/M = null)
	get_uristrune_cult(word1, word2, word3, M)

/obj/item/weapon/tome_legacy
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister looking cover."
	icon = 'icons/obj/cult.dmi'
	icon_state ="tome"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	var/datum/faction/cult/narsie/my_cult
	var/notedat = ""
	var/tomedat = ""
	var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")
	var/list/cultwords = list()

	tomedat = {"<html>
				<head>
				<style>
				h1 {font-size: 25px; margin: 15px 0px 5px;}
				h2 {font-size: 20px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood.</h1>

				<i>The book is written in an unknown dialect, there are lots of pictures of various complex geometric shapes. You find some notes in english that give you basic understanding of the many runes written in the book. The notes give you an understanding what the words for the runes should be. However, you do not know how to write all these words in this dialect.</i><br>
				<i>Below is the summary of the runes.</i> <br>

				<h2>Contents</h2>
				<p>
				<b>Teleport self: </b>Travel Self (word)<br>
				<b>Teleport other: </b>Travel Other (word)<br>
				<b>Summon new tome: </b>See Blood Hell<br>
				<b>Convert a person: </b>Join Blood Self<br>
				<b>Summon Nar-Sie: </b>Hell Join Self<br>
				<b>EMP: </b>Destroy See Technology<br>
				<b>Drain blood: </b>Travel Blood Self<br>
				<b>Raise dead: </b>Blood Join Hell<br>
				<b>Hide runes: </b>Hide See Blood<br>
				<b>Reveal runes: </b>Blood See Hide<br>
				<b>Astral Journey: </b>Hell travel self<br>
				<b>Imbue a talisman: </b>Hell Technology Join<br>
				<b>Sacrifice: </b>Hell Blood Join<br>
				<b>Wall: </b>Destroy Travel Self<br>
				<b>Summon cultist: </b>Join Other Self<br>
				<b>Free a cultist: </b>Travel technology other<br>
				<b>Deafen: </b>Hide Other See<br>
				<b>Blind: </b>Destroy See Other<br>
				<b>Communicate: </b>Self Other Technology<br>
				<b>Stun: </b>Join Hide Technology<br>
				<b>Cult Armor: </b>Hell Destroy Other<br>
				<b>See Invisible: </b>See Hell Join<br>
				<b>Blood Boil: </b>Destroy See Blood<br>
				</p>
				<h2>Rune Descriptions</h2>
				<h3>Teleport self</h3>
				Teleport rune is a special rune, as it only needs two words, with the third word being destination. Basically, when you have two runes with the same destination, invoking one will teleport you to the other one. If there are more than 2 runes, you will be teleported to a random one. Runes with different third words will create separate networks. You can imbue this rune into a talisman, giving you a great escape mechanism.<br>
				<h3>Teleport other</h3>
				Teleport other allows for teleportation for any movable object to another rune with the same third word. You need 2 cultists chanting the invocation for this rune to work.<br>
				<h3>Summon new tome</h3>
				Invoking this rune summons a new arcane tome.
				<h3>Convert a person</h3>
				This rune opens target's mind to the realm of Nar-Sie, which usually results in this person joining the cult. However, some people (mostly the ones who posess high authority) have strong enough will to stay true to their old ideals. <br>
				<h3>Summon Nar-Sie</h3>
				The ultimate rune. It summons the Avatar of Nar-Sie himself, tearing a huge hole in reality and consuming everything around it. Summoning it is the final goal of any cult. Just make sure that you have completed any other objectives and that you are on the Station when you try summon Him.<br>
				<h3>EMP</h3>
				Invoking this rune creates a strong electromagnetic pulse in a small radius, making it basically analogic to an EMP grenade. You can imbue this rune into a talisman, making it a decent defensive item.<br>
				<h3>Drain Blood</h3>
				This rune instantly heals you of some brute damage at the expense of a person placed on top of the rune. Whenever you invoke a drain rune, ALL drain runes on the station are activated, draining blood from anyone located on top of those runes. This includes yourself, though the blood you drain from yourself just comes back to you. This might help you identify this rune when studying words. One drain gives up to 25HP per each victim, but you can repeat it if you need more. Draining only works on living people, so you might need to recharge your "Battery" once its empty. Drinking too much blood at once might cause blood hunger.<br>
				<h3>Raise Dead</h3>
				This rune allows for the resurrection of any dead person. You will need a dead human body and a living human sacrifice. Make 2 raise dead runes. Put a living non-braindead human on top of one, and a dead body on the other one. When you invoke the rune, the life force of the living human will be transferred into the dead body, allowing a ghost standing on top of the dead body to enter it, instantly and fully healing it. Use other runes to ensure there is a ghost ready to be resurrected.<br>
				<h3>Hide runes</h3>
				This rune makes all nearby runes completely invisible. They are still there and will work if activated somehow, but you cannot invoke them directly if you do not see them.<br>
				<h3>Reveal runes</h3>
				This rune is made to reverse the process of hiding a rune. It reveals all hidden runes in a rather large area around it.
				<h3>Astral Journey</h3>
				This rune gently rips your soul out of your body, leaving it intact. You can observe the surroundings as a ghost as well as communicate with other ghosts. Your body takes damage while you are there, so ensure your journey is not too long, or you might never come back.<br>
				<h3>Imbue a talisman</h3>
				This rune allows you to imbue the magic of some runes into paper talismans. Create an imbue rune, then an appropriate rune beside it. Put an empty piece of paper on the imbue rune and invoke it. You will now have a one-use talisman with the power of the target rune. Using a talisman drains some health, so be careful with it. You can imbue a talisman with power of the following runes: summon tome, reveal, conceal, teleport, disable technology, communicate, deafen, blind and stun.<br>
				<h3>Sacrifice</h3>
				Sacrifice rune allows you to sacrifice a living thing or a body to the Geometer of Blood. Monkeys and dead humans are the most basic sacrifices, they might or might not be enough to gain His favor. A living human is what a real sacrifice should be, however, you will need 3 people chanting the invocation to sacrifice a living person.<br>Silicons can also be disposed of using this rune.<br>
				<h3>Create a wall</h3>
				Invoking this rune solidifies the air above it, creating an an invisible wall. To remove the wall, simply invoke the rune again.
				<h3>Summon cultist</h3>
				This rune allows you to summon a fellow cultist to your location. The target cultist must be unhandcuffed ant not buckled to anything. You also need to have 2 people chanting at the rune to successfully invoke it. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Free a cultist</h3>
				This rune unhandcuffs and unbuckles any cultist of your choice, no matter where he is. You need to have 2 people invoking the rune for it to work. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Deafen</h3>
				This rune temporarily deafens all non-cultists around you.<br>
				<h3>Blind</h3>
				This rune temporarily blinds all non-cultists around you. Very robust. Use together with the deafen rune to leave your enemies completely helpless.<br>
				<h3>Communicate</h3>
				Invoking this rune allows you to relay a message to all cultists on the station and nearby space objects.
				<h3>Stun</h3>
				Unlike other runes, this ons is supposed to be used in talisman form. When invoked directly, it simply releases some dark energy, briefly stunning everyone around. When imbued into a talisman, you can force all of its energy into one person, stunning him so hard he cant even speak. However, effect wears off rather fast.<br><br>Works on robots!<br>
				<h3>Cult Armor</h3>
				When this rune is invoked, either from a rune or a talisman, it will equip the user with the armor of the followers of Nar-Sie. To use this rune to its fullest extent, make sure you are not wearing any form of headgear, armor, gloves or shoes, and make sure you are not holding anything in your hands.<br>Small-sized individuals will be provided with a fitting armor.<br><br>You may also use this rune to change a construct's type. Simply ask the construct to stand on the rune then touch it.<br>
				<h3>See Invisible</h3>
				When invoked when standing on it, this rune allows the user to see the the world beyond as long as he does not move.<br>
				<h3>Blood boil</h3>
				This rune boils the blood all non-cultists in visible range. The damage is enough to instantly critically hurt any person. You need 3 cultists invoking the rune for it to work. This rune is unreliable and may cause unpredicted effect when invoked. It also drains significant amount of your health when successfully invoked.<br>
				</body>
				</html>
				"}

/obj/item/weapon/tome_legacy/New(var/datum/faction/cult/narsie/our_cult) // Multiple cults with multiple words ? Why not
	if (!istype(our_cult))
		our_cult = find_active_faction_by_type(/datum/faction/cult/narsie) // No cult given, let's find ours
	if (!istype(our_cult))
		message_admins("Error: trying to spawn a cult tome without an active cult! Create one first.")
		visible_message("<span class='warning'>The tome suddendly catches fire and fades out in a dark puff of smoke.</span>")
		qdel(src)
		return FALSE
	my_cult = our_cult
	cultwords = my_cult.cult_words
	return ..()

/obj/item/weapon/tome_legacy/Topic(href,href_list[])
	if (src.loc == usr)
		var/number = text2num(href_list["number"])
		if (usr.stat || usr.restrained())
			return
		switch(href_list["action"])
			if("clear")
				words[words[number]] = words[number]
			if("change")
				words[words[number]] = input("Enter the translation for [words[number]]", "Word notes") in engwords
				for (var/w in words)
					if ((words[w] == words[words[number]]) && (w != words[number]))
						words[w] = w
		notedat = {"
					<br><b>Word translation notes</b> <br>
					[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
					[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
					[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
					[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
					[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
					[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
					[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
					[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
					[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
					[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
					"}
		usr << browse("[notedat]", "window=notes")
//		call(/obj/item/weapon/tome_legacy/proc/edit_notes)()
	else
		usr << browse(null, "window=notes")
		return

/*
/obj/item/weapon/tome_legacy/proc/edit_notes()     FUCK IT. Cant get it to work properly. - K0000
	to_chat(world, "its been called! [usr]")
	notedat = {"
	<br><b>Word translation notes</b> <br>
		[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
		[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
		[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
		[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
		[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
		[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
		[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
		[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
		[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
		[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
				"}
	to_chat(usr, "whatev")
	usr << browse(null, "window=tank")
*/

/obj/item/weapon/tome_legacy/attack(mob/living/M as mob, mob/living/user as mob)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had the [name] used on him by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used [name] on [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(M))
		M.LAssailant = null
	else
		M.LAssailant = user
	if(isobserver(M))
		if(M.invisibility != 0)
			M.invisibility = 0
			user.visible_message(
				"<span class='warning'>[user] drags the ghost to our plane of reality!</span>",
				"<span class='warning'>You drag the ghost to our plane of reality!</span>"
			)
		return
	if(!istype(M))
		return
	if(!islegacycultist(user))
		return ..()
	if(islegacycultist(M))
		return
	M.take_organ_damage(0,rand(5,20)) //really lucky - 5 hits for a crit
	for(var/mob/O in viewers(M, null))
		O.show_message(text("<span class='danger'>[] beats [] with the arcane tome!</span>", user, M), 1)
	to_chat(M, "<span class='warning'>You feel searing heat inside!</span>")


/obj/item/weapon/tome_legacy/attack_self(mob/living/user as mob)
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(!cultwords["travel"])
		my_cult.randomiseWords()
	if(islegacycultist(user))
		if (!istype(user.loc,/turf))
			to_chat(user, "<span class='warning'>You do not have enough space to write a proper rune.</span>")
			return
		var/datum/role/r = user.mind.GetRole(LEGACY_CULT)
		var/datum/faction/cult = find_active_faction_by_member(r)
		var/cultists = 1
		if(cult)
			cultists = cult.members.len
		if (rune_list_legacy.len >= 26+runedec+4*cultists) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
			alert("The cloth of reality can't take that much of a strain. Remove some runes first!")
			return
		else
			switch(alert("You open the tome",,"Read it","Scribe a rune", "Notes")) //Fuck the "Cancel" option. Rewrite the whole tome interface yourself if you want it to work better. And input() is just ugly. - K0000
				if("Cancel")
					return
				if("Read it")
					if(user.get_active_hand() != src)
						return
					user << browse("[tomedat]", "window=Arcane Tome")
					return
				if("Notes")
					if(user.get_active_hand() != src)
						return
					notedat = {"
				<br><b>Word translation notes</b> <br>
				[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
				[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
				[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
				[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
				[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
				[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
				[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
				[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
				[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
				[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
				"}
//						call(/obj/item/weapon/tome_legacy/proc/edit_notes)()
					user << browse("[notedat]", "window=notes")
					return
		if(usr.get_active_hand() != src)
			return

		var/w1
		var/w2
		var/w3
		var/list/english = list()
		for (var/w in words)
			english+=words[w]
		if(usr)
			w1 = input("Write your first rune: \[ __ \] \[ ... \] \[ ... \]", "Rune Scribing") as null|anything in english
			if(!w1)
				return
		if(usr)
			w2 = input("Write your second rune: \[ [w1] \] \[ __ \] \[ ... \]", "Rune Scribing") as null|anything in english
			if(!w2)
				return
		if(usr)
			w3 = input("Write your third rune: \[ [w1] \] \[ [w2] \] \[ __ \]", "Rune Scribing") as null|anything in english
			if(!w3)
				return

		for (var/w in words)
			if (words[w] == w1)
				w1 = w
			if (words[w] == w2)
				w2 = w
			if (words[w] == w3)
				w3 = w

		if(user.get_active_hand() != src)
			return
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(!H.held_items.len)
				to_chat(user, "<span class='notice'>You have no hands to draw with!</span>")
				return
			if(H.species.anatomy_flags & NO_BLOOD) //No blood, going to have to improvise
				if(H.bloody_hands) //Blood on hand to use, and hands on hand to use
					user.visible_message("<span class='warning'>[user] starts to paint drawings on the floor with the blood on their hands, whilst chanting.</span>",\
					"<span class='warning'>You use the blood smeared on your hands to begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>",\
					"<span class='warning'>You hear chanting.</span>")
					H.bloody_hands = max(0, H.bloody_hands - 1)
				else //We'll have to search around for blood
					var/turf/T = get_turf(user)
					var/found = 0
					for (var/obj/effect/decal/cleanable/blood/B in T)
						if(B.amount && B.counts_as_blood)
							user.visible_message("<span class='warning'>[user] paws at the blood puddles splattered on \the [T], and begins to chant and paint symbols on the floor.</span>",\
							"<span class='warning'>You use the blood splattered across \the [T], and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>",\
							"<span class='warning'>You hear chanting.</span>")
							B.amount--
							found = 1
							break
					if(!found)
						to_chat(user, "<span class='notice'>You have no blood in, on, or around you that you can use to draw a rune!</span>")
						return
			else
				user.visible_message("<span class='warning'>[user] slices open a finger and begins to chant and paint symbols on the floor.</span>",\
				"<span class='warning'>You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>",\
				"<span class='warning'>You hear chanting.</span>")
				H.vessel.remove_reagent(BLOOD, rand(9)+2)
				user.take_overall_damage((rand(9)+1)/10) // 0.1 to 1.0 damage
		else //Monkeys, diona, let's just assume it's normal apefoolery
			user.visible_message("<span class='warning'>[user] slices open a finger and begins to chant and paint symbols on the floor.</span>",\
			"<span class='warning'>You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>",\
			"<span class='warning'>You hear chanting.</span>")
			user.take_overall_damage((rand(9)+1)/10) // 0.1 to 1.0 damage
		if(do_after(user, user.loc, 50))
			if(user.get_active_hand() != src)
				return
			var/mob/living/carbon/human/H = user
			var/obj/effect/rune_legacy/R = new /obj/effect/rune_legacy(get_turf(user))
			to_chat(user, "<span class='warning'>You finish drawing the arcane markings of the Geometer.</span>")
			R.word1 = w1
			R.word2 = w2
			R.word3 = w3
			R.check_icon(H)
			R.blood_DNA = list()
			R.blood_DNA[H.dna.unique_enzymes] = H.dna.b_type
			R.blood_color = H.species.blood_color
		return
	else
		to_chat(user, "The book seems full of illegible scribbles. Is this a joke?")
		return

/obj/item/weapon/tome_legacy/attackby(obj/item/weapon/tome_legacy/T as obj, mob/living/user as mob)
	if(istype(T, /obj/item/weapon/tome_legacy) && islegacycultist(user)) // sanity check to prevent a runtime error
		switch(alert("Copy the runes from your tome?",,"Copy", "Cancel"))
			if("Cancel")
				return
		for(var/w in words)
			words[w] = T.words[w]
		to_chat(user, "You copy the translation notes from your tome.")
		flick("tome-copied",src)


/obj/item/weapon/tome_legacy/examine(mob/user)
	..()
	if(islegacycultist(user))
		to_chat(user, "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of. Most of these are useless, though.")

/obj/item/weapon/tome_legacy/cultify()
	return

/obj/item/weapon/tome_legacy/imbued //admin tome, spawns working runes without waiting
	w_class = W_CLASS_SMALL
	var/cultistsonly = 1
	attack_self(mob/user as mob)
		if(src.cultistsonly && !islegacycultist(usr))
			return
		if(!cultwords["travel"])
			my_cult.randomiseWords()
		if(user)
			var/r
			if (!istype(user.loc,/turf))
				to_chat(user, "<span class='warning'>You do not have enough space to write a proper rune.</span>")
			var/list/runes = list("teleport", "itemport", "tome", "armor", "convert", "tear in reality", "emp", "drain", "seer", "raise", "obscure", "reveal", "astral journey", "manifest", "imbue talisman", "sacrifice", "wall", "freedom", "cultsummon", "deafen", "blind", "bloodboil", "communicate", "stun")
			r = input("Choose a rune to scribe", "Rune Scribing") in runes //not cancellable.
			var/obj/effect/rune_legacy/R = new /obj/effect/rune_legacy
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				R.blood_DNA = list()
				R.blood_DNA[H.dna.unique_enzymes] = H.dna.b_type
				R.blood_color = H.species.blood_color
			switch(r)
				if("teleport")
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					R.word1=cultwords["travel"]
					R.word2=cultwords["self"]
					R.word3=beacon
					R.forceMove(user.loc)
					R.check_icon()
				if("itemport")
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					R.word1=cultwords["travel"]
					R.word2=cultwords["other"]
					R.word3=beacon
					R.forceMove(user.loc)
					R.check_icon()
				if("tome")
					R.word1=cultwords["see"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["hell"]
					R.forceMove(user.loc)
					R.check_icon()
				if("armor")
					R.word1=cultwords["hell"]
					R.word2=cultwords["destroy"]
					R.word3=cultwords["other"]
					R.forceMove(user.loc)
					R.check_icon()
				if("convert")
					R.word1=cultwords["join"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["self"]
					R.forceMove(user.loc)
					R.check_icon()
				if("tear in reality")
					R.word1=cultwords["hell"]
					R.word2=cultwords["join"]
					R.word3=cultwords["self"]
					R.forceMove(user.loc)
					R.check_icon()
				if("emp")
					R.word1=cultwords["destroy"]
					R.word2=cultwords["see"]
					R.word3=cultwords["technology"]
					R.forceMove(user.loc)
					R.check_icon()
				if("drain")
					R.word1=cultwords["travel"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["self"]
					R.forceMove(user.loc)
					R.check_icon()
				if("seer")
					R.word1=cultwords["see"]
					R.word2=cultwords["hell"]
					R.word3=cultwords["join"]
					R.forceMove(user.loc)
					R.check_icon()
				if("raise")
					R.word1=cultwords["blood"]
					R.word2=cultwords["join"]
					R.word3=cultwords["hell"]
					R.forceMove(user.loc)
					R.check_icon()
				if("obscure")
					R.word1=cultwords["hide"]
					R.word2=cultwords["see"]
					R.word3=cultwords["blood"]
					R.forceMove(user.loc)
					R.check_icon()
				if("astral journey")
					R.word1=cultwords["hell"]
					R.word2=cultwords["travel"]
					R.word3=cultwords["self"]
					R.forceMove(user.loc)
					R.check_icon()
				if("manifest")
					R.word1=cultwords["blood"]
					R.word2=cultwords["see"]
					R.word3=cultwords["travel"]
					R.forceMove(user.loc)
					R.check_icon()
				if("imbue talisman")
					R.word1=cultwords["hell"]
					R.word2=cultwords["technology"]
					R.word3=cultwords["join"]
					R.forceMove(user.loc)
					R.check_icon()
				if("sacrifice")
					R.word1=cultwords["hell"]
					R.word2=cultwords["blood"]
					R.word3=cultwords["join"]
					R.forceMove(user.loc)
					R.check_icon()
				if("reveal")
					R.word1=cultwords["blood"]
					R.word2=cultwords["see"]
					R.word3=cultwords["hide"]
					R.forceMove(user.loc)
					R.check_icon()
				if("wall")
					R.word1=cultwords["destroy"]
					R.word2=cultwords["travel"]
					R.word3=cultwords["self"]
					R.forceMove(user.loc)
					R.check_icon()
				if("freedom")
					R.word1=cultwords["travel"]
					R.word2=cultwords["technology"]
					R.word3=cultwords["other"]
					R.forceMove(user.loc)
					R.check_icon()
				if("cultsummon")
					R.word1=cultwords["join"]
					R.word2=cultwords["other"]
					R.word3=cultwords["self"]
					R.forceMove(user.loc)
					R.check_icon()
				if("deafen")
					R.word1=cultwords["hide"]
					R.word2=cultwords["other"]
					R.word3=cultwords["see"]
					R.forceMove(user.loc)
					R.check_icon()
				if("blind")
					R.word1=cultwords["destroy"]
					R.word2=cultwords["see"]
					R.word3=cultwords["other"]
					R.forceMove(user.loc)
					R.check_icon()
				if("bloodboil")
					R.word1=cultwords["destroy"]
					R.word2=cultwords["see"]
					R.word3=cultwords["blood"]
					R.forceMove(user.loc)
					R.check_icon()
				if("communicate")
					R.word1=cultwords["self"]
					R.word2=cultwords["other"]
					R.word3=cultwords["technology"]
					R.forceMove(user.loc)
					R.check_icon()
				if("stun")
					R.word1=cultwords["join"]
					R.word2=cultwords["hide"]
					R.word3=cultwords["technology"]
					R.forceMove(user.loc)
					R.check_icon()