# Adds the default boilerplate code to the preference file.

#!/usr/bin/env python3

import re

file_path = "./code/modules/client/preferences_savefile.dm"

# 1. Reading the variable name
var_name = str(input("Input the name of the new preference."))

# 2. Editing the sql queries 
with open(file_path) as f:
    for line in f.readlines():
        if "INSERT into client" in line
            line.replace("[^\?]\)", " ,"+var_name+")" % (f)) # No "?" and a closing parenthesis ; replace ")" by ", var_name)"
            line.replace("\?\)", "?, ?)" % (f)) # replace "?)" by "?, ?)"
            line = reader.readline()
            line.replace("[^\?]\)", " ,"+var_name+")" % (f)) # No "?" and a closing parenthesis ; replace ")" by ", var_name)"
            print("Changed the INSERT into client")
        if "UPDATE client"
            line.replace("WHERE", var_name+"=?"+" WHERE" % (f)) # replace "WHERE" by "var_name=?, WHERE"
            line = reader.readline()
            line.replace(", ckey)", ","+var_name+", ckey)" % (f)) # replace ",ckey)" by "var_name, ckey)"
            print("Changed the UPDATE client")