#if EXTOOLS_REFERENCE_TRACKING

/proc/get_back_references(datum/D)
	CRASH("/proc/get_back_references not hooked by extools, reference tracking will not function!")

/proc/get_forward_references(datum/D)
	CRASH("/proc/get_forward_references not hooked by extools, reference tracking will not function!")

/client/verb/view_refs(atom/D) //it actually supports datums as well but byond no likey
	set category = "Debug"
	set name = "View References"

	var/list/backrefs = get_back_references(D)
	if(isnull(backrefs))
		usr << browse("Reference tracking not enabled", "window=ref_view")
		return
	var/list/frontrefs = get_forward_references(D)
	var/list/dat = list()
	dat += "<h1>References of \ref[D] - [D]</h1><br><a href='?_src_=vars;view_references=[ref(D)]'>\[Refresh\]</a><hr>"
	dat += "<h3>Back references - these things hold references to this object.</h3>"
	dat += "<table>"
	dat += "<tr><th>Ref</th><th>Type</th><th>Variable Name</th><th>Follow</th>"
	for(var/ref in backrefs)
		var/datum/R = ref
		dat += "<tr><td><a href='?_src_=vars;Vars=[ref(R)]'>"
		dat += "[ref(R)]</td>"
		try
			dat += "<td>[R.type]</td>"
		catch
			dat += "<td>RUNTIME ERROR</td>"
		dat += "<td>[backrefs[R]]</td>"
		dat += "<td><a href='?_src_=vars;view_references=[ref(R)]'>\[Follow\]</a></td></tr>"
	dat += "</table><hr>"
	dat += "<h3>Forward references - this object is referencing those things.</h3>"
	dat += "<table>"
	dat += "<tr><th>Variable name</th><th>Ref</th><th>Type</th><th>Follow</th>"
	for(var/ref in frontrefs)
		var/datum/R = frontrefs[ref]
		dat += "<tr><td>[ref]</td><td><a href='?_src_=vars;Vars=[ref(R)]'>[ref(R)]</a></td><td>[R.type]</td><td><a href='?_src_=vars;view_references=[ref(R)]'>\[Follow\]</a></td></tr>"
	dat += "</table><hr>"
	dat = dat.Join()

	usr << browse(dat, "window=ref_view;size=800x500")

#endif
