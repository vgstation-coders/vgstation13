//These are papers that generate special text based on the situation.

/obj/item/weapon/paper/djstation
	name = "paper - 'DJ Listening Outpost'"

/obj/item/weapon/paper/djstation/initialize()
	..()
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br>\
	<ol>\
		<li>Equip yourself with a multi-tool</li>\
		<li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li>\
		<li>Turn all the machines on, it has already been configured for you to listen on.</li>\
	</ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. \
	\
	Here is a list of frequencies for you to listen on.<br>\
	<ul>\
		<li>[COMMON_FREQ] - Common Channel</li>\
		<li>[AIPRIV_FREQ] - Private AI Channel</li>\
		<li>[SEC_FREQ] - Security Channel</li>\
		<li>[ENG_FREQ] - Engineering Channel</li>\
		<li>[MED_FREQ] - Medical Channel</li>\
		<li>[COMM_FREQ] - Command Channel</li>\
		<li>[SCI_FREQ] - Science Channel</li>\
		<li>[SER_FREQ] - Service Channel</li>\
		<li>[SUP_FREQ] - Supply Channel</li>"

/obj/item/weapon/paper/intercoms
	name = "paper - 'Ace Reporter Intercom manual'"

/obj/item/weapon/paper/intercoms/initialize()
	..()
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio frequencies.Now to listen to the private channels, you'll have to configure the intercoms.<br>\
	Here is a list of frequencies for you to listen on.<br>\
	<ul>\
		<li>[COMMON_FREQ] - Common Channel</li>\
		<li>[AIPRIV_FREQ] - Private AI Channel</li>\
		<li>[SEC_FREQ] - Security Channel</li>\
		<li>[ENG_FREQ] - Engineering Channel</li>\
		<li>[MED_FREQ] - Medical Channel</li>\
		<li>[COMM_FREQ] - Command Channel</li>\
		<li>[SCI_FREQ] - Science Channel</li>\
		<li>[SER_FREQ] - Service Channel</li>\
		<li>[SUP_FREQ] - Supply Channel</li>"
	update_icon()

/obj/item/weapon/paper/manifest
	name = "Supply Manifest"

/obj/item/weapon/paper/anomaly
	name = "Anomaly Report"
	var/obj/machinery/artifact/artifact

/obj/item/weapon/paper/anomaly/Destroy()
	artifact = null
	..()

/obj/item/weapon/paper/merchant
	var/identity
	var/list/mugshots = list()
	var/icon_updates = FALSE
	display_y = 500

/obj/item/weapon/paper/merchant/update_icon()
	if(icon_updates)
		..()

/obj/item/weapon/paper/merchant/New(loc,mob/living/carbon/human/merchant)
	if(merchant)
		merchant.client.prefs.update_preview_icon(0) //This is necessary because if they don't check their character sheet it never generates!
		mugshots += fcopy_rsc(merchant.client.prefs.preview_icon_front)
		mugshots += fcopy_rsc(merchant.client.prefs.preview_icon_side)
		apply_text(merchant)
	..()

/obj/item/weapon/paper/merchant/show_text(var/mob/user, var/links = FALSE, var/starred = FALSE)
	var/index = 1
	for(var/image in mugshots)
		user << browse_rsc(image, "previewicon-[identity][index].png")
		index++
	..()

/obj/item/weapon/paper/merchant/proc/apply_text(mob/living/carbon/human/merchant)
	identity = merchant.client.prefs.real_name
	icon = 'icons/obj/items.dmi'
	icon_state = "permit"
	name = "Merchant's Licence - [identity]"
	info = {"<html><style>
			body {color: #000000; background: #ffff0d;}
			h1 {color: #000000; font-size:30px;}
			fieldset {width:140px;}
			</style>
			<body>
			<center><img src="http://ss13.moe/wiki/images/1/17/NanoTrasen_Logo.png"> <h1>Merchant's Licence</h1></center>
			Nanotrasen\'s commercial arm has authorized commercial activity for a merchant who holds a licence for corporate commerce, a process which includes a background check and Nanotrasen loyalty implant. The associate\'s image is displayed below.<BR>
			<fieldset>
	  		<legend>Picture</legend>
			<center><img src="previewicon-[identity]1.png" width="64" height="64"><img src="previewicon-[identity]2.png" width="64" height="64"></center>
			</fieldset><BR>
			Name: [identity]<BR>
			Blood Type: [merchant.dna.b_type]<BR>
			Fingerprint: [md5(merchant.dna.uni_identity)]</body></html>"}

/obj/item/weapon/paper/merchant/report
	icon_updates = TRUE
	display_y = 700

/obj/item/weapon/paper/merchant/report/apply_text(mob/living/carbon/human/merchant)
	identity = merchant.client.prefs.real_name
	name = "Licensed Merchant Report - [identity]"
	info = {"<html><style>
			body {color: #000000; background: #ccffff;}
			h1 {color: #000000; font-size:30px;}
			fieldset {width:140px;}
			</style>
			<body>
			<center><img src="http://ss13.moe/wiki/images/1/17/NanoTrasen_Logo.png"> <h1>ATTN: Internal Affairs</h1></center>
			Nanotrasen\'s commercial arm has noted the presence of a registered merchant who holds a licence for corporate commerce, a process which includes a background check and Nanotrasen loyalty implant. The associate\'s image is enclosed. Please continue to monitor trade on an ongoing basis such that Nanotrasen can maintain highest standard small business enterprise (SBE) partners.<BR>
			<fieldset>
	  		<legend>Picture</legend>
			<center><img src="previewicon-[identity]1.png" width="64" height="64"><img src="previewicon-[identity]2.png" width="64" height="64"></center>
			</fieldset><BR>
			Name: [identity]<BR>
			Blood Type: [merchant.dna.b_type]<BR>
			Fingerprint: [md5(merchant.dna.uni_identity)]</body></html>"}
	CentcommStamp(src)

/obj/item/weapon/paper/traderapplication
	name = "trader application"
	display_x = 500
	display_y = 600
	var/applicant

/obj/item/weapon/paper/traderapplication/New(loc,var/newapp)
	..()
	applicant = newapp
	if(!applicant)
		qdel(src)
	info = {"<html><style>
						body {color: #000000; background: #e7c9a9;}
						h1 {color: #4444ee; font-size:30px;}
  						h2 {color: #4444ee; font-size:14px}
						fieldset {width:140px;}
						</style>
						<body>
						<center><img src="https://ss13.moe/wiki/images/9/92/Shoal-logo.png"> <h1>Trade Pact</h1></center>
						<h2>
                          I, the inker, do solemnly vow that [applicant] (hereafter 'Applicant') can be trusted. By blood and claw, responsibility for this one is bound in blood to me.<BR>
                          <B>JURISDICTION.</B> Disputes related to this contract will be brought before the Shoal Trade Council.<BR>
                          <B>SCOPE.</B> Provisional licensure as a trader shall last the duration of this shift and apply to this sector.<BR>
                          <B>INDEMNIFICATION.</B> The applicant waives legal rights against the Shoal, holding it harmless against all indemnification. Traders are independent contractors and the shoal does not accept responsibility for their actions.<BR>
                          <B>CONFIDENTIALITY.</B> The applicant vows to uphold all Shoal trade secrets.<BR>
                          <B>ASSIGNMENT.</B> The Shoal retains all rights related to its intellectual properties. This contract is not to be construed as a release of IP rights.<BR>
                          <B>ARBITRATION.</B> The applicant is entitled to settle legal disputes before a Shoal Arbitration Flock and must seek this remedy before formal lawsuit.<BR>
                          <B>NOTICE.</B> Notice of intent to dissolve relationship must be given by fax with at least one day advance notice.<BR>
                          <B>FORCE MAJEURE.</B> This contract may be voided if the trade outpost is destroyed.
                         </h2> <BR></body></html>"}

/obj/item/weapon/paper/inventory
	name = "\improper Inventory Manifest"
	desc = "A list of objects in an area to check against the current inventory for misplacement."
	var/list/areastocheck = list()

/obj/item/weapon/paper/inventory/initialize()
	..()
	var/areafound = FALSE
	for(var/areatype in areastocheck)
		var/area/A = locate(areatype) in areas
		if(A)
			areafound = TRUE
			info = "<h1>[A.name] Item List</h1><br>"
			var/list/obj/manifest_stuff = list()
			for(var/obj/O in A.contents)
				if(O.on_armory_manifest)
					manifest_stuff += O
				if(O.holds_armory_items)
					for(var/obj/item/I in O.contents)
						if(O.on_armory_manifest)
							manifest_stuff += O
			info += "[counted_english_list(manifest_stuff,"No items found.","","<br>","<br>")]<br>"
	if(!areafound)
		info = "This station has been inspected by Nanotrasen Officers and has been found to not have any kind of [english_list(areastocheck,and_text = "or")]. If you believe to have received this manifest by mistake, contact Central Command."
	update_icon()

/obj/item/weapon/paper/inventory/armory
	name = "\improper Armory Inventory Manifest"
	areastocheck = list(/area/security/armory,/area/security/warden)

/obj/item/weapon/paper/audit/New(loc, user, account, wage, newwage)
	name = "Wage Audit - [account]"
	display_x = 500
	display_y = 600
	info = {"<html><style>
			body {color: #000000; background: #ccffff;}
			h1 {color: #000000; font-size:30px;}
			fieldset {width:140px;}
			</style>
			<body>
			<center><img src="http://ss13.moe/wiki/images/1/17/NanoTrasen_Logo.png"> <h1>ATTN: Internal Affairs</h1></center>
			An unusual wage increase has been authorized at the accounts database on your station. Although command staff have broad latitude to set wages within reason, there are documented cases of abuse, off-books dealing, cryptographic sequencing, and even simple security errors such as leaving a computer logged in without supervision. For this reason, Internal Affairs is requested to audit the following recent wage modification.<BR>
			Account name: [account]<BR>
			Old wage: [wage]<BR>
			New wage: [newwage]<BR>
			Name on authorizing ID: [user]<BR>
			Time of operation: [worldtime2text()]<BR><BR>
			We wish you the best of luck in your investigation. This paper should be taken as official authorization to inspect the Accounts Database.<BR>
			<I>Central Command Audits Department</I>
			</body></html>"}
	CentcommStamp(src)
	..()