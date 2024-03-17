/*
 * Paper
 * also scraps of paper
 */

/obj/item/weapon/paper
	name = "paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/bureaucracy.dmi', "right_hand" = 'icons/mob/in-hand/right/bureaucracy.dmi')
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = W_CLASS_TINY
	w_type = RECYK_WOOD
	throw_range = 1
	throw_speed = 1
	layer = ABOVE_DOOR_LAYER
	pressure_resistance = 1
	attack_verb = list("slaps")
	autoignition_temperature = AUTOIGNITION_PAPER

	var/info		//What's actually written on the paper.
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields		//Amount of user created fields
	var/list/stamped
	var/rigged = 0
	var/spam_flag = 0
	var/display_x = 400
	var/display_y = 400

	var/log=""
	var/obj/item/weapon/photo/img

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/weapon/paper/New()
	..()
	pixel_y = rand(-8, 8) * PIXEL_MULTIPLIER
	pixel_x = rand(-9, 9) * PIXEL_MULTIPLIER
	spawn(2)
		update_icon()
		updateinfolinks()
		return

/obj/item/weapon/paper/proc/show_text(var/mob/user, var/links = FALSE, var/starred = FALSE)
	var/info_text = links ? info_links : info
	var/info_image = ""

	if(!user.can_read())
		starred = TRUE

	if(starred)
		info_text = stars(info_text)

	if(img)
		user << browse_rsc(img.img, "tmp_photo.png")
		info_image = "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' /><br><a href='?src=\ref[src];picture=1'>Remove</a><br>"
	user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY[color ? " bgcolor=[src.color]":""]>[info_image][info_text][stamps]</BODY></HTML>", "window=[name];size=[display_x]x[display_y]")
	onclose(user, "[name]")

/obj/item/weapon/paper/update_icon()
	icon_state=initial(icon_state)
	if(info)
		icon_state += "_words"

/obj/item/weapon/paper/examine(mob/user)
	if(user.range_check(src))
		show_text(user)
	else
		..() //Only show a regular description if it is too far away to read.
		to_chat(user, "<span class='notice'>It is too far away to read.</span>")

/mob/proc/range_check(paper)
	return Adjacent(paper)

/mob/dead/range_check(paper)
	return 1

/mob/living/silicon/ai/range_check(paper)
	if(ai_flags & HIGHRESCAMS)
		return 1
	return ..()

/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if(clumsy_check(usr) && prob(50))
		to_chat(usr, "<span class='warning'>You cut yourself on [src].</span>")
		return
	var/n_name = copytext(sanitize(input(usr, "What would you like to label [src]?", "Paper Labelling", null)  as text), 1, MAX_NAME_LEN)
	if((loc == usr && !usr.isUnconscious()))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

/obj/item/weapon/paper/attack_self(mob/living/user as mob)
	if(user.attack_delayer.blocked())
		return
	if(ishuman(user)) // best not let the monkeys write loveletters
		var/mob/living/carbon/human/H = user
		if((H.attack_type == ATTACK_BITE) && (H.a_intent == I_HELP)) //if biting and helping
			if(!(H.species.anatomy_flags & HAS_LIPS) || (H.species.flags & SPECIES_NO_MOUTH)) // skeletons can apply lipstick but cannot kiss
				to_chat(user, "You have no lips, how are you going to kiss?")
				return
			if(H.check_body_part_coverage(MOUTH))
				to_chat(user, "Remove the equipment covering your mouth, first.")
				return
			add_fingerprint(H)
			user.delayNextAttack(1 SECONDS)
			if(H.lip_style)
				to_chat(user, "<span class='notice'>You kiss the piece of paper, leaving a lipstick impression.</span>")
				src.stamps += (src.stamps=="" ? "<HR>" : "<BR>") + "<i>The [src.name] has a big [H.lip_style] kiss on it.</i>"
				var/image/kissoverlay = image('icons/obj/paper.dmi')
				var/colourcode = "#FF0000" //red default
				switch(H.lip_style) // TODO - make lip_style use RGB values instead of color name in text
					if("jade")
						colourcode = "#00FF00"
					if("black")
						colourcode = "#000000"
					if("blue")
						colourcode = "#0000FF"
					if("purple")
						colourcode = "#800080"
				kissoverlay.icon_state = "lipstick_kiss"
				kissoverlay.icon += colourcode // make the kiss the color of the lipstick
				add_paper_overlay(src,kissoverlay,1,1)
			else
				to_chat(user, "<span class='notice'>You kiss the piece of paper.</span>")


	user.examination(src)
	if(rigged && (Holiday == APRIL_FOOLS_DAY))
		if(spam_flag == 0)
			spam_flag = 1
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
	return

/obj/item/weapon/paper/attack_robot(var/mob/user as mob)
	if(isMoMMI(user) && Adjacent(user))
		return attack_hand(user)
	else
		return attack_ai(user)

/obj/item/weapon/paper/attack_ai(var/mob/living/silicon/ai/user as mob)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2 || (istype(user) && (user.ai_flags & HIGHRESCAMS)))
		show_text(user)
	else
		show_text(user, starred = TRUE)
	return

//Normally ghosts can read at any range, but nobody bothered to actually make attack_ghost not be attack_ai who
//normally can't read at any range. This fixes it.
/obj/item/weapon/paper/attack_ghost(mob/user)
	user.examination(src)

/obj/item/weapon/paper/proc/addtofield(var/id, var/text, var/links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	var/softcount = 0
	while(1) // I know this can cause infinite loops and fuck up the whole server, but the if(istart==0) should be safe as fuck
		if(softcount>50)
			break
		if(softcount%25 == 0)
			sleep(1)
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart==0)
			return // No field found with matching id

		softcount++
		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/weapon/paper/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		if(i>=50)
			break //abandon ship
		if(i%25 == 0)
			sleep(1)
		addtofield(i, "<A href='?src=\ref[src];write=[i]'>write</A> ", 1)
		addtofield(i, "<A href='?src=\ref[src];help=[i]'>help</A> ", 1)
	info_links +="<A href='?src=\ref[src];write=end'>write</A> "
	info_links +="<A href='?src=\ref[src];help=end'>help</A> "

/obj/item/weapon/paper/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	overlays.len = 0
	updateinfolinks()
	update_icon()
	if(istype(loc, /obj/item/weapon/storage/bag/clipboard))
		var/obj/C = loc
		C.update_icon()

/obj/item/weapon/paper/proc/parsepencode(var/mob/user,var/obj/item/i, var/t)
	if(istype(i,/obj/item/weapon/pen))
		//t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html
		var/obj/item/weapon/pen/P=i
		t=P.Format(user,t,src)

	else if(istype(i,/obj/item/toy/crayon))
		var/obj/item/toy/crayon/C=i
		t=C.Format(user,t,src)

	return t


/obj/item/weapon/paper/proc/openhelp(mob/user as mob)
	user << browse({"<HTML><HEAD><TITLE>Pen Help</TITLE></HEAD>
	<BODY>
		<b><center>Crayon & Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <span style=\"font-size:25px\">size</span> of the text.<br>
		\[table\] - \[/table\] : Creates table using \[row\] and \[cell\] tags.<br>
		\[row\] - Creates a new table row.<br>
		\[cell\] - Creates a new table cell.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		\[date\] : Inserts the current date in the format DAY MONTH, YEAR.<br>
		\[time\] : Inserts the current station time.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <span style=\"font-size:15px\">size</span> of the text.<br>
		\[tiny\] - \[/tiny\] : Sharply decreases the <span style=\"font-size:10px\">size</span> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.<br>
		\[img\]http://url\[/img\] : Add an image.<br>
		<br>
		<b><center>Fonts</center><br></b>
		\[agency\] - \[/agency\] : <span style=\"font-family:Agency FB\">Agency FB</span><br>
		\[algerian\] - \[/algerian\] : <span style=\"font-family:Algerian\">Algerian</span><br>
		\[arial\] - \[/arial\] : <span style=\"font-family:Arial\">Arial</span><br>
		\[arialb\] - \[/arialb\] : <span style=\"font-family:Arial Black\">Arial Black</span><br>
		\[calibri\] - \[/calibri\] : <span style=\"font-family:Calibri\">Calibri</span><br>
		\[courier\] - \[/courier\] : <span style=\"font-family:Courier\">Courier</span><br>
		\[helvetica\] - \[/helvetica\] : <span style=\"font-family:Helvetica\">Helvetica</span><br>
		\[impact\] - \[/impact\] : <span style=\"font-family:Impact\">Impact</span><br>
		\[palatino\] - \[/palatino\] : <span style=\"font-family:Palatino Linotype\">Palatino Linotype</span><br>
		\[tnr\] - \[/tnr\] : <span style=\"font-family:Times New Roman\">Times New Roman</span>

	</BODY></HTML>"}, "window=paper_help")

/obj/item/weapon/paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return

	if(href_list["picture"])
		if(!ishigherbeing(usr))
			return
		var/mob/living/carbon/human/H = usr
		H.put_in_hands(img)
		img = null

	if(href_list["write"])
		var/id = href_list["write"]
		//var/t = utf8_sanitize(input(usr, "What text do you wish to add to " + (id=="end" ? "the end of the paper" : "field "+id) + "?", "[name]", null),8192) as message
		//var/t =  utf8_sanitize(input("Enter what you want to write:", "Write", null, null)  as message, MAX_MESSAGE_LEN)
		var/new_text

		//Wrap this part in a loop to prevent text from getting lost
		do
			new_text = sanitize(input("Enter what you want to write:", "Write", new_text) as null|message, MAX_MESSAGE_LEN)
			var/obj/item/i = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.

			//The user either entered a non-value, or logged off
			if(isnull(new_text) || !usr.key)
				return

			//Not writing with a pen or crayon
			if(!istype(i,/obj/item/weapon/pen) && !istype(i,/obj/item/toy/crayon))
				to_chat(usr, "<span class='warning'>Please ensure your pen is in your active hand and that you're holding the paper.</span>")
				continue

			//Lost the paper or lost consciousness
			if(!Adjacent(usr, 1) || usr.isUnconscious()) //the 1 means that the paper can be in one other item and be written on
				to_chat(usr, "<span class='warning'>You are to unable to write on this paper.</span>")
				continue

		while(isnull(new_text))

		log += "<br />\[[time_stamp()]] [key_name(usr)] added: [new_text]"

		new_text = replacetext(new_text, "\n", "<BR>")

		var/mob/living/M = usr
		if(istype(M))
			var/obj/item/weapon/pen/P = M.get_active_hand()
			if(istype(P) && P.arcanetampered)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.vessel.remove_reagent(BLOOD,length(new_text))
				else
					M.adjustBruteLoss(length(new_text))

		if(arcanetampered)
			switch(rand(1,4))
				if(1)
					new_text = slur(new_text)
				if(2)
					new_text = derpspeech(new_text)
				if(3)
					new_text = tumblrspeech(new_text)
					new_text = nekospeech(new_text)
				if(4)
					new_text = markov_chain(new_text, rand(2,5), rand(100,700))

		spawn()
			new_text = parsepencode(usr, usr.get_active_hand() ,new_text)

			//Count the fields
			var/laststart = 1
			while(1)
				var/j = findtext(new_text, "<span class=\"paper_field\">", laststart)
				if(j==0)
					break
				laststart = j+1
				fields++

			if(id!="end")
				addtofield(text2num(id), new_text) // He wants to edit a field, let him.
			else
				info += new_text // Oh, he wants to edit to the end of the file, let him.
				updateinfolinks()

			show_text(usr, links = TRUE)

			update_icon()

			if(istype(loc, /obj/item/weapon/storage/bag/clipboard))
				var/obj/item/weapon/storage/bag/clipboard/C = loc
				C.update_icon()

	if(href_list["help"])
		if(arcanetampered)
			to_chat(usr, "<span class='sinister'>REAL SPESSMEN DON'T NEED INSTRUCTIONS!</span>")
		else
			openhelp(usr)


/obj/item/weapon/paper/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()

	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		if ( istype(P, /obj/item/weapon/pen/robopen) && P:mode == 2 )
			P:RenamePaper(user,src)
		else
			show_text(user, links = TRUE)
		//openhelp(user)
		return

	else if(istype(P, /obj/item/weapon/stamp))
		var/obj/item/weapon/stamp/S = P
		S.try_stamp(user,src)
	else if(istype(P, /obj/item/weapon/photo) && !istype(src, /obj/item/weapon/paper/envelope))
		if(img)
			to_chat(user, "<span class='notice'>This paper already has a photo attached.</span>")
			return

		if(user.drop_item(P, src))
			img = P
			to_chat(user, "<span class='notice'>You attach the photo to the piece of paper.</span>")
	else if(P.is_hot())
		src.ashify_item(user)
		return 1 //no fingerprints, paper is gone
	add_fingerprint(user)
	return ..()

/obj/item/proc/ashify_item(mob/user)
	var/prot = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if (M_RESIST_HEAT in H.mutations)
			prot = 1
		else if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.max_heat_protection_temperature)
				prot = (G.max_heat_protection_temperature > src.autoignition_temperature)
		if(!prot && clumsy_check(H) && prob(50)) //only fail if human
			H.apply_damage(10,BURN,(pick(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)))
			user.drop_hands()
			user.visible_message( \
				"<span class='notice'>[user] tries to burn the [src.name], but burns \his hand trying!</span>", \
				"<span class='warning'>You try to burn the [src.name], but burn your hand trying!</span>")
			return //you fail before even managing to burn it!
	if(prot) //user is human and is protected from fire, let's make them a badass
		user.visible_message( \
			"<span class='warning'>[user] holds up the [src.name] and sets it on fire, holding it in \his hand as it burns down to ashes. Damn, \he's cold.</span>", \
			"<span class='warning'>You hold up the [src.name] and set it on fire, holding it in your hand as it burns down to ashes. Damn, you're cold.</span>")
	else
		user.visible_message( \
			"<span class='warning'>[user] holds up the [src.name] and sets it on fire, reducing it to a heap of ashes.</span>", \
			"<span class='warning'>You hold up the [src.name] and set it on fire, reducing it to a heap of ashes.</span>")
	var/ashtype = ashtype()
	new ashtype(get_turf(src)) //not using ashify() since it calls for src.loc rather than get_turf(src), and requires the object to be on fire also
	qdel(src)
	return

var/global/list/paper_folding_results = list ( \
	"ball of paper" = /obj/item/weapon/p_folded/ball,
	"paper plane" = /obj/item/weapon/p_folded/plane,
	"paper hat" = /obj/item/weapon/p_folded/hat,
	"folded note" = /obj/item/weapon/p_folded/note_small,
	"origami crane" = /obj/item/weapon/p_folded/crane,
	"origami boat" = /obj/item/weapon/p_folded/boat,
	"origami heart" = /obj/item/weapon/p_folded/folded_heart,
	"envelope" = /obj/item/weapon/paper/envelope,
	)

/obj/item/weapon/paper/verb/fold()
	set category = "Object"
	set name = "Fold paper"
	set src in usr

	if (!canfold(usr))
		return
	var/foldtype = paper_folding_results[input("What do you want to make the paper into?", "Paper Folding") as null|anything in paper_folding_results]
	if (!foldtype)
		return
	if (!canfold(usr))
		return //second check in case some chucklefuck moves the paper or falls down while the menu is open

	usr.drop_item(src, force_drop = 1)	//Drop the original paper to free our hand and call proper inventory handling code
	var/obj/item/P
	if(ispath(foldtype, /obj/item/weapon/p_folded))
		P = new foldtype(get_turf(src), unfolds_into = src) //Let's make a new item that unfolds into the original paper
	else
		P = new foldtype(get_turf(src))
	src.forceMove(P)	//and also contains it, for good measure.
	usr.put_in_hands(P)
	P.pixel_y = src.pixel_y
	P.pixel_x = src.pixel_x
	if (istype(src, /obj/item/weapon/paper/nano))
		P.color = "#9A9A9A"
		if(istype(P, /obj/item/weapon/p_folded))
			var/obj/item/weapon/p_folded/pf = P
			pf.nano = 1
	usr.visible_message("<span class='notice'>[usr] folds \the [src.name] into a [P.name].</span>", "<span class='notice'>You fold \the [src.name] into a [P.name].</span>")
	transfer_fingerprints(src, P)
	return

/obj/item/weapon/paper/proc/canfold(mob/user)
	if(!user)
		return 0
	if(user.stat || user.restrained())
		to_chat(user, "<span class='notice'>You can't do that while restrained.</span>")
		return 0
	if(!user.is_holding_item(src))
		to_chat(user, "<span class='notice'>You'll need [src] in your hands to do that.</span>")
		return 0
	return 1

/obj/item/weapon/paper/AltClick()
	if(is_holder_of(usr, src) && canfold(usr))
		fold()
	else
		return ..()


/obj/item/weapon/paper/proc/sudokize(var/color)
	var/list/sudokus = file2list("data/sudoku.txt")
	info = "<style>\
	td{width: 35px;height: 35px;border: 1px solid black;text-align: center;vertical-align: middle;font-family:Verdana, sans;color:[color];font-weight: bold;}\
	table{border: 3px solid black;}\
	</style>\
	<table cellpadding='0' cellspacing='0'>[pick(sudokus)]</table>"
	updateinfolinks()
	update_icon()

/*
 * Paper in different states
 */

/obj/item/weapon/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/weapon/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0.0
	item_state = "paper"


/obj/item/weapon/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/weapon/paper/crumpled/update_icon()
	return

/obj/item/weapon/paper/crumpled/bloody
	icon_state = "scrap_bloodied"
