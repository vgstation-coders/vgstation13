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

//var/stdshellout_dllFile = 'byond_markdown.dll'
var/paperwork = 0
var/paperwork_library

/client/proc/handle_paperwork()

	set category = "Debug"
	set name = "Modify Paperwork Mode"

	if(!check_rights(R_DEBUG))
		return

	if(!paperwork)
		paperwork_setup()
	else
		paperwork_stop()
		paperwork = 0

/proc/paperwork_setup()
	if(config.paperwork_library)
		if(world.system_type == MS_WINDOWS)
			paperwork_library = "markdown_byond.dll"
		else
			paperwork_library = "markdown_byond.so"
		world.log << "Setting up paperwork..."
		if(!fexists(paperwork_library))
			world.log << "Paperwork was not properly setup, please notify a coder/host about this issue."
			return
		world.log << call(paperwork_library, "init_renderer")()
		paperwork = 1
		return 1
	else
		return 0
	return 0

/proc/paperwork_stop()
	if(!fexists(paperwork_library))
		world.log << "Paperwork file may be missing or something terrible has happened, don't panic and notify a coder/host about this issue."
		return
	if(paperwork)
		call(paperwork_library, "free_memory")()
		return
	else
		return

/datum/writing_style/proc/parse_markdown(command_args)
//	if(!fexists("byond_markdown.dll")){fcopy(stdshellout_dllFile,"[stdshellout_dllFile]")}
	return call(paperwork_library,"render_html")(command_args)


/datum/writing_style/proc/Format(var/t, var/obj/item/weapon/pen/P, var/mob/user, var/obj/item/weapon/paper/paper)
	if(paperwork)
		t = parse_markdown(t)
	else
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

	var/text_color
	if(istype(P, /obj/item/weapon/pen))
		text_color = P.color
	else if(istype(P, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = P
		text_color = C.colour

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

/obj/item/weapon/pen/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is jamming the [src.name] into \his ear! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/weapon/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/weapon/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"


/obj/item/weapon/pen/attack(mob/M as mob, mob/user as mob)
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
	return


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

/obj/item/weapon/pen/sleepypen/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents)
			reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
 /obj/item/weapon/pen/paralysis
	flags = FPRINT  | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=5"


/obj/item/weapon/pen/paralysis/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents)
			reagents.trans_to(M, 50)
	return


/obj/item/weapon/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(25)
	reagents = R
	R.my_atom = src
	R.add_reagent(ZOMBIEPOWDER, 10)
	R.add_reagent(CRYPTOBIOLIN, 15)
	..()
	return
