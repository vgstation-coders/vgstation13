/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */

#define ACT_BBCODE_IMG /datum/speech_filter_action/bbcode/img
#define ACT_BBCODE_VIDEO /datum/speech_filter_action/bbcode/video
#define ACT_BBCODE_YOUTUBE /datum/speech_filter_action/bbcode/youtube
#define CHECK_NANO /obj/item/weapon/pen
// MACROS
#define REG_NOTBB "\[^\\\[\]+"    // [^\]]+

// This WAS a macro, but BYOND a shit.
/proc/REG_BBTAG(x)
	return "\\\[[x]\\\]"

// [x]blah[/x]
/proc/REG_BETWEEN_BBTAG(x)
	return "[REG_BBTAG(x)]([REG_NOTBB])[REG_BBTAG("/[x]")]"

/datum/speech_filter_action/bbcode/Run(var/text, var/mob/user, var/atom/movable/P)
	return

/datum/speech_filter_action/bbcode/img/Run(var/text, var/mob/user, var/atom/movable/P)
	expr.index = 1
	while(expr.Find(text, expr.index))
		message_admins("[key_name_admin(user)] added an image ([html_encode(expr.group[1])]) to [P] at [formatJumpTo(get_turf(P))]")
		var/rtxt   = "<img src=\"[html_encode(expr.group[1])]\" />"
		text       = copytext(text, 1, expr.index) + rtxt + copytext(text, expr.index + length(expr.match))
		expr.index = expr.index + length(rtxt)
	return text

/datum/speech_filter_action/bbcode/video/Run(var/text, var/mob/user, var/atom/movable/P)
	expr.index = 1
	while(expr.Find(text, expr.index))
		message_admins("[key_name_admin(user)] added a video ([html_encode(expr.group[1])]) to [P] at [formatJumpTo(get_turf(P))]")
		var/rtxt   = "<embed src=\"[html_encode(expr.group[1])]\" width=\"420\" height=\"344\" type=\"x-ms-wmv\" volume=\"85\" autoStart=\"0\" autoplay=\"true\" />"
		text       = copytext(text, 1, expr.index) + rtxt + copytext(text, expr.index + length(expr.match))
		expr.index = expr.index + length(rtxt)
	return text

/datum/speech_filter_action/bbcode/youtube/Run(var/text, var/mob/user, var/atom/movable/P)
	expr.index = 1
	while(expr.Find(text,expr.index))
		var/regex/youtubeid = regex("(youtu\\.be\\/|youtube\\.com\\/(watch\\?(.*&)?v=|(embed|v)\\/))(\[\\w\]+)", "gi")
		youtubeid.Find(expr.group[1])
		var/link = "http://www.youtube.com/embed/[youtubeid.group[5]]?autoplay=1&loop=1&controls=0&showinfo=0&rel=0"
		message_admins("[key_name_admin(user)] added a youtube video ([html_encode(expr.group[1])]) to [P] at [formatJumpTo(get_turf(P))]")
		var/rtxt   = "<iframe width=\"420\" height=\"345\" src=\"[link]\" frameborder=\"0\">"
		text       = copytext(text, 1, expr.index) + rtxt + copytext(text, expr.index + length(expr.match))
		expr.index = expr.index + length(rtxt)
	return text

// Attached to writing instrument. (pen/pencil/etc)
/datum/writing_style
	parent_type = /datum/speech_filter

	var/style      = "font-family:Verdana, sans;"
	var/style_sign = "font-family:'Times New Roman', monospace;text-style:italic;"

/datum/writing_style/New()
	..()

	addReplacement(REG_BBTAG("center"), 	"<center>")
	addReplacement(REG_BBTAG("/center"),	"</center>")
	addReplacement(REG_BBTAG("br"),     	"<BR>")
	addReplacement(REG_BBTAG("b"),      	"<B>")
	addReplacement(REG_BBTAG("/b"),     	"</B>")
	addReplacement(REG_BBTAG("i"),      	"<I>")
	addReplacement(REG_BBTAG("/i"),     	"</I>")
	addReplacement(REG_BBTAG("u"),      	"<U>")
	addReplacement(REG_BBTAG("/u"),     	"</U>")
	addReplacement(REG_BBTAG("large"),  	"<span style=\"font-size:25px\">")
	addReplacement(REG_BBTAG("/large"), 	"</span>")
	//addReplacement(REG_BBTAG("sign"),   	"<span style=\"[style_sign]\"><USERNAME /</span>")
	//addReplacement(REG_BBTAG("field"),  	"<span class=\"paper_field\"></span>")

	// Fallthrough just fucking kills the tag
	addReplacement(REG_BBTAG("\[^\\\]\]"), "")
	return


/datum/writing_style/proc/Format(var/t, var/obj/item/weapon/pen/P, var/mob/user, var/obj/item/weapon/paper/paper)
	var/count = 0
	if(expressions.len)
		for(var/key in expressions)
			if(count >= 500)
				break
			count++
			var/datum/speech_filter_action/SFA = expressions[key]
			if(SFA && !SFA.broken)
				t = SFA.Run(t,user,paper)
			if(count%100 == 0)
				sleep(1) //too much for us.
	t = replacetext(t, "\[sign\]", "<font face=\"Times New Roman\"><i>[user.real_name]</i></font>")
	t = replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")
	t = replacetext(t, "\[date\]", "[current_date_string]")
	t = replacetext(t, "\[time\]", "[worldtime2text()]")

	// tables ported from Baystation12 : https://github.com/Baystation12/Baystation12

	t = replacetext(t, "\[table\]", "<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>")
	t = replacetext(t, "\[/table\]", "</td></tr></table>")
	t = replacetext(t, "\[row\]", "</td><tr>")
	t = replacetext(t, "\[cell\]", "<td>")

	var/text_color
	if(istype(P, /obj/item/weapon/pen))
		text_color = P.colour
	else if(istype(P, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = P
		text_color = C.mainColour

	return "<span style=\"[style];color:[text_color]\">[t]</span>"

/datum/writing_style/pen/New()
	addReplacement(REG_BBTAG("\\*"), "<li>")
	addReplacement(REG_BBTAG("hr"), "<HR>")
	addReplacement(REG_BBTAG("small"), "<span style=\"font-size:15px\">")
	addReplacement(REG_BBTAG("/small"), "</span>")
	addReplacement(REG_BBTAG("tiny"), "<span style=\"font-size:10px\">")
	addReplacement(REG_BBTAG("/tiny"), "</span>")
	addReplacement(REG_BBTAG("list"), "<ul>")
	addReplacement(REG_BBTAG("/list"), "</ul>")
	addReplacement(REG_BBTAG("agency"),  	"<span style=\"font-family:Agency FB\">")
	addReplacement(REG_BBTAG("/agency"), 	"</span>")
	addReplacement(REG_BBTAG("algerian"),  	"<span style=\"font-family:Algerian\">")
	addReplacement(REG_BBTAG("/algerian"), 	"</span>")
	addReplacement(REG_BBTAG("arial"),  	"<span style=\"font-family:Arial\">")
	addReplacement(REG_BBTAG("/arial"), 	"</span>")
	addReplacement(REG_BBTAG("arialb"),  	"<span style=\"font-family:Arial Black\">")
	addReplacement(REG_BBTAG("/arialb"), 	"</span>")
	addReplacement(REG_BBTAG("calibri"),  	"<span style=\"font-family:Calibri\">")
	addReplacement(REG_BBTAG("/calibri"), 	"</span>")
	addReplacement(REG_BBTAG("courier"),  	"<span style=\"font-family:Courier\">")
	addReplacement(REG_BBTAG("/courier"), 	"</span>")
	addReplacement(REG_BBTAG("helvetica"),  "<span style=\"font-family:Helvetica\">")
	addReplacement(REG_BBTAG("/helvetica"), "</span>")
	addReplacement(REG_BBTAG("impact"),  	"<span style=\"font-family:Impact\">")
	addReplacement(REG_BBTAG("/impact"), 	"</span>")
	addReplacement(REG_BBTAG("palatino"),  	"<span style=\"font-family:Palatino Linotype\">")
	addReplacement(REG_BBTAG("/palatino"), 	"</span>")
	addReplacement(REG_BBTAG("tnr"),		"<span style=\"font-family:Times New Roman\">")
	addReplacement(REG_BBTAG("/tnr"),		"</span>")

	addExpression(REG_BBTAG("img")+"("+REG_NOTBB+")"+REG_BBTAG("/img"), ACT_BBCODE_IMG,list(),flags = "gi")

	..() // Order of operations

/datum/writing_style/script/New()
	style = "font-family:'Segoe Script', cursive;"
	addReplacement(REG_BBTAG("\\*"), "<li>")
	addReplacement(REG_BBTAG("hr"), "<HR>")
	addReplacement(REG_BBTAG("small"), "<span style=\"font-size:15px\">")
	addReplacement(REG_BBTAG("/small"), "</span>")
	addReplacement(REG_BBTAG("tiny"), "<span style=\"font-size:10px\">")
	addReplacement(REG_BBTAG("/tiny"), "</span>")
	addReplacement(REG_BBTAG("list"), "<ul>")
	addReplacement(REG_BBTAG("/list"), "</ul>")

	addExpression(REG_BBTAG("img")+"("+REG_NOTBB+")"+REG_BBTAG("/img"), ACT_BBCODE_IMG,list(),flags = "gi")

	..()

/datum/writing_style/pen/nano_paper/New()
	addExpression(REG_BBTAG("video")+"("+REG_NOTBB+")"+REG_BBTAG("/video"), ACT_BBCODE_VIDEO,list(),flags = "gi")
	addExpression(REG_BBTAG("youtube")+"("+REG_NOTBB+")"+REG_BBTAG("/youtube"), ACT_BBCODE_YOUTUBE,list(),flags = "gi")

	..()

/datum/writing_style/crayon
	style = "font-family:'Comic Sans MS';font-weight:bold"


/*
 * Pens
 */
/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/bureaucracy.dmi', "right_hand" = 'icons/mob/in-hand/right/bureaucracy.dmi')
	icon_state = "pen"
	item_state = "pen"
	origin_tech = Tc_MATERIALS + "=1"
	sharpness = 0.5
	sharpness_flags = SHARP_TIP
	flags = FPRINT
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	starting_materials = list(MAT_IRON = 10)
	w_type = RECYK_MISC
	pressure_resistance = 2

	var/colour = "black"	//what colour the ink is!
	var/colour_rgb = "#000000"
	var/style_type = /datum/writing_style/pen
	var/nano_style_type = /datum/writing_style/pen/nano_paper
	var/datum/writing_style/style
	var/datum/writing_style/nano_style // stlyle when used on nano_paper

/obj/item/weapon/pen/New()
	..()

	style = new style_type
	nano_style = new nano_style_type

// checks if its used on nano paper, if it is, use the nano paper formatting
/obj/item/weapon/pen/proc/Format(var/mob/user, var/text, var/obj/item/weapon/paper/P)
	if(istype(P,/obj/item/weapon/paper/nano))
		return nano_style.Format(text,src,user,P)
	else
		return style.Format(text,src,user,P)

/obj/item/weapon/pen/suicide_act(var/mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/reagent/blood/B = get_blood(H.vessel)
		if(B)
			for(var/obj/item/weapon/paper/P in recursive_type_check(user, /obj/item/weapon/paper))
				if(P.info) //clean paper only
					continue
				P.sudokize(B.data["blood_colour"])
				H.vessel.remove_reagent(BLOOD, 15)
				to_chat(viewers(user), "<span class='danger'>[user] is stabbing \himself with \the [src.name] and pouring their soul into \the [P]! It looks like they're trying to commit sudoku.</span>")
				return(SUICIDE_ACT_BRUTELOSS|SUICIDE_ACT_OXYLOSS)

	to_chat(viewers(user), "<span class='danger'>[user] is jamming the [src.name] into \his ear! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/pen/arcane_act(mob/user, recursive)
	colour = "red" // for convincing blood effect
	colour_rgb = "#ff0000"
	return ..()

/obj/item/weapon/pen/bless()
	..()
	if(arcanetampered)
		colour = initial(colour)
		colour_rgb = initial(colour_rgb)

/obj/item/weapon/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"
	colour_rgb = "#0000ff"

/obj/item/weapon/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"
	colour_rgb = "#ff0000"

/obj/item/weapon/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"
	colour_rgb = "#ffffff"

/obj/item/weapon/pen/NT
	name = "promotional Nanotrasen pen"
	desc = "Just a cheap plastic pen. It reads: \"For our most valued customers\". They probably meant 'employees'."

/obj/item/weapon/pen/multi
	colour = "black"
	name = "multi-pen"
	desc = "It's a multicolor ink pen with three different ink colors. Its color is currently set to black."
	icon_state = "pen_multi"
	var/image/tip = null

/obj/item/weapon/pen/multi/attack_self(mob/user as mob)
	overlays.len = 0
	switch(colour)
		if("black")
			colour = "blue"
			tip = image('icons/obj/bureaucracy.dmi', src, "pen_tip_blue")
		if("blue")
			colour = "red"
			tip = image('icons/obj/bureaucracy.dmi', src, "pen_tip_red")
		else //red and also edge cases (how???)
			colour = "black"
			tip = image('icons/obj/bureaucracy.dmi', src, "pen_tip_black")
	overlays += tip
	desc = "It's a multicolor ink pen with three different ink colors. Its color is currently set to [colour]."
	to_chat(user, "<span class='notice'>You switch the tip of \the [src] to [colour].</span>")

/obj/item/weapon/pen/fountain
	name = "fountain pen"
	desc = "A fancy fountain pen, for when you really want to impress. The nib is quite sharp."
	icon_state = "pen_fountain"
	sharpness = 1.2
	force = 5
	throwforce = 5
	attack_verb = list("stabs")
	style_type = /datum/writing_style/script
	var/bloodied = null

/obj/item/weapon/pen/fountain/examine(mob/user)
	. = ..()
	if(bloodied)
		to_chat(user, "<span class='info'>The nib is dripping with a viscous substance.</span>")

/obj/item/weapon/pen/fountain/afterattack(obj/reagentholder, mob/user as mob)
	..()
	if(!bloodied)
		return
	if(reagentholder.is_open_container() && !ismob(reagentholder) && reagentholder.reagents)
		if(reagentholder.reagents.has_only_any(list(WATER,CLEANER,BLEACH,ETHANOL, HOLYWATER))) //cannot contain any reagent outside of this list, but can contain the list in any proportion
			to_chat(user, "<span class='notice'>You dip \the [src] into \the [reagentholder], cleaning out the nib.</span>")
			bloodied = FALSE
			colour = "black"

/obj/item/weapon/pen/fountain/cap
	name = "captain's fountain pen"
	desc = "A fancy fountain pen, for when you really want to impress. This one comes in a commanding navy and gold. The nib is quite sharp."
	icon_state = "pen_fountain_cap"

/obj/item/weapon/pen/tactical
	name = "tacpen"
	desc = "Tactical pen. The tip is self heating and can light things, the reverse can be used as a screwdriver. It contains a one-time reservoir of biofoam that cannot be refilled."
	sharpness_flags = SHARP_TIP | HOT_EDGE

/obj/item/weapon/pen/tactical/New()
	..()
	create_reagents(9)
	reagents.add_reagent(BIOFOAM, 9) //90 ticks, about 3 minutes

/obj/item/weapon/pen/tactical/is_screwdriver(mob/user)
	return TRUE

/obj/item/weapon/pen/attack(mob/M as mob, mob/user as mob)
	if(istype(src, /obj/item/weapon/pen/fountain))
		var/obj/item/weapon/pen/fountain/P = src
		if(user.zone_sel.selecting == "eyes" || user.zone_sel.selecting == LIMB_HEAD)
			if(!istype(M))
				return ..()
			if(can_operate(M, user, P))
				return ..()
			if(clumsy_check(user) && prob(50))
				M = user
			return eyestab(M,user)
		..()
		var/mob/living/carbon/human/H = M
		var/datum/reagent/blood/B = get_blood(H.vessel)
		if(B)
			P.bloodied = TRUE
			P.colour = B.data["blood_colour"]

	if(!ismob(M))
		return
	to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
	to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [type]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [type] to stab [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) Used the [type] to stab [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user
		M.assaulted_by(user)
	if(reagents && reagents.total_volume)
		reagents.trans_to(M,50)


/*
 * Sleepy Pens
 */
/obj/item/weapon/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags = FPRINT  | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=5"


/obj/item/weapon/pen/sleepypen/New()
	. = ..()
	create_reagents(30) // Used to be 300
	reagents.add_reagent(CHLORALHYDRATE, 22) // Used to be 100 sleep toxin // 30 Chloral seems to be fatal, reducing it to 22. /N

/*
 * Parapens
 */
 /obj/item/weapon/pen/paralysis
	flags = FPRINT  | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=5"

/obj/item/weapon/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(25)
	reagents = R
	R.my_atom = src
	R.add_reagent(ZOMBIEPOWDER, 10)
	R.add_reagent(CRYPTOBIOLIN, 15)
	..()
