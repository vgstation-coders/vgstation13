//This file contains some basic rules so that changing them in one place changes them everywhere.

var/rc_basic_dash = "<b>Dash</b>: Move an extra 2."
var/rc_basic_drag = "<b>Drag</b>: Start dragging a friendly character. They will move along your path, directly behind you, until end of turn. If you move back, you swap positions. You can only drag one person a time."
var/rc_basic_pill = "<b>Pill</b>: Take a pill or feed a pill to an adjacent friendly, if you have one. When you take a pill, you get 6 blood. You start every battle with 0 pills and can hold no more than 3."

var/rc_miner_armor = "<b>Basilisk-skin Armor</b>: Free. Whenever you would lose blood, reduce that by 3."
var/rc_miner_shoot = "<b>Kinetic Accelerator</b>: 1 action. Shoot an enemy in range 3. Deal 1d6 damage."
var/rc_miner_drill = "<b>Diamond Drill</b>: 1 action. Move up to 3 spaces, but you may destroy walls and obstacles with this movement."

var/rc_miner_jaunt = "<b>Jaunter</b>: 1 action. Teleport somewhere in range 3. This ignores normal movement rules. After you arrive, Deal 1 damage to enemies in range 1."
var/rc_miner_butcher = "<b>Butcher</b>: Free. When you kill an enemy that isn't a Swarm, you get a pill."
var/rc_miner_hookshot = "<b>Hookshot</b>: 1 action. Force a character in range 3 to move in a straight line toward you until blocked. If it's an enemy, deal 1d6. If it's an ally, you can Drag them for free."
var/rc_miner_bodyblock = "<b>Bodyblock</b>: 2 offturn. If a friendly in range 2 would take damage, you can move 1 toward that character and take the damage instead. You may swap positions if adjacent."

var/rc_para_roller = "<b>Rollerbed</b>: Free. Your first Drag per turn costs no action."
var/rc_para_grenade = "<b>H2OK Grenade</b>: 1 action. Target a space in range 3. All spaces within range 1 of that location take 1d4+1 damage."
var/rc_para_hyperzine = "<b>Hyperzine Spray</b>: 1 action. A friendly (including self) in range 3 can immediately move 3, ignoring movement restrictions."

var/rc_para_hypospray = "<b>Hypospray</b>: 1 action. An adjacent friendly character gains 1d4+1 blood. If they started at 12 or less blood, they get a pill too."
var/rc_para_cauterize = "<b>Cauterize</b>: 1 action. All enemies in range 1 take 1d4+1 damage. All friendlies in range 1 (including self) get a pill and stop bleeding."
var/rc_para_pillpop = "<b>Pill Popper</b>: Free. Your first Pill a turn costs no action."
var/rc_para_wildride = "<b>Wild Ride</b>: 2 offturn. If a friendly ends their movement adjacent to you, they can immediately move 3 ignoring movement restrictions."

var/rc_anom_touched = "<b>Touched</b>: When you move, it can be diagonal. When you dash, move 4."
var/rc_anom_roulette = "<b>Roulette Revolver</b>: 1 action. Shoot an enemy in range 3. Deal 1d12 damage, then place two small artifacts on the map anywhere."
var/rc_anom_excav = "<b>Excavation</b>: Free. When you end any movement within 1 range of a small artifact, you can remove it from the map and deal 3 damage to a the nearest enemy (foe's choice if tied) within 3 range of the artifact."

var/rc_anom_phase = "<b>Phase Out Anomaly</b>: 2 offturn. If you get attacked, roll any die. If the result is even, the attack is completely negated."
var/rc_anom_parts = "<b>Suspicious Metal Parts</b>: Free. Your Roulette Revolver deals 2d12 instead."
var/rc_anom_happymask = "<b>Happiest Mask</b>: Free. You don't bleed. You don't go unconscious at 0 blood, but you still die at -6."
var/rc_anom_large = "<b>Large Artifact</b>: Free. When you excavate an artifact, roll 1d4. If it's a 4, deal 3 damage to all enemies instead of just your target. Otherwise, add your roll to the excavate damage."

var/rc_eng_gloves = "<b>Stun Gloves</b>: Free. It doesn't cost an extra movement for you when adjacent to an enemy."
var/rc_eng_emitter = "<b>Emitter</b>: Pick an entire row or column of the map. All characters in that area take 1d8 damage."
var/rc_eng_flamethrower = "<b>Dodgy Flamethrower</b>: Deal 1d8+2 damage to an enemy that is 4 or more away from you."

var/rc_eng_rcd = "<b>RCD</b>: 1 action. Build three impassible obstacles in range 3."
var/rc_eng_jetpack = "<b>Jetpack</b>: Free. Your first Dash each turn costs no action."
var/rc_eng_recharger = "<b>Recharger</b>: 1 action. A friendly that is 4 or more away from you can take one of their normal actions immediately."
var/rc_eng_supermatter = "<b>Supermatter Chunk</b>: Free. Lose 6 blood. Your emitter deals 2d8+2 damage instead this turn."

//Manual
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
<p>Red Core uses team-based turns. A team elects one piece to take a turn, then the other team does so. This continues until all pieces have taken a turn. Each round, the order of pieces within a team can change.
<p>Please <b>Bug Report</b> feedback for the 2nd Edition!
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

<h3>Range</h3>
<p>Unlike movement, range can be diagonal. However, "adjacent" means orthogonal only.
<p>Even if there's an obstruction, you can shoot through it. Walls only block movement.

<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Gibtonite ore"))]' style='position: relative; top: 8;'><a id="Actions">Actions</h2>
<p>You get two actions a turn. Everyone can do the actions listed here, but there are also actions that each job can do. <b>You start with BASICS of your job and ONE unlockable.</b>
<p><i>You can't use the same action twice in a turn.</i>
<p>[rc_basic_dash]
<p>[rc_basic_drag]
<p>[rc_basic_pill]

<h3>Offturn</h3>
<p>You might get an action that has an "Offturn" cost instead of an action cost. It will say how many times you can use it between your turns.

<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Adamantine ore"))]' style='position: relative; top: 8;'><a id="Miner">Shaft Miner</h2>
<h3>Basics</h3>
<p>[rc_miner_armor]
<p>[rc_miner_shoot]
<p>[rc_miner_drill]
<h3>Unlockables</h3>
<p>[rc_miner_jaunt]
<p>[rc_miner_butcher]
<p>[rc_miner_hookshot]
<p>[rc_miner_bodyblock]
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Diamond ore"))]' style='position: relative; top: 8;'><a id="Para">Paramedic</h2>
<p>[rc_para_roller]
<p>[rc_para_grenade]
<p>[rc_para_hyperzine]
<h3>Unlockables</h3>
<p>[rc_para_cauterize]
<p>[rc_para_hypospray]
<p>[rc_para_pillpop]
<p>[rc_para_wildride]
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Plasma ore"))]' style='position: relative; top: 8;'><a id="Anom">Anomalist</h2>
<p>[rc_anom_touched]
<p>[rc_anom_roulette]
<p>[rc_anom_excav]
<h3>Unlockables</h3>
<p>[rc_anom_phase]
<p>[rc_anom_parts]
<p>[rc_anom_happymask]
<p>[rc_anom_large]
<h2><img src='data:image/png;base64,[icon2base64(icon('icons/obj/mining.dmi', "Gold ore"))]' style='position: relative; top: 8;'><a id="Eng">Engineer</h2>
<p>[rc_eng_gloves]
<p>[rc_eng_emitter]
<p>[rc_eng_flamethrower]
<h3>Unlockables</h3>
<p>[rc_eng_rcd]
<p>[rc_eng_jetpack]
<p>[rc_eng_recharger]
<p>[rc_eng_supermatter]
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
<p>The battle mat should be used on a big table, at least two-by-two. Most libraries contain a good one.
<p>Next edition is expected to include new game master tools and new monsters!
</body>
</html>"}

