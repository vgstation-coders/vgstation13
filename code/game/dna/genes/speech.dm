#define ACT_REPLACE      /datum/speech_filter_action/replace
#define ACT_PICK_REPLACE /datum/speech_filter_action/pick_replace

/datum/speech_filter
	// REGEX OH BOY
	// orig -> /datum/SFA
	var/list/expressions=list()

// Simple replacements. (ass -> butt) => s/ass/butt/
/datum/speech_filter/proc/addReplacement(var/orig,var/replacements , var/case_sensitive=0)
	orig        = replacetext(orig,       "/","\\/")
	return addExpression(orig,ACT_REPLACE, replacements, flags = "[case_sensitive?"":"i"]g")

/datum/speech_filter/proc/addPickReplacement(var/orig,var/list/replacements, var/case_sensitive=0)
	orig        = replacetext(orig,"/","\\/")
	return addExpression(orig,ACT_PICK_REPLACE,replacements, flags = "[case_sensitive?"":"i"]g")

/datum/speech_filter/proc/addWordReplacement(var/orig,var/replacement, var/case_sensitive=0)
	return addReplacement("\\b[orig]\\b",replacement, case_sensitive)

/datum/speech_filter/proc/addCallback(var/orig,var/callback,var/list/args)
	return addExpression(orig,callback,args)

/datum/speech_filter/proc/addExpression(var/orig,var/action,var/list/replacetext, var/flags)
	expressions[orig]=new action(orig,replacetext,flags)
	return orig

/datum/speech_filter/proc/rmExpression(var/key)
	expressions[key]=null

/datum/speech_filter/proc/FilterSpeech(var/msg)
	if(expressions.len)
		for(var/key in expressions)
			var/datum/speech_filter_action/SFA = expressions[key]
//			to_chat(world, "speech filter run on <br>[msg], name is [SFA.expr.name], flags are [SFA.expr.flags]")
			if(SFA && !SFA.broken)
				msg = SFA.Run(msg)
	return msg

#undef ACT_REPLACE

/datum/speech_filter_action
	var/regex/expr
	var/str_expr
	var/broken = 0
	var/replacements

/datum/speech_filter_action/New(var/orig, var/replace, var/flags)
	str_expr = orig
	replacements = replace
	expr = regex(orig, flags)

/datum/speech_filter_action/proc/Run(var/text)
	return "[type] has not overrode run()."

/////////////////////////////
// REPLACE ACTION
/////////////////////////////
/datum/speech_filter_action/replace

/datum/speech_filter_action/replace/Run(var/text)
	var/ret = expr.Replace(text, replacements)
	if(ret)
		return ret
	return text

/////////////////////////////
// PICK REPLACE ACTION
/////////////////////////////
/datum/speech_filter_action/pick_replace

/datum/speech_filter_action/pick_replace/Run(var/text)
	expr.index = 1
	while(expr.Find(text, expr.index))
		var/repl   = pick(replacements)
		text       = copytext(text, 1, expr.index) + repl + copytext(text, expr.index + length(expr.match))
		expr.index = expr.index + length(repl)
	return text

/////////////////////////////
// ALL THE SPEECH FILTERS NOW
/////////////////////////////

// TAJARANS
/datum/speech_filter/tajaran
	expressions = list()

/datum/speech_filter/tajaran/New()
	// Combining all the worst shit the world has ever offered.

	// Note: Comes BEFORE other stuff.
	// Trying to remember all the stupid fucking furry memes is hard
	addPickReplacement("\\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|nigger|faggot|shitcurity)",
		list(
			"silly rabbit",
			"sandwich", // won't work too well with plurals OH WELL
			"recolor",
			"party pooper"
		)
	)
	addWordReplacement("me","meow")
	addWordReplacement("I","meow") // Should replace with player's first name.
	addReplacement("fuck","yiff")
	addReplacement("shit","scat")
	addReplacement("scratch","scritch")
	addWordReplacement("(help|assist)\\smeow","kill meow") // help me(ow) -> kill meow
	addReplacement("god",list("gosh","golly"))
	addPickReplacement("(ass|butt)", list("rump", "tush", "behind", "rear"))

// LIZARDS-SS-S
/datum/speech_filter/unathi
	expressions = list()

/datum/speech_filter/unathi/New()
	addReplacement("s", "s-s") //not using stutter("s") because it likes adding more s's.
	addReplacement("s-ss-s", "ss-ss") //asshole shows up as ass-sshole

// INZECTOIDZ
/datum/speech_filter/insectoid
	expressions = list()

/datum/speech_filter/insectoid/New()
	addReplacement("s", "z") //stolen from plasman code if it borks.

// HONK
/datum/speech_filter/cluwne
	expressions = list()

/datum/speech_filter/cluwne/New()
	addPickReplacement("\\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|nigger|faggot|security|shitcurity)",
	list(
		"honker",
		"fun police",
		"unfun",
	))
	// HELP THEY'RE KILLING ME
	// FINALLY THEY'RE TICKLING ME
	var/tickle_prefixes="\\b(kill+|murder|beat|wound|hurt|harm)"
	addReplacement("[tickle_prefixes]ing","tickling")
	addReplacement("[tickle_prefixes]ed", "tickled")
	addReplacement(tickle_prefixes,       "tickle")

	addReplacement("h\[aei\]lp\\s+me","end my show")
	addReplacement("h\[aei\]lp\\s+him","end his show")
	addReplacement("h\[aei\]lp\\s+her","end her show")
	addReplacement("h\[aei\]lp\\s+them","end their show")
	addReplacement("h\[aei\]lp\\s+(\[^\\s\]+)","end $1's show")
	addReplacement("^h\[aei\]lp.*","END THE SHOW")

// CHAVS, INNIT
/datum/speech_filter/chav
	expressions = list()

/datum/speech_filter/chav/New()
	// Now, finally regex
	addReplacement("dick","prat")
	addReplacement("comdom","knob'ead")
	addReplacement("looking at","gawpin' at")
	addReplacement("great","bangin'")
	addWordReplacement("man","mate")
	addPickReplacement("friend",list("mate","bruv","bledrin","fam"))
	addReplacement("what","wot")
	addReplacement("drink","wet")
	addWordReplacement("get","giz")
	addReplacement("what","wot")
	addReplacement("no thanks","wuddent fukken do one")
	addReplacement("\\b(don't know|dunno)","don't bleedin knaw")
	addReplacement("\\b(isn't|ain't)\\sit","innit")
	addPickReplacement("\\b(very|absolutely|completely|utterly|totally)",list("well","right","proper"))
	addPickReplacement("\\b(retard|dumbass|idiot|moron)",list("spastic","spazzer","mong","bell-end"))
	addWordReplacement("no","naw")
	addReplacement("robust","chin")
	addWordReplacement("hi","how what how")
	addReplacement("hello","sup bruv")
	addWordReplacement("\\b(murder|kill)","bang")
	addReplacement("windows","windies")
	addReplacement("window","windy")
	addWordReplacement("break","do")
	addWordReplacement("your","yer")
	addWordReplacement("\\b(sec|security|shitcurity)","coppers")
	//addReplacement("?",", innit?")

// BORK BORK BORK
/datum/speech_filter/swedish
	expressions = list()

/datum/speech_filter/swedish/New()
	addReplacement("w","v")
	addReplacement("\\b(ow|oh|ou|oa|au)","er")

// How nice
/datum/speech_filter/smile
	expressions = list()

/datum/speech_filter/smile/New()
//Time for a friendly game of SS13
	AddWordReplacement("stupid","smart")
	AddWordReplacement("retard","genius")
	AddWordReplacement("unrobust","robust")
	AddReplacement("dumb","smart")
	AddWordReplacement("awful","great")
	AddPickReplacement("gay",list("nice","ok","alright"))
	AddWordReplacement("horrible","fun")
	AddWordReplacement("terrible","terribly fun")
	AddWordReplacement("terrifying","wonderful")
	AddWordReplacement("gross","cool")
	AddWordReplacement("disgusting","amazing")
	AddWordReplacement("loser","winner")
	AddWordReplacement("useless","useful")
	AddWordReplacement("oh god","cheese and crackers")
	AddWordReplacement("jesus","gee wiz")
	AddWordReplacement("weak","strong")
	AddWordReplacement("kill","hug")
	AddReplacement("murder","tease")
	AddWordReplacement("ugly","beutiful")
	AddWordReplacement("douchbag","nice guy")
	AddReplacement("whore","lady")
	AddWordReplacement("nerd","smart guy")
	AddWordReplacement("moron","fun person")
	AddWordReplacement("\\b(SINGULOOSE|PLASMAFLOOD|PLASMAFLUBB)","PERFECTLY NORMAL STATION")
	AddWordReplacement("IT'S \\b(ROGUE|LOOSE)","EVERYTHING IS FINE")
	AddWordReplacement("\\b(ROGUE|ROUGE|LOOSE)","FINE")
	AddWordReplacement("rape","hug fight")
	AddWordReplacement("idiot","genius")
	AddReplacement("fat","thin")
	AddWordReplacement("beer","water with ice")
	AddWordReplacement("drink","water")
	AddWordReplacement("\\b(feminist|feminazi|SJW|social justice warrior)","empowered woman")
	AddWordReplacement("\\b(fuck you|i hate you|kill yourself|go die)","you're mean")
	AddWordReplacement("nigger","african american")
	AddWordReplacement("faggot","effeminate male")
	AddPickReplacement("fag", list("fig", "friend"))
	AddWordReplacement("tranny","felinid")
	AddWordReplacement("trannies","felinids")
	AddReplacement("\\b(shit|crap)","poo")
	AddReplacement("slut","tease")
	AddReplacement("ass","butt")
	AddWordReplacement("damn",list("darn","dang"))
	AddReplacement("hell","heck")
	AddReplacement("fuck","gently caress")
	AddWordReplacement("\\b(penis|cunt|vagina)","privates")
	AddReplacement("dick","jerk")

// WHOA MAMA
/datum/speech_filter/elvis
	expressions = list()

/datum/speech_filter/elvis/New()
	AddWordReplacement("im not","I ain't")
	AddWordReplacement("i'm not","I aint")
	AddPickReplacement("girl",list("honey","baby","baby doll"))
	AddPickReplacement("man",list("son", "buddy", "brother", "pal", "friendo"))
	AddWordReplacement("out of","outta")
	AddWordReplacement("\\b(thank you|thanks)","thank you, thank you very much")
	AddWordReplacement("what are you","whatcha")
	AddWordReplacement("what do you","whaddya")
	AddPickReplacement("yes",list("sure", "yea", "sure thing", "that's right"))
	AddWordReplacement("\\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|nigger|shitcurity|faggot)","square")
	AddWordReplacement("valids","kicks")
	AddReplacement("\\b(v|p)ox","bird")
	AddReplacement("\\b(insect|insectoid)","bug")