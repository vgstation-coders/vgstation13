/datum/role/traitor
	name = TRAITOR
	id = TRAITOR
	logo_state = "synd-logo"
	wikiroute = ROLE_TRAITOR


/datum/role/traitor/OnPostSetup()
	..()
	if(istype(antag.current, /mob/living/silicon))
		add_law_zero(antag.current)
		antag.current << sound('sound/voice/AISyndiHack.ogg')
	else
		equip_traitor(antag.current, 20)
		antag.current << sound('sound/voice/syndicate_intro.ogg')

/datum/role/traitor/ForgeObjectives()
	if(istype(antag.current, /mob/living/silicon))
		AppendObjective(/datum/objective/target/assassinate)

		AppendObjective(/datum/objective/survive)

		if(prob(10))
			AppendObjective(/datum/objective/block)

	else
		AppendObjective(/datum/objective/target/assassinate)
		AppendObjective(/datum/objective/target/steal)
		switch(rand(1,100))
			if(1 to 30) // Die glorious death
				if(!locate(/datum/objective/die) in objectives.GetObjectives() && !locate(/datum/objective/target/steal) in objectives.GetObjectives())
					AppendObjective(/datum/objective/die)
				else
					if(prob(85))
						if (!(locate(/datum/objective/escape) in objectives.GetObjectives()))
							AppendObjective(/datum/objective/escape)
					else
						if(prob(50))
							if (!(locate(/datum/objective/hijack) in objectives.GetObjectives()))
								AppendObjective(/datum/objective/hijack)
						else
							if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
								AppendObjective(/datum/objective/minimize_casualties)
			if(31 to 90)
				if (!(locate(/datum/objective/escape) in objectives.objectives))
					AppendObjective(/datum/objective/escape)
			else
				if(prob(50))
					if (!(locate(/datum/objective/hijack) in objectives.objectives))
						AppendObjective(/datum/objective/hijack)
				else // Honk
					if (!(locate(/datum/objective/minimize_casualties) in objectives.GetObjectives()))
						AppendObjective(/datum/objective/minimize_casualties)

/datum/role/traitor/extraPanelButtons()
	var/dat = ""
	if(antag.find_syndicate_uplink())
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];removeuplink=1;'>(Remove uplink)</a>"
	else
		dat = " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];giveuplink=1;'>(Give uplink)</a>"
	return dat

/datum/role/traitor/RoleTopic(href, href_list, var/datum/mind/M, var/admin_auth)
	if(href_list["giveuplink"])
		equip_traitor(antag.current, 20)
	if(href_list["removeuplink"])
		M.take_uplink()
		to_chat(M.current, "<span class='warning'>You have been stripped of your uplink.</span>")

/datum/role/traitor/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Syndicate agent, a Traitor.</span>")
		if (GREET_AUTOTATOR)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are now a Traitor.<br>Your memory clears up as you remember your identity as a sleeper agent of the Syndicate. It's time to pay your debt to them. </span>")
		if (GREET_LATEJOIN)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Traitor.<br>As a Syndicate agent, you are to infiltrate the crew and accomplish your objectives at all cost.</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Traitor.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

//_______________________________________________

/*
 * Summon guns and sword traitors
 */

/datum/role/traitor/survivor
	id = SURVIVOR
	name = SURVIVOR
	var/survivor_type = "survivor"

/datum/role/traitor/survivor/crusader
	id = CRUSADER
	name = CRUSADER
	survivor_type = "crusader"

/datum/role/traitor/survivor/OnPostSetup()
	var/randomizeguns = pick("taser","stunrevolver","egun","laser","retro","laserak","revolver","detective","c20r","nuclear","deagle","gyrojet","pulse","silenced","cannon","doublebarrel","shotgun","combatshotgun","mateba","smg","uzi","microuzi","crossbow","saw","hecate","osipr","gatling","bison","ricochet","spur","nagant","obrez","beegun","beretta","usp","glock","luger","colt","plasmapistol")
	var/mob/living/H = antag.current
	switch (randomizeguns)
		if("taser")
			new /obj/item/weapon/gun/energy/taser(get_turf(H))
		if("stunrevolver")
			new /obj/item/weapon/gun/energy/stunrevolver(get_turf(H))
		if("egun")
			new /obj/item/weapon/gun/energy/gun(get_turf(H))
		if("laser")
			new /obj/item/weapon/gun/energy/laser(get_turf(H))
		if("retro")
			new /obj/item/weapon/gun/energy/laser/retro(get_turf(H))
		if("laserak")
			new /obj/item/weapon/gun/energy/laser/LaserAK(get_turf(H))
		if("plasmapistol")
			new /obj/item/weapon/gun/energy/plasma/pistol(get_turf(H))
		if("revolver")
			new /obj/item/weapon/gun/projectile(get_turf(H))
		if("detective")
			new /obj/item/weapon/gun/projectile/detective(get_turf(H))
		if("c20r")
			new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
		if("nuclear")
			new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(H))
		if("deagle")
			new /obj/item/weapon/gun/projectile/deagle/camo(get_turf(H))
		if("gyrojet")
			new /obj/item/weapon/gun/projectile/gyropistol(get_turf(H))
		if("pulse")
			new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(H))
		if("silenced")
			new /obj/item/weapon/gun/projectile/pistol(get_turf(H))
			new /obj/item/gun_part/silencer(get_turf(H))
		if("cannon")
			new /obj/item/weapon/gun/energy/laser/cannon(get_turf(H))
		if("doublebarrel")
			new /obj/item/weapon/gun/projectile/shotgun/pump/(get_turf(H))
		if("shotgun")
			new /obj/item/weapon/gun/projectile/shotgun/pump/(get_turf(H))
		if("combatshotgun")
			new /obj/item/weapon/gun/projectile/shotgun/pump/combat(get_turf(H))
		if("mateba")
			new /obj/item/weapon/gun/projectile/mateba(get_turf(H))
		if("smg")
			new /obj/item/weapon/gun/projectile/automatic(get_turf(H))
		if("uzi")
			new /obj/item/weapon/gun/projectile/automatic/uzi(get_turf(H))
		if("microuzi")
			new /obj/item/weapon/gun/projectile/automatic/uzi/micro(get_turf(H))
		if("crossbow")
			new /obj/item/weapon/gun/energy/crossbow(get_turf(H))
		if("saw")
			new /obj/item/weapon/gun/projectile/automatic/l6_saw(get_turf(H))
		if("hecate")
			new /obj/item/weapon/gun/projectile/hecate(get_turf(H))
			new /obj/item/ammo_casing/BMG50(get_turf(H))//can't give a full box of such deadly bullets. 3 shots is plenty.
			new /obj/item/ammo_casing/BMG50(get_turf(H))
		if("osipr")
			new /obj/item/weapon/gun/osipr(get_turf(H))
		if("gatling")
			new /obj/item/weapon/gun/gatling(get_turf(H))
		if("bison")
			new /obj/item/weapon/gun/energy/bison(get_turf(H))
		if("ricochet")
			new /obj/item/weapon/gun/energy/ricochet(get_turf(H))
		if("spur")
			new /obj/item/weapon/gun/energy/polarstar(get_turf(H))
			new /obj/item/device/modkit/spur_parts(get_turf(H))
		if("nagant")
			new /obj/item/weapon/gun/projectile/nagant(get_turf(H))
		if("obrez")
			new /obj/item/weapon/gun/projectile/nagant/obrez(get_turf(H))
		if("beegun")
			new /obj/item/weapon/gun/gatling/beegun(get_turf(H))
		if("beretta")
			new /obj/item/weapon/gun/projectile/beretta(get_turf(H))
		if("usp")
			new /obj/item/weapon/gun/projectile/NTUSP/fancy(get_turf(H))
		if("glock")
			new /obj/item/weapon/gun/projectile/sec/fancy(get_turf(H))
		if("luger")
			new /obj/item/weapon/gun/projectile/luger(get_turf(H))
		if("colt")
			new /obj/item/weapon/gun/projectile/colt(get_turf(H))
	playsound(H,'sound/effects/summon_guns.ogg', 50, 1)

/datum/role/traitor/survivor/crusader/OnPostSetup()
	var/randomizeswords = pick("unlucky", "misc", "glass", "throw", "armblade", "pickaxe", "pcutter", "esword", "alt-esword", "machete", "kitchen", "spear", "katana", "axe", "venom", "boot", "saw", "scalpel", "bottle", "switchtool")
	var/randomizeknightcolor = pick("green", "yellow", "blue", "red", "templar")
	var/mob/living/H = antag.current
	switch (randomizeknightcolor) //everyone gets some armor as well
		if("green")
			new /obj/item/clothing/suit/armor/knight(get_turf(H))
			new /obj/item/clothing/head/helmet/knight(get_turf(H))
		if("yellow")
			new /obj/item/clothing/suit/armor/knight/yellow(get_turf(H))
			new /obj/item/clothing/head/helmet/knight/yellow(get_turf(H))
		if("blue")
			new /obj/item/clothing/suit/armor/knight/blue(get_turf(H))
			new /obj/item/clothing/head/helmet/knight/blue(get_turf(H))
		if("red")
			new /obj/item/clothing/suit/armor/knight/red(get_turf(H))
			new /obj/item/clothing/head/helmet/knight/red(get_turf(H))
		if("templar")
			new /obj/item/clothing/suit/armor/knight/templar(get_turf(H))
			new /obj/item/clothing/head/helmet/knight/templar(get_turf(H))

	switch (randomizeswords)
		if("unlucky") //so the chance to get an unlucky item does't clutter the main pool of swords
			var/noluck = pick(/obj/item/weapon/kitchen/utensil/knife/plastic, /obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters, /obj/item/toy/foamblade, /obj/item/toy/sword)
			new noluck(get_turf(H))
		if("misc")
			var/miscpick = pick(/obj/item/weapon/scythe, /obj/item/weapon/harpoon, /obj/item/weapon/sword, /obj/item/weapon/sword/executioner, /obj/item/weapon/claymore, /obj/item/weapon/sord)
			new miscpick(get_turf(H))
		if("glass")
			if(prob(50))
				new /obj/item/weapon/shard(get_turf(H))
			else
				new /obj/item/weapon/shard/plasma(get_turf(H))
		if("throw")
			if(prob(20))
				new /obj/item/weapon/kitchen/utensil/knife/nazi(get_turf(H))
			else
				new /obj/item/weapon/hatchet(get_turf(H))
		if("armblade") // good luck getting it off. Maybe cut your own arm off :^)
			new /obj/item/weapon/armblade(get_turf(H))
		if("pickaxe")
			var/pickedaxe = pick(/obj/item/weapon/pickaxe, /obj/item/weapon/pickaxe/silver, /obj/item/weapon/pickaxe/gold, /obj/item/weapon/pickaxe/diamond)
			new pickedaxe(get_turf(H))
		if("pcutter")
			new /obj/item/weapon/pickaxe/plasmacutter(get_turf(H))
		if("esword")
			new /obj/item/weapon/melee/energy/sword(get_turf(H))
			if(prob(70)) //chance for a second one to make a double esword
				new /obj/item/weapon/melee/energy/sword(get_turf(H))
		if("alt-esword")
			if(prob(75))
				new /obj/item/weapon/melee/energy/sword/pirate(get_turf(H))
				if(prob(70))
					new /obj/item/weapon/melee/energy/sword/pirate(get_turf(H))
			else //hope you're the clown
				new /obj/item/weapon/melee/energy/sword/bsword(get_turf(H))
				if(prob(70))
					new /obj/item/weapon/melee/energy/sword/bsword(get_turf(H))
		if("machete")
			new /obj/item/weapon/melee/energy/hfmachete(get_turf(H))
			if(prob(70))
				new /obj/item/weapon/melee/energy/hfmachete(get_turf(H))
		if("kitchen")
			if(prob(60))
				if(prob(25))
					new /obj/item/weapon/kitchen/utensil/knife/large(get_turf(H))
				else
					new /obj/item/weapon/kitchen/utensil/knife/large/butch(get_turf(H))
			else
				new /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver(get_turf(H))
		if("spear")
			if(prob(50))
				new /obj/item/weapon/spear(get_turf(H))
			else
				new /obj/item/weapon/melee/lance(get_turf(H))
		if("katana")
			new /obj/item/weapon/katana(get_turf(H))
					//No fun allowed, maybe nerf later and readd
					/*
					if(prob(5))
						new /obj/item/weapon/katana/hfrequency(get_turf(H))
					else
						new /obj/item/weapon/katana(get_turf(H))
					*/
		if("axe")
			if(prob(50))
				if(prob(5))
					new /obj/item/weapon/melee/energy/axe(get_turf(H))
				else
					new /obj/item/weapon/melee/energy/axe/rusty(get_turf(H))
			else
				new /obj/item/weapon/fireaxe(get_turf(H))
		if("venom")
			new /obj/item/weapon/sword/venom(get_turf(H))
		if("boot")
			if(prob(50))
				new /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical(get_turf(H))
			else
				new /obj/item/clothing/accessory/holster/knife/boot/preloaded/skinning(get_turf(H))
		if("saw")
			if(prob(40))
				new /obj/item/weapon/circular_saw/plasmasaw(get_turf(H))
			else
				new /obj/item/weapon/circular_saw(get_turf(H))
		if("scalpel")
			if(prob(60))
				if(prob(50))
					new /obj/item/weapon/scalpel/laser(get_turf(H))
				else
					new /obj/item/weapon/scalpel/laser/tier2(get_turf(H))
			else
				new /obj/item/weapon/scalpel(get_turf(H))
		if("bottle")
			new /obj/abstract/map/spawner/space/drinks(get_turf(H))
		if("switchtool")
			if(prob(40))
				if(prob(50))
					new /obj/item/weapon/switchtool(get_turf(H))
				else
					new /obj/item/weapon/switchtool/surgery(get_turf(H))
			else
				new /obj/item/weapon/switchtool/swiss_army_knife(get_turf(H))
	playsound(H,'sound/items/zippo_open.ogg', 50, 1)

/datum/role/traitor/survivor/Greet()
	to_chat(antag.current, "<B>You are a [survivor_type]! Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...</B>")

/datum/role/traitor/survivor/ForgeObjectives()
	var/datum/objective/survive/S = new
	AppendObjective(S)

//________________________________________________


/datum/role/traitor/rogue//double agent
	name = ROGUE
	id = ROGUE
	logo_state = "synd-logo"

/datum/role/traitor/rogue/ForgeObjectives()
	var/datum/role/traitor/rogue/rival
	var/list/potential_rivals = list()
	if(faction && faction.members)
		potential_rivals = faction.members-src
	else
		for(var/datum/role/traitor/rogue/R in ticker.mode.orphaned_roles) //It'd be awkward if you ended up with your rival being a vampire.
			if(R != src)
				potential_rivals.Add(R)
	if(potential_rivals.len)
		rival = pick(potential_rivals)
	if(!rival) //Fuck it, you're now a regular traitor
		return ..()

	var/datum/objective/target/assassinate/kill_rival = new(auto_target = FALSE)
	if(kill_rival.set_target(rival.antag))
		AppendObjective(kill_rival)
	else
		qdel(kill_rival)

	if(prob(70)) //Your target knows!
		var/datum/objective/target/assassinate/kill_new_rival = new(auto_target = FALSE)
		if(kill_new_rival.set_target(antag))
			rival.AppendObjective(kill_new_rival)
		else
			qdel(kill_new_rival)

	if(prob(50)) //Spy v Spy
		var/datum/objective/target/assassinate/A = new()
		if(A.target)
			AppendObjective(A)

			var/datum/objective/target/protect/P = new(auto_target = FALSE)
			if(P.set_target(A.target))
				rival.AppendObjective(P)

	if(prob(30))
		AppendObjective(/datum/objective/target/steal)

	switch(rand(1,3))
		if(1)
			if(!locate(/datum/objective/target/steal) in objectives.GetObjectives())
				AppendObjective(/datum/objective/die)
			else
				AppendObjective(/datum/objective/escape)
		if(2)
			AppendObjective(/datum/objective/hijack)
		else
			AppendObjective(/datum/objective/escape)

//________________________________________________

/datum/role/nuclear_operative
	name = NUKE_OP
	id = NUKE_OP
	disallow_job = TRUE
	logo_state = "nuke-logo"

/datum/role/nuclear_operative/leader
	logo_state = "nuke-logo-leader"
