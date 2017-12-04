#define HTMLTAB "&nbsp;&nbsp;&nbsp;&nbsp;"

//Loops through every line in (text). The 'line' variable holds the current line
//Example use:
/*
var/text = {"Line 1
Line 2
Line 3
"}
forLineInText(text)
	world.log << line
*/
#define forLineInText(text) for({var/__index=1;var/line=copytext(text, __index, findtext(text, "\n", __index))} ; {__index != 0} ; {__index = findtext(text, "\n", __index+1) ; line = copytext(text, __index+1, findtext(text, "\n", __index+1))})

/*
 * Holds procs designed to help with filtering text
 * Contains groups:
 *			SQL sanitization
 *			Text sanitization
 *			Text searches
 *			Text modification
 *			Misc
 */


/*
 * SQL sanitization
 */

// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(var/t as text)
	//var/sanitized_text = replacetext(t, "'", "\\'")
	//sanitized_text = replacetext(sanitized_text, "\"", "\\\"")

	var/sqltext = dbcon.Quote(t)
	//testing("sanitizeSQL(): BEFORE copytext(): [sqltext]")
	sqltext = copytext(sqltext, 2, length(sqltext))//Quote() adds quotes around input, we already do that
	//testing("sanitizeSQL(): AFTER copytext(): [sqltext]")
	return sqltext

/*
/mob/verb/SanitizeTest(var/t as text)
	to_chat(src, "IN: [t]")
	to_chat(src, "OUT: [sanitizeSQL(t)]")
*/
/*
 * Text sanitization
 */

//Simply removes < and > and limits the length of the message
/proc/strip_html_simple(var/t,var/limit=MAX_MESSAGE_LEN)
	var/list/strip_chars = list("<",">")
	t = copytext(t,1,limit)
	for(var/char in strip_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + copytext(t, index+1)
			index = findtext(t, char)
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
/proc/sanitize_simple(var/t,var/list/repl_chars = list("\n"="#","\t"="#","�"="�"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	return t

//Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(var/t,var/list/repl_chars = null)
	return html_encode(sanitize_simple(t,repl_chars))

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

//Filters out undesirable characters from names
/proc/reject_bad_name(var/t_in, var/allow_numbers=0, var/max_length=MAX_NAME_LEN)
	if(!t_in || length(t_in) > max_length)
		return //Rejects the input if it is null or if it is longer then the max length allowed

	var/number_of_alphanumeric	= 0
	var/last_char_group			= 0
	var/t_out = ""

	for(var/i=1, i<=length(t_in), i++)
		var/ascii_char = text2ascii(t_in,i)
		switch(ascii_char)
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// a  .. z
			if(97 to 122)			//Lowercase Letters
				if(last_char_group<2)
					t_out += ascii2text(ascii_char-32)	//Force uppercase first character
				else
					t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(!last_char_group)
					continue	//suppress at start of string
				if(!allow_numbers)
					continue
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 3

			// '  -  .
			if(39,45,46)			//Common name punctuation
				if(!last_char_group)
					continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			// ~   |   @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43)			//Other symbols that we'll allow (mainly for AI)
				if(!last_char_group)
					continue	//suppress at start of string
				if(!allow_numbers)
					continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			//Space
			if(32)
				if(last_char_group <= 1)
					continue	//suppress double-spaces and spaces at start of string
				t_out += ascii2text(ascii_char)
				last_char_group = 1
			else
				return

	if(number_of_alphanumeric < 2)
		return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == 1)
		t_out = copytext(t_out,1,length(t_out))	//removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai","plating"))	//prevents these common metagamey names
		if(cmptext(t_out,bad_name))
			return	//(not case sensitive)

	return t_out

//checks text for html tags
//if tag is not in whitelist (var/list/paper_tag_whitelist in global.dm)
//relpaces < with &lt;
proc/checkhtml(var/t)
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
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

//Returns a string with double spaces removed
/proc/trimcenter(text)
	var/regex/trimcenterregex = regex("\\s{2,}","g")
	return trimcenterregex.Replace(text," ")

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))

//Returns a string with the first element of the string capitalized.
/proc/capitalize(var/t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

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

var/list/watt_suffixes = list("W", "KW", "MW", "GW", "TW", "PW", "EW", "ZW", "YW")
/proc/format_watts(var/number)
	if (number<0)
		return "-[format_watts(abs(number))]"
	if (number==0)
		return "0 W"

	var/max_watt_suffix = watt_suffixes.len
	var/i=1
	while (round(number/1000) >= 1)
		number/=1000
		i++
		if (i == max_watt_suffix)
			break

	return "[format_num(number)] [watt_suffixes[i]]"

//Returns 1 if [text] ends with [suffix]
//Example: text_ends_with("Woody got wood", "dy got wood") returns 1
//         text_ends_with("Woody got wood", "d") returns 1
//         text_ends_with("Woody got wood", "Wood") returns 0
proc/text_ends_with(text, suffix)
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
