/datum/role/changeling
	name = "Changeling"
	id = CHANGELING
	required_pref = CHANGELING
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	protected_traitor_prob = PROB_PROTECTED_RARE
	logo_state = "change-logoa"
	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/list/absorbed_chems = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/datum/power_holder/power_holder
	var/mimicing = ""

/datum/role/changeling/OnPostSetup()
	. = ..()
	power_holder = new(src)
	antag.current.make_changeling()
	var/honorific
	if(antag.current.gender == FEMALE)
		honorific = "Ms."
	else
		honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/role/changeling/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Changeling.</span>")
	to_chat(antag.current, "<span class='danger'>Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</span>")
	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	if (antag.current.mind && antag.current.mind.assigned_role == "Clown")
		to_chat(antag.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
		antag.current.mutations.Remove(M_CLUMSY)

	antag.current << sound('sound/effects/ling_intro.ogg')

/datum/role/changeling/ForgeObjectives()
	if(!antag.current.client.prefs.antag_objectives)
		AppendObjective(/datum/objective/freeform/changeling)
		return
	AppendObjective(/datum/objective/absorb)
	AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/target/steal)
	if(prob(50))
		AppendObjective(/datum/objective/chem_sample)
	if(prob(50))
		AppendObjective(/datum/objective/escape)
	else
		AppendObjective(/datum/objective/hijack)

/datum/role/changeling/proc/changelingRegen()
	if(antag && antag.current && antag.current.stat == DEAD)
		return
	var/changes = FALSE
	var/changeby = chem_charges
	chem_charges = Clamp(chem_charges + chem_recharge_rate, 0, chem_storage)
	if(chem_charges != changeby)
		changes = TRUE
	changeby = geneticdamage
	geneticdamage = max(0, geneticdamage-1)
	if(geneticdamage != changeby)
		changes = TRUE
	if(antag && changes)
		antag.current.updateChangelingHUD()

/datum/role/changeling/proc/GetDNA(var/dna_owner)
	var/datum/dna/chosen_dna
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			chosen_dna = DNA
			break
	return chosen_dna

/datum/role/changeling/process()
	changelingRegen()
	..()

// READ: Don't use the apostrophe in name or desc. Causes script errors.

var/list/powers = subtypesof(/datum/power/changeling)
var/list/powerinstances = list()
var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")


/datum/power			//Could be used by other antags too
	var/name = "Power"
	var/desc = "Placeholder"
	var/helptext = ""
	var/isVerb = 1 	// Is it an active power, or passive?
	var/verbpath // Path to a verb that contains the effects.

/datum/power/changeling
	var/allowduringlesserform = 0
	var/genomecost = 500000 // Cost for the changling to evolve this power.


/datum/power/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "Permits us to syphon the DNA from a human. They become one with us, and we become stronger."
	genomecost = 0
	verbpath = /obj/item/verbs/changeling/proc/changeling_absorb_dna

/datum/power/changeling/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	genomecost = 0
	verbpath = /obj/item/verbs/changeling/proc/changeling_transform

/datum/power/changeling/change_species
	name = "Change Species"
	desc = "We take on the apperance of a species that we have absorbed."
	genomecost = 0
	verbpath = /obj/item/verbs/changeling/proc/changeling_change_species

/datum/power/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We become weakened to a death-like state, where we will rise again from death."
	helptext = "Can be used before or after death. Duration varies greatly."
	genomecost = 0
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_fakedeath

// Hivemind

/datum/power/changeling/hive_upload
	name = "Hive Channel"
	desc = "We can channel a DNA into the airwaves, allowing our fellow changelings to absorb it and transform into it as if they acquired the DNA themselves."
	helptext = "Allows other changelings to absorb the DNA you channel from the airwaves. Will not help them towards their absorb objectives."
	genomecost = 0
	verbpath = /obj/item/verbs/changeling/proc/changeling_hiveupload

/datum/power/changeling/hive_download
	name = "Hive Absorb"
	desc = "We can absorb a single DNA from the airwaves, allowing us to use more disguises with help from our fellow changelings."
	helptext = "Allows you to absorb a single DNA and use it. Does not count towards your absorb objective."
	genomecost = 0
	verbpath = /obj/item/verbs/changeling/proc/changeling_hivedownload

/datum/power/changeling/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser.  We become a monkey."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_lesser_form

/datum/power/changeling/horror_form
	name = "Horror Form"
	desc = "This costly evolution allows us to transform into an all-consuming abomination. We are incredibly strong, to the point that we can force open airlocks, and are immune to conventional stuns."
	genomecost = 15
	verbpath = /obj/item/verbs/changeling/proc/changeling_horror_form

/datum/power/changeling/deaf_sting
	name = "Deaf Sting"
	desc = "We silently sting a human, completely deafening them for a short time."
	genomecost = 1
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_deaf_sting

/datum/power/changeling/blind_sting
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	genomecost = 2
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_blind_sting

/datum/power/changeling/silence_sting
	name = "Silence Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to a victim that they have been stung, until they try to speak and cannot."
	genomecost = 2
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_silence_sting

/datum/power/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice."
	helptext = "Will turn your voice into the name that you enter. We must constantly expend chemicals to maintain our form like this"
	genomecost = 3
	verbpath = /obj/item/verbs/changeling/proc/changeling_mimicvoice

/datum/power/changeling/extractdna
	name = "Extract DNA"
	desc = "We stealthily sting a target and extract the DNA from them."
	helptext = "Will give you the DNA of your target, allowing you to transform into them. Does not count towards absorb objectives."
	genomecost = 3
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_extract_dna_sting

/datum/power/changeling/transformation_sting
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform into another."
	helptext = "Does not provide a warning to others. The victim will transform much like a changeling would."
	genomecost = 3
	verbpath = /obj/item/verbs/changeling/proc/changeling_transformation_sting

/datum/power/changeling/paralysis_sting
	name = "Paralysis Sting"
	desc = "We silently sting a human, paralyzing them for a short time."
	genomecost = 4
	verbpath = /obj/item/verbs/changeling/proc/changeling_paralysis_sting

/datum/power/changeling/LSDSting
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a powerful hallunicationary chemical."
	helptext = "The target does not notice they have been stung.  The effect occurs after 30 to 60 seconds."
	genomecost = 3
	verbpath = /obj/item/verbs/changeling/proc/changeling_lsdsting

/datum/power/changeling/unfat_sting
	name = "Unfat Sting"
	desc = "We silently sting a human or ourselves, forcing them to rapidly metabolize their fat."
	helptext = "Caution: This can also target you!"
	genomecost = 0
	verbpath = /obj/item/verbs/changeling/proc/changeling_unfat_sting

/datum/power/changeling/fat_sting
	name = "Fat Sting"
	desc = "We silently sting a human or ourselves, forcing them to rapidly accumulate fat."
	helptext = "Caution: This can also target you!"
	genomecost = 0
	verbpath = /obj/item/verbs/changeling/proc/changeling_fat_sting

/datum/power/changeling/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	genomecost = 2
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_boost_range

/datum/power/changeling/Epinephrine
	name = "Epinephrine sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Gives the ability to instantly recover from stuns.  High chemical cost."
	genomecost = 4
	verbpath = /obj/item/verbs/changeling/proc/changeling_unstun

/datum/power/changeling/ChemicalSynth
	name = "Rapid Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 4
	isVerb = 0
	verbpath = /mob/proc/changeling_fastchemical

/datum/power/changeling/AdvChemicalSynth
	name = "Advanced Chemical-Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 8
	isVerb = 0
	verbpath = /mob/proc/changeling_fastchemical

/datum/power/changeling/EngorgedGlands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an extra 25 units of chemicals."
	genomecost = 4
	isVerb = 0
	verbpath = /mob/proc/changeling_engorgedglands

/datum/power/changeling/DigitalCamoflague
	name = "Digital Camouflage"
	desc = "We evolve the ability to distort our form and proportions, defeating common algorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill. We must constantly expend chemicals to maintain our form like this."
	genomecost = 3
	allowduringlesserform = 1
	verbpath = /obj/item/verbs/changeling/proc/changeling_digitalcamo

/datum/power/changeling/rapidregeneration
	name = "Rapid Regeneration"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	helptext = "Heals a moderate amount of damage every tick."
	genomecost = 8
	verbpath = /obj/item/verbs/changeling/proc/changeling_rapidregen

/datum/power/changeling/armblade
	name = "Arm Blade"
	desc = "We transform one of our arms into an organic blade that can cut through flesh and bone."
	helptext = "The blade can be retracted by using the same verb used to manifest it. It has a chance to deflect projectiles."
	genomecost = 5
	verbpath = /obj/item/verbs/changeling/proc/changeling_armblade

// /datum/power/changeling/chemsting
// 	name = "Chemical Sting"
// 	desc = "We repurpose our internal organs to process and recreate any chemicals we have learned, ready to inject into another lifeform or ourselves if needs be."
// 	helptext = "This can be used to hinder others, or help ourselves, through the application of medicines or poisons."
// 	genomecost = 1
// 	verbpath = /obj/item/verbs/changeling/proc/changeling_chemsting

// /datum/power/changeling/chemspit
// 	name = "Chemical Spit"
// 	desc = "We repurpose our internal organs to process and recreate any chemicals we have learned, ready to fire like projectile venom in our facing direction."
// 	helptext = "Handy for firing acid at enemies, providing we have learned such chemicals."
// 	genomecost = 1
// 	allowduringlesserform = 1
// 	verbpath = /obj/item/verbs/changeling/proc/changeling_chemspit
	
/datum/power_holder
	var/datum/role/R
	var/list/purchasedpowers = list()

/datum/power_holder/New(var/datum/role/newRole)
	R = newRole

/datum/power_holder/proc/EvolutionMenu()
	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	var/geneticpoints
	if(istype(R, /datum/role/changeling))
		var/datum/role/changeling/C = R
		geneticpoints = C.geneticpoints

	var/dat = "<html><head><title>Changling Evolution Menu</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != "")
						{
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == "")
						{
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0)
									{
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,name,desc,helptext,power,ownsthis){

					clearAll();

					var span = document.getElementById(id);


					body = "<table><tr><td>";
					body +=	"</td><td align='center'>";
					body +=	"<font size='2'><b>"+desc+"</b></font> <BR>";
					body +=	"<font size='2'><font color = 'red'><b>"+helptext+"</b></font> <BR>";

					if(!ownsthis)
					{
						body += "<a href='?src=\ref[src];P="+power+"'>Evolve</a>"
					}


					body += "</td><td align='center'>";
					body +=	"</td></tr></table>";

					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id)
								{
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1")
						{
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id)
							{
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id)
							{
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Changling Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current evolution points left to evolve with: [geneticpoints]<br>
					Absorb genomes to acquire more evolution points
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/i = 1
	for(var/datum/power/changeling/P in powerinstances)
		var/ownsthis = 0

		if(P in purchasedpowers)
			ownsthis = 1


		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P]",[ownsthis])'
					>
					<b id='search[i]'>Evolve [P] - Cost: [ownsthis ? "Purchased" : P.genomecost]</b>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>

		"}

		i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=powers;size=900x480")


/datum/role/changeling/proc/EvolutionMenu()
	set category = "Changeling"
	set desc = "Level up!"

	if(!usr || !usr.mind)
		return

	src = usr.mind.GetRole(CHANGELING)

	power_holder.EvolutionMenu()

/datum/power_holder/Topic(href, href_list)
	if(href_list["P"])
		purchasePower(href_list["P"])
		EvolutionMenu()

/datum/power_holder/proc/purchasePower(var/Pname, var/remake_verbs = 1)
	var/datum/mind/M = R.antag
	var/datum/power/changeling/Thepower = Pname
	var/datum/role/changeling/C = M.GetRole(CHANGELING)

	for (var/datum/power/changeling/P in powerinstances)
//		to_chat(world, "[P] - [Pname] = [P.name == Pname ? "True" : "False"]")
		if(P.name == Pname)
			Thepower = P
			break


	if(Thepower == null)
		to_chat(M.current, "This is awkward.  Changeling power purchase failed, please report this bug to a coder!")
		return

	if(Thepower in purchasedpowers)
		to_chat(M.current, "We have already evolved this ability!")
		return


	if(C.geneticpoints < Thepower.genomecost)
		to_chat(M.current, "We cannot evolve this... yet.  We must acquire more DNA.")
		return

	C.geneticpoints -= Thepower.genomecost

	purchasedpowers += Thepower

	if(!Thepower.isVerb && Thepower.verbpath)
		call(M.current, Thepower.verbpath)()
	else if(remake_verbs)
		M.current.make_changeling()

/datum/role/changeling/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	if (!power_holder) // This is for when you spawn as a new_player
		return
	new_character.make_changeling() // Will also restore any & all genomes/powers we have
