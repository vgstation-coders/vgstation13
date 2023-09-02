#define HTMLTAB "&nbsp;&nbsp;&nbsp;&nbsp;"
#define UTF_LIMIT (1 << 20) + (1 << 16) - 1
#define string2charlist(string) (splittext(string, regex("(.)")) - splittext(string, ""))

/*
 * Holds procs designed to help with filtering text
 * Contains groups:
 *			Text sanitization
 *			Text searches
 *			Text modification
 *			Misc
 */

/*
 * Text sanitization
 */

//Simply removes < and > and limits the length of the message
/proc/strip_html_simple(var/t, var/limit=MAX_MESSAGE_LEN)
	var/list/strip_chars = list("<",">")
	t = copytext(t, 1, limit)
	for(var/char in strip_chars)
		t = replacetext(t, char, "")
	return t

/proc/strip_html_properly(input = "")
	// these store the position of < and > respectively
	var/opentag = 0
	var/closetag = 0

	while (input)
		opentag = rfindtext(input, "<")
		closetag = findtext(input, ">", opentag + 1)

		if (!opentag || !closetag)
			break

		input = copytext(input, 1, opentag) + copytext(input, closetag + 1)

	return input

/proc/rfindtext(Haystack, Needle, Start = 1, End = 0)
	var/i = findtext(Haystack, Needle, Start, End)

	while (i)
		. = i
		i = findtext(Haystack, Needle, i + 1, End)

//Removes a few problematic characters
/proc/sanitize_simple(var/t,var/list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		t = replacetext(t, char, repl_chars[char])
	return t

//Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(var/t,var/list/repl_chars = null)
	return html_encode(sanitize_simple(t,repl_chars))

/proc/sanitize_speech(var/t, var/limit = MAX_MESSAGE_LEN)
	//Currently allowed:
	//( -~): Printable ASCII
	//(¡-ÿ): Most of the Latin-1 supplement
	//(Ѐ-ӿ): The entire Cyrillic block
	var/static/regex/speech_regex = regex(@"[^ -~¡-ÿЀ-ӿ]", "g") //Matches all characters not in the above allowed ranges. In BYOND, \w doesn't work outside the ASCII range, so it's no help here.
	return trim(copytext(speech_regex.Replace(t, "*"), 1, limit)) //Note that this does NOT scrub HTML, because this is done in different places in me and say messages.

//Runs sanitize and strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' after sanitize() calls byond's html_encode()
/proc/strip_html(var/t,var/limit=MAX_MESSAGE_LEN)
	return copytext((sanitize(strip_html_simple(t))),1,limit)

//Runs byond's sanitization proc along-side strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' that html_encode() would cause
/proc/adminscrub(var/t,var/limit=MAX_MESSAGE_LEN)
	return copytext((html_encode(strip_html_simple(t))),1,limit)

/proc/reverse_text(txt)
	var/i = length(txt)+1
	. = ""
	while(--i)
		. += copytext(txt,i,i+1)

/*
 * returns null if there is any bad text in the string
 */
/proc/reject_bad_text(const/text, var/max_length = 512)
	var/text_length = length(text)

	if(text_length > max_length)
		return // message too long

	var/non_whitespace = FALSE

	for(var/i = 1 to text_length)
		switch(text2ascii(text, i))
			if(62, 60, 92, 47)
				return // rejects the text if it contains these bad characters: <, >, \ or /
			if(127 to 255)
				return // rejects weird letters like �
			if(0 to 31)
				return // more weird stuff
			if(32)
				continue //whitespace
			else
				non_whitespace = TRUE

	if(non_whitespace)
		return text // only accepts the text if it has some non-spaces

// Used to get a sanitized input.
/proc/stripped_input(var/mob/user, var/message = "", var/title = "", var/default = "", var/max_length=MAX_MESSAGE_LEN)
	var/name = input(user, message, title, default) as null|text
	return strip_html_simple(name, max_length)

//As above, but for full-size paragraph textboxes
/proc/stripped_message(var/mob/user, var/message = "", var/title = "", var/default = "", var/max_length=MAX_MESSAGE_LEN)
	var/name = input(user, message, title, default) as null|message
	return strip_html_simple(name, max_length)

/proc/test_ascii(var/text)
	for(var/i=1, i<=length(text), i++)
		world.log << text2ascii(text, i)

var/list/whitelist_name_diacritics_cap = list(
	"À", "Á", "Â", "Ã", "Ä", "Ä", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ð", "Ñ", "Ò", "Ó", "Ô", "Ö", "Ø", "Ù", "Ú", "Û", "Ü", "Ý",
)
var/list/whitelist_name_diacritics_min = list(
	"à", "á", "â", "ã", "ä", "ä", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï", "ð", "ñ", "ò", "ó", "ô", "ö", "ø", "ù", "ú", "û", "ü", "ý",
)

/proc/reject_bad_name(var/t_in, var/allow_numbers=0, var/max_length=MAX_NAME_LEN)
	if(!t_in || length(t_in) > max_length)
		return //Rejects the input if it is null or if it is longer then the max length allowed

	var/current_space = TRUE
	var/length = 0
	var/started = FALSE

	t_in = trim(t_in)
	var/t_out = ""
	for(var/i=1, i<=length(t_in), i++)
		var/ascii_char = text2ascii(t_in,i)
		switch(ascii_char)
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				started = TRUE
				current_space = FALSE
				t_out += t_in[i]
				length++
			// a  .. z
			if(97 to 122)			//Lowercase Letters
				started = TRUE
				if (current_space)
					current_space = FALSE
					t_out += ascii2text(ascii_char - 32)
				else
					current_space = FALSE
					t_out += t_in[i]
				length++

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(allow_numbers)
					if (!started)
						continue
					current_space = FALSE
					t_out += t_in[i]
					length++
				else
					continue

			// '  -  .
			if(39,45,46)			//Common name punctuation
				if (!started)
					continue
				current_space = FALSE
				t_out += t_in[i]


			// ~   |   @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43)			//Other symbols that we'll allow (mainly for AI)
				if(allow_numbers)
					if (!started)
						continue
					current_space = FALSE
					t_out += t_in[i]
				else
					continue


			//Space
			if(32)
				if (current_space)
					continue
				else
					current_space = TRUE
					t_out += t_in[i]
			else
				if (t_in[i] in whitelist_name_diacritics_cap)
					started = TRUE
					t_out += t_in[i]
					i++ // Those are two-bytes letters
					length++
					current_space = FALSE
				else if (t_in[i] in whitelist_name_diacritics_min)
					started = TRUE
					if (current_space)
						var/index = whitelist_name_diacritics_min.Find(t_in[i])
						t_out += whitelist_name_diacritics_cap[index]
						i++ // Those are two-bytes letters
						length++
						current_space = FALSE
					else
						t_out += t_in[i]
						i++ // Those are two-bytes letters
						length++
						current_space = FALSE
				else
					return

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai","plating"))	//prevents these common metagamey names
		if(cmptext(t_out,bad_name))
			return	//(not case sensitive)

	t_out = trim(t_out)

	if (length < 2)
		return

	return t_out

//checks text for html tags
//if tag is not in whitelist (var/list/paper_tag_whitelist in global.dm)
//relpaces < with &lt;
/proc/checkhtml(var/t)
	t = sanitize_simple(t, list("&#"="."))
	var/p = findtext(t,"<",1)
	while (p)	//going through all the tags
		var/start = p++
		var/tag = copytext(t,p, p+1)
		if (tag != "/")
			while (reject_bad_text(copytext(t, p, p+1), 1))
				tag = copytext(t,start, p)
				p++
			tag = copytext(t,start+1, p)
			if (!(tag in paper_tag_whitelist))	//if it's unkown tag, disarming it
				t = copytext(t,1,start-1) + "&lt;" + copytext(t,start+1)
		p = findtext(t,"<",p)
	return t
/*
 * Text searches
 */

//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

//Checks the beginning of a string for a specified sub-string. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix_case(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx(text, prefix, start, end)

//Checks the end of a string for a specified substring.
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)
	return

//Checks the end of a string for a specified substring. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix_case(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtextEx(text, suffix, start, null)

/*
 * Text modification
 */

//Adds 'u' number of zeros ahead of the text 't'
/proc/add_zero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t

//Adds 'u' number of spaces ahead of the text 't'
/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

//Adds 'u' number of spaces behind the text 't'
/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32 && text2ascii(text, i) <= UTF_LIMIT)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32 && text2ascii(text, i) <= UTF_LIMIT)
			return copytext(text, 1, i + 1)

	return ""

//Returns a string with double spaces removed
/proc/trimcenter(text)
	var/regex/trimcenterregex = regex("\\s{2,}","g")
	return trimcenterregex.Replace(text," ")

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))

//Returns the first word in a string.
/proc/get_first_word(text)
	var/list/L = splittext(text, " ")
	return L[1]

//Returns the last word in a string.
/proc/get_last_word(text)
	var/list/L = splittext(text, " ")
	return L[L.len]

//Returns a string with the first element of the string capitalized.
/proc/capitalize(var/t as text)
	return uppertext(copytext_char(t, 1, 2)) + copytext_char(t, 2)

//Centers text by adding spaces to either side of the string.
/proc/dd_centertext(message, length)
	var/new_message = message
	var/size = length(message)
	var/delta = length - size
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)
	if(delta == 1)
		return new_message + " "
	if(delta % 2)
		new_message = " " + new_message
		delta--
	var/spaces = add_lspace("",delta/2-1)
	return spaces + new_message + spaces

//Limits the length of the text. Note: MAX_MESSAGE_LEN and MAX_NAME_LEN are widely used for this purpose
/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)

/proc/stringmerge(var/text,var/compare,replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	if(length(text) != length(compare))
		return 0
	for(var/i = 1, i < length(text), i++)
		var/a = copytext(text,i,i+1)
		var/b = copytext(compare,i,i+1)
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext,1,i) + b + copytext(newtext, i+1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext,1,i) + a + copytext(newtext, i+1)
			else //The lists disagree, Uh-oh!
				return 0
	return newtext

/proc/stringpercent(var/text,character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= length(text), i++)
		var/a = copytext(text,i,i+1)
		if(a == character)
			count++
	return count

/**
 * Format number with thousands seperators.
 * @param number Number to format.
 * @param sep seperator to use
 */
/proc/format_num(var/number, var/sep=",")
	var/c="" // Current char
	var/list/parts = splittext("[number]",".")
	var/origtext = "[parts[1]]"
	var/len      = length(origtext)
	var/offset   = len % 3
	for(var/i=1;i<=len;i++)
		c = copytext(origtext,i,i+1)
		. += c
		if((i%3)==offset && i!=len)
			. += sep
	if(parts.len==2)
		. += ".[parts[2]]"


/**
 * Formats unites with their suffixes
 * Should be good for J, W, and stuff
 */
var/list/unit_suffixes = list("", "k", "M", "G", "T", "P", "E", "Z", "Y")

/proc/format_units(var/number, var/decimals=2)
	if (number<0)
		return "-[format_units(abs(number))]"
	if (number==0)
		return "0 "

	// Figure out suffix
	var/max_unit_suffix = unit_suffixes.len
	var/i=1
	while (round(number/1000) >= 1)
		number/=1000
		i++
		if (i == max_unit_suffix)
			break

	// Remove excess decimals
	decimals = 10 ** decimals
	number = round(number * decimals)/decimals

	return "[format_num(number)] [unit_suffixes[i]]"


/**
 * Old unit formatter, the TEG used to use this
 */
/proc/format_watts(var/number)
	return "[format_units(number)]W"


//Returns 1 if [text] ends with [suffix]
//Example: text_ends_with("Woody got wood", "dy got wood") returns 1
//         text_ends_with("Woody got wood", "d") returns 1
//         text_ends_with("Woody got wood", "Wood") returns 0
/proc/text_ends_with(text, suffix)
	if(length(suffix) > length(text))
		return FALSE

	return (copytext(text, length(text) - length(suffix) + 1) == suffix)

// Custom algorithm since stackoverflow is full of complete garbage and even the MS algorithm sucks.
// Uses recursion, in places.
// (c)2015 Rob "N3X15" Nelson <nexisentertainment@gmail.com>
// Available under the MIT license.

var/list/number_digits=list(
	"one",
	"two",
	"three",
	"four",
	"five",
	"six",
	"seven",
	"eight",
	"nine",
	"ten",
	"eleven",
	"twelve",
	"thirteen",
	"fourteen",
	"fifteen",
	"sixteen",
	"seventeen",
	"eighteen",
	"nineteen",
)

var/list/number_tens=list(
	null, // 0 :V
	null, // teens, special case
	"twenty",
	"thirty",
	"forty",
	"fifty",
	"sixty",
	"seventy",
	"eighty",
	"ninety"
)

var/list/number_units=list(
	null, // Don't yell units
	"thousand",
	"million",
	"billion"
)

// The " character
var/quote = ascii2text(34)

/proc/num2words(var/number, var/zero="zero", var/minus="minus", var/hundred="hundred", var/list/digits=number_digits, var/list/tens=number_tens, var/list/units=number_units, var/recursion=0)
	if(!isnum(number))
		warning("num2words fed a non-number: [number]")
		return list()
	number=round(number)
	//testing("num2words [recursion] ([number])")
	if(number == 0)
		return list(zero)

	if(number < 0)
		return list(minus) + num2words(abs(number), zero, minus, hundred, digits, tens, units, recursion+1)

	var/list/out=list()
	if(number < 1000)
		var/hundreds = round(number/100)
		//testing(" ([recursion]) hundreds=[hundreds]")
		if(hundreds)
			out += num2words(hundreds, zero, minus, hundred, digits, tens, units, recursion+1) + list(hundred)
			number %= 100
			if(number == 0)
				return out

	if(number < 100)
		// Teens
		if(number <= 19)
			out.Add(digits[number])
		else
			var/tens_place = tens[round(number/10)+1]
			//testing(" ([recursion]) tens_place=[round(number/10)+1] = [tens_place]")
			if(tens_place!=null)
				out.Add(tens_place)
			number = number%10
			//testing(" ([recursion]) number%10+1 = [number+1] = [digits[number+1]]")
			if(number>0)
				out.Add(digits[number])
	else
		var/i=1
		while(round(number) > 0)
			var/unit_number = number%1000
			//testing(" ([recursion]) [number]%1000 = [unit_number] ([i])")
			if(unit_number > 0)
				if(units[i])
					//testing(" ([recursion]) units = [units[i]]")
					out = list(units[i]) + out
				out = num2words(unit_number, zero, minus, hundred, digits, tens, units, recursion+1) + out
			number /= 1000
			i++
	//testing(" ([recursion]) out=list("+jointext(out,", ")+")")
	return out

///mob/verb/test_num2words(var/number as num)
//	to_chat(usr, "\"[jointext(num2words(number), " ")]\"")

// Sanitize inputs to avoid SQL injection attacks
/proc/sql_sanitize_text(var/text)
	text = replacetext(text, "'", "''")
	text = replacetext(text, ";", "")
	text = replacetext(text, "&", "")
	return text

/proc/is_letter(var/thing) // Thing is an ascii number
    return (thing >= 65 && thing <= 122)

/proc/buttbottify(var/message, var/min = 1, var/max = 3)
	var/list/split_phrase = splittext(message," ") // Split it up into words.

	var/list/prepared_words = split_phrase.Copy()
	var/i = rand(min,max)
	for(,i > 0,i--) //Pick a few words to change.

		if (!prepared_words.len)
			break
		var/word = pick(prepared_words)
		prepared_words -= word //Remove from unstuttered words so we don't stutter it again.
		var/index = split_phrase.Find(word) //Find the word in the split phrase so we can replace it.

		split_phrase[index] = "butt"
	return jointext(split_phrase," ") // No longer need to sanitize, speech is automatically html_encoded at render-time.

/proc/tumblrspeech(var/speech)
	if(!speech)
		return
	var/static/regex/hewwo_lowercase = new("l|r", "g")
	var/static/regex/hewwo_uppercase = new("L|R", "g")
	speech = hewwo_lowercase.Replace(speech, "w")
	speech = hewwo_uppercase.Replace(speech, "W")
	return speech

/proc/piratespeech(var/speech)
	if(!speech)
		return

	var/static/regex/cannon_lowercase = new("gun", "g")
	var/static/regex/cannon_uppercase = new("Gun", "g")
	var/static/regex/cannon_allcaps = new("GUN", "g")

	var/static/regex/locker_lowercase = new("heaven", "g")
	var/static/regex/locker_uppercase = new("Heaven", "g")
	var/static/regex/locker_allcaps = new("HEAVEN", "g")

	var/static/regex/aye_middle = new(" I ", "g")
	var/static/regex/aye_start = new("I ", "g")

	var/static/regex/aye_lowercase = new("yes", "g")
	var/static/regex/aye_uppercase = new("Yes", "g")
	var/static/regex/aye_allcaps = new("YES", "g")

	var/static/regex/argh_lowercase = new("are", "g")
	var/static/regex/argh_uppercase = new("Are", "g")
	var/static/regex/argh_allcaps = new("ARE", "g")

	var/static/regex/yarh_lowercase = new("yeah", "g")
	var/static/regex/yarh_uppercase = new("Yeah", "g")
	var/static/regex/yarh_allcaps = new("YEAH", "g")

	var/static/regex/cap_lowercase = new("captain", "g")
	var/static/regex/cap_uppercase = new("Captain", "g")
	var/static/regex/cap_allcaps = new("CAPTAIN", "g")

	var/static/regex/hos_lowercase = new("hos", "g")
	var/static/regex/hos_uppercase = new("HoS", "g")
	var/static/regex/hos_allcaps = new("HOS", "g")

	var/static/regex/hop_lowercase = new("hop", "g")
	var/static/regex/hop_uppercase = new("HoP", "g")
	var/static/regex/hop_allcaps = new("HOP", "g")

	var/static/regex/ai_lowercase = new("ai ", "g")
	var/static/regex/ai_uppercase = new("Ai ", "g")
	var/static/regex/ai_allcaps = new("AI ", "g")

	var/static/regex/treasure_lowercase = new("money", "g")
	var/static/regex/treasure_uppercase = new("Money", "g")
	var/static/regex/treasure_allcaps = new("MONEY", "g")

	var/static/regex/matey_lowercase = new("friend", "g")
	var/static/regex/matey_uppercase = new("Friend", "g")
	var/static/regex/matey_allcaps = new("FRIEND", "g")

	var/static/regex/vessel_lowercase = new("station", "g")
	var/static/regex/vessel_uppercase = new("Station", "g")
	var/static/regex/vessel_allcaps = new("STATION", "g")

	var/static/regex/rowboat_lowercase = new("shuttle", "g")
	var/static/regex/rowboat_uppercase = new("Shuttle", "g")
	var/static/regex/rowboat_allcaps = new("SHUTTLE", "g")

	var/static/regex/sails_lowercase = new("engine", "g")
	var/static/regex/sails_uppercase = new("Engine", "g")
	var/static/regex/sails_allcaps = new("ENGINE", "g")

	var/static/regex/sea_lowercase = new("space", "g")
	var/static/regex/sea_uppercase = new("Space", "g")
	var/static/regex/sea_allcaps = new("SPACE", "g")

	speech = cannon_lowercase.Replace(speech, "cannon")
	speech = cannon_uppercase.Replace(speech, "Cannon")
	speech = cannon_allcaps.Replace(speech, "CANNON")

	speech = locker_lowercase.Replace(speech, "davy jones' locker")
	speech = locker_uppercase.Replace(speech, "Davy Jones' locker")
	speech = locker_allcaps.Replace(speech, "DAVY JONES' LOCKER")

	speech = aye_middle.Replace(speech, " aye ")
	speech = aye_start.Replace(speech, "Aye ")

	speech = aye_lowercase.Replace(speech, "aye")
	speech = aye_uppercase.Replace(speech, "Aye")
	speech = aye_allcaps.Replace(speech, "AYE")

	speech = argh_lowercase.Replace(speech, "argh")
	speech = argh_uppercase.Replace(speech, "Argh")
	speech = argh_allcaps.Replace(speech, "ARGH")

	speech = yarh_lowercase.Replace(speech, "yarh")
	speech = yarh_uppercase.Replace(speech, "Yarh")
	speech = yarh_allcaps.Replace(speech, "YARH")

	speech = cap_lowercase.Replace(speech, "cap'n")
	speech = cap_uppercase.Replace(speech, "Cap'n")
	speech = cap_allcaps.Replace(speech, "CAP'N")

	speech = hos_lowercase.Replace(speech, "first mate")
	speech = hos_uppercase.Replace(speech, "First Mate")
	speech = hos_allcaps.Replace(speech, "FIRST MATE")

	speech = hop_lowercase.Replace(speech, "crewmaster")
	speech = hop_uppercase.Replace(speech, "Crewmaster")
	speech = hop_allcaps.Replace(speech, "CREWMASTER")

	speech = ai_lowercase.Replace(speech, "navigator ")
	speech = ai_uppercase.Replace(speech, "Navigator ")
	speech = ai_allcaps.Replace(speech, "NAVIGATOR ")

	speech = treasure_lowercase.Replace(speech, "treasure")
	speech = treasure_uppercase.Replace(speech, "Treasure")
	speech = treasure_allcaps.Replace(speech, "TREASURE")

	speech = matey_lowercase.Replace(speech, "matey")
	speech = matey_uppercase.Replace(speech, "Matey")
	speech = matey_allcaps.Replace(speech, "MATEY")

	speech = vessel_lowercase.Replace(speech, "vessel")
	speech = vessel_uppercase.Replace(speech, "Vessel")
	speech = vessel_allcaps.Replace(speech, "VESSEL")

	speech = rowboat_lowercase.Replace(speech, "rowboat")
	speech = rowboat_uppercase.Replace(speech, "Rowboat")
	speech = rowboat_allcaps.Replace(speech, "ROWBOAT")

	speech = sails_lowercase.Replace(speech, "sails")
	speech = sails_uppercase.Replace(speech, "Sails")
	speech = sails_allcaps.Replace(speech, "SAILS")

	speech = sea_lowercase.Replace(speech, "sea")
	speech = sea_uppercase.Replace(speech, "Sea")
	speech = sea_allcaps.Replace(speech, "SEA")

	return speech

//Removes all the <img> tags from a string, useful for logs.
/proc/remove_images(var/dat)
	if(!dat)
		return
	var/static/regex/image_finder = new(@"(<img)[^>]*(>)", "g")
	dat = image_finder.Replace(dat, "")
	return dat

/proc/nekospeech(var/speech)
	if(!speech)
		return
	var/static/regex/nya_lowercase = new("n(?=\[aeiou])|N(?=\[aeiou])", "g")
	var/static/regex/nya_uppercase = new("N(?=\[AEIOU])|n(?=\[AEIOU])", "g")
	var/static/regex/nya_Ny = new("^ny|^NY(?!\[A-Z])") //Thanks, saycode.
	speech = nya_lowercase.Replace(speech, "ny")
	speech = nya_uppercase.Replace(speech, "NY")
	speech = nya_Ny.Replace(speech, "Ny")
	return speech

/proc/count_matches(haystack, needle)
	var/last_index = 0
	var/count = 0
	do
		last_index = findtext(haystack, needle, last_index+1)
		if(last_index)
			count++
	while(last_index)
	return count

/proc/get_reflexive_pronoun(var/gender) //For when \himself won't work.
	switch(gender)
		if(MALE)
			return "himself"
		if(FEMALE)
			return "herself"
		if(PLURAL) //Can be used in conjunction with shift_verb_tense(). eg. "The bees cleans themselves." -> "The bees clean themselves."
			return "themselves"
		else
			return "itself"

/proc/shift_verb_tense(var/input) //Turns "slashes" into "slash" and "hits" into "hit".
	//Check if there's more than one word in the input, and if so, separate the first word from the rest, eg. "looks over at" separates into "looks" and " over at".
	var/space = findtext(input, " ")
	var/fromspace
	if(space)
		fromspace = copytext(input, space)
		input = copytext(input, 1, space)
	//Check if input ends in "es" or "s" and chop those off if so.
	var/inputlength = length(input)
	if(inputlength > 2)
		if(copytext(input, inputlength - 1, inputlength + 1) == "es") //If it ends in "es"
			var/third_to_last = copytext(input, inputlength - 2, inputlength - 1)
			if(findtext("cdefgklmnprstuvxz", third_to_last)) //If the third-to-last letter is any of the given letters, remove only the "s".
				input = copytext(input, 1, inputlength) //"smiles" becomes "smile"
			else if(third_to_last == "i")
				input = copytext(input, 1, inputlength - 2) + "y" //"parries" becomes "parry"
			else
				input = copytext(input, 1, inputlength - 1) //Otherwise remove the "es".
		else if(copytext(input, inputlength, inputlength + 1) == "s") //If the second-to-last letter isn't "e", and the last letter is "s", remove the "s".
			input = copytext(input, 1, inputlength)	//"gets" becomes "get"
	return input + fromspace

/proc/get_indefinite_article(input, gender = NEUTER)
	if (!input)
		return
	if (gender == PLURAL)
		return "some"
	else
		var/first = copytext(input, 1, 2)
		var/upperfirst = uppertext(first)
		if (first == upperfirst || findtext("AEIOU", upperfirst))
			return "an"
		else
			return "a"
