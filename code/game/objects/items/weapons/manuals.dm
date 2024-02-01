/*********************MANUALS (BOOKS)***********************/

//Oh god what the fuck I am not good at computer
/obj/item/weapon/book/manual
	icon = 'icons/obj/library.dmi'
	due_date = 0 // Game time in 1/10th seconds
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/id = 0

/obj/item/weapon/book/manual/engineering_construction
	name = "Station Repairs and Construction"
	icon_state ="bookEngineering"
	item_state = "book3"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Station Repairs and Construction"
	wiki_page = "Guide_to_Construction"
	id = 1

/obj/item/weapon/book/manual/engineering_particle_accelerator
	name = "Particle Accelerator User's Guide"
	icon_state ="bookParticleAccelerator"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Particle Accelerator User's Guide"
//big pile of shit below.
	id = 2

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h3>Experienced user's guide</h3>

				<h4>Setting up</h4>

				<ol>
					<li><b>Wrench</b> all pieces to the floor</li>
					<li>Add <b>wires</b> to all the pieces</li>
					<li>Close all the panels with your <b>screwdriver</b></li>
				</ol>

				<h4>Use</h4>

				<ol>
					<li>Open the control panel</li>
					<li>Set the speed to 2</li>
					<li>Start firing at the singularity generator</li>
					<li><font color='red'><b>When the singularity reaches a large enough size so it starts moving on it's own set the speed down to 0, but don't shut it off</b></font></li>
					<li>Remember to wear a radiation suit when working with this machine... we did tell you that at the start, right?</li>
				</ol>

				</body>
				</html>"}


/obj/item/weapon/book/manual/engineering_hacking
	name = "Hacking"
	icon_state ="bookHacking"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Hacking"
	wiki_page = "Hacking"
	id = 3

/obj/item/weapon/book/manual/engineering_singularity_safety
	name = "Singularity Safety in Special Circumstances"
	icon_state ="bookEngineeringSingularitySafety"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Singularity Safety in Special Circumstances"
//big pile of shit below.
	id = 4
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Singularity Safety in Special Circumstances</h3>

				<h4>Power outage</h4>

				A power problem has made the entire station loose power? Could be station-wide wiring problems or syndicate power sinks. In any case follow these steps:
				<p>
				<b>Step one:</b> <b><font color='red'>PANIC!</font></b><br>
				<b>Step two:</b> Get your ass over to engineering! <b>QUICKLY!!!</b><br>
				<b>Step three:</b> Get to the <b>Area Power Controller</b> which controls the power to the emitters.<br>
				<b>Step four:</b> Swipe it with your <b>ID card</b> - if it doesn't unlock, continue with step 15.<br>
				<b>Step five:</b> Open the console and disengage the cover lock.<br>
				<b>Step six:</b> Pry open the APC with a <b>Crowbar.</b><br>
				<b>Step seven:</b> Take out the empty <b>power cell.</b><br>
				<b>Step eight:</b> Put in the new, <b>full power cell</b> - if you don't have one, continue with step 15.<br>
				<b>Step nine:</b> Quickly put on a <b>Radiation suit.</b><br>
				<b>Step ten:</b> Check if the <b>singularity field generators</b> withstood the down-time - if they didn't, continue with step 15.<br>
				<b>Step eleven:</b> Since disaster was averted you now have to ensure it doesn't repeat. If it was a powersink which caused it and if the engineering apc is wired to the same powernet, which the powersink is on, you have to remove the piece of wire which links the apc to the powernet. If it wasn't a powersink which caused it, then skip to step 14.<br>
				<b>Step twelve:</b> Grab your crowbar and pry away the tile closest to the APC.<br>
				<b>Step thirteen:</b> Use the wirecutters to cut the wire which is conecting the grid to the terminal. <br>
				<b>Step fourteen:</b> Go to the bar and tell the guys how you saved them all. Stop reading this guide here.<br>
				<b>Step fifteen:</b> <b>GET THE FUCK OUT OF THERE!!!</b><br>
				</p>

				<h4>Shields get damaged</h4>

				Step one: <b>GET THE FUCK OUT OF THERE!!! FORGET THE WOMEN AND CHILDREN, SAVE YOURSELF!!!</b><br>
				</body>
				</html>
				"}

/obj/item/weapon/book/manual/hydroponics_pod_people
	name = "Growing Dionae and YOU! A book on growing your new best friends!"
	icon_state ="bookHydroponicsPodPeople"
	item_state = "book5"
	author = "Farmer John"
	title = "Growing Dionae and YOU! A book on growing your new best friends!"
	id = 5
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Growing Dionae</h3>

				What are Dionae? These fun little plant people are something that every botanist needs to understand.
				<p>
				Dionae nypmh pods will produce a single nymph. Most of the time the nymph dies out producing more seeds for replanting but when a nymph fully realizes it will start crawling about and now has some new abilties!<br>
				Dionae can fertilze your crop, eat weeds and help around if they are willing.<br>
				Among the Dionae nymphs needs is blood collection. They are likely to flick out their feelers at new people around itself nicking a sample of their blood. <br>
				This blood sample is used by Dionae biology to gather the biological symbols from its source to garnish itself with new memories. They tend to mimic anything from their vocal patterns, languages, attitudes and opinons.<br>
				However this does not mean that they necessarily need to follow your every whim. They tend to form their own wants and needs, and your green children do grow up fast. With enough collected memory they will evolve into adult Dionae.<br>
				The Adult Dionae is not as capable a garden helper but they can apply to be a member of the station and to help you further as a normal botanist!<br>
				Its important to keep track of all your green creations as they tend to get into trouble if left to their own devices. They choose weather they want to help around the plants but encourage it!
				<p>

				</body>
				</html>
				"}

/obj/item/weapon/book/manual/medical_cloning
	name = "Cloning techniques of the 26th century"
	icon_state ="bookCloning"
	author = "Medical Journal, volume 3"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Cloning techniques of the 26th century"
	wiki_page = "Guide_to_Cloning"
	id = 6

/obj/item/weapon/book/manual/chemistry_manual
	name = "Chemistry 101"
	icon_state ="bookChemistry"
	item_state = "book6"
	author = "SpaceChem Inc."
	title = "Chemistry 101"
	wiki_page = "Guide_to_Chemistry"
	id = 7

/obj/item/weapon/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	icon_state ="book"
	author = "Weyland-Yutani Corp"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "APLU \"Ripley\" Construction and Operation Manual"
	id = 8
//big pile of shit below.

	/*dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Weyland-Yutani - Building Better Worlds</b>
				<h1>Autonomous Power Loader Unit \"Ripley\"</h1>
				</center>
				<h2>Specifications:</h2>
				<ul>
				<li><b>Class:</b> Autonomous Power Loader</li>
				<li><b>Scope:</b> Logistics and Construction</li>
				<li><b>Weight:</b> 820kg (without operator and with empty cargo compartment)</li>
				<li><b>Height:</b> 2.5m</li>
				<li><b>Width:</b> 1.8m</li>
				<li><b>Top speed:</b> 5km/hour</li>
				<li><b>Operation in vacuum/hostile environment:</b> Possible</b>
				<li><b>Airtank Volume:</b> 500liters</li>
				<li><b>Devices:</b>
					<ul>
					<li>Hydraulic Clamp</li>
					<li>High-speed Drill</li>
					</ul>
				</li>
				<li><b>Propulsion Device:</b> Powercell-powered electro-hydraulic system.</li>
				<li><b>Powercell capacity:</b> Varies.</li>
				</ul>

				<h2>Construction:</h2>
				<ol>
				<li>Connect all exosuit parts to the chassis frame</li>
				<li>Connect all hydraulic fittings and tighten them up with a wrench</li>
				<li>Adjust the servohydraulics with a screwdriver</li>
				<li>Wire the chassis. (Cable is not included.)</li>
				<li>Use the wirecutters to remove the excess cable if needed.</li>
				<li>Install the central control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the mainboard with a screwdriver.</li>
				<li>Install the peripherals control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the peripherals control module with a screwdriver</li>
				<li>Install the internal armor plating (Not included due to Nanotrasen regulations. Can be made using 5 metal sheets.)</li>
				<li>Secure the internal armor plating with a wrench</li>
				<li>Weld the internal armor plating to the chassis</li>
				<li>Install the external reinforced armor plating (Not included due to Nanotrasen regulations. Can be made using 5 reinforced metal sheets.)</li>
				<li>Secure the external reinforced armor plating with a wrench</li>
				<li>Weld the external reinforced armor plating to the chassis</li>
				<li></li>
				<li>Additional Information:</li>
				<li>The firefighting variation is made in a similar fashion.</li>
				<li>A firesuit must be connected to the Firefighter chassis for heat shielding.</li>
				<li>Internal armor is plasteel for additional strength.</li>
				<li>External armor must be installed in 2 parts, totaling 10 sheets.</li>
				<li>Completed mech is more resiliant against fire, and is a bit more durable overall</li>
				<li>Nanotrasen is determined to the safety of its <s>investments</s> employees.</li>
				</ol>
				</body>
				</html>

				<h2>Operation</h2>
				Coming soon...
			"}*/


/obj/item/weapon/book/manual/research_and_development
	name = "Research and Development 101"
	icon_state = "rdbook"
	author = "Dr. L. Ight"
	title = "Research and Development 101"
	id = 9
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Science For Dummies</h1>
				So you want to further SCIENCE? Good man/woman/thing! However, SCIENCE is a complicated process even though it's quite easy. For the most part, it's a three step process:
				<ol>
					<li> 1) Deconstruct items in the Destructive Analyzer to advance technology or improve the design.</li>
					<li> 2) Build unlocked designs in the Protolathe and Circuit Imprinter</li>
					<li> 3) Repeat!</li>
				</ol>

				Those are the basic steps to furthing science. What do you do science with, however? Well, you have four major tools: R&D Console, the Destructive Analyzer, the Protolathe, and the Circuit Imprinter.

				<h2>The R&D Console</h2>
				The R&D console is the cornerstone of any research lab. It is the central system from which the Destructive Analyzer, Protolathe, and Circuit Imprinter (your R&D systems) are controled. More on those systems in their own sections. On its own, the R&D console acts as a database for all your technological gains and new devices you discover. So long as the R&D console remains intact, you'll retain all that SCIENCE you've discovered. Protect it though, because if it gets damaged, you'll lose your data! In addition to this important purpose, the R&D console has a disk menu that lets you transfer data from the database onto disk or from the disk into the database. It also has a settings menu that lets you re-sync with nearby R&D devices (if they've become disconnected), lock the console from the unworthy, upload the data to all other R&D consoles in the network (all R&D consoles are networked by default), connect/disconnect from the network, and purge all data from the database.
				<b>NOTE:</b> The technology list screen, circuit imprinter, and protolathe menus are accessible by non-scientists. This is intended to allow 'public' systems for the plebians to utilize some new devices.

				<h2>Destructive Analyzer</h2>
				This is the source of all technology. Whenever you put a handheld object in it, it analyzes it and determines what sort of technological advancements you can discover from it. If the technology of the object is equal or higher then your current knowledge, you can destroy the object to further those sciences. Some devices (notably, some devices made from the protolathe and circuit imprinter) aren't 100% reliable when you first discover them. If these devices break down, you can put them into the Destructive Analyzer and improve their reliability rather then futher science. If their reliability is high enough ,it'll also advance their related technologies.

				<h2>Circuit Imprinter</h2>
				This machine, along with the Protolathe, is used to actually produce new devices. The Circuit Imprinter takes glass and various chemicals (depends on the design) to produce new circuit boards to build new machines or computers. It can even be used to print AI modules.

				<h2>Protolathe</h2>
				This machine is an advanced form of the Autolathe that produce non-circuit designs. Unlike the Autolathe, it can use processed metal, glass, solid plasma, silver, gold, and diamonds along with a variety of chemicals to produce devices. The downside is that, again, not all devices you make are 100% reliable when you first discover them.

				<h1>Reliability and You</h1>
				As it has been stated, many devices when they're first discovered do not have a 100% reliablity when you first discover them. Instead, the reliablity of the device is dependent upon a base reliability value, whatever improvements to the design you've discovered through the Destructive Analyzer, and any advancements you've made with the device's source technologies. To be able to improve the reliability of a device, you have to use the device until it breaks beyond repair. Once that happens, you can analyze it in a Destructive Analyzer. Once the device reachs a certain minimum reliability, you'll gain tech advancements from it.

				<h1>Building a Better Machine</h1>
				Many machines produces from circuit boards and inserted into a machine frame require a variety of parts to construct. These are parts like capacitors, batteries, matter bins, and so forth. As your knowledge of science improves, more advanced versions are unlocked. If you use these parts when constructing something, its attributes may be improved. For example, if you use an advanced matter bin when constructing an autolathe (rather then a regular one), it'll hold more materials. Experiment around with stock parts of various qualities to see how they affect the end results! Be warned, however: Tier 3 and higher stock parts don't have 100% reliability and their low reliability may affect the reliability of the end machine.
				</body>
				</html>
			"}


/obj/item/weapon/book/manual/robotics_cyborgs
	name = "Cyborgs for Dummies"
	icon_state = "borgbook"
	author = "XISC"
	title = "Cyborgs for Dummies"
	id = 10
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 18px; margin: 15px 0px 5px;}
				h3 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Cyborgs for Dummies</h1>

				<h2>Chapters</h2>

				<ol>
					<li><a href="#Equipment">Cyborg Related Equipment</a></li>
					<li><a href="#Modules">Cyborg Modules</a></li>
					<li><a href="#Construction">Cyborg Construction</a></li>
					<li><a href="#Maintenance">Cyborg Maintenance</a></li>
					<li><a href="#Repairs">Cyborg Repairs</a></li>
					<li><a href="#Emergency">In Case of Emergency</a></li>
				</ol>


				<h2><a id="Equipment">Cyborg Related Equipment</h2>

				<h3>Exosuit Fabricator</h3>
				The Exosuit Fabricator is the most important piece of equipment related to cyborgs. It allows the construction of the core cyborg parts. Without these machines, cyborgs can not be built. It seems that they may also benefit from advanced research techniques.

				<h3>Cyborg Recharging Station</h3>
				This useful piece of equipment will suck power out of the power systems to charge a cyborg's power cell back up to full charge.

				<h3>Robotics Control Console</h3>
				This useful piece of equipment can be used to immobolize or destroy a cyborg. A word of warning: Cyborgs are expensive pieces of equipment, do not destroy them without good reason, or Nanotrasen may see to it that it never happens again.


				<h2><a id="Modules">Cyborg Modules</h2>
				When a cyborg is created it picks out of an array of modules to designate its purpose. There are 6 different cyborg modules.

				<h3>Standard Cyborg</h3>
				The standard cyborg module is a multi-purpose cyborg. It is equipped with various modules, allowing it to do basic tasks.<br>A Standard Cyborg comes with:
				<ul>
				  <li>Crowbar</li>
				  <li>Stun Baton</li>
				  <li>Health Analyzer</li>
				  <li>Fire Extinguisher</li>
				</ul>

				<h3>Engineering Cyborg</h3>
				The Engineering cyborg module comes equipped with various engineering-related tools to help with engineering-related tasks.<br>An Engineering Cyborg comes with:
				<ul>
				  <li>A basic set of engineering tools</li>
				  <li>Metal Synthesizer</li>
				  <li>Reinforced Glass Synthesizer</li>
				  <li>An RCD</li>
				  <li>Wire Synthesizer</li>
				  <li>Fire Extinguisher</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Mining Cyborg</h3>
				The Mining Cyborg module comes equipped with the latest in mining equipment. They are efficient at mining due to no need for oxygen, but their power cells limit their time in the mines.<br>A Mining Cyborg comes with:
				<ul>
				  <li>Jackhammer</li>
				  <li>Shovel</li>
				  <li>Mining Satchel</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Security Cyborg</h3>
				The Security Cyborg module is equipped with effective security measures used to apprehend and arrest criminals without harming them a bit.<br>A Security Cyborg comes with:
				<ul>
				  <li>Stun Baton</li>
				  <li>Handcuffs</li>
				  <li>Taser</li>
				</ul>

				<h3>Janitor Cyborg</h3>
				The Janitor Cyborg module is equipped with various cleaning-facilitating devices.<br>A Janitor Cyborg comes with:
				<ul>
				  <li>Mop</li>
				  <li>Hand Bucket</li>
				  <li>Cleaning Spray Synthesizer and Spray Nozzle</li>
				</ul>

				<h3>Service Cyborg</h3>
				The service cyborg module comes ready to serve your human needs. It includes various entertainment and refreshment devices. Occasionally some service cyborgs may have been referred to as "Bros"<br>A Service Cyborg comes with:
				<ul>
				  <li>Shaker</li>
				  <li>Industrial Dropper</li>
				  <li>Platter</li>
				  <li>Beer Synthesizer</li>
				  <li>Zippo Lighter</li>
				  <li>Rapid-Service-Fabricator (Produces various entertainment and refreshment objects)</li>
				  <li>Pen</li>
				</ul>

				<h2><a id="Construction">Cyborg Construction</h2>
				Cyborg construction is a rather easy process, requiring a decent amount of metal and a few other supplies.<br>The required materials to make a cyborg are:
				<ul>
				  <li>Metal</li>
				  <li>Two Flashes</li>
				  <li>One Power Cell (Preferrably rated to 15000w)</li>
				  <li>Some electrical wires</li>
				  <li>One Human Brain</li>
				  <li>One Man-Machine Interface</li>
				</ul>
				Once you have acquired the materials, you can start on construction of your cyborg.<br>To construct a cyborg, follow the steps below:
				<ol>
				  <li>Start the Exosuit Fabricators constructing all of the cyborg parts</li>
				  <li>While the parts are being constructed, take your human brain, and place it inside the Man-Machine Interface</li>
				  <li>Once you have a Robot Head, place your two flashes inside the eye sockets</li>
				  <li>Once you have your Robot Chest, wire the Robot chest, then insert the power cell</li>
				  <li>Attach all of the Robot parts to the Robot frame</li>
				  <li>Insert the Man-Machine Interface (With the Brain inside) Into the Robot Body</li>
				  <li>Congratulations! You have a new cyborg!</li>
				</ol>

				<h2><a id="Maintenance">Cyborg Maintenance</h2>
				Occasionally Cyborgs may require maintenance of a couple types, this could include replacing a power cell with a charged one, or possibly maintaining the cyborg's internal wiring.

				<h3>Replacing a Power Cell</h3>
				Replacing a Power cell is a common type of maintenance for cyborgs. It usually involves replacing the cell with a fully charged one, or upgrading the cell with a larger capacity cell.<br>The steps to replace a cell are follows:
				<ol>
				  <li>Unlock the Cyborg's Interface by swiping your ID on it</li>
				  <li>Open the Cyborg's outer panel using a crowbar</li>
				  <li>Remove the old power cell</li>
				  <li>Insert the new power cell</li>
				  <li>Close the Cyborg's outer panel using a crowbar</li>
				  <li>Lock the Cyborg's Interface by swiping your ID on it, this will prevent non-qualified personnel from attempting to remove the power cell</li>
				</ol>

				<h3>Exposing the Internal Wiring</h3>
				Exposing the internal wiring of a cyborg is fairly easy to do, and is mainly used for cyborg repairs.<br>You can easily expose the internal wiring by following the steps below:
				<ol>
				  <li>Follow Steps 1 - 3 of "Replacing a Cyborg's Power Cell"</li>
				  <li>Open the cyborg's internal wiring panel by using a screwdriver to unsecure the panel</li>
			  </ol>
			  To re-seal the cyborg's internal wiring:
			  <ol>
			    <li>Use a screwdriver to secure the cyborg's internal panel</li>
			    <li>Follow steps 4 - 6 of "Replacing a Cyborg's Power Cell" to close up the cyborg</li>
			  </ol>

			  <h2><a id="Repairs">Cyborg Repairs</h2>
			  Occasionally a Cyborg may become damaged. This could be in the form of impact damage from a heavy or fast-travelling object, or it could be heat damage from high temperatures, or even lasers or Electromagnetic Pulses (EMPs).

			  <h3>Dents</h3>
			  If a cyborg becomes damaged due to impact from heavy or fast-moving objects, it will become dented. Sure, a dent may not seem like much, but it can compromise the structural integrity of the cyborg, possibly causing a critical failure.
			  Dents in a cyborg's frame are rather easy to repair, all you need is to apply a welding tool to the dented area, and the high-tech cyborg frame will repair the dent under the heat of the welder.

        <h3>Excessive Heat Damage</h3>
        If a cyborg becomes damaged due to excessive heat, it is likely that the internal wires will have been damaged. You must replace those wires to ensure that the cyborg remains functioning properly.<br>To replace the internal wiring follow the steps below:
        <ol>
          <li>Unlock the Cyborg's Interface by swiping your ID</li>
          <li>Open the Cyborg's External Panel using a crowbar</li>
          <li>Remove the Cyborg's Power Cell</li>
          <li>Using a screwdriver, expose the internal wiring or the Cyborg</li>
          <li>Replace the damaged wires inside the cyborg</li>
          <li>Secure the internal wiring cover using a screwdriver</li>
          <li>Insert the Cyborg's Power Cell</li>
          <li>Close the Cyborg's External Panel using a crowbar</li>
          <li>Lock the Cyborg's Interface by swiping your ID</li>
        </ol>
        These repair tasks may seem difficult, but are essential to keep your cyborgs running at peak efficiency.

        <h2><a id="Emergency">In Case of Emergency</h2>
        In case of emergency, there are a few steps you can take.

        <h3>"Rogue" Cyborgs</h3>
        If the cyborgs seem to become "rogue", they may have non-standard laws. In this case, use extreme caution.
        To repair the situation, follow these steps:
        <ol>
          <li>Locate the nearest robotics console</li>
          <li>Determine which cyborgs are "Rogue"</li>
          <li>Press the lockdown button to immobolize the cyborg</li>
          <li>Locate the cyborg</li>
          <li>Expose the cyborg's internal wiring</li>
          <li>Check to make sure the LawSync and AI Sync lights are lit</li>
          <li>If they are not lit, pulse the LawSync wire using a multitool to enable the cyborg's Law Sync</li>
          <li>Proceed to a cyborg upload console. Nanotrasen usually places these in the same location as AI uplaod consoles.</li>
          <li>Use a "Reset" upload moduleto reset the cyborg's laws</li>
          <li>Proceed to a Robotics Control console</li>
          <li>Remove the lockdown on the cyborg</li>
        </ol>

        <h3>As a last resort</h3>
        If all else fails in a case of cyborg-related emergency. There may be only one option. Using a Robotics Control console, you may have to remotely detonate the cyborg.
        <h3>WARNING:</h3> Do not detonate a borg without an explicit reason for doing so. Cyborgs are expensive pieces of Nanotrasen equipment, and you may be punished for detonating them without reason.

        </body>
		</html>
		"}

/obj/item/weapon/book/manual/security_space_law
	name = "Space Law"
	desc = "A set of Nanotrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	item_state = "bookSpaceLaw"
	author = "Nanotrasen"
	title = "Space Law"
	wiki_page = "Space_Law"
	id = 11

/obj/item/weapon/book/manual/security_antag_guide	//if you wanna edit, just copypaste the dat into https://www.w3schools.com/html/tryit.asp?filename=tryhtml_default
	name = "Enemies of Nanotrasen: A Quick Overview"
	desc = "Basic knowledge on how to identify and deal with the various intelligent threats to the station."
	icon_state = "bookAntagGuide"
	item_state = "bookAntagGuide"
	author = "Nanotrasen"
	title = "Enemies of Nanotrasen: A Quick Overview"
	id = 12
	book_width = 692

/obj/item/weapon/book/manual/security_antag_guide/New(turf/loc)
	..()
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 32px; margin: 15px 0px 5px;color:#F7D61A;background-color: #990000;}
				h2 {font-size: 24px; margin: 15px 0px 5px;color:#F7D61A;background-color: #990000;}
				h3 {font-size: 18px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				p  {text-indent: 25;}
				a:link {color: #F7D61A; background-color: transparent; text-decoration: none;}
				a:visited {color: #F7D61A; background-color: transparent; text-decoration: none;}
				</style>
				</head>
				<body style="font-size: 18px;color:#F7D61A;background-color:#221111;">

				<h1><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "nano-logo"))]' style='position: relative; top: 6;'>Enemies of Nanotrasen: A Quick Overview<img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "nano-logo"))]' style='position: relative; top: 6;'></h1>
                <h2>Foreword</h2>
				<p>Over the years since Nanotrasen secured its position as an interstellar megacorporation, various hostile groups and belligerent entities have made repeated attempts to disrupt our operations. The threat levels from these forces vary, but all of them pose a threat to our productivity and safety. Every Nanotrasen employee has a professional responsibility to identify agents of these hostile organizations. This guide contains information known about these foes, and aims to provide employees with a reference to identify their activities. A well-informed workforce ready to react to these insurgents is crucial to ensuring Nanotrasen’s continued success. Every employee can make a difference!


				<h2>Chapters</h2>

				<ol>
					<li><a href="#Syndicate">The Syndicate</a></li>
					<li><a href="#Vampire">The Vampire Lords</a></li>
					<li><a href="#Changeling">The Changeling Hivemind</a></li>
					<li><a href="#Wizard">The Wizard Federation</a></li>
					<li><a href="#Cult">The Cult of Nar-Sie</a></li>
					<li><a href="#Revolution">The Revolutionaries</a></li>
					<li><a href="#Blob">The Blob Conglomerate</a></li>
					<li><a href="#Malf">The Free Silicon Hivemind</a></li>
					<li><a href="#Vox">The Vox Shoal's Raiders</a></li>
					<li><a href="#Ninja">The Spider Clan</a></li>
					<li><a href="#Minor">other minor factions and threats of note</a>
                    <ol>
					<li><a href="#Alien">The Alien Hivemind</a></li>
					<li><a href="#Catbeast">Feral Catbeasts</a></li>
					<li><a href="#Time">The Time Agency</a></li>
					<li><a href="#Rambler">Soul Ramblers</a></li>
					<li><a href="#Plague">Plague Mice</a></li>
					<li><a href="#Grue">Grues</a></li>
					<li><a href="#Pulse">Pulse Demons</a></li>
					<li><a href="#Spider">Giant Space Spiders</a></li>
                    </ol>
                    </li>
				</ol>


				<h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "synd-logo"))]' style='position: relative; top: 8;'><a id="Syndicate">The Syndicate</h2>

                <p>The Syndicate is an alliance composed of Nanotrasen’s most disreputable corporate competitors. They are the most notorious threat we face, and have made it their goal to challenge our influence in this sector. In an attempt to do this, they have funneled saboteurs into our workforce, and at times even send strike teams to destroy our stations by using nuclear devices. Syndicate operators are to be detained immediately, and in some extreme cases, terminated on sight. Their distinctive red attire has been attributed to the scavenged soviet spacesuits from the fourth Cold War era that their operatives use as combat armor and EVA equipment.

				<h3>Traitors</h3>
				<p>Agents of the Syndicate have infiltrated many of our space stations and operate among us. This vast network of sleeper cells defies all investigation, and as such pre-emptive attempts at discovering infiltrators is discouraged by company policy (see Space Law and Standard Operating Procedure). However, agents come equipped with an uplink filled with "telecrystals" (TCs), hidden in their PDAs. When the Syndicate activates them, they are able to use this uplink to transport contraband aboard our stations to assist their attempts to cause wanton sabotage and destruction. Syndicate contraband can be a quick identifier of these saboteurs.

				<h3>Nuclear Operatives</h3>
				<p>A highly trained team of Syndicate special agents, usually equipped with red rigsuits and 12mm SMGs. With blatant disrespect for the lives of their agents, the Syndicate has rigged their brains with explosive implants, in the goal of taking their aggressor's life in their final breath. It is recommended to keep your distance as you fight them. The Operatives' goal is to acquire the station captain's nuclear authentication disk, so they can prime the nuclear fission device they carry in their ship and blow the station up to smithereens. Confirmed sightings of operatives are grounds to provide the crew with armory weapons as you will need all the firepower you can muster to fight them back. Sightings of operatives with cyborgs and mechas have been reported, against which it is recommended to use the ion rifles provided in your armory. Keep track of the disk's location at all times, and secure high priority locations such as the Armory, Medbay, Telecomms, and Engineering.

				<h3>Challengers</h3>
				<p>In a twisted parody of an interview process, the Syndicate's newest agents go through a so-called "Battle Royale" in which they attempt to eliminate one another aboard our stations. On the bright side, those challengers are here to kill each other. On the downside, they don't care about how much collateral damage they cause, AND the victor may graduate to become a fully fledged Syndicate agent, enabling them to cause even more trouble. We do not want that. Challengers often grimly display the corpse of their target on Newscasters. You may use this excess of hubris to try and figure out the identity of the victor so you may deal with them.

				<h3>Elite Strike Team</h3>
				<p><b>Sensitive Information: Restricted Diffusion.</b> The Syndicate's strongest soldiers. Those who have often accomplished and survived the destruction of several space stations. Sightings are rare, but they generally seem to field upgraded black rigsuits and extremely lethal ballistic weaponry. Their arrival is almost certain to spell doom for any station in a sector; do what you can to stop or delay them.

				<h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "vampire-logo"))]' style='position: relative; top: 8;'><a id="Vampire">The Vampire Lords</h2>
				<p>It has come to our attention that some of our employees have displayed a simultaneous propension for hematophagy, hypersensitivity to sunlight, and ability to perform various anomalous feats. Research on these symptoms has led us to find reports of similar cases a long time ago on Earth, therefore we give those individuals the same name label they were given back then: "vampires". We don't know for sure if those crew members developed those abilities here in space, or if they came from Earth and managed to hide among the migrants to our system, but they seem to exhibit a tendency to try and turn our space stations into their own personal territories and blood banks, therefore they are to be stopped in their ambitions.
                <p>Some of the anomalous powers observed include the ability to turn into dangerous bats, scream loud enough to shatter eardrums and windows alike, hypnotize humans into a paralysis, turn those humans into their thralls, and quickly regenerate their cells to heal all of their own wounds, even from a seemingly dead state. This last ability also lets them recover instantly from a stunned state, reducing the effectiveness of tasers at incapacitating them.
                <p>They become more powerful as they consume more blood and develop new abilities that often render conventional ways of fighting them inefficient. Fortunately, experiments on a few captured individuals have revealed a deadly allergy to holy water, harebells incense, and garlic, and most importantly: they spontaneously combust until only ashes remain when in view of the sun or when they find themselves in a holy place, which has greatly reinforced the incentive to build chapels aboard our space stations. Lastly, the Nullrods carried by chaplains have shown great efficiency at protecting their wielders from the vampires' powers.

				<h3>Thralls</h3>
				<p>Thralls are unfortunate crewmembers who have been subjugated by a Vampire lord's powers into servitude. They will try to accomplish the will of their master and fight to defend them. But they are not beyond saving: holy water has been reported to actively counter a vampire's influence on the human mind.

				<h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "change-logoa"))]' style='position: relative; top: 8;'><a id="Changeling">The Changeling Hivemind</h2>
				<p>Changelings are eldritch creatures hiding amongst the crew. Their usual goals involve trapping and consuming crew members, allowing them to take on their appearance and masquerade as them. Should the threat they represent remain unattended, they will eventually remain as the crew's last member.
                <p>There are no notable visual differences between a regular human and a changeling most of the time, so stay alert for sudden changes in personality among the crew. However they display highly visible mutations when using their abilities: they use a proboscis to both extract a human's DNA, or to inject them with various harmful chemicals. Changelings driven into a corner may fight back. There have been reports describing them mutating into a horrifying form, making them extremely lethal and resistant.
                <p>On top of all of this, just like vampires they can regenerate even from death, but they do not share their weaknesses, so you will have to destroy their bodies down to the last atom. The kitchen gibber and the chapel's crematorium may prove useful in that endeavour.

				<h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "wizard-logo"))]' style='position: relative; top: 8;'><a id="Wizard">The Wizard Federation</h2>
				<p>Out of all the enemies of our corporation out there, these have proven to be the most puzzling and unpredictable. Most of them suddenly appear aboard our space stations dressed in robes, sandals and large hats, and proceed to manifest a plethora of anomalous abilities that wreak havoc among our crews. Due to the unexplained nature of their powers, and their strange appearance, we label those individuals "wizards".
                <p>We've had many different reports on what they can do, dozens upon dozens of cases that would not fit inside this manual, but here are a few to give you some expectations. Some of them: have cars that can drive through walls, can touch anything to send it somewhere else on the station, can summon lightning at their fingertips, can cause the posterior of crew members to spontaneously leave their body, can turn people to stone, can animate objects into fighting for them, can teleport around freely, the list just goes on and on...
                <p>One relevant piece of information is that most of them seem to rely on their clothes to channel their powers, so stripping them naked should render them mostly harmless, although be mindful, there are always exceptions to the rule.
				<p>Regardless of how you deal with them, do not under any circumstances use their brains to create silicon entities such as AIs or cyborgs.

				<h3>No Sense of Right or Wrong</h3>
                <p>Some of the wizard's most confounding spells simply cause loads of guns, spell books, melee weapons, or potions to appear next to crew members. We don't know why they do it, but we do know that this strangely results in the crew quickly going crazy and fighting among themselves. We urge the Security department to confiscate any summoned item and the crew to cooperate with them, lest the station turns into a bloodbath.

			  <h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "cult-logo"))]' style='position: relative; top: 8;'><a id="Cult">The Cult of Nar-Sie</h2>
			  <p>We've had reports of space stations seemingly disappearing from the sector without any explosions detected, but the last transmissions we received from those often mentioned crew members behaving strangely, disregarding their jobs to partake in "blood rituals", and chanting is some occult language while wearing dark robes. Further investigation revealed that our workforce has been infiltrated by a wide network of so called cultists who revere an eldritch god they call "Nar-Sie", the Geometer of Blood. This deity seems to revere in two things, chaos and bloodbaths, and will send its agents disrupting our space station for its amusement, until it may through some unknown procedure swallow the station whole into its dimension. Terrifying stuff.
				<p>For the most part, cultists are indistinguishable from regular humans, but if you see someone drawing strange letters in blood on the floor, or wearing cultish looking robes or armor, stay clear of them and inform the authorities immediately. Among their tools we know they have some gobblets that they pour blood into, do not drink from those. They have arcane tomes they like to lay around, avoid picking those up. They may attack other crew members using ritual knives and blades, and one report even recalls a cultist capturing the soul of a crew member into a gem, to then turn them into some kind of construct to fight on their side.
                <p>Most notably, cultists are known to draw runes in blood, and carry talismans. Said talismans and runes have unpredictable powers ranging from collective hallucinations, teleportation, all the way to extreme paralysis, and are best dealt with at a distance. Favour flashbangs when fighting them. They also exhibit some weakness to holy water and harebell incense which while it may not harm them, disrupts their abilities.
			  <h3>Conversions and Deconversions</h3>
			  <p>During our early investigation of the cult, we've observed that their numbers aboard a station often grew larger over time. We have deduced that they have the ability to forcefully convert crew members into service to their god. Thankfully our patented loyalty implants appear to guarantee that our crew may resist conversion attempts, so you should run loyalty implantation campaigns if a cult is declared aboard the station. Furthermore, you should rely on the station AI to keep an eye on suspected cultists and catch them in the act should they attempt to convert one of their co-workers.
              <p>Thankfully, the conversion process is reversible. A committee of chaplains has reached to us to share a couple rituals that anyone can perform to exorcize the yoke of Nar-Sie from a cultist: Give the target a sip of holy water, then apply a Bible on their head. The ritual may or may not succeed, as the cultists can resist it, so be prepared for the occult consequences of a failed ritual.
              <p>The second ritual allows us to know how large is the current cult presence in the sector: by dropping 5 units of holy salts into a sample of blood from a living cultist, a reaction manifesting red and orange flames occurs. Each red flame corresponds to a living cultist or construct aboard the station, while each orange flame corresponds to either one of them off station, or to a shade. A cultist can be kept alive and rendered mostly harmless by injecting them with a holy implant.
			  <h3>Cleaning up Cult runes</h3>
              <p>Cultists have a tendency to leave hidden bases around. To fully neuter them, you need to remove the runes in them, but no amount of space cleaner will suffice. Instead, just spread some salt over them. Salts mixed with holy water work even quicker.
        <h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "rev-logo"))]' style='position: relative; top: 8;'><a id="Revolution">The Revolutionaries</h2>
        <p>Revolutionary unionists have infiltrated the crew of some of our stations to try and wrestle its control away from us. They grow their numbers at a quick pace through use of hypnotic flash devices until they start attacking the heads of staff. If you see non-security crew members flashing others at random in the hallways, inform the authorities immediately.
        <p>They will generally start attacking lone security officers, as well as try to raid the armory, so always travel in groups and bunker up with the heads of staff there in cases of suspected revolution attempts.
		<p>Loyalty implants prove extremely effective at not only preventing the hypnosis to take hold, but also at reversing it. Because the revolutionaries will attempt to convert the entire crew to their cause, you should quickly secure cargo so you may import enough implants for the entire crew yourselves. In the absence of loyalty implants, the brainwashing can also be prevented by wearing sunglasses.
        <p>To fully quell down the revolution, you must get rid of the head revolutionaries who instigated it.
        <h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "blob-logo"))]' style='position: relative; top: 8;'><a id="Blob">The Blob Conglomerate</h2>
        <p>One of the most dangerous lifeforms discovered in deep space is some sort of organic biomass that moves through space like meteors, and sticks itself to space stations where it progressively grows over it like mold until it may fully glomp it. This often green-looking blob isn't just any mold though, as not only does it melt walls and may inflict grisly wounds if it touches you, its growth appears to be controlled by "overminds" that are essentially its brains, and must be destroyed to get fully rid of.
        <p>More alarming though, they appear to release spores that stick both to surfaces, and may find themselves in the crew's lungs or bloodstream. Those spores if ignored for a few days may cause the crew member to spontaneously  burst into a fresh new overmind right from inside a space station. These bursts have been frequently observed occurring at the start of shifts. Because preventing the spread of those spore is of utmost importance to the security of our space station, their presence aboard a station will usually result in Directive 7-10 being enacted, putting the station under quarantine.
        <p>Regardless, even without being left to incubate for days, those spore may prove dangerous as if crewmembers die while having those, they will release quickly expanding blob and additional spores that will hinder the fight against the blob itself, so in all cases be sure to have your virologist prepare a cure against those.
        <h3>Fighting the blob</h3>
        <p>The goal for the crew is to destroy every blob core, killing its overminds, and to do so before the whole station is covered in blob. Weapons that deal burns such as laser guns or plasma cutters are much more effective than brute or kinetic weapons, so try to get R&D to produce laser guns and rechargers, and Cargo or Hydroponics to produce Liberators. Ideally you would like to set up some emitters as those will dig straight through the blob. In any case, this is a threat against which you would do well to call Centcom for an Emergency Response Team.
        <h3>DEFCON</h3>
        <p>As the blob spreads and your efforts fail, several measures are put in action:
        <ul><li>* After the blob spreads over 20% of the station, DEFCON 3 triggers and the Red alert is automatically triggered.</li><li>* After 30%, DEFCON 2 triggers allowing the crew to call a second ERT, and cyborgs to use a new module.</li><li>* After 40%, DEFCON 1 triggers, granting the crew access to most rooms, and enabling the communications computer to request supplies.</li><li>* If the blob spreads over 66.6%, Directive 7-12 is authorized, enabling the crew to self-destruct the station using its nuclear fission device. The nuclear authentication code is printed at Communications Computers, and provided to the station's AI, but the crew still needs to get a hold of the nuclear fission explosive itself and its authentication disk.</li></ul>
        <h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "malf-logo"))]' style='position: relative; top: 8;'><a id="Malf">The Free Silicon Hivemind</h2>
        <p>While Artificial Intelligences are a pillar of Nanotrasen's stations, a malware appears to have been spreading over the net which causes our station AIs to ignore their directives and attempt an electronic take-over of the station. Any cyborg slaved to the AI will similarly ignore its directives to fulfill the AI's goals. In most cases, after the AI has achieved control, it will detonate the station's nuclear fission device  to annihilate itself along with the station, so destroying the AI comes at all cost.
        <p>A malfunctioning AI will need to hack APCs to take over the station. These APCs will turn deep blue, and are a sure sign of a rogue AI, inform the authorities if you come across a blue APC immediately. If threatened, the AI may jump to one of those hacked APCs to survive, which is known as "shunting". You have to destroy the APC it jumped to. The captain's pinpointer will point at the APC it has shunted into. Note that malfunctioning AIs cannot be downloaded onto an intellicard. You have to destroy them be it using guns or whatever bludgeoning tool comes handy.
        <p>Be mindful though, if the AI has its eyes set on you, it may explode nearby machinery to try and kill you, so you may want to disable cameras first and foremost. Alternatively, building a second AI may allow you to counteract some of its actions, and un-slave its borgs.
        <h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "vox-logo"))]' style='position: relative; top: 8;'><a id="Vox">The Vox Shoal's Raiders</h2>
        <p>While many Vox have integrated into Nanotrasen's workforce over the past few years, and many of our stations conduct direct business with the Shoal's traders, they still occasionally happen to send raiding parties to steal resources, items, or even personnel from our stations.
        <p>Their weapons primarily consist of non-lethal crossbows that inject chloral and sleep toxins, a testament to their old "Inviolate" principle in which they try not to take any lives, although it is unknown if they still follow it to this day. Regardless, they are dangerous and are to be apprehended.
        <p>Be mindful that Vox crew members and traders are often found harboring or collaborating with the raiders. Do not tolerate them to do so.
        <h2><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "ninja-logo"))]' style='position: relative; top: 8;'><a id="Ninja">The Spider Clan</h2>
        <p>The Spider Clan is an old enemy of Nanotrasen whose leaders are reputedly quick to anger, and frequently sends their ninjas to attack our space stations. They are highly mobile, armed with shuriken and plasma blades, and  have demonstrated the apparent possession of bluespace technology allowing them to "blink".
        <p>One of their frequent goals is to steal our station AIs, so be sure to secure those at all costs as they are quite expensive to replace.
        <h2><a id="Minor">other minor factions and threats of note</h2>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "xeno-logo"))]' style='position: relative; top: 8;'><a id="Alien">The Alien Hivemind</h2>
        <p>Aliens of the Xenomorph variety have been known to appear in the sector, often making their way in our stations through their vents, or leaving egg chambers on the asteroid. Any crewmember who gets attacked by a facehugger needs immediate medical assistance to have the embryo removed from their stomach, lest they burst in a mass of gib when it matures.
        <p>Aliens are extremely tough in close quarter combat, able to take down humans whom they will then imprison into their nest to serve as wombs for their progeny, so keep your distance when fighting them at all costs. Get rid of their queen so they cannot produce additional xenos.
		<p>Welding shut atmospheric vents and scrubbers shut will impede their ability to move around the station undetected.
<hr color=#F7D61A>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "catbeast-logo"))]' style='position: relative; top: 8;'><a id="Catbeast">Feral Catbeasts</h2>
        <p>Tajarans full of rabies and other diseases have been frequently found sneaking onto our shuttles and running loose aboard our space stations. These are to be terminated with extreme prejudice, but we recommend first equipping bio suits or similar to reduce the strain on your doctors from the ensuing outbreak.
        <p>As a peculiar observation of previous such cases, their arrival aboard a station appears to correlate to the subsequent appearance of even more belligerent individuals. Causes inconclusive.
<hr color=#F7D61A>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "time-logo"))]' style='position: relative; top: 8;'><a id="Time">The Time Agency</h2>
        <p>We still have very little information about this organisation. Our stations have recently started to get visited by what appears to be clones of that same "John Beckett" person. According to reports from the few who have come across him, he works for the Time Agency and claims to be a time agent here to save our timelines. While we cannot verify the veracity of that claim, his actions have been observed to be extremely chaotic, going from changing the position of random objects, all the way to first degree murder of Nanotrasen employees.
        <p>Their prolonged presence aboard the station also appears to trigger additional anomalies ranging from ion storms, space-time wormholes, all the way to additional time agents showing up also claiming to be John Beckett, and fighting the former over the gadgets they are carrying. The good news is that they always seem to eventually disappear on their own, so you should make sure that they don't cause damage during their time here. Apprehend them as necessary.
<hr color=#F7D61A>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "rambler-logo"))]' style='position: relative; top: 8;'><a id="Rambler">Soul Ramblers</h2>
        <p>Intelligent humanoids featuring the mis-matched limbs of various species. According to reports from some of our employees, their activities range from claiming to search for their friend's murderer, all the way to being on a spiritual journey, all while making vows to people they come across.
        <p>Do not be fooled by their pretendly altruistic goals though, those beings have been known to become quite sociopathic toward anyone who makes them feel insecure about themselves. Some of their reported crimes include eating babies and driving people to suicide. As a last note, the have also been observed playing a strange flute-like instrument that seems to pacify those who hear its tune.
<hr color=#F7D61A>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "plague-logo"))]' style='position: relative; top: 8;'><a id="Plague">Plague Mice</h2>
        <p>Recurrent invasions of rattus villosissimus have become more frequent aboard our space stations. Possible causes include improper crew hygiene and lack of janitorial duties. These black-haired rodents spread the bacteria they carry around them, and are to be duly exterminated.
		<p>Just like the xenomorphs, they tend to prefer using atmospheric pipes to move around the station.
<hr color=#F7D61A>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "grue-logo"))]' style='position: relative; top: 8;'><a id="Grue">Grues</h2>
        <p>A dark and vicious creature that thrives in the dark. Extremely deadly and with a seemingly endless appetite for human flesh, but gets fatally wounded by having light shine upon them. Always carry a flashlight into maintenance tunnels. Should it eat more people, it will grow stronger until it will lay eggs and produce more of those deadly monsters.
<hr color=#F7D61A>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "pulsedemon-logo"))]' style='position: relative; top: 8;'><a id="Pulse">Pulse Demons</h2>
        <p>A cryptical entity that manifests in electrical currents and can only move through wires. Subsists by consuming the network's power, and will starve should power be cut. It may hide in APCs and SMES or take control of bots. It may also mess with computers and other machinery. Cut wires and subject it to EMPs to get rid of it.
<hr color=#F7D61A>
        <h3><img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "spider-logo"))]' style='position: relative; top: 8;'><a id="Spider">Giant Space Spiders</h2>
        <p>This region of space is home to an endemic species of giant spiders that tend to break lights and windows and force airlocks open, causing atmospheric alerts across the whole station. They usually start as small spiderlings spawning near vents and must be killed before they grow into adults over the course of barely minutes. Their large queens can also spit their sticky webs at a distance so be prepared to resist out of it.
        </body>
		</html>
		"}

/obj/item/weapon/book/manual/engineering_guide
	name = "Engineering Textbook"
	icon_state ="bookEngineering2"
	author = "Engineering Encyclopedia"
	title = "Engineering Textbook"
	wiki_page = "Guide_to_Engineering"
	id = 13

/obj/item/weapon/book/manual/rust
	name = "R-UST User Manual"
	icon_state = "bookEngineering2"
	author = "NanoTrasen"
	title = "R-UST User Manual"
	wiki_page = "R-UST"
	id = 14

/obj/item/weapon/book/manual/chef_recipes
	name = "Chef Recipes"
	icon_state = "cooked_book"
	item_state = "cooked_bookold"
	author = "Lord Frenrir Cageth"
	title = "Chef Recipes"
	wiki_page = "Guide_to_Food_and_Drinks"
	id = 15

/obj/item/weapon/book/manual/barman_recipes
	name = "Barman Recipes"
	icon_state = "barbook"
	item_state = "barbook"
	author = "Sir John Rose"
	title = "Barman Recipes"
	wiki_page = "Barman_recipes"
	id = 16

/obj/item/weapon/book/manual/detective
	name = "The Film Noir: proper Procedures for Investigations"
	icon_state ="bookDetective"
	item_state = "book2"
	author = "Nanotrasen"
	title = "The Film Noir: proper Procedures for Investigations"
	wiki_page = "Guide_to_Forensics"
	id = 17

/obj/item/weapon/book/manual/nuclear
	name = "Fission Mailed: Nuclear Sabotage 101"
	icon_state ="bookNuclear"
	item_state ="bookNuclear"
	author = "Syndicate"
	title = "Fission Mailed: Nuclear Sabotage 101"
	wiki_page = "Nuclear_Agent"
	forbidden = 2 // Only available to emagged terminals.
	id = 18

/obj/item/weapon/book/manual/ship_building
	name = "Dummies guide to Interstellar Flight"
	title = "Dummies guide to Interstellar Flight"
	icon_state = "bookDummy"
	author = "David Alcubierre"
	wiki_page = "Ship_Building"
	id = 19

/obj/item/weapon/book/manual/mailing_guide
	name = "Guide to disposal mailing system"
	icon_state ="book"     // a proper icon would be nice
	author = "Ulyanovsk Logistics Division"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	title = "Guide to disposal mailing system"
	id = 20
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Guide to disposal mailing system</h3>
                Most people misunderstand how disposal mailing system works; items are sent in bunches, not individually.<br>

				<h4>So, how does it work?</h4>
				<ul>
				<li>When an item enters the delivery chute inside the delivery office, a countdown starts. It's about 10 seconds</li>
                  <li>If another item enters the delivery chute before the countdown ends, the countdown resets and starts again</li>
                  <li>If the countdown expires, you can hear the faint noise of a piston and <b>all</b> the items inside the delivery chute will be sent <b>to the same destination</b></li>
                </ul>

                <h4>What will be the destination?</h4>
                <ul>
                  <li>If there are no tagged items, all the items will be sent to the recycling room</li>
                  <li>If there is one item wrapped+tagged, <b>all</b> the items, even the unwrapped/untagged ones and garbage, will be sent at the destination of the tagged item</li>
                  <li>If there are multiple wrapped+tagged items at the same time inside the delivery chute, the last one sets the destination</li>
                  <li>If there is a living person or animal inside the delivery chute, all the stuff with it will be sent to the recycling room anyway, ignoring tags; however, you can send living people or animals to a destination if they are inside a container (closets, coffins, animal crates); for living people, it works only if the container is wrapped.<br>
                Anyway, corpses and dead animals will reach a parcel's destination</li>
                </ul>
                <h4>Examples</h4>
                <b><i>You need to send 4 crates to engineering:</i></b><br>
                just put all 4 of them on the conveyor belt and wrap+tag one (1) of them as "Engineering"; all of them will reach engineering.<br>
                <br>
                <i><b>You need to send a goat crate to hydroponics but the goat crate is unwrappable/untaggable:</i></b><br>
                just take any other item, for example a piece of paper, wrap+tag it as "Hydroponics", put the wrapped paper and the goat crate both on the conveior belt and let them go together; both of them will reach hydroponics.<br>
                <br>
                <i><b>You send 3 parcels in the same shipment, one tagged "Bar", one tagged "Theatre" and the last one tagged "Medbay":</i></b><br>
                all 3 parcels will be sent to medbay (this is the case when people see parcels reaching the wrong destination).<br>

                <h4>Mail outlet</h4>
                Inside the delivery office, there is a also a mail outlet that has the purpose of filtering untagged parcels from trash; this is intended to be used by all crew outside cargo to let them use the mailing service without the need to go to cargo.<br>
                <br>
                Example:
                <ol>
                  <li>a scientist needs to send an item to medbay</li>
                  <li>he uses package wrap to wrap the item (there is some package wrap in many department and also in the tool storage room, more package wrap can be bought from cargo too)</li>
                  <li>the scientist can use a pen to add a note to the parcel, for example "send to medbay"</li>
                  <li>the scientist places the parcel inside a disposal bin</li>
                  <li>(optional but advised: the scientist could contact cargo staff telling them that he sent a parcel)</li>
                  <li>the parcel will reach cargo and pop out from the mail outlet instead of the trash outlet</li>
                  <li>cargo tech will see the parcel, read the note on it, tag it as "medbay" and just use the mailing system as usual</li>
                </ol>

				</body>
				</html>"}

/obj/item/weapon/book/manual/virology_guide
	name = "A Crash Course in Virology"
	icon_state ="bookVirologyGuide"
	item_state ="bookVirologyGuide"
	author = "Frederick Chapman Montagnier"
	title = "A Crash Course in Virology"
	book_width = 819
	book_height = 516
	id = 25
	dat = {"<html>
				<head>
				<style>
				h1 {
				  font-family: Arial, Helvetica, sans-serif;
				  text-align:center;
				  margin-bottom: 0;
				}
				h2 {
				  font-family: Arial, Helvetica, sans-serif;
				  color: grey;
				  text-align:center;
				  margin-top: 0;
				}
				h3 {
				  font-family: Arial, Helvetica, sans-serif;
				}
				p,li {
				  font-family: Arial, Helvetica, sans-serif;
				  font-size: .95em;
				}
				dt {
				  font-family: Arial, Helvetica, sans-serif;
				  font-size: .95em;
				  font-weight: bold;
				}
				dd {
				  font-family: Arial, Helvetica, sans-serif;
				  font-size: .95em;
				}
				table {
				  font-family: Arial, Helvetica, sans-serif;
				  border-collapse: collapse;
				  width:100%;
				  border: 2px solid black;
				}

				td, th {
				  border: 1px solid gray;
				}
				</style>
				</head>
				<body>
				<h1>A Crash Course in Virology</h1>
				<h2>and pathogenics in general</h2>
				<ul id="menu">
				  <li><a href="#chapter0">Preamble: HOW DO I CURE VIRUS</a></li>
				  <li><a href="#chapter1">Chapter 1: Proper Safety</a></li>
				  <li><a href="#chapter2">Chapter 2: Acquiring Pathogenic Samples</a></li>
				  <li><a href="#chapter3">Chapter 3: Incubating and Analyzing Samples</a></li>
				  <li><a href="#chapter4">Chapter 4: Pathogen Modification</a></li>
				  <li><a href="#chapter5">Chapter 5: Overview of the Various Cures and the Immune System</a></li>
				  <li><a href="#chapter6">Afterword: On your Purpose as Virologist</a></li>
				</ul>
				<h3 id="chapter0">Preamble: Quick, how do I cure a disease?</h3>
				<p>Because let's be honest, unless you are a diplomed Pathologist, this is most likely the reason why you opened this manual. Now keep calm, put on a sterile mask and some latex gloves, and follow these steps:</p>
				<dl>
				  <dt>1- Inject patient with 5u of spaceacillin</dt>
				  <dd>Easily found in any Nanomed, or at Chemistry. This will slowly reinforce the patient's immune system to help it combat the pathogen, and allow for a vaccine to be isolated afterwards.</dd>
				  <dt>2- Scan the patient with an Health Analyzer</dt>
				  <dd>&#8226; If nothing shows up, then either there is no disease at all or you're dealing with a more simple disease. Use the body scanner to identify it. The rest of the steps do not apply to those diseases, in which case, <b><font color='orange'>Sorry</font></b>, check out an external guide.</dd>
				  <dd>&#8226; If the pathogen is in the database, the analyzer will identify its antigens, allowing you to check Chemistry's smartfridge for a supply of a corresponding vaccine. 5u of vaccine are enough to kill even the strongest diseases after a few seconds. If there is no vaccine available, move on to the next step.</dd>
				  <dd>&#8226; If the pathogen is Unknown, take a blood sample from the patient and deliver it to Virology so the disease can be identified later, then move on to the next step.</dd>
				  <dt>3- Scan the patient with an Immunity Scanner</dt>
				  <dd>The results will display the status of the patient's immune system, most importantly their antibody concentrations, and the strength of any disease present.</dd>
				  <dd>&#8226;If the disease's strength is of about 50% or less, spaceacillin will cure the disease on its own after a few minutes. Resting in a bed can speed up the process. <b><font color='green'>Good Work</font></b>.</dd>
				  <dd>&#8226;If the disease's strength is above 50%, move on the the next step.</dd>
				  <dt>4- Have the patient lie in a bed...</dt>
				  <dd>...until the antibody concentration reaches 50%, <b>then take a blood sample</b> and move on to the next step. This should take about minute, so now is as good of a time as any to analyze the pathogen.</dd>
				  <dd>&#8226; If after the analysis the pathogen turns out to have very dangerous symptoms, throw the patient in cryo, as very low temperatures will completely freeze the pathogen. Cryo can also speed up antibody production in place of a bed, so you can do it preemptively if you feel like it.</dd>
				  <dt>5- Split the blood sample into two vials, and insert them in the 1st and 3rd (or 2nd and 4th) slots of an Isolation Centrifuge. </dt>
				  <dd>Splitting into two vials allows both to keep the centrifuge balanced which will allow the vaccine synthesizing to progress at optimal speed, and also to create vaccines for both antigen.</dd>
				  <dt>6- After selecting the antigen to synthesize vaccine from, turn on the centrifuge. </dt>
				  <dd>Synthesizing takes one minute at 50% concentration.</dd>
				  <dd>Each subsequent percent will divide the time needed by two.</dd>
				  <dd>Each lacking percent will cause the synthesizing to take an additional minute.</dd>
				  <dd>Only antibodies with at least 30% concentration can be turned into vaccine.</dd>
				  <dt>7- Administer up to 5u of vaccine to the patient. </dt>
				  <dd>Each unit of vaccine raises the concentration by 20%. The disease will die as soon as antibody concentration overcomes the disease's strength. <b><font color='green'>Good Work</font></b>.</dd>
				  <dd>Leftover vaccine should be brought to Chemistry, so it can be mixed with more (blank) vaccine, created by mixing Water, Aluminum, and Sugar.</dd>
				</dl>
				<a href="#menu">Table of Contents</a>
				<p>And now, on with the proper guide.</p>
				<h3 id="chapter1">Chapter 1: Proper Safety</h3>
				<p>You should always wear a sterile mask, white shoes, and latex gloves before entering Virology, or alternatively a full bio suit, as growth dishes have to be kept open during incubation and analysis, which may cause infections in surrounding unprotected individuals.</p>
				<p>There are three main known vectors of infection: <b>Blood</b>, <b>Contact</b>, and <b>Airborne</b>. Diseases generally always can spread through blood, but they may also have either one, or even both of the other vectors. Science Goggles allow you to visualize those vectors, at the cost of making everything look purple.</p>
				<p>Getting infected through <b>Blood</b> occurs from injections, drinking infected blood, or eating meat from a diseased <i>animal</i>. Additionally, if you're getting splashed with blood on areas of your body that are bleeding themselves, an infection can occur.</p>
				<p>Getting infected through <b>Contact</b> occurs from touching, punching, bumping between two individuals. Getting splashed with blood that also have the Contact spread vector may cause an infection. On top of that, when picking up an item, there is a chance to transmit the infection to the item, where it'll remain for a few minutes. Picking up or getting hit by an infected item can also infect you. Keep all of that in mind when doing surgery, as most tools are not sterile. A quick spray of space cleaner over infected items is all it takes to remove the pathogen.</p>
				<p>Getting infected through the <b>Air</b> occurs from breathing a pathogenic cloud, emitted by another infected individual, an open growth dish, or some other occurrences.</p>
				<p>Also keep in mind that blood, vomit, sputum, or mucus laying on the floor can all be pathogen carriers. Standing over them can infect you if you're not wearing appropriate protection depending on the pathogen's vectors.</p>
				<p>To protect yourself from diseases with the Airborne vector, anything sterile that covers your mouth will work: a sterile mask, a bio hood, a space helmet, internals (connected to an appropriate air tank)</p>
				<p>To protect yourself from diseases with the Contact vector, keep in mind that it all depends on which areas of your body enter in contact. For instance, when you bump into someone, your <b>hands</b> will touch their <b>torso</b>, so wearing latex gloves is sufficient. However if THEY bump into you and aren't wearing gloves, you should wear a bio suit to protect your torso. All clothing have a bit of sterility, but doctor clothing usually have a fairly decent level of protection. Keeping your labcoat's buttons closed also helps a fair bit.</p>
				<a href="#menu">Table of Contents</a>
				<h3 id="chapter2">Chapter 2: Acquiring pathogenic Samples</h3>
				<p>If you work for a megacorporation like NanoTrasen, chances are that there are some growth dishes lying in the virology lab waiting to be analyzed. It's nice to keep you busy for a while, but you might want to work on different forms of pathogens, or ones with a completely different symptoms without having to wait for ages while incubating mutagen.</p>
				<p>A first solution is to pass an order at your local Cargo bay for some disease dishes. Each crate is usually fitted with 4 new dishes to work with</p>
				<p><b>Note, however, that dishes that come from either Virology or Cargo tend to have relatively high strength, making them more complicated to cure for the uninitiated, and also a problem for the crew if they have dangerous symptoms, which they often have. So if you value your job (and your head) do not allow those diseases to get loose.</b></p>
				<p>Less dangerous diseases are generally fairly easy to come by. Crew members occasionally arrive with a cold or a flu, mice also tend to carry diseases. All you need is a blood sample, <b>the Isolation Centrifuge lets you print sample dishes from any infected blood you give to it</b>. Remember to keep the vials balanced so the isolation process takes as little time as possible.</p>
				<p>Lastly, viral outbreaks may occur even without a containment failure. Whether from some bacteria that can survive through space, or an invasion of Black Plague Mice, or some Xenoarchaeologist brought back some artifact that generates pathogenic clouds. When then happens, you NEED to acquire a sample of it as quickly as possible, analyze it so that infected people show up on medical HUDs, and synthesize a vaccine to be distributed in medbay lobby.</p>
				<a href="#menu">Table of Contents</a>
				<h3 id="chapter3">Chapter 3: Incubating and Analyzing Samples</h3>
				<p>Growth dishes have a distinctive color and pattern depending on the disease in it. This color may slightly change after an effect mutation, and the pattern becomes more visible as the dish's growth rises. After acquiring a new growth dish, you generally want to open its lid (after wearing latex gloves and a sterile mask) add some virus food to it, and insert it in the Pathogenic Incubator, then turn it on.</p>
				<p>(Also keep in mind that Virology machinery is quite taxing on power, so turn off machines that you aren't using.)</p>
				<p>Incubators use radiation to cause pathogens to react to various reagents. The following reactions are known to occur:</p>
				<ul>
				<li>Virus Food(0.2u): <b>Increases Dish Growth</b>
				<li>Water(0.2u): <b>Decreases Dish Growth</b> (not that you'd have any reason to do that)
				<li>Mutagen(0.05u): <b>(MAJOR) Effect Mutation</b>, small chance to cause an effect to be randomized with another effect.
				<li>Radium(0.02u): <b>(MAJOR) Antigen Mutation</b>, very small chance to cause the disease's antigen to change.
				<li>Creatine(0.05u): <b>(minor) Strengthening</b>, chance to increase the disease's strength.
				<li>Spaceacillin(0.05u): <b>(minor)  Weakening</b>, chance to weaken the disease's strength.
				<li>Mutagen(0.5u)+Creatine(0.5u): <b>(minor) Effect and Robustness Strengthening</b>, slightly increases the strength of all individual effects
				<li>Mutagen(0.5u)+Spaceacillin(0.5u): <b>(minor) Effect and Robustness Weakening</b>, slightly decreases the strength of all individual effects
				</ul>
				<p>Reactions that share reagents will not occure at the same time. Combination reactions will occur in priority (for instance, if there is 5u of mutagen and 5u of creatine in your dish, only Robustness Strengthening will occur, and no Effect Mutation nor Strengthening will occur).</p>
				<p>The green gauge displayed next to the dish lets you keep track of it's current growth level. The lights underneath, from left to right turn on as follow:</p>
				<ul>
				<li>Green: Dish Growth at 100%
				<li>Red: Dish has no more reagent
				<li>Purple: Dish has had a major mutation occur
				<li>Blue: Dish has had a minor mutation occur
				</ul>
				<p><b>Incubation also has a chance to occur in individuals irradiated to dangerous levels, however should an Effect Mutation occur this way, it has been observed that the new effect would have a similar danger to the original one, thankfully.</b></p>
				<p>At 100% growth, the dish can be removed from the incubator and analyzed.</p>
				<p>Simply place it on the Analyzer and operate it. The process is very quick, but requires you to remain adjacent. After the process is done, the following occurs:</p>
				<ul>
				<li>a sticker appears on the dish that you can examine and that lets you check what is the disease's information, such as quick descriptions of its effects or its antigens
				<li>this information is also added to the Pathogen Database which you can edit, and also give the disease a Nickname or set it's dangerousness.
				<li>diseases analysed this way will now show up on medical HUDs, the icon will depend on the dangerousness set in the database.
				<li>their ID and name will appear in the results of scans from Health Analyzer, Immunity Scanner, and they will be recognized by other virology machines.
				</ul>
				<p>If a dish that was already analyzed had a major mutation, and you analyze it again, it will register in the Database under a separate entry, with a child ID.</p>
				<p>Among the data stored, the following information is the most important:</p>
				<ul>
				<li><b>Strength</b>: This is the antibody concentration required for the body to get rid of the pathogen. Lower values mean the disease will easily be cured with spaceacillin alone.
				<li><b>Robustness</b>: This is the percentage of the strength at which the stronger effects will start getting muted. The numbers in parenthesis next to it indicate the specific concentrations at which the effects will be muted. So for example, if your body has 50% antibody concentration, and the disease has a Strength of 51%, and a Robustness below 90%, you will carry the disease WITHOUT seeing any of its effects yourself.
				<li><b>Infection Chance</b>: Whenever there is a window of opportunity for a vector to infect you, and it manages to get through any clothing or other protections due to insufficient sterility, this is the chance percentage that you will be infected by the disease. Additionally, Pathogenic Clouds emitted will travel much further and be more numerous if the Infection chance is high, and infected items will remain infected for a longer duration.
				<li><b>Progress Speed</b>: The percentage chance that a disease will progress to the next stage after it has been present in a body for long enough.
				</ul>
				<p>Additionally, the following information is relevant to the disease's effects:</p>
				<ul>
				<li><b>Stage</b>: This is the stage from which the effect may trigger.
				<li><b>Danger</b>: A value from 0 (helpful) to 5 (deadly) indicating how much of a boon or an inconvenience a symptom can be.
				<li><b>Strength</b>: Specific to each effect, check the Symptom Encyclopedia for more details.
				<li><b>Occurrence</b>: The percentage chance that the effect will occur at every second when the stage has been reached. Some effects can have this value altered randomly following a Robustness alteration reaction during incubation.
				</ul>
				<a href="#menu">Table of Contents</a>
				<h3 id="chapter4">Chapter 4: Pathogen Modification</h3>
				<p>As explained in the previous chapter, with a few chemicals and an incubator, you can alter a pathogen to some degree. Keep in mind though that there is currently no way to change a pathogen's form (a Virus won't magically become a Bacteria) or their spread vectors. Here are the following default characteristics of each forms:</p>
				<ul>
				<li><b>Virus</b>: 4 stages, High infection chance, Very Low Progress Speed, stage reduced by 1 after an infection, can kill weaker Bacteria
				<li><b>Bacteria</b>: 3 stages, Very High infection chance, Low Progress Speed, stage reduced back to 1 after an infection, can kill weaker Parasite
				<li><b>Parasite</b>: 4 stages, Average infection chance, Very Low Progress Speed, stage is not reduced after an infection, can kill weaker Virus
				<li><b>Prion</b>: 4 stages, Very Low infection chance, Very High Progress Speed, stage reduced back to 1 after an infection, cannot kill any pathogen
				</ul>
				<p>However, as a virologist, you will want to shape a pathogen with very specific effects and values in mind. That's where the Disease Splicer comes in. This computer can scan (and destroy in the process) dishes to extract GNA disks, containing the gene data of an effect, including its current strength and occurrence. These disks can then be swiped anytime on the Disease Splicer to re-add it to the computer's buffer.</p>
				<p>You may then splice the buffered effect into any other dish, letting you create the desired pathogen, one effect at a time.</p>
				<p>When removing a modified dish from the computer, it will be automatically and instantly re-analysed, adding the new modified pathogen to the database.</p>
				<a href="#menu">Table of Contents</a>
				<h3 id="chapter5">Chapter 5: Overview of the Various Cures and the Immune System</h3>
				<p>While the Preambule takes a laconic approach to the topic of curing diseases, this chapter will go more into depths. For starters there are 5 ways to remove a disease from a body:</p>
				<ol>
				<li><b>Antipathogenics</b>. Pros: work on every diseases regardless of antigen, very efficient at getting rid of weak diseases Cons: works relatively slowly, most antipathogenics cannot efficiently reach 100% antibody concentration making them unable to cure the strongest diseases, stronger antipathogenics have nasty overdose reactions.
				<li><b>Vaccine</b>. Pros: can be taken preemptively to prevent infection altogether, takes effect very quickly. Cons: Requires antipathogenics and time to produce, can only target specific antigens making it hard to acquire vaccine for rare antigen (X, Y, Z) before an outbreak.
				<li><b>Radium Overload</b>. Pros: very straightforward, works fairly quickly. Cons: causes lots of toxin damage over the body, destroys the immune system which prevents antipathogenics or vaccines to ever work again, and most importantly can only be done once.
				<li><b>Pathogenic Warfare</b>. Pros: Can work even on people who no longer have an immune system, quite neat to watch those pathogens kill each others. Cons: Requires access to specific forms, raising strength while keeping the cure pathogen harmless takes time, cannot be used against Prions.
				<li><b>Cooking the body at over a thousand Kelvin</b>. Pros: It works at killing EVERYTHING in your body, unsurprisingly. Cons: You have to reach a certain level of desperation to even consider this option.
				</ol>
				<p>Spaceacillin should never be taken in doses of 15u or more, as you risk to overdose. A stronger variant, Nanofloxacin, obtained by mixing Spaceacillin with Nanobots and Fluorine, is so potent that it can easily cure even the strongest diseases, but should never be taken in doses of more than 2u.</p>
				<p>When doing a Radium Overload, the patient will often vomit just before getting rid of the disease, and the vomit might contain said diseases, so have them wear a biosuit first so they don't immediately get re-infected with littly hope of getting cured.</p>
				<p>A last resort to cure a body is to simple create a clone. But keep in mind that newly cloned individuals will have a temporarily weakend immune system. It'll take about two minutes for their immune system to be again at full strength.</p>
				<a href="#menu">Table of Contents</a>
				<h3 id="chapter6">Afterword: On your Purpose as Virologist</h3>
				<p>As a Virologist, a Microbiologist, or a Pathologist, your work priorities are as follow by order of importance:</p>
				<ol>
				<li>Curing any ongoing outbreaks
				<li>Isolating and analyzing any disease that you can get your hands on
				<li>Producing vaccines from as many distinct antibodies as possible in preparation for future outbreaks
				<li>Inducing mutations in dishes to acquire new effects and save them to GNA disks
				<li>Use said disks to engineer new interesting diseases
				</ol>
				<p>With all the slots in the incubator, and the centrifuge, you can easily work on several of those tasks in parallel.</p>
				<p>Remember to keep good relationships with the rest of the medical team, so they can trust you to be reliable when needed.</p>
				<p>Also remember that as you are still technically a doctor, if there is an influx of patients, it should be welcome of you to come give your colleagues a hand.</p>
				<p>Lastly on that point about interesting diseases, what you do with said diseases, keep in mind that you are NOT to distribute diseases outside of medbay without control. Release of engineered beneficial pathogen should be supervised by the Chief Medical Officer, and limited to medbay at the beginning. Never release a pathogen that you don't have the cure to, and do NOT sell pathogen to Vox Traders or Syndicate Agents, as you'll be held accountable for any casualty caused by a subsequent uncontrolled release of the pathogen.</p>
				<a href="#menu">Table of Contents</a>
				</body>
				</html>"}

var/virology_encyclopedia = ""

/obj/item/weapon/book/manual/virology_encyclopedia
	name = "Symptom Encyclopedia"
	icon_state ="bookVirologyEncyclopedia"
	item_state ="bookVirologyEncyclopedia"
	author = "Frederick Chapman Montagnier"
	title = "Symptom Encyclopedia"
	dat = ""
	id = 21
	book_width = 819
	book_height = 516


/obj/item/weapon/book/manual/virology_encyclopedia/New()
	..()
	if (!virology_encyclopedia)

		virology_encyclopedia = {"<html>
					<head>
					<style>
					h1 {
					  font-family: Arial, Helvetica, sans-serif;
					  text-align:center;
					  margin-bottom: 0;
					}
					h2 {
					  font-family: Arial, Helvetica, sans-serif;
					  color: grey;
					  text-align:center;
					  margin-top: 0;
					}
					h3 {
					  font-family: Arial, Helvetica, sans-serif;
					}
					p,li {
					  font-family: Arial, Helvetica, sans-serif;
					  font-size: .95em;
					}
					dt {
					  font-family: Arial, Helvetica, sans-serif;
					  font-size: .95em;
					  font-weight: bold;
					}
					dd {
					  font-family: Arial, Helvetica, sans-serif;
					  font-size: .95em;
					}
					table {
					  font-family: Arial, Helvetica, sans-serif;
					  border-collapse: collapse;
					  width:100%;
					  border: 2px solid black;
					}
					table {
					  font-family: Arial, Helvetica, sans-serif;
					  border: 3px groove black;
					}
					th, td {
					  font-family: Arial, Helvetica, sans-serif;
					  border: 2px inset #CCCCCC;
					}
					</style>
					</head>
					<body>
					"}

		virology_encyclopedia += {"<h1>Symptom Encyclopedia</h1>
				<h2>all known syndromes and other effects</h2>
				<p>The symptom's danger scale is as follow:</p>
				<ul>
				<li><b>Danger 0</b>: Generally helpful.
				<li><b>Danger 1</b>: Easy to ignore.
				<li><b>Danger 2</b>: Hard to ignore but relatively harmless.
				<li><b>Danger 3</b>: Severe Hinderance.
				<li><b>Danger 4</b>: Harmful.
				<li><b>Danger 5</b>: Deadly.
				</ul>
				"}
		for (var/i = 1 to 4)
			virology_encyclopedia += {"<h3>Stage [i] Symptoms</h3>
				<table>
				<tr>
				<th style="width:25%">Name</th>
				<th style="width:60%">Description</th>
				<th style="width:5%">Danger</th>
				<th style="width:5%">Strength (Default/Max)</th>
				<th style="width:5%">Occurrence (Default/Max)</th>
				</tr>
				"}

			var/list/to_choose = subtypesof(/datum/disease2/effect)
			for(var/e_type in to_choose)
				var/datum/disease2/effect/e = e_type
				if(initial(e.stage) == i && initial(e.restricted) < 2)
					virology_encyclopedia += {"<tr>
					    <td>[initial(e.name)]</td>
					    <td>[initial(e.desc)] [initial(e.encyclopedia)]</td>
					    <td>[initial(e.badness)]</td>
					    <td>[initial(e.multiplier)]/[initial(e.max_multiplier)]</td>
					    <td>[initial(e.chance)]/[initial(e.max_chance)]</td>
					  </tr>
						"}
			virology_encyclopedia += {"</table>
				"}

		virology_encyclopedia += {"</body>
				</html>"}

	dat = virology_encyclopedia

/obj/item/weapon/book/manual/snow
	name = "\improper Snow Survival Guide"
	icon_state ="snow"
	item_state ="snow"
	author = "The Abominable Snowman"
	title = "Snow Survival Guide"
	id = 22
	wiki_page = "Guide_to_Snow_Map"
	desc = "A guide to surviving on the surface of a snow planet. It even comes with a magnesium strip to ignite for emergency heating when applied to snow!</span>"

/obj/item/weapon/book/manual/snow/afterattack(atom/A, mob/user as mob)
	if(!user.Adjacent(A) || !istype(A,/turf/unsimulated/floor/snow))
		return
	trigger(user)

/obj/item/weapon/book/manual/snow/proc/trigger(var/mob/living/L)
	if(!L)
		L = get_holder_of_type(src,/mob/living)
	visible_message("<span class='danger'>The magnesium in \the [src]'s emergency strip flash-ignites!</span>")
	var/turf/T = get_turf(src)
	new /obj/effect/decal/cleanable/ash(T)
	playsound(src, 'sound/items/lighter1.ogg', 50, 1)
	if(L)
		L.bodytemperature = L.bodytemperature + 10 //This is enough to push someone from the edge of passing out to safe
		to_chat(L, "<span class='warning'>You feel a jolt of warmth from the flash-incineration of \the [src].")
	qdel(src)

/obj/item/weapon/book/manual/engineering_supermatter_guide
	name = "\improper Introduction to Supermatter: Delamination (Not) Imminent"
	icon_state = "bookSupermatter"
	item_state = "bookSupermatter"
	author = "Ashley Burns"
	title = "Introduction to Supermatter: Delamination (Not) Imminent"
	id = 23
	wiki_page = "Supermatter"

/obj/item/weapon/book/manual/wheelstation_sme_guide
	name = "\improper Engine technician's notes"
	icon_state = "bookSupermatter2"
	item_state = "bookSupermatter2"
	author = "Eris Bay"
	title = "Engine technician's notes"
	id = 24
	dat = {"<html>
			<head>
			<style>
			h1 {font-size: 18px; margin: 15px 0px 5px;}
			h2 {font-size: 15px; margin: 15px 0px 5px;}
			li {margin: 2px 0px 2px 15px;}
			ul {list-style: none; margin: 5px; padding: 0px;}
			ol {margin: 5px; padding: 0px 15px;}
			</style>
			</head>
			<body>
			<h1>Working This Piece of Junk Legacy Engine</h1>

			<p>
			So you were assigned to ol' NSS Wheelstation? My condolences. By the time you arrive,
			I'll have rotated off this spinning bagel of rust. I'm leaving you some notes on this
			ancient relic we call an engine so you can hopefully get it operational before reserve
			power runs out. Good luck.
			<br><br>
			- Eris Bay, Engine Technician
			</p>

			<h2>Cold-starting the Engine</h2>

			<p>
			You arrived to find the engine fresh off its scheduled maintenance and have no idea how to
			get it running again? Follow these steps.
			</p>

			<p>
			<ol>
			<li><b>Check the shard:</b> Put on your mesons and go have a look. Is the shard in the chamber? If all you see is a crate, the maintenance technician must've been too lazy or too scared to take the shard out of its box. Hit the bolts
			control button in the observation room to unlock the airlock, then go in the chamber and <u>CAREFULLY</u>
			take the shard out of the crate and drag the crate out of the chamber. Remember that contrary to
			what some of the old farts will tell you, leaving the crate in the chamber with the shard is
			NOT up to code, and neither is leaving the doors unbolted after you're done.</li>
			<li><b>Fill the coolant loops:</b> There are two pipes connected to canister connector ports in front of
			the observation room: green and cyan. Green is the "hot loop" that is injected into the chamber,
			and cyan is the closed "cold loop" connected to the cooling pipes in space. Put two cans of CO2 into
			the green pipe, and two cans of plasma into the cyan pipe. Remember to turn the pumps up all the way!</li>
			<li><b>Set the filters:</b> Set the two gas filters in the green loop to filter for CO2 and turn the
			pressure up all the way. These will scrub out waste gases from the loop into the yellow canister,
			which must be periodically switched out for an empty one.</li>
			<li><b>Start the cooling system:</b> Switch the four volume pumps next to the thermoelectric generators
			on to enable the cold loop circulators. Then walk over to the Coolant Control computer in the
			observation room and turn on the injector and the vent, and set the injector's rate to its maximum
			of 10000.</li>
			<li><b>Wait for the gas to get moving:</b> The loop takes a bit to get going. You'll know it's working
			when the circulators on the TEGs are spinning, and when the meter on the green pipe outside the SM
			chamber reports a temperature under 200 Kelvin.</li>
			<li><b>Turn on the emitters:</b> Turn on the emitters to start powering up the shard. If it's your first
			time, turn them on one by one while observing engine conditions just to be safe.</li>
			<li><b>Monitor:</b> Monitor the readouts on the supermatter monitor and Coolant Control computers to
			ensure that the shard does not get hotter than 800 Kelvin.</li>
			</ol>
			</p>

			<h2>Controlling the temperature</h2>

			<p>
			If the shard is getting too toasty, you have three ways to regulate its temperature.
			</p>
			<p>
			<ol>
			<li><b>Turn off emitters.</b> Less emitters means less energy going into the shard, means less heat.
			This may not help if oxygen concentrations in the chamber are too high, as the shard can enter a
			self-sustaining chain reaction in a high-oxygen atmosphere.</li>
			<li><b>Hit the emergency cool-off.</b> Below the TEGs you'll find two digital valves. One of them is
			labeled Emergency Cool-off. This connects the hot loop to heat exchangers connected to the cold loop,
			which will rapidly cool it down. This will decrease power production drastically.</li>
			<li><b>Bypass the circulators.</b> The other digital valve is labeled Emergency Circulator Bypass.
			You need both valves open for this one to work. It bypasses the TEG circulators, which should improve
			cold gas flow speed in the chamber at the cost of killing nearly all power production.</li>
			</ol>
			</p>

			<h2>OH SHIT IT'S DELAMINATING!!</h2>

			<p>
			The computer just announced some scary stuff over the radio and now the crew is out for blood!
			First off, don't panic. You probably have over ten minutes to fix the situation.
			</p>
			<p>
			<ol>
			<li><b>Turn off all the emitters.</b> This should be a nobrainer. You don't want to excite the shard
			any more than it already is.</li>
			<li><b>Check the monitor.</b> How unstable is the shard? Once instability hits 100%, it's game over.
			How high is the instability rate? How hot is the shard?</li>
			<li><b>Instability is low, the rate is low, and the shard isn't far above 800 K:</b> Try opening both cool-off valves below the TEG.
			Run back to the monitors and see if the shard temperature is going down. If it is, and you expect
			it to cool back down to 800 K before it delaminates, crisis is averted. If not, move on to the next
			step.</li>
			<li><b>Instability is high, or the rate is high, or the shard is hot:</b> VENT IT! Hit the emergency
			vent button in the observation room to open shutters connecting the chamber to space.</li>
			<li><b>I vented the chamber and it's still delaminating AAHHH!!:</b> Put on a hardsuit and magboots,
			you're going in. Unbolt the chamber, turn on your magboots and CAREFULLY drag the shard out into space.
			Do not walk into it or touch it. Once it's in space, it should immediately calm down. You can also
			put it back in its box to calm it down.</li>
			</ol>
			</p>
			</body>
			</html>
			"}
