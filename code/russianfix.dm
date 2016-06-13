/proc/sanitize_simple(var/t,var/list/repl_chars = list("ÿ"="&#255;", "\n"="#","\t"="#","???"="???"))
        for(var/char in repl_chars)
                var/index = findtext(t, char)
                while(index)
                        t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
                        index = findtext(t, char)
        return t

proc/sanitize_russian(var/msg, var/html = 0)
        var/rep
        rep = "&#1103;"
        var/index = findtext(msg, "ÿ")
        while(index)
                msg = copytext(msg, 1, index) + rep + copytext(msg, index + 1)
                index = findtext(msg, "ÿ")
        return msg

/proc/rhtml_encode(var/msg, var/html = 0)
        var/rep
        rep = "&#1103;"
        var/list/c = splittext(msg, "ÿ")
        if(c.len == 1)
                c = splittext(msg, rep)
                if(c.len == 1)
                        return html_encode(msg)
        var/out = ""
        var/first = 1
        for(var/text in c)
                if(!first)
                        out += rep
                first = 0
                out += html_encode(text)
        return out

/proc/rhtml_decode(var/msg, var/html = 0)
        var/rep
        rep = "&#1103;"
        var/list/c = splittext(msg, "ÿ")
        if(c.len == 1)
                c = splittext(msg, "&#1103;")
                if(c.len == 1)
                        c = splittext(msg, "&#x4FF")
                        if(c.len == 1)
                                return html_decode(msg)
        var/out = ""
        var/first = 1
        for(var/text in c)
                if(!first)
                        out += rep
                first = 0
                out += html_decode(text)
