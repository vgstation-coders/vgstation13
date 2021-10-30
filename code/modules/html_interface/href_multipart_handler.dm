/*
 * ==== HREF multipart handler ====
 * For situations where your Topic() link exceeds the browser's ~2000 character limit and ends up ignored
 *
 * Give your atom a handler, specifying said atom as the handler's parent on New(), and have your atom's Topic() be redirected to
 *  the handler if the href contains the 'multipart=1' parameter.
 * An example would look like this:
 *
 *		/obj/foo
 *			var/datum/href_multipart_handler/mp_handler
 *
 *		/obj/foo/New()
 *			..()
 *			mp_handler = new /datum/href_multipart_handler(src)
 *			...
 *
 *		/obj/foo/Topic(href, href_list)
 *			if (href_list["multipart"])
 *				mp_handler.Topic(href, href_list)
 *			else
 *
 * On your UI's headers, import href_multipart_handler.js and have your submit link pass it's href through 'HREFmultipartHandler()'
 *  (See '/code/modules/html_interface/href_multipart_handler.js' for more info)
 *
 *
 * == How it works ==
 * As explained, the parent atom's Topic() receives a multipart request that is redirected to this handler.
 *
 * This request contains the following parameters:
 * - src: As with all Topic() links, specifies the object that'll handle the request
 * - multipart: Specifies that this is a multipart request. Will always be '1'
 * - multipart-total: Specifies how many more requests to expect
 * - multipart-number: Specifies which part this is, so that all parts may be reassembled in order
 * - multipart-content: The actual payload, percent encoded. The parameters you were trying to send but had to be sliced up.
 *
 * Each part's multipart-content is stored in an array, sorted by multipart-number as there's a risk parts may arrive out of order. Once
 *  all parts have been received the array's contents are pieced together, decoded, and used to call the parent atom's Topic().
 *
 */

/datum/href_multipart_handler
	var/atom/parent
	var/list/parts

/datum/href_multipart_handler/New(parent)
	..()
	src.parent = parent

/datum/href_multipart_handler/Destroy()
	..()
	parent = null
	parts = null

/datum/href_multipart_handler/proc/set_parent(parent)
	src.parent = parent

/datum/href_multipart_handler/Topic(href, href_list)
	if(href_list["multipart"])
		// Initialize the list to the size specified by 'multipart-total'
		if (!parts)
			parts = new /list(text2num(href_list["multipart-total"]))

		// Store the part we've received
		parts[text2num(href_list["multipart-number"])] = href_list["multipart-content"]

		// Check wether we've received all parts
		var/complete = 1
		for (var/i = 1; i <= parts.len && complete; i++)
			complete = complete && parts[i]

		// If we've received the complete set, piece it all together and pass the resulting parameters back to our parent object's Topic()
		if (complete)
			var/content = "";
			for (var/c in parts)
				content += c
			content = url_decode(content)
			parts = null
			parent.Topic(content, params2list(content))
