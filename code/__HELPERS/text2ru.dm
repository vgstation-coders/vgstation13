//Используем RUbayевские дефайны, ибо они няшные. но фикс всё равно наш.

#define JA         "я"
#define JA_TEMP    "¶"
#define JA_CHAT    "&#255;"
#define JA_POPUP   "&#1103;"
#define TEMP       0
#define CHAT       1
#define POPUP      2

//Что бы не портить основной файл, оставим это здесь. Как и остальные скрипты.
/proc/sanitize(var/t,var/list/repl_chars = null)
	return sanitize_simple_ru(t,repl_chars)

/proc/sanitize_uni(var/t,var/list/repl_chars = null)
	return sanitize_simple_uni_ru(t,repl_chars)

//Removes a few problematic characters я яшку меняем в надлежащий вид..
/proc/sanitize_simple_ru(var/t,var/list/repl_chars = list("\n"="#","\t"="#","пїЅ"="пїЅ",JA=JA_TEMP))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	t = html_encode(t) //а теперь сразу чиним.
	var/index = findtext(t, JA_TEMP)
	while(index)
		t = copytext(t, 1, index) + JA_CHAT + copytext(t, index+8)
		index = findtext(t, JA_TEMP)
	return t

//тут тоже самое.
/proc/sanitize_simple_uni_ru(var/t,var/list/repl_chars = list("\n"="#","\t"="#","пїЅ"="пїЅ",JA=JA_TEMP))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	t = html_encode(t)
	var/index = findtext(t, JA_TEMP)
	while(index)
		t = copytext(t, 1, index) + JA_POPUP + copytext(t, index+8)
		index = findtext(t, JA_TEMP)
	return t

//кусок рубея, что бы не возиться с большими и маленькими буквами в будущем.
var/ja_temp_ascii = text2ascii(JA_TEMP)

/proc/lowertext_alt(var/text)
	var/lenght = length(text)
	var/new_text = null
	var/lcase_letter
	var/letter_ascii

	var/p = 1
	while(p <= lenght)
		lcase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(lcase_letter)

		if((letter_ascii >= 65 && letter_ascii <= 90) || (letter_ascii >= 192 && letter_ascii < 223))
			lcase_letter = ascii2text(letter_ascii + 32)
		else if(letter_ascii == 223)
			lcase_letter = JA_TEMP

		new_text += lcase_letter
		p++

	return new_text

/proc/uppertext_alt(var/text)
	var/lenght = length(text)
	var/new_text = null
	var/ucase_letter
	var/letter_ascii

	var/p = 1
	while(p <= lenght)
		ucase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(ucase_letter)

		if((letter_ascii >= 97 && letter_ascii <= 122) || (letter_ascii >= 224 && letter_ascii < 255))
			ucase_letter = ascii2text(letter_ascii - 32)
		else if(letter_ascii == ja_temp_ascii)
			ucase_letter = "Я"

		new_text += ucase_letter
		p++

	return new_text

//конец. Пока всё, но думаю изза некоторых проблем, понадобится еще и rhtml encode\decode, но к этому я вернусь познее.
//Так же, замечу, я мог и не использовать sanitize как скрипт донор, но тогда пришлось бы опять елозить по чатам,
//и смотреть, где не пофикшена яшка. Так же сюда стоит добавить все скрипты которые так или иначе связаны с яшкой, например
//локальная замена в переводе букв или чатов.