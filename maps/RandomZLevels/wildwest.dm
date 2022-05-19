//Wild West Away Mission
#define WILDWEST_MAYORDEAD 1

/datum/map_element/away_mission/wildwest
	name = WESTERN
	file_path = "maps/RandomZLevels/wildwest.dmm"
	desc = "An adventure to the township of Old Zounds and the mysterious Lost Orphan Mine. A Wish Granter is hidden deep within."
	var/flags = 0
	var/list/wanted = list()

/datum/map_element/away_mission/wildwest/initialize(list/objects)
	..()
	SSDayNight.daynight_z_lvl = zLevel //use away mission Z
	SSDayNight.flags = SS_KEEP_TIMING
	SSDayNight.all_times_in_cycle = list(new /datum/timeofday/daytime/short, new /datum/timeofday/afternoon/short, new /datum/timeofday/sunset,
		new /datum/timeofday/nighttime/short, new /datum/timeofday/morning, new /datum/timeofday/sunrise)
	SSDayNight.Initialize()
	message_admins("Started the daynight cycle.")

/datum/map_element/away_mission/wildwest/can_load()
	if(!(SSDayNight.flags & SS_NO_FIRE))
		message_admins("Wild West load failed. Cannot load if daynight is already active.")
		return FALSE
	return ..()

///Areas
/area/surface/western
	forbid_apc = TRUE
	construction_zone = FALSE
	flags = NO_PERSISTENCE|NO_PACIFICATION

/area/surface/western/township //Needs to be area/surface to get day/night
	name = "\improper Old Zounds Township"
	icon_state = "green"

/area/surface/western/desert
	name = "\improper Desert"
	icon_state = "yellow"

/area/surface/western/grave
	name = "\improper Grave of Freights"
	icon_state = "red"

/area/awaymission/western
	forbid_apc = TRUE
	requires_power = FALSE

/area/awaymission/western/town_interior //building insides
	name = "\improper Old Zounds Township"
	icon_state = "bluenew"

/area/awaymission/western/mine
	name = "\improper Lost Orphan Lode"
	icon_state = "mine"

/area/awaymission/western/zerogcave
	name = "\improper Zero-G Cave"
	icon_state = "mine"

/area/awaymission/western/floodedcave
	name = "\improper Flooded Cave"
	icon_state = "mine"

/area/awaymission/western/dontgodeep
	name = "\improper Don't-Go-Deep Mine"
	icon_state = "mine"

/area/awaymission/western/enemymine
	name = "\improper Enemy Mine"
	icon_state = "mine"

/area/awaymission/western/crypt
	name = "\improper La Casa de la Siesta Final"
	icon_state = "blueold"

/area/awaymission/western/mayor //building insides
	name = "\improper Old Zounds Mayoral Mansion"
	icon_state = "bluenew"

/area/awaymission/western/refinery
	name = "\improper Old Zounds Refinery"
	icon_state = "away3"

/area/awaymission/western/rodeoshowroom
	name = "\improper Old Zounds Rodeo Viewing Room"
	icon_state = "showroom"

/area/awaymission/western/rodeocombatfloor
	name = "\improper Old Zounds Rodeo"
	icon_state = "honk"

/area/awaymission/western/umbra
	name = "\improper Umbra"
	icon_state = "away2"

/area/awaymission/western/escapeship
	name = "\improper Old Zounds Escape Ship"
	icon_state = "away1"

//Objects
/obj/item/weapon/card/id/deputy
	name = "deputy badge"
	desc = "A metal star that signifies one as a friend of Old Zounds. You're my favorite deputy."
	assignment = "Deputy"
	icon_state = "deputystar"
	access = list(access_deputy)

/obj/item/weapon/card/id/deputy/prepickup(mob/user)
	var/datum/map_element/away_mission/wildwest/W = get_away_mission(WESTERN)
	if(user in W.wanted)
		to_chat(user, "<span class='danger'>You spit on \the [src]. A villain would never wear that.</span>")
		return 1 //Cancel the pickup
	if(registered_name != "Unknown")
		return 0 //If someone already registered this badge, don't assign it or send a warning.

	var/decision = alert(user,"Putting on that badge will make people think you're a good guy around Old Zounds, but if you disgrace the badge, you'll be a villain forever.",
	"Perfidy Warning","I do not shoot with my hand. (Understood)","Get out of Dodge. (Reject badge)")
	if(decision != "I do not shoot with my hand. (Understood)")
		return 1
	if(!Adjacent(user))
		return 1 //Just a little sanity in case they moved away in that time

	registered_name = user.real_name

	return 0


/obj/item/weapon/card/id/deputy/equipped(\mob/user, slot, hand_index = 0)
	to_chat(user, "<span class = 'warning'>\The [src] disappears from your grasp!</span>")
	user.drop_item(src)

/obj/structure/uraninitecrystal
	name = "glowing crystal"
	icon = 'icons/obj/mining.dmi'
	icon_state = "crystal"
	light_color = "#00FF00"
	anchored = TRUE
	var/lit = FALSE

/obj/structure/uraninitecrystal/New()
	..()
	set_light(2, l_color = light_color)

/obj/structure/uraninitecrystal/bullet_act()
	rad_pulse()

/obj/structure/uraninitecrystal/kick_act()
	rad_pulse()

/obj/structure/uraninitecrystal/ex_act()
	rad_pulse()

/obj/structure/uraninitecrystal/proc/rad_pulse()
	if(lit)
		return
	lit = TRUE
	set_light(6, l_color = light_color)
	rad_pulse()
	sleep(10 SECONDS)
	set_light(2, l_color = light_color)
	lit = FALSE
	emitted_harvestable_radiation(get_turf(src), 20, range = 5)
	for(var/mob/living/carbon/M in view(src,3))
		var/rads = 50 * sqrt( 1 / (get_dist(M, src) + 1) )
		M.apply_radiation(round(rads/2),RAD_EXTERNAL)

/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/dorf/New()
	..()
	reagents.add_reagent(MANLYDORF, 50)
	on_reagent_change()

/obj/structure/cartrail
	name = "rail"
	desc = "A hunk of shaped metal."
	icon = 'icons/obj/mining.dmi'
	icon_state = "rail"

/obj/structure/rustycart
	name = "rusty cart"
	desc = "This isn't going anywhere fast."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "mining_cart"
	anchored = TRUE
	density = TRUE

// Umbra Vault

/obj/machinery/wish_granter_dark
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "wishgranter"
	anchored = 1
	density = 1
	use_power = MACHINE_POWER_USE_NONE
	var/chargesa = 1
	var/insistinga = 0

/obj/machinery/wish_granter_dark/attack_hand(var/mob/living/carbon/human/user as mob)
	usr.set_machine(src)

	if(chargesa <= 0)
		to_chat(user, "The Wish Granter lies silent.")
		return

	else if(!istype(user, /mob/living/carbon/human))
		to_chat(user, "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.")
		return

	else if (!insistinga)
		to_chat(user, "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?")
		insistinga++

	else
		chargesa--
		insistinga = 0
		var/wish = input("You want...","Wish") as null|anything in list("Power","Wealth","Immortality","Peace")
		switch(wish)
			if("Power")
				if (!(M_LASER in user.mutations))
					user.mutations.Add(M_LASER)
					to_chat(user, "\blue You feel pressure building behind your eyes.")
				if (!(M_RESIST_COLD in user.mutations))
					user.mutations.Add(M_RESIST_COLD)
					to_chat(user, "\blue Your body feels warm.")
				if (!(M_RESIST_HEAT in user.mutations))
					user.mutations.Add(M_RESIST_HEAT)
					to_chat(user, "\blue Your skin feels icy to the touch.")
				if (!(M_XRAY in user.mutations))
					user.mutations.Add(M_XRAY)
					user.change_sight(adding = SEE_TURFS|SEE_MOBS|SEE_OBJS)
					user.see_in_dark = 8
					user.see_invisible = SEE_INVISIBLE_LEVEL_TWO
					to_chat(user, "\blue The walls suddenly disappear.")
				shadowize(user)
			if("Wealth")
				new /obj/structure/closet/syndicate/resources/everything(loc)
				shadowize(user)
			if("Immortality")
				user.add_spell(new /spell/changeling/regenerate/wishgranter)
				shadowize(user)
			if("Peace")
				to_chat(user, "<B>Whatever alien sentience that the Wish Granter possesses is satisfied with your wish. There is a distant wailing as the last of the Faithless begin to die, then silence.</B>")
				to_chat(user, "You feel as if you just narrowly avoided a terrible fate...")
				for(var/mob/living/simple_animal/hostile/faithless/F in mob_list)
					F.health = -10
					F.stat = 2
					F.icon_state = "faithless_dead"

/obj/machinery/wish_granter_dark/proc/shadowize(mob/living/carbon/human/user)
	to_chat(user, "<B>Your wish is granted, but at a terrible cost...</B>")
	to_chat(user, "The Wish Granter punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart.")
	user.dna.mutantrace = "shadow"
	user.update_mutantrace()


///////////////Meatgrinder//////////////


/obj/effect/meatgrinder
	name = "Meat Grinder"
	desc = "What is that thing?"
	density = 1
	anchored = 1
	icon = 'icons/mob/critter.dmi'
	icon_state = "blob"

/obj/effect/meatgrinder/Crossed(atom/movable/AM)
	Bumped(AM)

/obj/effect/meatgrinder/Bumped(mob/living/carbon/M)
	if(istype(M))
		visible_message("<span class='red'>[M] triggered the [bicon(src)] [src]</span>")
		spark(src)
		explosion(M, 1, 0, 0, 0)
		qdel(src)


/////For the Wishgranter///////////

/spell/changeling/regenerate/wishgranter
	name = "Immortality"
	desc = "I will rise again from death."
	abbreviation = "RSWG"
	chemcost = 0

/spell/changeling/regenerate/wishgranter/cast_check(skipcharge = 0, var/mob/user = usr)
	if(M_HUSK in user.mutations)
		to_chat(user, "<span class='warning'>There is not enough left to regenerate.</span>")
		return FALSE
	if(inuse)
		return FALSE
	return TRUE

///Spells
/mob/living/proc/mountup()
	for(var/spell/mountup/M in spell_list)
		M.cast(src,src)
		return

/spell/mountup
	name = "Mount Up"
	desc = "Mount a steed."
	charge_max = 0
	spell_flags = 0
	cast_delay = 2 SECONDS
	var/obj/effect/overlay/my_overlay
	var/active = FALSE
	var/remembered_speed

/spell/mountup/New()
	..()
	my_overlay = new /obj/effect/overlay/horsebroom_mount

/spell/mountup/choose_targets(var/mob/user = usr)
	return list(user)

/spell/mountup/cast(var/list/targets, var/mob/user)
	if(!active)
		var/choosefile = pick('sound/items/jinglebell1.ogg','sound/items/jinglebell2.ogg','sound/items/jinglebell3.ogg')
		playsound(user, choosefile, 100, 1)
		user.register_event(/event/damaged, src, .proc/dismount)
		user.overlays.Add(my_overlay)
		active = TRUE
		if(istype(user,/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = user
			remembered_speed = SA.speed
			SA.speed = max(0.6, SA.speed-0.4)
	else
		dismount()

/spell/mountup/proc/dismount(kind, amount)
	var/mob/living/user = src.holder
	playsound(user, 'sound/voice/cow.ogg', 100, 1)
	user.overlays.Remove(my_overlay)
	user.unregister_event(/event/damaged, src, .proc/dismount)
	active = FALSE
	if(istype(user,/mob/living/simple_animal))
		var/mob/living/simple_animal/SA = user
		SA.speed = remembered_speed

/obj/effect/overlay/horsebroom_mount
	name = "steed"
	icon = 'icons/mob/in-hand/left/items_lefthand.dmi'
	icon_state = "horsebroom0"
	layer = VEHICLE_LAYER
	plane = ABOVE_HUMAN_PLANE
	mouse_opacity = 0
	pixel_x = 0
	pixel_y = 0


//Mobs
///CIVIL WESTERNERS
///Members of Old Zounds

/mob/living/simple_animal/hostile/humanoid/civilwest
	faction = "oldzounds"
	icon = 'icons/mob/western_mobs.dmi'
	var/list/reporting_murderers = list()

/mob/living/simple_animal/hostile/humanoid/civilwest/CanAttack(atom/A)
	if(!..())
		return 0
	if(faction != "oldzounds")
		return 0 //All bets are off, not so civil anymore.
	if(ismob(A))
		if(ishuman(A)) //If the target is human, don't attack if they're wearing a badge or if the mayor is dead
			var/mob/living/carbon/human/H = A
			if(H.is_wearing_item(/obj/item/weapon/card/id/deputy))
				return 0
			var/datum/map_element/away_mission/wildwest/W = get_away_mission(WESTERN)
			if(W.flags & WILDWEST_MAYORDEAD)
				return 0
		var/mob/living/L = A //If the target is neutral, ignore it unless it has attacked us.
		if(L.faction == "neutral" && !(L in reporting_murderers))
			return 0
	return 1

/mob/living/simple_animal/hostile/humanoid/civilwest/assaulted_by(mob/M, weak_assault=FALSE)
	..()
	if(faction != "oldzounds")
		return //We're not part of society anymore
	if(!(M in reporting_murderers))
		reporting_murderers += M
	sleep(5 MINUTES)
	if(!stat)
		reporting_murderers -= M

/mob/living/simple_animal/hostile/humanoid/civilwest/death(var/gibbed = FALSE)
	if(faction == "oldzounds")
		if(reporting_murderers.len > 0)
			var/datum/map_element/away_mission/wildwest/W = get_away_mission(WESTERN)
			if(W)
				for(var/entry in reporting_murderers)
					if(!(entry in W.wanted))
						W.wanted += entry

		for(var/mob/living/simple_animal/hostile/humanoid/civilwest/CW in view(src,7))
			CW.enrage(src)
	reporting_murderers.Cut()
	..()

/mob/living/simple_animal/hostile/humanoid/civilwest/proc/enrage(mob/nowdead)

/mob/living/simple_animal/hostile/humanoid/civilwest/prospector
	name = "prospector"
	desc = "A muscular mining man. He sets out to find claims before the rush."

	icon_state = "prospector"
	icon_living = "prospector"

	maxHealth = 140 // High health to accomodate lack of range
	health = 140
	melee_damage_lower = 10
	melee_damage_upper = 15 // Decent melee damage, but the stun is the real danger
	move_to_delay = 1.2

	items_to_drop = list(/obj/item/weapon/pickaxe)

	attacktext = "picks"
	attack_sound = 'sound/weapons/genhit1.ogg'

	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART

	corpse = /obj/effect/landmark/corpse/prospector

	speak = list("Thar's gold in them hills!.",
	"Ye caught me off guard! Not s'pposed to see me 'til further down the road.",
	"Care fer a game o' chance? Pick a Boulder 'n I'll break it. If it's gold... it's yers.",
	"Dag nab it... no gold.",
	"Where's that hound o' mine?!",
	"G-Gold?! I can smell it!",
	"G-G-Gold! I've struck gold!")
	speak_chance = 1

	var/goldrush = TRUE

/mob/living/simple_animal/hostile/humanoid/civilwest/prospector/Life()
	..()
	if(goldrush && (stance == HOSTILE_STANCE_ATTACK) && (get_dist(src,target) > 3) && !stat)
		say(pick("G-G-Gold rush!", "I'm rushin' in!", "G-Golden power!"))
		goldrush = FALSE
		for(var/i = 1 to 3)
			MoveToTarget()
			new /obj/item/stack/ore/gold(loc)

/mob/living/simple_animal/hostile/humanoid/civilwest/prospector/enrage(var/mob/living/nowdead)
	goldrush = TRUE
	move_to_delay = max(move_to_delay-0.2,0.6) //Can gain speed up to 3 times
	melee_damage_lower += 5
	melee_damage_upper += 5
	health = min(health+50,maxHealth)
	say(pick("Daaag nab it!", "Ye coward! That [nowdead.name] was defenseless!", "Dag nab it!"))

//Wow I hate that this thing has to be a humanoid for inheritance
/mob/living/simple_animal/hostile/humanoid/civilwest/bloodhound
	name = "bloodhound"
	icon = 'icons/mob/animal.dmi'
	icon_state = "pitbull"
	icon_living = "pitbull"
	icon_dead = "pitbull_dead"
	speak_chance = 20
	emote_hear = list("growls", "barks")
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"

	health = 40
	maxHealth = 40
	move_to_delay = 1.2
	melee_damage_lower = 8
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

/obj/effect/landmark/corpse/prospector
	name = "prospector"
	corpseuniform = /obj/item/clothing/under/rank/miner
	corpsegloves = /obj/item/clothing/gloves/black
	corpseshoes = /obj/item/clothing/shoes/black

/mob/living/simple_animal/hostile/humanoid/civilwest/gandydancer
	name = "gandy dancer"
	desc = "A platelayer, a stake driver, a railroad worker. Mind the hammer."
	icon_state = "swoleboy"
	items_to_drop = list(/obj/item/weapon/hammer)
	melee_damage_lower = 5
	melee_damage_upper = 35
	attack_sound = 'sound/items/hammer_strike.ogg'
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART
	maxHealth = 200 // High health to accomodate lack of range
	health = 200

/mob/living/simple_animal/hostile/humanoid/civilwest/gandydancer/get_unarmed_damage()
	var/swing = rand(5,35)
	if(swing>=20)
		visible_message("<span class='rose'>\The [src] winds up exceptionally high!</span>")
	else
		visible_message("<span class='rose'>\The [src] swings low, sweet chariot!</span>")

/mob/living/simple_animal/hostile/humanoid/civilwest/gandydancer/get_unarmed_damage_zone(mob/living/victim)
	return LIMB_HEAD

/mob/living/simple_animal/hostile/humanoid/civilwest/sheriff/deputy
	name = "deputy sheriff"
	desc = "An honest deputy, likely part of a posse. Courage is being scared to death and saddling up anyway!"
	projectiletype = /obj/item/projectile/bullet/fourtyfive //35 damage + 2 agony + 2 drowsy + 3 penetration; nasty
	icon_state = "cowboy_deputy"

/mob/living/simple_animal/hostile/humanoid/civilwest/sheriff/deputy/New()
	..()
	add_spell(new /spell/mountup, "gen_leap")

/mob/living/simple_animal/hostile/humanoid/civilwest/sheriff
	name = "sheriff"
	desc = "An elected official who keeps the peace. The giver of the people's law. Where the leather is scarred, there is a great story to tell."
	projectiletype = /obj/item/projectile/bullet //The ammotype of the Colt. 60 damage. Enough to kill anything that moves.
	icon_state = "cowboy_sheriff"
	retreat_distance = 0
	ranged = 1
	minimum_distance = 2
	var/ammo = 6

/mob/living/simple_animal/hostile/humanoid/civilwest/sheriff/Shoot(atom/target, atom/start, mob/user)
	if(!ammo)
		playsound(src, 'sound/weapons/empty.ogg', 100, 1)
		return
	..()
	ammo--
	if(!ammo)
		retreat_distance = 6
		begin_reload()

/mob/living/simple_animal/hostile/humanoid/civilwest/sheriff/proc/begin_reload()
	playsound(src, 'sound/weapons/revolver_spin.ogg', 50, 1)
	sleep(6 SECONDS)
	playsound(src, 'sound/weapons/revolver_cock.ogg', 50, 1)
	retreat_distance = 0
	ammo = 6

/mob/living/simple_animal/hostile/humanoid/civilwest/butcher
	icon_state = "chuckwagon_cook"

/mob/living/simple_animal/hostile/humanoid/civilwest/flee/bartender
	icon_state = "saloon_tender"

/mob/living/simple_animal/hostile/humanoid/civilwest/flee/banker
	icon_state = "bank_teller"

/mob/living/simple_animal/hostile/humanoid/civilwest/flee/dancer
	icon_state = "saloon_woman"

/mob/living/simple_animal/hostile/humanoid/civilwest/clownboy
	icon_state = "clownboy_baton"

/mob/living/simple_animal/hostile/humanoid/civilwest/clownboy/ranged
	icon_state = "clownboy_banana"

/mob/living/simple_animal/hostile/humanoid/civilwest/cowboy
	icon_state = "cowboy_whip"

//UNCIVIL WESTERNERS
//Enemies of Old Zounds. They won't report on murders, but they won't have mercy for badged players.

/mob/living/simple_animal/hostile/bull
	name = "bull"
	desc = "That's bull."
	icon = 'icons/mob/western_mobs.dmi'
	icon_state = "bull"
	icon_dead = "bull_dead"

/mob/living/simple_animal/hostile/bull/arena

/mob/living/simple_animal/hostile/bull/muerte
	faction = "muerte"

/mob/living/simple_animal/hostile/humanoid/dastard
	name = "dastardly cowboy" //desc is a nod to Angel Eyes from G+B+U and Calvera from M7
	desc = "This villainous gunslinger doesn't give one lick about you or your shiny badge. People with ropes around their necks don't always hang, and sooner or later you must answer for every good deed."

	icon = 'icons/mob/western_mobs.dmi'
	icon_state = "dastardly_cowboy"

	faction = "dastards"

	health = 100
	maxHealth = 100
	move_to_delay = 1.4

	stat_attack = 1 //Evil
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG | OPEN_DOOR_SMART

	corpse = /obj/effect/landmark/corpse //gotta remember to add these

	items_to_drop = list(/obj/item/weapon/gun/projectile/shotgun/pump/combat, /obj/item/cannonball/fuse_bomb)

	speak = list("New wall. Won't keep me out!", "A man like you... why?", "Now, to business! I could kill you all.",
	"What if you had to carry my load?", "You’re smart enough to know that talking won't save you.",
	"The war's over for you.", "When I'm paid, I always follow my job through.")
	speak_chance = 1

	projectiletype = /obj/item/projectile/bullet/buckshot
	projectilesound = 'sound/weapons/shotgun.ogg'
	ranged = 1
	minimum_distance = 2

/mob/living/simple_animal/hostile/humanoid/dastard/New()
	..()
	add_spell(new /spell/mountup, "gen_leap")

/mob/living/simple_animal/hostile/humanoid/dastard/Shoot(atom/target, atom/start, mob/user)
	if(prob(15)) // Throw a bomb
		visible_message("<span class = 'warning'>\The [src] hoists his own petard at \the [target]!</span>")
		var/obj/item/cannonball/fuse_bomb/B = new /obj/item/cannonball/fuse_bomb(get_turf(src))
		B.throw_at(target,10,2)
		B.seconds_left = 2
		B.lit(src)
	else // Otherwise just fire the shotgun
		..()

/mob/living/simple_animal/hostile/humanoid/syndicate/ranged/spaceboy
	name = "space cowboy"
	desc = "Wait, space is on the INSIDE? Always has been."
	icon = 'icons/mob/western_mobs.dmi'
	icon_state = "space_cowboy"
	icon_living = "space_cowboy"
	faction = "russian" //allied to space bears
	items_to_drop = list(/obj/item/organ/internal/eyes/adv_1)

/mob/living/simple_animal/hostile/humanoid/syndicate/ranged/spaceboy/death(gibbed = FALSE)
	visible_message("<span class='average'>Behind his mask, you can almost see \the [src] smiling. Just before he collapses, he shapes his hand into a finger pistol and gives you one last gesture. See you, space cowboy.</span>")
	..()

/mob/living/simple_animal/hostile/humanoid/syndicate/ranged/spaceboy/Shoot(atom/target, atom/start, mob/user)
	..()
	if(prob(5))
		say("Bang...")

//Crypts

/mob/living/simple_animal/hostile/necro/skeleton/western
	name = "muerto de el tipo abstracto"
	faction = "muertos"
	icon = 'icons/mob/western_mobs.dmi'
	icon_state = ""

/mob/living/simple_animal/hostile/necro/skeleton/western/scythe
	name = "muerto ambulante"
	desc = "Incluso un simple peón de campo puede ser peligroso con la herramienta adecuada."
	icon_state = "elmuerto"
	melee_damage_lower = 15
	melee_damage_upper = 25
	attacktext = "slashes"
	attack_sound = "sound/weapons/bloodyslice.ogg"

/mob/living/simple_animal/hostile/necro/skeleton/western/scythe/caballero
	name = "muerto caballeroso"
	desc = "Incluso entre los muertos, prospera la rica tradición de la equitación."
	icon_state = "caballero_muerto"
	health = 130
	maxHealth = 130

/mob/living/simple_animal/hostile/necro/skeleton/western/scythe/caballero/New()
	..()
	add_spell(new /spell/mountup, "gen_leap")
	mountup()

/mob/living/simple_animal/hostile/necro/skeleton/western/scythe/caballero/LoseTarget()
	..()
	mountup()

/mob/living/simple_animal/hostile/necro/skeleton/western/heno
	name = "niño de heno"
	desc = "Cuando el municipio todavía era \"New Zounds\", la mayoría se ganaba la vida cultivando."
	icon_state = "elmuerto_2"
	speed = 3
	melee_damage_lower = 22
	melee_damage_upper = 32
	attacktext = "devours"
	attack_sound = "sound/weapons/bloodyslice.ogg"
	items_to_drop = list(/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)

/mob/living/simple_animal/hostile/necro/skeleton/western/heno/death(gibbed)
	..()
	qdel(src)

/mob/living/simple_animal/hostile/necro/skeleton/western/heno/enoch
	name = "Don Enoch"
	desc = "Cuando el municipio todavía era \"New Zounds\", Don Enoch supervisó la Cámara de Comercio."
	icon = 'icons/mob/giantmobs.dmi'
	icon_state = "enoch"
	icon_living = "enoch"
	attack_sound = 'sound/weapons/whip.ogg'
	move_to_delay = 20
	ranged = 1
	minimum_distance = 3
	friendly = "greets"
	speed = 4
	maxHealth = 500
	health = 500
	harm_intent_damage = 0
	melee_damage_lower = 5 //Doesn't hit very hard in melee
	melee_damage_upper = 7
	ranged_cooldown_cap = 6
	minimum_shot_distance = 0 //Enoch will always fire his tentacle attack if off cooldown
	attacktext = "flagellates"
	size = SIZE_HUGE
	items_to_drop = list(/obj/item/weapon/reagent_containers/food/snacks/grown/wheat,/obj/item/weapon/reagent_containers/food/snacks/grown/wheat,/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)
	status_flags = UNPACIFIABLE

/mob/living/simple_animal/hostile/necro/skeleton/western/heno/enoch/OpenFire(atom/ttarget)
	var/tturf = get_turf(ttarget)
	if(!istype(tturf, /turf/space) && istype(ttarget))
		visible_message("<span class='warning'>\The [src] sprouts wheat from below \the [ttarget]!</span>")
		playsound(loc, 'sound/weapons/whip.ogg', 50, 1, -1)
		new /obj/effect/goliath_tentacle/original/enoch(tturf)
		ranged_cooldown = ranged_cooldown_cap

/mob/living/simple_animal/hostile/necro/skeleton/western/heno/enoch/attackby(mob/user, obj/item/I)
	..()
	ranged_cooldown_cap--
	//Cooldown faster when being melee attacked

/mob/living/simple_animal/hostile/necro/skeleton/western/heno/enoch/AfterIdle()
	say("Now let me get this straight... you come to our town, you trample our crops, you interrupt our private engagement, and now you wanna leave?")
	say(pick("It saddens me that you don't wish to stay here with us.", "By the authority of the New Zounds Chamber of Commerce, I sentence you to die.", "I find you guilty of trespassing, destruction of property, disturbing the peace, and murder."))

/obj/effect/goliath_tentacle/original/enoch
	name = "Enoch roots"
	icon = 'icons/mob/western_mobs.dmi'
	icon_state = "enoch_tentacle"
	trip_delay = 1.5 SECONDS
	spread_dirs = 2
	//Enoch's tentacles come more often than a goliaths (25%), and trip faster (25%), but spread 1 less direction (100% higher dodge)

/mob/living/simple_animal/hostile/necro/skeleton/western/juergista
	name = "juergista de la muerte"
	desc = "Hay quienes no temen a la muerte, pero le dan la bienvenida. Ellos festejan incluso ahora."
	icon_state = "juergista"

/mob/living/simple_animal/hostile/necro/skeleton/western/bandito
	name = "bandito muerte"
	desc = "Se desconoce el propósito de su robo, porque dejan objetos de valor en el polvo."
	icon_state = "bandito_muerto"

/mob/living/simple_animal/hostile/necro/skeleton/western/matador
	name = "El Matador de Toros"
	desc = "Cuando se olvidó el nombre de \"New Zounds\", los tres toreros se fueron por caminos separados. El matador de toros se fue al norte, donde ganó seguidores entre los recién llegados."
	icon_state = "matador_blue"

/mob/living/simple_animal/hostile/necro/skeleton/western/banderillo
	name = "El Banderillo Misterioso"
	desc = "Hubo un tiempo en que la bandera de \"New Zounds\" se posaba en el lomo de todo toro desde aquí hasta el horizonte. Se dice que esta tarea la cumplió un banderillero sin nombre."
	icon_state = "matador_cape"

/mob/living/simple_animal/hostile/necro/skeleton/western/picador
	name = "El Picador Pedido"
	desc = "En el desierto, hay un picador que una vez usó su lanza para un trío de toreros. Sin embargo, las arenas secas han dejado al descubierto sus recuerdos."
	icon_state = "matador_capeless"

//Refinery
/mob/living/simple_animal/hostile/hivebot/refinery
	name = "refinery robot"
	desc = "A robot specialized for traction on conveyor belts. This one seems to be malfunctioning."
	icon = 'icons/mob/robots.dmi'
	icon_state = "engibot"
	health = 65
	maxHealth = 65
	speed = 1.6
	melee_damage_lower = 2
	melee_damage_upper = 3
	faction = "oldzounds"

/mob/living/simple_animal/hostile/hivebot/refinery/New()
	..()
	icon_living = pick("engibot","minerbot","robot_old",)
	icon_state = icon_living
	icon_dead = "gib[pick(1,2,3,4,5,6,7)]"

/mob/living/simple_animal/hostile/hivebot/refinery/convey(obj/machinery/conveyor/C)
	return FALSE //cannot be moved by conveyors

/mob/living/simple_animal/hostile/hivebot/refinery/get_unarmed_damage()
	var/damage = rand(melee_damage_lower, melee_damage_upper)
	visible_message("<span class='rose'>[src] optimizes!</span>")

	melee_damage_upper += melee_damage_lower //increase our cap by the last lowest possibility
	melee_damage_lower = damage //We'll never deal less again
	return damage