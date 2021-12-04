//Inverts an HTML-colour string.
//I.e. "#FF0000" will become "#00FFFF".

//This will *ONLY* accept a colour in the
// form "#XXXXXX".  Nothing else will work!

/proc/invertHTML(HTMLstring)
	if(!istext(HTMLstring))
		CRASH("Given non-text argument!")
	else if(length(HTMLstring) != 7)
		CRASH("Given non-HTML argument!")

	var/textr = copytext(HTMLstring, 2,4)
	var/textg = copytext(HTMLstring, 4,6)
	var/textb = copytext(HTMLstring, 6,8)

	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)

	textr = num2hex(255-r)
	textg = num2hex(255-g)
	textb = num2hex(255-b)
	if(length(textr) < 2)
		textr = "0[textr]"
	if(length(textg) < 2)
		textr = "0[textg]"
	if(length(textb) < 2)
		textr = "0[textb]"

	return("#[textr][textg][textb]")


/*
//Testing code/sample implementation
mob/verb/test_invertHTML()
	to_chat(usr, "#CC9933")
	to_chat(usr, invertHTML("#CC9933"))
*/
