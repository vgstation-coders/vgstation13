// Wrappers needed for webview 2.0 / 516 compat.

#define HTML_SKELETON_INTERNAL(head, body, style) \
"<!DOCTYPE html><html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><meta http-equiv='X-UA-Compatible' content='IE=edge'>[head]</head><body style=[style]>[body]</body></html>"

#define HTML_SKELETON_TITLE_STYLE(title, body, style) HTML_SKELETON_INTERNAL("<title>[title]</title>", body, style)
#define HTML_SKELETON_TITLE(title, body) HTML_SKELETON_INTERNAL("<title>[title]</title>", body, "")
#define HTML_SKELETON(body) HTML_SKELETON_INTERNAL("", body, "")
