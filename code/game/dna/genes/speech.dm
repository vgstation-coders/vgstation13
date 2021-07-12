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
	addPickReplacement("\\b(asshole|comdom|shitter|shitler|retard|dipshit|dipshit|greyshirt|nigger)\\b",
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
	addReplacement("god","gosh")
	addWordReplacement("(ass|butt)", "rump")

// PLASMEMES
/datum/speech_filter/plasmaman
	expressions = list()

/datum/speech_filter/plasmaman/New()
	addReplacement("s", "s-s") //not using stutter("s") because it likes adding more s's.
	addReplacement("s-ss-s", "ss-ss") //asshole shows up as ass-sshole

// INZECTOIDZ
/datum/speech_filter/insectoid
	expressions = list()

/datum/speech_filter/insectoid/New()
	addReplacement("s", "z") //stolen from plasman code if it borks.

// CHAVS, INNIT
/datum/speech_filter/chav
	expressions = list()

/datum/speech_filter/chav/New()
	// Now, finally regex
	addReplacement("dick","prat")
	addReplacement("comdom","knob'ead")
	addReplacement("looking at","gawpin' at")
	addReplacement("great","bangin'")
	addReplacement("man","mate")
	addPickReplacement("friend",list("mate","bruv","bledrin"))
	addReplacement("what","wot")
	addReplacement("drink","wet")
	addReplacement("get","giz")
	addReplacement("what","wot")
	addReplacement("no thanks","wuddent fukken do one")
	addReplacement("i don't know","wot mate")
	addReplacement("no","naw")
	addReplacement("robust","chin")
	addWordReplacement("hi","how what how")
	addReplacement("hello","sup bruv")
	addReplacement("kill","bang")
	addReplacement("murder","bang")
	addReplacement("windows","windies")
	addReplacement("window","windy")
	addReplacement("break","do")
	addReplacement("your","yer")
	addReplacement("security","coppers")