/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language" // Fluff name of language if any.
	var/desc = "A language."         // Short description for 'Check Languages'.
	var/speech_verb = "says"         // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"            // Used when sentence ends in a ?
	var/exclaim_verb = "exclaims"    // Used when sentence ends in a !
	var/whisper_verb = "whispers"    // For whispers and final whispers.
	var/colour = "body"         // CSS style to use for strings in this language.
	var/key = "x"                    // Character used to speak in language eg. :o for Unathi.
	var/flags = 0                    // Various language flags.
	var/native                       // If set, non-native speakers will have trouble speaking.
	var/list/syllables
	var/list/space_chance = 55       // Likelihood of getting a space in the random scramble string.

/datum/language/proc/get_spoken_verb(var/msg, var/silicon, var/mode, var/mob/speaker)
	if(istype(speaker))
		var/speaker_verb_override = speaker.get_spoken_verb(msg)
		if (speaker_verb_override)
			return speaker_verb_override
		if(locate(/obj/item/clothing/head/cardborg) in speaker.get_equipped_items())
			silicon = 1
	switch(mode)
		if(SPEECH_MODE_WHISPER)
			return "[whisper_verb]"
		if(SPEECH_MODE_FINAL)
			return "[whisper_verb] with their final breath"
	var/msg_end = copytext(msg,length(msg))
	switch(msg_end)
		if("!")
			return (silicon ? "declares" : exclaim_verb)
		if("?")
			return (silicon ? "queries" : ask_verb)
	return (silicon ? "states" : speech_verb)

/datum/language/proc/say_misunderstood(mob/M, message)
	return stars(message)

// N3X15-saycode splits saycode into two phases: filtering and rendering.
//  Therefore, filtering is in one proc while actual rendering is last.

/datum/language/proc/filter_speech(var/datum/speech/speech)
	//var/datum/speech/speech2 = speech.clone()
	speech.message_classes.Add(colour)
	speech.message=capitalize(speech.message)
	return speech

/datum/language/proc/render_speech(var/datum/speech/speech, var/html_message)
	// html_message is the message itself + <span> tags. Do NOT filter it.
	return "[get_spoken_verb(speech.message,issilicon(speech.speaker),speech.mode, speech.speaker)], [html_message]"

/* Obsolete, here for reference
/datum/language/proc/format_message(mob/M, message)
	return "[get_spoken_verb(message,issilicon(M))], <span class='message'><span class='[colour]'>\"[capitalize(message)]\"</span></span>"

/datum/language/proc/format_message_plain(mob/M, message)
	return "[get_spoken_verb(message,issilicon(M))], \"[capitalize(message)]\""

/datum/language/proc/format_message_radio(mob/M, message)
	return "[get_spoken_verb(message,issilicon(M))], <span class='[colour]'>\"[capitalize(message)]\"</span>"
*/

/datum/language/unathi
	name = LANGUAGE_UNATHI
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "roars"
	colour = "soghun"
	key = "*"
	syllables = list("ss","ss","ss","ss","skak","seeki","resh","las","esi","kor","sh")

/datum/language/clown
	name = LANGUAGE_CLOWN
	desc = "The forbidden language of clowns. Taught at the clown planet. Only native clowns can weave sentences in such a complex system. Composed of honking and clownish noises."
	speech_verb = "honks"
	ask_verb = "slips"
	exclaim_verb = "farts"
	whisper_verb = "bwoinks"
	colour = "clown"
	native=1
	key = "!"
	space_chance = 45
	syllables = list("honk", "henk", "nk", "ho", "ha", "hunke", "hunk", "hu", "ba", "nana", "bwo", "bwoink", "ink", "fart", "peel", "banana", "poot", "toot", "cluwn")

/datum/language/tajaran
	name = LANGUAGE_CATBEAST
	desc = "An expressive language that combines yowls and chirps with posture, tail and ears. Native to the Tajaran."
	speech_verb = "mrowls"
	ask_verb = "mrowls"
	exclaim_verb = "yowls"
	colour = "tajaran"
	key = "+"
	syllables = list("rr","rr","tajr","kir","raj","kii","mir","kra","ahk","nal","vah","khaz","jri","ran","darr", \
	"mi","jri","dynh","manq","rhe","zar","rrhaz","kal","chur","eech","thaa","dra","jurl","mah","sanu","dra","ii'r", \
	"ka","aasi","far","wa","baq","ara","qara","zir","sam","mak","hrar","nja","rir","khan","jun","dar","rik","kah", \
	"hal","ket","jurl","mah","tul","cresh","azu","ragh", "mro", "mra")

/datum/language/skrell
	name = LANGUAGE_SKRELLIAN
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verb = "warbles"
	colour = "skrell"
	key = "/"
	syllables = list("qr","qrr","xuq","qil","quum","xuqm","vol","xrim","zaoo","qu-uu","qix","qoo","zix","*","!")

/datum/language/vox
	name = LANGUAGE_VOX
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "caws"
	ask_verb = "creels"
	exclaim_verb = "shrieks"
	colour = "vox"
	key = "v"
	syllables = list("ti","ti","ti","hi","hi","ki","ki","ki","ki","ya","ta","ha","ka","ya","chi","cha","kah", \
	"SKRE","AHK","EHK","RAWK","KRA","AAA","EEE","KI","II","KRI","KA")

/datum/language/insectoid
	name = LANGUAGE_INSECT
	desc = "A collection of disquieting vibrations and chittering sounds, the spoken tongue of insectoids. "
	speech_verb = "chitters"
	ask_verb = "clicks"
	exclaim_verb = "hisses"
	colour = "gutter"
	key = "%"
	native = 1
	syllables = list("ch","ke","chi","tch","sk","skch","ra","kch","esk","kra","sh","tik","ech","ks")
	space_chance = 40

/datum/language/diona
	name = LANGUAGE_ROOTSPEAK
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	ask_verb = "creaks"
	exclaim_verb = "rustles"
	colour = "soghun"
	key = "q"
	flags = NONORAL
	syllables = list("hs","zt","kr","st","sh")

/datum/language/common
	name = LANGUAGE_GALACTIC_COMMON
	desc = "The language no one would ever use is now the language every race uses."
	key = "1"
	flags = RESTRICTED
	syllables = list("sa","lu","to","n","bo","na","ve","spe","ro","no","non","ki","el","vi","far","tas",
	"ne","da","dan","ko","kon","ka","kaj","kin","de","ami","ko","kio","vin","nen","ne","nio","mi","gi","gis","per",
	"po","vas","va","he","min","mi","cu","dig","di","gi","gis","nu","ven","as","kie","re","ven","dau")

/datum/language/human
	name = LANGUAGE_HUMAN
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	key = "7"
	colour = "solcom"

/datum/language/human/monkey
	name = LANGUAGE_MONKEY
	desc = "Ook ook ook."
	speech_verb = "chimpers"
	ask_verb = "chimpers"
	exclaim_verb = "screeches"
	key = "6"
	syllables = list("ook","eek", "ack", "ookie", "eekie", "AHAH", "ree", "mudik", "bix", "nood", "mof", "ugga")

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = LANGUAGE_TRADEBAND
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	colour = "say_quote"
	key = "2"
	space_chance = 100
	flags = CAN_BE_SECONDARY_LANGUAGE
	syllables = list("lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
					 "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore",
					 "magna", "aliqua", "ut", "enim", "ad", "minim", "veniam", "quis", "nostrud",
					 "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo",
					 "consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in",
					 "voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla",
					 "pariatur", "excepteur", "sint", "occaecat", "cupidatat", "non", "proident", "sunt",
					 "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum")

/datum/language/gutter
	name = LANGUAGE_GUTTER
	desc = "Much like Standard, this crude pidgin tongue descended from numerous languages and serves as Tradeband for criminal elements."
	speech_verb = "growls"
	colour = "gutter"
	key = "3"
	flags = CAN_BE_SECONDARY_LANGUAGE
	syllables = list("gra","ba","ba","breh","bra","rah","dur","ra","ro","gro","go","ber","bar","geh","heh","gra")

/datum/language/grey
	name = LANGUAGE_GREY
	desc = "Sounds more like quacking than anything else."
	key = "k"
	speech_verb = "quacks"
	ask_verb = "acks"
	exclaim_verb = "quacks loudly"
	colour = "grey"
	native=1
	space_chance = 100
	syllables = list("ACK", "AKACK", "ACK")

/datum/language/grey/say_misunderstood(mob/M, message)
	message="ACK"
	var/len = max(1,Ceiling(length(message)/3))
	if(len > 1)
		for(var/i=0,i<len,i++)
			message += " ACK"
	return message+"!"

/datum/language/skellington
	name = LANGUAGE_CLATTER
	desc = "Click clack go the bones."
	key = "z"
	speech_verb = "chatters"
	ask_verb = "clatters"
	exclaim_verb = "chatters loudly"
	colour = "sinister"
	native=1
	space_chance = 95
	flags = NONORAL
	syllables = list("CLICK", "CLACK")

/datum/language/golem
	name = LANGUAGE_GOLEM
	desc = "A slow, guttural language produced by the grinding of a golem's joints against one another."
	speech_verb = "grinds"
	ask_verb = "groans"
	exclaim_verb = "cracks"
	whisper_verb = "grumbles"
	colour = "golem"
	native = 1
	key = "8"
	flags = NONORAL
	syllables = list("oa","ur","ae","um","tu","gor","an","lo","ag","oon","po")

/datum/language/slime
	name = LANGUAGE_SLIME
	desc = "A tonal language produced by the bubbling of the ambient atmosphere through a slime's surface."
	speech_verb = "bubbles"
	ask_verb = "gurgles"
	exclaim_verb = "froths"
	whisper_verb = "burbles"
	colour = "slime"
	native = 1
	key = "f"
	flags = NONORAL
	syllables = list("ba","ab","be","eb","bi","ib","bo","ob","bu","ub")

/datum/language/skellington/say_misunderstood(mob/M, message)
	message="CLICK"
	var/len = max(1,Ceiling(length(message)/5))
	if(len > 1)
		for(var/i=0,i<len,i++)
			message += " CL[pick("A","I")]CK"
	return message+"!"

/datum/language/xenocommon
	name = LANGUAGE_XENO
	colour = "alien"
	desc = "The common tongue of the xenomorphs."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "hisses"
	key = "4"
	flags = RESTRICTED
	syllables = list("sss","sSs","SSS")

/datum/language/xenocommon/say_misunderstood(mob/M, message)
	return speech_verb

/datum/language/cultcommon
	name = LANGUAGE_CULT
	desc = "The chants of the occult, the incomprehensible."
	speech_verb = "intones"
	ask_verb = "intones"
	exclaim_verb = "chants"
	colour = "cult"
	key = "5"
	flags = RESTRICTED
	space_chance = 100
	syllables = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri", \
		"orkan", "allaq", "sas'so", "c'arta", "forbici", "tarem", "n'ath", "reth", "sh'yro", "eth", "d'raggathnor", \
		"mah'weyh", "pleggh", "at", "e'ntrath", "tok-lyr", "rqa'nap", "g'lt-ulotf", "ta'gh", "fara'qha", "fel", "d'amar det", \
		"yu'gular", "faras", "desdae", "havas", "mithum", "javara", "umathar", "uf'kal", "thenar", "rash'tla", \
		"sektath", "mal'zua", "zasan", "therium", "viortia", "kla'atu", "barada", "nikt'o", "fwe'sh", "mah", "erl", "nyag", "r'ya", \
		"gal'h'rfikk", "harfrandid", "mud'gib", "fuu", "ma'jin", "dedo", "ol'btoh", "n'ath", "reth", "sh'yro", "eth", \
		"d'rekkathnor", "khari'd", "gual'te", "nikka", "nikt'o", "barada", "kla'atu", "barhah", "hra" ,"zar'garis")

/datum/language/mouse
	name = LANGUAGE_MOUSE
	desc = "It's literally just squeaks."
	speech_verb = "squeaks"
	colour = "say_quote"
	key = "9"
	space_chance = 80
	syllables = list("squeak")

/datum/language/grue
	name = LANGUAGE_GRUE
	desc = "The sounds grues use to communicate with one another."
	speech_verb = "roars"
	ask_verb = "roars"
	exclaim_verb = "roars"
	whisper_verb = "hisses"
	key = "g"
	flags = RESTRICTED
	native = 1
	syllables = list("BWAAGH","BWOOGH","GRAAH","WAAGH","ROOHR","SWOOH","KROOH","KRAAH")
	space_chance = 100

/datum/language/martian
	name = LANGUAGE_MARTIAN
	desc = "Complex warbles and burbles used by the odd squid people."
	speech_verb = "burbles"
	ask_verb = "blorbles"
	exclaim_verb = "blurbs"
	key = "@"
	colour = "grey"
	flags = RESTRICTED
	space_chance = 35
	native = 1
	syllables = list("khah","kig","kitol","kaor","bar","dar","dator","lok","ma","mu","o","och","gort","gal")

/datum/language/deathsquad
	name = LANGUAGE_DEATHSQUAD
	desc = "A set of codewords that Nanotrasen's deathsquads use for communication."
	key = "&"
	colour = "dsquadradio"
	flags = RESTRICTED
	space_chance = 100
	syllables = list("alpha", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel", "india", "juliet", "kilo", "lima", "mike", "november", "oscar", "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor", "whiskey", "x-ray", "yankee", "zulu")

// Language handling.
/mob/proc/add_language(var/language)


	var/datum/language/new_language = all_languages[language]

	if(!istype(new_language) || (new_language in languages))
		return 0

	languages.Add(new_language)
	return 1

/mob/proc/remove_language(rem_language)
	var/datum/language/L = all_languages[rem_language]
	return languages.Remove(L)

/mob/living/remove_language(rem_language)
	. = ..()
	if(.)
		var/datum/language/L = all_languages[rem_language]
		if(default_language == L)
			if(languages.len)
				default_language = languages[1]
			else
				default_language = null

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak_lang(datum/language/speaking)
	return (universal_speak || (speaking in src.languages))

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	for(var/datum/language/L in languages)
		dat += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return

/mob/living/check_languages()
	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	if(default_language)
		dat += "Current default language: [default_language] - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/><br/>"

	for(var/datum/language/L in languages)
		if(L == default_language)
			dat += "<b>[L.name] (:[L.key])</b> - default - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/>[L.desc]<br/><br/>"
		else
			dat += "<b>[L.name] (:[L.key])</b> - <a href='byond://?src=\ref[src];default_lang=[L]'>set default</a><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")

/mob/living/Topic(href, href_list)
	if(href_list["default_lang"])
		if(usr != src)
			return
		if(href_list["default_lang"] == "reset")
			set_default_language(null)
		else
			var/datum/language/L = all_languages[href_list["default_lang"]]
			if(L)
				set_default_language(L)
		check_languages()
		return 1
	else
		return ..()

/datum/language/human/syllables = list(
"a", "ai", "an", "ang", "ao", "ba", "bai", "ban", "bang", "bao", "bei", "ben", "beng", "bi", "bian", "biao",
"bie", "bin", "bing", "bo", "bu", "ca", "cai", "can", "cang", "cao", "ce", "cei", "cen", "ceng", "cha", "chai",
"chan", "chang", "chao", "che", "chen", "cheng", "chi", "chong", "chou", "chu", "chua", "chuai", "chuan", "chuang", "chui", "chun",
"chuo", "ci", "cong", "cou", "cu", "cuan", "cui", "cun", "cuo", "da", "dai", "dan", "dang", "dao", "de", "dei",
"den", "deng", "di", "dian", "diao", "die", "ding", "diu", "dong", "dou", "du", "duan", "dui", "dun", "duo", "e",
"ei", "en", "er", "fa", "fan", "fang", "fei", "fen", "feng", "fo", "fou", "fu", "ga", "gai", "gan", "gang",
"gao", "ge", "gei", "gen", "geng", "gong", "gou", "gu", "gua", "guai", "guan", "guang", "gui", "gun", "guo", "ha",
"hai", "han", "hang", "hao", "he", "hei", "hen", "heng", "hm", "hng", "hong", "hou", "hu", "hua", "huai", "huan",
"huang", "hui", "hun", "huo", "ji", "jia", "jian", "jiang", "jiao", "jie", "jin", "jing", "jiong", "jiu", "ju", "juan",
"jue", "jun", "ka", "kai", "kan", "kang", "kao", "ke", "kei", "ken", "keng", "kong", "kou", "ku", "kua", "kuai",
"kuan", "kuang", "kui", "kun", "kuo", "la", "lai", "lan", "lang", "lao", "le", "lei", "leng", "li", "lia", "lian",
"liang", "liao", "lie", "lin", "ling", "liu", "long", "lou", "lu", "luan", "lun", "luo", "ma", "mai", "man", "mang",
"mao", "me", "mei", "men", "meng", "mi", "mian", "miao", "mie", "min", "ming", "miu", "mo", "mou", "mu", "na",
"nai", "nan", "nang", "nao", "ne", "nei", "nen", "neng", "ng", "ni", "nian", "niang", "niao", "nie", "nin", "ning",
"niu", "nong", "nou", "nu", "nuan", "nuo", "o", "ou", "pa", "pai", "pan", "pang", "pao", "pei", "pen", "peng",
"pi", "pian", "piao", "pie", "pin", "ping", "po", "pou", "pu", "qi", "qia", "qian", "qiang", "qiao", "qie", "qin",
"qing", "qiong", "qiu", "qu", "quan", "que", "qun", "ran", "rang", "rao", "re", "ren", "reng", "ri", "rong", "rou",
"ru", "rua", "ruan", "rui", "run", "ruo", "sa", "sai", "san", "sang", "sao", "se", "sei", "sen", "seng", "sha",
"shai", "shan", "shang", "shao", "she", "shei", "shen", "sheng", "shi", "shou", "shu", "shua", "shuai", "shuan", "shuang", "shui",
"shun", "shuo", "si", "song", "sou", "su", "suan", "sui", "sun", "suo", "ta", "tai", "tan", "tang", "tao", "te",
"teng", "ti", "tian", "tiao", "tie", "ting", "tong", "tou", "tu", "tuan", "tui", "tun", "tuo", "wa", "wai", "wan",
"wang", "wei", "wen", "weng", "wo", "wu", "xi", "xia", "xian", "xiang", "xiao", "xie", "xin", "xing", "xiong", "xiu",
"xu", "xuan", "xue", "xun", "ya", "yan", "yang", "yao", "ye", "yi", "yin", "ying", "yong", "you", "yu", "yuan",
"yue", "yun", "za", "zai", "zan", "zang", "zao", "ze", "zei", "zen", "zeng", "zha", "zhai", "zhan", "zhang", "zhao",
"zhe", "zhei", "zhen", "zheng", "zhi", "zhong", "zhou", "zhu", "zhua", "zhuai", "zhuan", "zhuang", "zhui", "zhun", "zhuo", "zi",
"zong", "zou", "zuan", "zui", "zun", "zuo", "zu",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi")

/datum/language
	var/list/scramble_cache = list()
#define SCRAMBLE_CACHE_LEN 20
/datum/language/proc/scramble(var/input)


	if(!syllables || !syllables.len)
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	if(input in scramble_cache)
		var/n = scramble_cache[input]
		scramble_cache -= input
		scramble_cache[input] = n
		return n

	var/list/scrambled_text_pieces = list(input)
	var/list/found_names = list()
	for(var/mob/living/carbon/human/H in player_list)
		var/list/nameparts = splittext(H.real_name," ")
		if(nameparts.len > 3) // so the clown or borgs can't abuse this to reveal languages with common words
			continue
		for(var/part in nameparts)
			if(findtext(lowertext(scrambled_text_pieces[scrambled_text_pieces.len]),lowertext(part))) // human player name in world?
				var/oldtext = scrambled_text_pieces[scrambled_text_pieces.len]
				scrambled_text_pieces.Remove(scrambled_text_pieces[scrambled_text_pieces.len]) // take out last element
				scrambled_text_pieces += splittext(oldtext,part,1,0,TRUE) // replace with split
				found_names += lowertext(part)

	. = ""
	var/capitalize = 1
	for(var/piece in scrambled_text_pieces)
		var/scramble_bit = ""
		if(lowertext(piece) in found_names)
			if(!capitalize && prob(95))
				scramble_bit += " "
			scramble_bit += piece // human name shows up here unscrambled
			if(prob(95))
				scramble_bit += " "
		else
			while(length(scramble_bit) < length(piece))
				var/next = pick(syllables)
				if(capitalize)
					next = capitalize(next)
					capitalize = 0
				scramble_bit += next
				var/chance = rand(100)
				if(chance <= 5)
					scramble_bit += ". "
					capitalize = 1
				else if(chance > 5 && chance <= space_chance)
					scramble_bit += " "
		. += scramble_bit

	. = trim(.)
	var/ending = copytext(., length(.))
	if(ending == ".")
		. = copytext(.,1,length(.)-1)
	var/input_ending = copytext(input, length(input))
	if(input_ending in list("!","?","."))
		. += input_ending

	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = .
	if(scramble_cache.len > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, scramble_cache.len-SCRAMBLE_CACHE_LEN-1)

#undef SCRAMBLE_CACHE_LEN
