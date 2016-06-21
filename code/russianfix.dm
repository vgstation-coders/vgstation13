//HTML ENCODE/DECODE + RUS TO CP1251 TODO: OVERRIDE html_encode after fix
/proc/rhtml_encode(var/msg)
	msg = replacetext(msg, "<", "&lt;")
	msg = replacetext(msg, ">", "&gt;")
	msg = replacetext(msg, "ÿ", "&#255;")
	return msg

/proc/rhtml_decode(var/msg)
	msg = replacetext(msg, "&gt;", ">")
	msg = replacetext(msg, "&lt;", "<")
	msg = replacetext(msg, "&#255;", "ÿ")
	return msg


//UPPER/LOWER TEXT + RUS TO CP1251 TODO: OVERRIDE uppertext
/proc/ruppertext(text as text)
	text = uppertext(text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 223)
			t += ascii2text(a - 32)
		else if (a == 184)
			t += ascii2text(168)
		else t += ascii2text(a)
	t = replacetext(t,"&#255;","ß")
	return t

/proc/rlowertext(text as text)
	text = lowertext(text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if (a > 191 && a < 224)
			t += ascii2text(a + 32)
		else if (a == 168)
			t += ascii2text(184)
		else t += ascii2text(a)
	return t


//TEXT SANITIZATION + RUS TO CP1251

/proc/sanitize_simple(var/t,var/list/repl_chars = list("\n"="#","\t"="#","ÿ"="&#255;","<"="&lt;",">"="&gt;"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	return t



//RUS CONVERTERS
/proc/russian_to_cp1251(var/msg)//CHATBOX
	return replacetext(msg, "ÿ", "&#255;")

/proc/russian_to_utf8(var/msg)//PDA PAPER POPUPS
	return replacetext(msg, "ÿ", "&#1103;")

/proc/utf8_to_cp1251(msg)
	return replacetext(msg, "&#1103;", "&#255;")

/proc/cp1251_to_utf8(msg)
	return replacetext(msg, "&#255;", "&#1103;")

/proc/edit_cp1251(msg)
	return replacetext(msg, "&#255;", "\\ß")

/proc/edit_utf8(msg)
	return replacetext(msg, "&#1103;", "\\ß")

/proc/post_edit_cp1251(msg)
	return replacetext(msg, "\\ß", "&#255;")

/proc/post_edit_utf8(msg)
	return replacetext(msg, "\\ß", "&#1103;")

var/global/list/rkeys = list(
	"à" = "f", "â" = "d", "ã" = "u", "ä" = "l",
	"å" = "t", "ç" = "p", "è" = "b", "é" = "q",
	"ê" = "r", "ë" = "k", "ì" = "v", "í" = "y",
	"î" = "j", "ï" = "g", "ð" = "h", "ñ" = "c",
	"ò" = "n", "ó" = "e", "ô" = "a", "ö" = "w",
	"÷" = "x", "ø" = "i", "ù" = "o", "û" = "s",
	"ü" = "m", "ÿ" = "z"
)

//RKEY2KEY
/proc/rkey2key(t)
	if(t in rkeys) return rkeys[t]
	return (t)

//TEXT MODS RUS
/proc/capitalize_cp1251(var/t as text)
	var/s = 2
	if (copytext(t,1,2) == ";")
		s += 1
	else if (copytext(t,1,2) == ":")
		s += 2
	return ruppertext(copytext(t, 1, s)) + copytext(t, s)

/proc/intonation(text)
	if (copytext(text,-1) == "!")
		text = "<b>[text]</b>"
	return text