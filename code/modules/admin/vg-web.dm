#ifdef __OPENBYOND
// The idea is to eventually be able to call
//to_chat(user, VGPanel(...))
// instead of
//to_chat(user, link(GetVGPanel(...)))
// But OpenBYOND isn't ready yet.
#define VGPanel(...) link(getVGPanel(__VA_ARGS__))
#endif

// Usage:
//to_chat(user, link(getVGPanel("route"[, admin=1][, query=list("get_var"="value")])))
// Turns into:
// [config.vgws_base_url]/index.php/route?get_var=value
// s is automatically added when admin=1.
/datum/admins/proc/getVGPanel(var/route,var/list/query=list(),var/admin=0)
	checkSessionKey()
	var/url="[config.vgws_base_url]/index.php/[route]"
	if(admin)
		query["s"]=sessKey
	url += buildurlquery(query)
	return url

/proc/getVGWiki(var/route)
	return "[config.vgws_base_url]/wiki/index.php/[route]"
