var mode = null;
var question = null;
var time_left = 0;
var toggle_map = 0;
var toggle_vote_method = 1;
var selected_vote = 0;
var admin = 0;
var updates = 0;
var clearallup = 0;

function clearAll(){
	clearallup += 1;
	$("#vote_main").empty();
	$("#vote_choices").empty();
	$("#vote_admin").empty();
}

function fuck(){
	var shit = document.all[0].outerHTML;
	$("body").empty().text(shit);
	//alert(document.all[0].outerHTML);
}
function client_data(selection, privs){
	updates += 1;
	selected_vote = parseInt(selection) || 0;
	admin = parseInt(privs) || 0;
}

function update_mode(newMode, newQuestion, newTimeleft, vmap, vmethod){
	mode = newMode;
	question = newQuestion;
	time_left = parseInt(newTimeleft) || 0;
	toggle_map = parseInt(vmap) || 0;
	toggle_vote_method = parseInt(vmethod) || 1;
	$("#vote_choices").append($("<div class='item'></div>").append($("<div class='itemLabel'></div>").html("Time Left")).append($("<div class='itemContent'></div>").html(displayBar(time_left, 0, 60, (time_left >= 50) ? 'good' : (time_left >= 25) ? 'average' : 'bad', '<center>' + time_left + '</center>'))));
	$("#vote_choices").append($("<div class='item'></div>").append($("<div class='itemLabel'></div>").html("<br />Question")).append($("<div class='itemContentMedium'></div>").append($("<div class='statusDisplay'></div>").text(question))));

	$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=restart'>Call Restart Vote</a>")));
	$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=gamemode'>Call Gamemode Vote</a>")));
	$("#vote_main").append($("<div class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=crew_transfer'>Call Crew Transfer Vote</a>")));
	$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=custom'>Call Custom Vote</a>")));
	$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=map'>Call Map Vote</a>" + (admin == 2 ? "(<a href='?src=" + hSrc + ";vote=toggle_map'>" + (toggle_map?"All Compiled":"Votable") + "</a>)" : ""))));
	if(admin > 0) {
		var a = ((toggle_vote_method == 1) ? "Weighted" : (toggle_vote_method == 2) ? "Majority" : (toggle_vote_method == 3) ? "Persistent" : (toggle_vote_method == 4) ? "Random" : "Null");
		$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=toggle_vote_method'>" + a + "</a>")));
	}
	if(mode != null && mode != ""){
		$("#vote_main").hide();
		if(admin > 0){
			$("#vote_admin").show();
			$("#vote_admin").append($("<div class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=abort'>Abort the current vote</a>")));
			$("#vote_admin").append($("<div class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=rig'>Rig the current vote</a>")));
		}
		else{
			$("#vote_admin").hide();
		}
		$("#vote_choices").show();
		$("#vote_choices").append($("<div class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=cancel_vote'>Cancel your vote</a>")));
	}
	else{
		$("#vote_main").show();
		$("#vote_choices").hide();
		$("#vote_admin").hide();
	}
}

function update_choices(ID, choice, votes){
	try{ID = parseInt(ID);
		votes = parseInt(votes);}
	catch(ex){alert("Failed to parse something " + ID + " " + votes); return;}
	$("#vote_choices").append($("<div class='item'></div>").append($("<div id='choice_"+ID +"'></div>").html("<a " + (selected_vote == ID ? "class='linkOn' " : "")  +  "href='?src=" + hSrc + ";vote=" + ID + "'>"+choice+" (" + votes + " votes)</a>")));
}
function displayBar(value, rangeMin, rangeMax, styleClass, showText) {

	if (rangeMin < rangeMax)
	{
		if (value < rangeMin)
		{
			value = rangeMin;
		}
		else if (value > rangeMax)
		{
			value = rangeMax;
		}
	}
	else
	{
		if (value > rangeMin)
		{
			value = rangeMin;
		}
		else if (value < rangeMax)
		{
			value = rangeMax;
		}
	}

	if (typeof styleClass == 'undefined' || !styleClass)
	{
		styleClass = '';
	}

	if (typeof showText == 'undefined' || !showText)
	{
		showText = '';
	}

	var percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100);

	return '<div class="displayBar ' + styleClass + '"><div class="displayBarFill ' + styleClass + '" style="width: ' + percentage + '%;"></div><div class="displayBarText">' + showText + '</div></div>';
}
