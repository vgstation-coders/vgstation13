/mob/living/silicon/robot/mommi/Login()
	..()
	greet_robot()

/mob/living/silicon/robot/mommi/proc/greet_robot()
	to_chat(src, "<span class='big warning'>MoMMIs are not standard cyborgs, and have different laws.  Review your laws carefully.</span>")
	to_chat(src, "<b>For newer players, a simple FAQ is <a href=\"http://ss13.moe/wiki/index.php/MoMMI\">here</a>.  Further questions should be directed to adminhelps (F1).</b>")
	to_chat(src, "<span class='info'>For cuteness' sake, using the various emotes MoMMIs have such as *beep, *ping, *buzz or *aflap isn't considered interacting. Don't use that as an excuse to get involved though, always remain neutral.</span>")

/mob/living/silicon/robot/mommi/sammi/greet_robot()
	to_chat(src, "<span class='big warning'>SAMMIs are not standard cyborgs, and have different laws.  Review your laws carefully.</span>")
	to_chat(src, "<b>For newer players, a simple FAQ is <a href=\"http://ss13.moe/wiki/index.php/SAMMI\">here</a>. Further questions should be directed to adminhelps (F1).</b>")
