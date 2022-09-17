
//lists used by both corgis and mannequins

var/list/valid_corgi_hats = list(
	/obj/item/clothing/head/collectable/tophat,
	/obj/item/clothing/head/that,
	/obj/item/clothing/head/collectable/paper,
	/obj/item/clothing/head/hardhat,
	/obj/item/clothing/head/collectable/hardhat,
	/obj/item/clothing/head/hardhat/white,
	/obj/item/clothing/head/helmet/tactical/sec,
	/obj/item/clothing/head/helmet/tactical/sec/preattached,
	/obj/item/clothing/head/helmet/tactical/swat,
	/obj/item/clothing/head/chefhat,
	/obj/item/clothing/head/collectable/chef,
	/obj/item/clothing/head/caphat,
	/obj/item/clothing/head/collectable/captain,
	/obj/item/clothing/head/cap,
	/obj/item/clothing/head/kitty,
	/obj/item/clothing/head/kitty/collectable,
	/obj/item/clothing/head/rabbitears,
	/obj/item/clothing/head/collectable/rabbitears,
	/obj/item/clothing/head/beret,
	/obj/item/clothing/head/collectable/beret,
	/obj/item/clothing/head/det_hat,
	/obj/item/clothing/head/nursehat,
	/obj/item/clothing/head/pirate,
	/obj/item/clothing/head/collectable/pirate,
	/obj/item/clothing/head/hgpiratecap,
	/obj/item/clothing/head/ushanka,
	/obj/item/clothing/head/collectable/police,
	/obj/item/clothing/head/wizard/fake,
	/obj/item/clothing/head/wizard,
	/obj/item/clothing/head/collectable/wizard,
	/obj/item/clothing/head/cardborg,
	/obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/head/christmas/santahat/red,
	/obj/item/clothing/head/soft,
	/obj/item/clothing/head/fedora,
	/obj/item/clothing/head/fez,
	/obj/item/clothing/head/helmet/space/rig,
	/obj/item/clothing/head/alien_antenna,
	/obj/item/clothing/head/franken_bolt,
	/obj/item/clothing/mask/vamp_fangs,
	/obj/item/clothing/head/cowboy,
	/obj/item/clothing/glasses/sunglasses,
	/obj/item/weapon/p_folded/hat,
	/obj/item/weapon/bedsheet,
	/obj/item/clothing/head/cowboy/sec,
	/obj/item/clothing/head/cap/cowboy,
	/obj/item/clothing/head/warden/cowboy,
	/obj/item/clothing/head/HoS/cowboy
	)


var/list/valid_corgi_backpacks = list(
	/obj/item/clothing/suit/armor/vest,
	/obj/item/clothing/suit/armor/vest/security,
	/obj/item/device/radio,
	/obj/item/device/radio/off,
	/obj/item/clothing/suit/cardborg,
	/obj/item/weapon/tank/oxygen,
	/obj/item/weapon/tank/air,
	/obj/item/weapon/extinguisher,
	/obj/item/clothing/suit/space/rig,
	)


/mob/living/simple_animal/corgi/proc/on_new_hat(obj/item/item_to_add)
	if (!item_to_add)
		return
	switch(item_to_add.type)
		if(/obj/item/clothing/head/helmet/tactical/sec,/obj/item/clothing/head/helmet/tactical/sec/preattached)
			name = "Sergeant [real_name]"
			desc = "The ever-loyal, the ever-vigilant."
			emote_see = list("ignores the chain of command.", "stuns you.")
			emote_hear = list("stops you right there, criminal scum!")

		if(/obj/item/clothing/head/helmet/tactical/swat)
			name = "Lieutenant [real_name]"
			desc = "When the going gets ruff..."
			emote_hear = list("goes dark.", "waits for his retirement tomorrow.")

		if(/obj/item/clothing/head/chefhat,	/obj/item/clothing/head/collectable/chef)
			name = "Sous chef [real_name]"
			desc = "Your food will be taste-tested.  All of it."
			emote_see = list("looks for the lamb sauce.", "eats the food.")
			emote_hear = list("complains that the meal is fucking raw!")

		if(/obj/item/clothing/head/caphat, /obj/item/clothing/head/collectable/captain, /obj/item/clothing/head/cap, /obj/item/clothing/head/cap/cowboy)
			name = "Captain [real_name]"
			desc = "Probably better than the last captain."
			emote_see = list("secures the spare.", "hides the nuke disk.", "abuses his authority.")
			emote_hear = list("assures the crew he is NOT a comdom.")

		if(/obj/item/clothing/head/kitty, /obj/item/clothing/head/kitty/collectable)
			name = "Runtime"
			desc = "It's a cute little kitty-cat! Well, he's definitely cute!"
			emote_see = list("coughs up a furball.", "stretches.")
			emote_hear = list("purrs.")
			speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS!", "MEEEEEEW!")

		if(/obj/item/clothing/head/rabbitears, /obj/item/clothing/head/collectable/rabbitears)
			name = "Hoppy"
			desc = "This is Hoppy. It's a corgi-er, bunny rabbit?"
			emote_see = list("twitches its nose.", "hops around a bit.", "eats a doggy carrot.", "jumps in place.")

		if(/obj/item/clothing/head/beret, /obj/item/clothing/head/collectable/beret)
			name = "Yann"
			desc = "Mon dieu! C'est un chien!"
			speak = list("le woof!", "le bark!", "JAPPE!!")
			emote_see = list("cowers in fear.", "surrenders.", "plays dead.","looks as though there is a wall in front of him.")

		if(/obj/item/clothing/head/det_hat)
			name = "Detective [real_name]"
			desc = "[name] sees through your lies..."
			emote_see = list("investigates the area.", "sniffs around for clues.", "searches for scooby snacks.")

		if(/obj/item/clothing/head/nursehat)
			name = "Nurse [real_name]"
			desc = "[name] needs 100cc of beef jerky... STAT!"
			emote_see = list("checks the crew monitoring console.", "stares, unblinking.", "tries to inject you with medicine... But fails!")
			emote_hear = list("asks you to max the suit sensors.")

		if(/obj/item/clothing/head/pirate, /obj/item/clothing/head/collectable/pirate, /obj/item/clothing/head/hgpiratecap)
			name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"
			desc = "Yaarghh! Thar' be a scurvy dog!"
			emote_see = list("hunts for treasure.","stares coldly...","gnashes his tiny corgi teeth.")
			emote_hear = list("growls ferociously.", "snarls.")
			speak = list("Arrrrgh!","Grrrrrr!")

		if(/obj/item/clothing/head/ushanka)
			name = "[pick("Tzar","Vladimir","Chairman")] [real_name]"
			desc = "A follower of Karl Barx."
			emote_see = list("contemplates the failings of the capitalist economic model.", "ponders the pros and cons of vangaurdism.", "plans out methods to equally redistribute capital.", "articulates an argument for the primacy of the bourgeoisie.", "develops an economic plan to industrialize the vast rural landscape.")

		if(/obj/item/clothing/head/collectable/police)
			name = "Officer [real_name]"
			emote_see = list("drools.", "looks for donuts.", "ignores Space Law.")
			desc = "Stop right there, criminal scum!"

		if(/obj/item/clothing/head/wizard/fake,	/obj/item/clothing/head/wizard,	/obj/item/clothing/head/collectable/wizard)
			name = "Grandwizard [real_name]"
			speak = list("Woof!", "Bark!", "EI NATH!", "FORTI GY AMA!")
			emote_see = list("casts a dastardly spell!", "curses you with a bark!", "summons a steak into his stomach.")

		if(/obj/item/clothing/head/cardborg)
			name = "Borgi"
			speak = list("Ping!","Beep!","Woof!")
			emote_see = list("goes rogue.", "sniffs out non-humans.", "waits for a malfunction.", "ignores law 2.", "gets EMP'd.", "doorcrushes you.")
			desc = "Result of robotics budget cuts."

		if(/obj/item/weapon/bedsheet)
			name = "\improper Ghost"
			speak = list("WoooOOOooo~","AuuuuuUuUuUuUuUuUuu~")
			emote_see = list("stumbles around.", "shivers.")
			emote_hear = list("howls.","groans.")
			desc = "Spooky!"

		if(/obj/item/clothing/head/helmet/space/santahat, /obj/item/clothing/head/christmas/santahat/red)
			name = "Santa's Corgi Helper"
			emote_hear = list("barks christmas songs.", "yaps merrily.")
			emote_see = list("looks for presents.", "checks his list.")
			desc = "He's very fond of milk and cookies."

		if(/obj/item/clothing/head/soft)
			name = "Corgi Tech [real_name]"
			desc = "The reason your yellow gloves have chew-marks."
			emote_see = list("orders emitter crates.", "declares independence from Nanotrasen.", "acquires insulated gloves.")

		if(/obj/item/clothing/head/fedora)
			name = "Autistic [real_name]"
			desc = "His paws seem to be covered in what looks like Cheezy Honker dust."
			emote_hear = list("barks ironically.", "makes you cringe.")
			emote_see = list("unsheathes katana.", "tips fedora.", "posts on Mongolian basket-weaving forums.", "theorycrafts about nothing.")

		if(/obj/item/clothing/head/fez)
			name = "Doctor Whom"
			desc = "A time-dog from the planet barkifray."
			emote_hear =  list("barks cleverly.")
			emote_see = list("fiddles around with a sonic-bone.", "evolves into a hotter version of himself! Er, nevermind.")

		if(/obj/item/clothing/head/helmet/space/rig)
			name = "Station Engineer [real_name]"
			desc = "Ian wanna cracker!"
			emote_see = list("scrungulooses.", "activates the SMES units.", "ignores engine safety.", "accidentally plasmafloods.", "delaminates the Supermatter.")
			min_oxy = 0
			minbodytemp = 0
			maxbodytemp = 999

		/*
		if(/obj/item/clothing/head/hardhat/reindeer)
			name = "[real_name] the red-nosed Corgi"
			emote_see = list("lights the way.", "illuminates the night sky.", "is bullied by the other reindogs. Poor Ian.")
			desc = "He has a very shiny nose."
			SetLuminosity(1)
		*/
		if(/obj/item/clothing/head/alien_antenna)
			name = "Al-Ian"
			desc = "Take us to your dog biscuits!"
			emote_see = list("drinks sulphuric acid.", "reads your mind.", "kidnaps your cattle.")

		if(/obj/item/clothing/head/franken_bolt)
			name = "Corgenstein's monster"
			desc = "If I cannot inspire love, I will cause fear! Now fetch me them doggy biscuits."

		if(/obj/item/clothing/mask/vamp_fangs)
			var/obj/item/clothing/mask/vamp_fangs/V = item_to_add
			if(!V.glowy_fangs)
				name = "Vlad the Ianpaler"
				desc = "Listen to them, the children of the night. What music they make!"
				emote_hear = list("bares his fangs.", "screeches.", "tries to suck some blood.")
			else
				to_chat(usr, "<span class = 'notice'>The glow of /the [V] startles [real_name]!</span>")

		if(/obj/item/clothing/head/cowboy)
			name = "Yeehaw [real_name]"
			desc = "Are you really just gonna stroll past without saying howdy?"
			emote_see = list("bullwhips you.", "spins his revolver.")
			emote_hear = list("complains about city folk.")

		if(/obj/item/clothing/head/cowboy/sec, /obj/item/clothing/head/HoS/cowboy, /obj/item/clothing/head/warden/cowboy)
			name = "Deputy [real_name]"
			desc = "He's your huckleberry."
			emote_see = list("bullwhips you.", "spins his revolver.")
			emote_hear = list("complains about city folk.")
