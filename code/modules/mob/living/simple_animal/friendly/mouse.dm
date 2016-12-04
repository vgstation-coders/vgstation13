/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeeks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	pass_flags = PASSTABLE
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	density = 0
	var/_color //brown, gray and white, leave blank for random
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	treadmill_speed = 0.2 //You can still do it, but you're not going to generate much power.

	size = SIZE_TINY
	holder_type = /obj/item/weapon/holder/animal/mouse

/mob/living/simple_animal/mouse/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << 'sound/effects/mousesqueek.ogg'

	if(!ckey && stat == CONSCIOUS && prob(0.5))
		stat = UNCONSCIOUS
		icon_state = "mouse_[_color]_sleep"
		wander = 0
		speak_chance = 0
		//snuffles
	else if(stat == UNCONSCIOUS)
		if(ckey || prob(1))
			stat = CONSCIOUS
			icon_state = "mouse_[_color]"
			wander = 1
		else if(prob(5))
			emote("snuffles")

/mob/living/simple_animal/mouse/New()
	..()
	if(config && config.uneducated_mice)
		universal_understand = 0
	// Mice IDs
	if(name == initial(name))
		name = "[name] ([rand(1, 1000)])"
	real_name = name
	if(!_color)
		_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[_color]"
	icon_living = "mouse_[_color]"
	icon_dead = "mouse_[_color]_dead"
	desc = "It's a small [_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."
	add_language(LANGUAGE_MOUSE)
	default_language = all_languages[LANGUAGE_MOUSE]


/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.stat = DEAD
	src.icon_dead = "mouse_[_color]_splat"
	src.icon_state = "mouse_[_color]_splat"
	if(client)
		client.time_died_as_mouse = world.time

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Object"

	if(isUnconscious())
		return

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("<B>[] scurries to the ground!</B>", src))
		*/
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("[] slowly peaks up from the ground...", src))
		*/

//make mice fit under tables etc? this was hacky, and not working
/*
/mob/living/simple_animal/mouse/Move(var/dir)

	var/turf/target_turf = get_step(src,dir)
	//CanReachThrough(src.loc, target_turf, src)
	var/can_fit_under = 0
	if(target_turf.ZCross(get_turf(src),1))
		can_fit_under = 1

	..(dir)
	if(can_fit_under)
		src.forceMove(target_turf)
	for(var/d in cardinal)
		var/turf/O = get_step(T,d)
		//Simple pass check.
		if(O.ZCross(T, 1) && !(O in open) && !(O in closed) && O in possibles)
			open += O
			*/

///mob/living/simple_animal/mouse/restrained() //Hotfix to stop mice from doing things with MouseDrop
//	return 1

/mob/living/simple_animal/mouse/start_pulling(var/atom/movable/AM)//Prevents mouse from pulling things
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] Squeek!</span>")
			M << 'sound/effects/mousesqueek.ogg'
	..()

/mob/living/simple_animal/mouse/Die()
	if(client)
		client.time_died_as_mouse = world.time
	..()

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	_color = "brown"
	icon_state = "mouse_brown"

/mob/living/simple_animal/mouse/black
	_color = "black"
	icon_state = "mouse_black"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"

/mob/living/simple_animal/mouse/black/dessert
	name = "Dessert"
	desc = "Crunchy!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "tenderizes"

/mob/living/simple_animal/mouse/black/biggie
	name = "Biggie Cheese"
	desc = "Oh so you like Biggie Cheese? Name 3 of his albums!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "187"
	speak = list("Mr. Boombastic","What you want is some boombastic romantic","Fantastic lover, Shaggy","Mr. Lover Lover, Mmm, Mr. Lover lover, Sha","Mr. Lover lover, Mmm, Mr. Lover lover","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","Smooth, just like the silk","Soft and cuddly hug me up like a quilt","I'm a lyrical lover","No take me for no filth","With my sexual physique, jah know me well-built","Oh me oh my, well well","Can't you tell","I'm just like a turtle crawling out of me shell","Gal you captivate my body put me under a spell","With your couscous perfume","I love your sweet smell","You are the only young girl who can ring my bell","And I could take rejection, so you tell me go to hell","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","Gee wheeze, baby please","Let me take you to an island of","The sweet cool breeze","You don't feel like drive well baby hand me the keys","And I will take you to a place to set your mind at ease","Don't you tickle my foot bottom ha ha, baby please","Don't you play with my nose 'cause I might ha-choo sneeze","(bless you)","Well, you a the bun and me a cheese","And if me a the rice well maybe you a the peas","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","I say","Give me your loving, gal your loving well good","Want your loving","Gal you need like you should","I say","Give me your loving, gal your loving well good","Want your loving","Gal you need like you should","Now remember that","Would you like to kiss and caress","Rub down every strand of hair on my chest","I'm boombastic","Rated as the best, the best you should get","Nothing more, nothing less","Give me your digits, jot down your address","I'll bet you confess when you put me to the test","That I'm","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","Gal, your admiration it's a-licked me from the start","With some physical attraction, gal, you know","To feel the spark","I want a few words, nogah tell you no sweet talk","Nogha lover, lover, lover","Nogha chat pure f","I'll get straight to the point","Like an arrow arrow dart","Come lay down in my jacuzzi and get some bubble bath","Only sound you will hear is the beating of my heart","And we will hm hm, and have some sweet pillow talk","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","She call me Mr. Boombastic","Say me fantastic touch me on the back","She says I'm Mr. Ro","Mantic, say me fantastic","Touch me on the back, she says I'm Mr. Ro","Smooth")

/mob/living/simple_animal/mouse/say_quote(text)
	if(!text)
		return "squeaks, \"...\"";	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	return "squeaks, [text]";

/mob/living/simple_animal/mouse/singularity_act()
	if(!(src.flags & INVULNERABLE))
		investigation_log(I_SINGULO,"has been consumed by a singularity")
		gib()
		return 0
