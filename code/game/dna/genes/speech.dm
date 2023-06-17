#define ACT_REPLACE      /datum/speech_filter_action/replace
#define ACT_PICK_REPLACE /datum/speech_filter_action/pick_replace
#define GENERIC_INSULT_WORDS "\\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|security|shitcurity)"

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
#ifdef SAY_DEBUG
			say_testing(world, "speech filter run on <br>[msg], name is [SFA.expr.name], flags are [SFA.expr.flags]")
#endif
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
	addPickReplacement(GENERIC_INSULT_WORDS,
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
	addPickReplacement("god",list("gosh","golly"))
	addPickReplacement("(ass|butt)", list("rump", "tush", "behind", "rear"))

// LIZARDS-SS-S
/datum/speech_filter/unathi
	expressions = list()

/datum/speech_filter/unathi/New()
	addReplacement("s", "s-s", 1) //not using stutter("s") because it likes adding more s's.
	addReplacement("s-ss-s", "ss-ss", 1) //asshole shows up as ass-sshole
	addReplacement("S", "S-S", 1) //not using stutter("s") because it likes adding more s's.
	addReplacement("S-SS-S", "SS-SS", 1) //asshole shows up as ass-sshole

// INZECTOIDZ
/datum/speech_filter/insectoid
	expressions = list()

/datum/speech_filter/insectoid/New()
	addReplacement("s", "z", 1) //stolen from plasman code if it borks.
	addReplacement("S", "Z", 1) //stolen from plasman code if it borks.

// HONK
/datum/speech_filter/cluwne
	expressions = list()

/datum/speech_filter/cluwne/New()
	addPickReplacement(GENERIC_INSULT_WORDS,
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
	addReplacement("\\b(good|nice|wonderful|cool|epic|great)","bangin'")
	addWordReplacement("man","mate")
	addPickReplacement("friend",list("mate","bruv","bledrin","fam"))
	addReplacement("what","wot")
	addReplacement("drink","wet")
	addWordReplacement("get","giz")
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
	addReplacement("(ow|oh|ou|oa|au)","er",1)
	addReplacement("(OW|OH|OU|OA|AU)","ER",1)
	addReplacement("w","v",1)
	addReplacement("W","V",1)

// How nice
/datum/speech_filter/smile
	expressions = list()

/datum/speech_filter/smile/New()
//Time for a friendly game of SS13
	addWordReplacement("stupid","smart")
	addWordReplacement("retard","genius")
	addWordReplacement("unrobust","robust")
	addReplacement("dumb","smart")
	addWordReplacement("awful","great")
	addPickReplacement("gay",list("nice","ok","alright"))
	addPickReplacement("\\b(horrible|terrifying)",list("fun","pleasant","lovely","wonderful"))
	addWordReplacement("terrible","terribly fun")
	addWordReplacement("gross","cool")
	addWordReplacement("disgusting","amazing")
	addWordReplacement("loser","winner")
	addWordReplacement("useless","useful")
	addWordReplacement("oh god","cheese and crackers")
	addWordReplacement("jesus","gee wiz")
	addWordReplacement("weak","strong")
	addWordReplacement("\\b(fuck you|i hate you|kill yourself|go die)","you're mean")
	addWordReplacement("kill","hug")
	addReplacement("murder","tease")
	addWordReplacement("ugly","beutiful")
	addWordReplacement("douchbag","nice guy")
	addReplacement("whore","lady")
	addWordReplacement("nerd","smart guy")
	addWordReplacement("moron","fun person")
	addWordReplacement("\\b(SINGULOOSE|PLASMAFLOOD|PLASMAFLUBB)","PERFECTLY NORMAL STATION")
	addWordReplacement("IT'S \\b(ROGUE|LOOSE)","EVERYTHING IS FINE")
	addWordReplacement("\\b(ROGUE|ROUGE|LOOSE)","FINE")
	addWordReplacement("rape","hug fight")
	addWordReplacement("idiot","genius")
	addReplacement("fat","thin")
	addWordReplacement("beer","water with ice")
	addWordReplacement("drink","water")
	addWordReplacement("\\b(feminist|feminazi|SJW|social justice warrior)","empowered woman")
	addPickReplacement("fag", list("fig", "friend"))
	addWordReplacement("tranny","felinid")
	addWordReplacement("trannies","felinids")
	addReplacement("\\b(shit|crap)","poo")
	addReplacement("slut","tease")
	addReplacement("ass","butt")
	addPickReplacement("damn",list("darn","dang"))
	addReplacement("hell","heck")
	addReplacement("fuck","gently caress")
	addWordReplacement("\\b(penis|cunt|vagina|cock)","privates")
	addReplacement("dick","jerk")
	addReplacement("tits","mammary glands") //now all the 7 dirty words are filtered

// WHOA MAMA
/datum/speech_filter/elvis
	expressions = list()

/datum/speech_filter/elvis/New()
	addWordReplacement("im not","I ain't")
	addWordReplacement("i'm not","I aint")
	addPickReplacement("girl",list("honey","baby","baby doll"))
	addPickReplacement("man",list("son", "buddy", "brother", "pal", "friendo"))
	addWordReplacement("out of","outta")
	addWordReplacement("\\b(thank you|thanks)","thank you, thank you very much")
	addWordReplacement("what are you","whatcha")
	addWordReplacement("what do you","whaddya")
	addPickReplacement("yes",list("sure", "yea", "sure thing", "that's right"))
	addWordReplacement(GENERIC_INSULT_WORDS,"square")
	addWordReplacement("valids","kicks")
	addReplacement("\\b(v|p)ox","bird")
	addReplacement("\\b(insectoid|insect)","bug")

// OLE!
/datum/speech_filter/luchador
	expressions = list()

/datum/speech_filter/luchador/New()
	addWordReplacement("captain", "CAPITÁN")
	addWordReplacement("station", "ESTACIÓN")
	addWordReplacement("sir", "SEÑOR")
	addPickReplacement("the", list("el","la"))
	addWordReplacement("my", "mi")
	addWordReplacement("is", "es")
	addWordReplacement("it's", "es")
	addWordReplacement("friend", "amigo")
	addWordReplacement("buddy", "amigo")
	addWordReplacement("hello", "hola")
	addWordReplacement("hot", " caliente")
	addWordReplacement("very ", "muy")
	addWordReplacement("sword", "espada")
	addWordReplacement("library", "biblioteca")
	addWordReplacement("traitor", "traidor")
	addWordReplacement("wizard", "mago")
