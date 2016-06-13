/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	if(isMoMMI(src))
		to_chat(src, "<span style=\"font-size:5;color:red\">MoMMIs are not standard cyborgs, and have different laws.  Review your laws carefully.</span>")
		to_chat(src, "<b>For newer players, a simple FAQ is <a href=\"http://ss13.moe/wiki/index.php/MoMMI\">here</a>.  Further questions should be directed to adminhelps (F1).</b>")

		to_chat(src, "<span style=\"color: blue\">For cuteness' sake, using the various emotes MoMMIs have such as *beep, *ping, *buzz or *aflap isn't considered interacting. Don't use that as an excuse to get involved though, always remain neutral.</span>")
	show_laws(0)
	if(mind)	ticker.mode.remove_revolutionary(mind)
	return
