/obj/item/dicetower
	name = "dice tower"
	desc = "A tower you can place or throw dice into to ensure a fair roll."
	icon = 'icons/obj/library.dmi'
	icon_state = "dicetower"
	w_class = W_CLASS_MEDIUM
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10
	layer = MACHINERY_LAYER

/obj/item/dicetower/attack_hand(mob/user)
	if(locate(/obj/item/weapon/dice) in contents)
		tower(user)
	else
		..()

/obj/item/dicetower/attackby(obj/item/O, mob/user)
	if(istype(O,/obj/item/weapon/dice))
		user.drop_item(O,src)
		tower(user)
	else
		..()

/obj/item/dicetower/Crossed(atom/movable/mover)
	if(istype(mover,/obj/item/weapon/dice) && mover.throwing) //Dice should always impact
		mover.forceMove(src)
		tower(usr)

/obj/item/dicetower/proc/tower(mob/user)
	playsound(src, 'sound/weapons/dicetower.ogg', 50, 1)
	shake(1,2)
	sleep(4)
	for(var/obj/item/weapon/dice/D in contents)
		D.result = rand(D.minsides, D.sides)
		D.update_icon()
		if(istype(D,/obj/item/weapon/dice/fudge))
			var/obj/item/weapon/dice/fudge/FD = D
			visible_message("<span class='notice'>[user] rolled a [FD.result_names[D.result]] in \the [src]!</span>")
		else
			visible_message("<span class='notice'>[user] rolled a [D.result] in \the [src]!</span>")
		D.forceMove(get_turf(loc))

/obj/item/toy/gamepiece
	icon = 'icons/obj/toy.dmi'
	w_class = W_CLASS_TINY

/obj/item/toy/gamepiece/miner
	name = "Red Core player gamepiece"
	desc = "Use it to change the class."
	icon_state = "miner_gamepiece"

/obj/item/toy/gamepiece/miner/attack_self(mob/user)
	var/list/choices = list("Shaft Miner", "Paramedic", "Anomalist", "Engineer")
	var/choice = input("Which class?") in choices
	switch(choice)
		if("Shaft Miner")
			icon_state = "miner_gamepiece"
		if("Paramedic")
			icon_state = "para_gamepiece"
		if("Anomalist")
			icon_state = "anom_gamepiece"
		if("Engineer")
			icon_state = "eng_gamepiece"

/obj/item/toy/gamepiece/hivelord
	name = "hivelord gamepiece"
	desc = "A beating heart manifest."
	icon_state = "hivelord_gamepiece"

/obj/item/toy/gamepiece/brood
	name = "brood gamepiece"
	desc = "The endless horde."
	icon_state = "brood_gamepiece"

/obj/item/weapon/storage/box/redcore
	name = "gamepiece box"
	desc = "A box containing game pieces for a tabletop game called Red Core."
	fits_max_w_class = W_CLASS_TINY
	storage_slots = 21
	items_to_spawn = list(
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/miner,
		/obj/item/toy/gamepiece/hivelord,
		/obj/item/toy/gamepiece/hivelord,
		/obj/item/toy/gamepiece/hivelord,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/toy/gamepiece/brood,
		/obj/item/weapon/book/manual/redcore1,
		/obj/item/weapon/paper/redcore/miner)

/obj/item/weapon/book/manual/redcore1	//edit with https://www.w3schools.com/html/tryit.asp?filename=tryhtml_default
	name = "Red Core, First Edition"
	desc = "A manual for a tabletop war game."
	icon_state = "bookAntagGuide"
	item_state = "bookAntagGuide"
	author = "Gary Durand"
	title = "Red Core, First Edition"
	id = 1974
	book_width = 692

/obj/item/weapon/book/manual/redcore1/New()
	..()
	dat = {"<html>
			<head>
			<style>
			h1 {font-size: 32px; margin: 15px 0px 5px;color:#F7D61A;background-color: #990000;}
			h2 {font-size: 24px; margin: 15px 0px 5px;color:#F7D61A;background-color: #990000;}
			h3 {font-size: 18px; margin: 15px 0px 5px;}
			li {margin: 2px 0px 2px 15px;}
			ul {list-style: none; margin: 5px; padding: 0px;}
			ol {margin: 5px; padding: 0px 15px;}
			p  {text-indent: 25;}
			a:link {color: #F7D61A; background-color: transparent; text-decoration: none;}
			a:visited {color: #F7D61A; background-color: transparent; text-decoration: none;}
			</style>
			</head>
			<body style="font-size: 18px;color:#F7D61A;background-color:#221111;">

<h1><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "nano-logo"))]' style='position: relative; top: 6;'>Red Core 1st Edition<img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "nano-logo"))]' style='position: relative; top: 6;'></h1>
<h2>What is this?</h2>
<p>Red Core is a tabletop tactical roleplaying game. One player takes on the role of game master to control enemies, and players take on the role of brave miners in search of precious phazon. There are four roles: the <b>Shaft Miner</b> who grapples up close, the <b>Paramedic</b> who keeps the squad alive, the <b>Anomalist</b> that searches for deadly artifacts, and the <b>Engineer</b> that supports from afar.
<p>Red Core uses team-based turns. A team elects one piece to take a turn, then the other team does so. This continues until all pieces have taken a turn. Each round, the order can change.
<h2>Chapters</h2>

<ol>
<li><a href="#Blood">Blood</a></li>
<li><a href="#Movement">Movement</a></li>
<li><a href="#Actions">Actions</a></li>
<ol>
<li><a href="#Miner">Shaft Miner</a></li>
<li><a href="#Para">Paramedic</a></li>
<li><a href="#Anom">Anomalist</a></li>
<li><a href="#Eng">Engineer</a></li>
</ol>
<li><a href="#GM">Game Master</a></li>
<ol>
<li><a href="#Enemies">Creatures</a></li>
<li><a href="#Grid">Battle Mat</a></li>
</ol>
</li>
</ol>


<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "claretine"))]' style='position: relative; top: 8;'><a id="Blood">Blood</h2>

<p>You lose blood when you take damage. You have 24 blood at most. If you drop to 0 blood, you fall unconscious. If you drop to -6, you die.
<p>Sometimes you might be <b>Bleeding</b>. If so, you roll a d4 at the end of each turn and lose that much blood. If you roll a 1, stop bleeding afterward.

<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/clothing/shoes.dmi', "magboots1"))]' style='position: relative; top: 8;'><a id="Movement">Movement and Range</h2>
<p>Red Core is meant to be played on a square grid. You get to move 4 spaces on your turn. You can't break up movement to take actions, but you can move less than your maximum movement or take an action before moving. You can only move orthagonally (not diagonal) unless you are the Anomalist. You can move through friendly characters, but not enemies. You can't end a turn in the same space as any other character.

<h3>Slower Movement</h3>
<p>If you're adjacent (orthagonally) to an enemy, your next move costs one more.
<p>If you go up a Z-level, that move costs one more per level.

<h3>Range</h3>
<p>Unlike movement, range can be diagonal. However, "adjacent" means orthogonal only.
<p>If you're on higher ground than your enemy, when you roll damage you can roll twice and take the better result.

<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Gibtonite ore"))]' style='position: relative; top: 8;'><a id="Actions">Actions</h2>
<p>You get two actions a turn. Everyone can do the actions listed here, but there are also actions that each job can do. <b>You start with BASICS of your job and ONE unlockable.</b>
<p><i>You can't use the same action twice in a turn.</i>
<p>Dash: Move an extra 2. If you're the Anomalist, up to 4.
<p>Drag: Start dragging a friendly character. They will move along your path, directly behind you, until end of turn. You can't move into someone's space while dragging them.
<p>Pill: Take a pill or give a pill to an adjacent friendly, if you have one. When you take a pill, you get 6 blood. You start every battle with 0 pills and can hold no more than 3.

<h3>Offturn</h3>
<p>You might get an action that has an "Offturn" cost instead of an action cost. It will say how many times you can use it between your turns.

<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Adamantine ore"))]' style='position: relative; top: 8;'><a id="Miner">Shaft Miner</h2>
<h3>Basics</h3>
<p>Basilisk-skin Armor: Free. Whenever you would lose blood, reduce that by 3.
<p>Kinetic Accelerator: 1 action. Shoot an enemy in range 3. Deal 1d6 damage.
<p>Driller: 1 action. Move up to 3.following normal movement rules. If you would go up a z-level, the ground becomes level with where you started this action instead.
<h3>Unlockables</h3>
<p>Jaunter: 1 action. Teleport somewhere in range 3. This ignores normal movement rules. After you arrive, Deal 1 damage to enemies in range 1.
<p>Butcher: Free. When you kill an enemy that isn't a Swarm, you get a pill.
<p>Hookshot: 1 action. Force an enemy in range 3 to move in a straight line toward you then deal 1d6. It stops if there's another creature blocking it.
<p>Bodyblock: 2 offturn. If a friendly in range 2 would take damage, you can move 1 toward that character and take the damage instead. You may swap positions if adjacent.
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Diamond ore"))]' style='position: relative; top: 8;'><a id="Para">Paramedic</h2>
<p>Rollerbed: Free. Your first Drag per turn costs no action.
<p>H2OK Grenade: 1 action. Target a space in range 3. All spaces within range 1 of that location take 1d4+1 damage.
<p>Hyperzine Spray: 1 action. A friendly (including self) in range 3 can immediately move 3, ignoring movement restrictions.
<h3>Unlockables</h3>
<p>Cauterize: 1 action. All enemies in range 1 take 1d4+1 damage. All friendlies in range 1 (including self) get a pill and stop bleeding.
<p>Hypospray: 1 action. An adjacent friendly character gains 1d4+1 blood. If they started at 12 or less blood, they get a pill too.
<p>Pill Popper: Free. Your first Pill a turn costs no action.
<p>Wild Ride: 2 offturn. If a friendly ends their movement adjacent to you, they can immediately move 3 ignoring movement restrictions.
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Plasma ore"))]' style='position: relative; top: 8;'><a id="Anom">Anomalist</h2>
<p>Touched: When you move, it can be diagonal. When you dash, move 4.
<p>Roulette Revolver: 1 action. Shoot an enemy in range 3. Deal 1d12 damage, then place two small artifacts on the map anywhere.
<p>Excavation: Free. When you end any movement within 1 range of a small artifact, you can remove it from the map and deal 3 damage to an enemy within 3 range of the artifact.
<h3>Unlockables</h3>
<p>Phase Out Anomaly: 2 offturn. If you get attacked, roll any die. If the result is even, the attack is completely negated.
<p>Suspicious Metal Parts: Free. Your Roulette Revolver deals 2d12 instead.
<p>Happiest Mask: Free. You don't bleed. You don't go unconscious at 0 blood, but you still die at -6.
<p>Large Artifact: Free. When you excavate an artifact, roll 1d4. If it's a 4, deal 3 damage to all enemies instead of just your target. Otherwise, add your roll to the excavate damage.
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Gold ore"))]' style='position: relative; top: 8;'><a id="Eng">Engineer</h2>
<p>Scrub Gloves: Free. It doesn't cost an extra movement for you when adjacent to an enemy.
<p>Emitter: Pick an entire row or column of the map. All characters in that area take 1d8 damage.
<p>Dodgy Flamethrower: Deal 1d8+2 damage to an enemy that is 4 or more away from you.
<h3>Unlockables</h3>
<p>RCD: 1 action. Build up the terrain by 1 Z-level in three spaces within range 3.
<p>Jetpack: Free. It costs no movement for you to go up a terrain level.
<p>Recharger: 1 action. A friendly that is 4 or more away from you can take one of their normal actions.
<p>Supermatter Chunk: Free. Lose 6 blood. Your emitter deals 2d8+2 damage instead this turn.
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Nanotrasite ore"))]' style='position: relative; top: 8;'><a id="GM">Game Master</h2>
<p>Red Core is primarily a tactics battle game, but there is space for roleplaying too. Consider how much story you want to involve in your game.
<h3>Rewards</h3>
<p>At the end of a battle, the group should find some amount of phazon. Consider 1 per hivelord defeated, or roll for it.
<h3>Trader</h3>
<p>The players should visit the trader between battles.
<p>New Gear: 1 phazon. All players gain an unlockable action. Can only buy this once per trader visit.
<p>Medicine: 1 phazon. All players gain 1 pill.
<p>Cloner: 1 phazon. Bring one player back from the dead.
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "xeno_warning"))]' style='position: relative; top: 8;'><a id="Enemies">Enemies</h2>
<p>Hivelord. Type: Normal. Blood: 24. Move: 4. Does not attack. Once per turn, create a Brood. If there are already three broods per hivelord, regain all blood.
<p>Brood. Type: Swarm. Blood: 3. Range: Adjacent. Move: 6. Attacks: Once per turn, deal 1d6. If it's 6, cause Bleeding.
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Glass ore"))]' style='position: relative; top: 8;'><a id="Grid">Battle Mat</h2>
<p>Grid spaces should be 6x6 pixels when painting. Keep your paint brush handy in case players change the terrain with abilities.
</body>
</html>"}

/obj/item/battlemat
	name = "battle mat"
	desc = "A big grid ideal for placing figurines. Place it on a table to unroll."
	icon = 'icons/obj/posters.dmi'
	icon_state = "rolled_poster"
	w_class = W_CLASS_MEDIUM
	layer = BELOW_OBJ_LAYER

/obj/item/battlemat/attackby(obj/item/W, mob/user, params)
	if(user.drop_item(W, src.loc))
		if(bound_width > WORLD_ICON_SIZE && W.loc == loc && params)
			W.setPixelOffsetsFromParams(params, user, pixel_x, pixel_y, FALSE)
			update_icon()
			return 1
	else
		..()

/obj/item/battlemat/update_icon()
	var/obj/O = locate(/obj/structure/table) in loc
	if(O)
		icon = 'icons/obj/objects_64x64.dmi'
		icon_state = "gamemat"
		bound_width = 2*WORLD_ICON_SIZE
		bound_height = 2*WORLD_ICON_SIZE
		switch(O.dir)
			if(NORTHEAST)
				pixel_x = 0
				pixel_y = 0
			if(SOUTHEAST)
				pixel_x = 0
				pixel_y = -32
			if(SOUTHWEST)
				pixel_x = -32
				pixel_y = -32
			if(NORTHWEST)
				pixel_x = -32
				pixel_y = 0
	else
		icon = 'icons/obj/posters.dmi'
		icon_state = "rolled_poster"
		bound_width = WORLD_ICON_SIZE
		bound_height = WORLD_ICON_SIZE

/obj/item/battlemat/pickup(mob/user as mob)
	..()
	update_icon()

/obj/item/battlemat/dropped(var/mob/user)
	..()
	update_icon()