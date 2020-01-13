#!/usr/bin/env python3

# Adds the default boilerplate code to the preference file.

import re

file_path = "../code/modules/client/preferences_savefile.dm"

# 1. Reading the variable name
var_name = str(input("Input the name of the new preference."))

# 2. Editing the sql queries 
with open(file_path) as f:
    for line in f.readlines():
        if "INSERT into client" in line:
            print(line)
            new_string = ", "+var_name+")"
            line = re.sub("[^\?]\)", new_string, line) # No "?" and a closing parenthesis ; replace ")" by ", var_name)"
            line = re.sub("\?\)", "?,?)", line) # replace "?)" by "?, ?)"
            print(line)
            print("Change the first line into the second one.\n")
        if "ckey, ooccolor" in line:
            print(line)
            line = re.sub("[^\?]\)", new_string, line) # No "?" and a closing parenthesis ; replace ")" by ", var_name)"
            print(line)
            print("Change the first line into the second one.\n")
        if "UPDATE client SET ooc" in line:
            new_string = ", "+var_name+"=? WHERE"
            print(line)
            line = re.sub("WHERE", new_string, line) # replace "WHERE" by "var_name=?, WHERE"
            print(line)
            print("Change the first line into the second one.\n")
        if "\tooccolor, lastchangelog" in line:
            new_string = ", "+var_name+", ckey)"
            print(line)
            line = re.sub(", ckey\)", new_string, line) # replace ",ckey)" by "var_name, ckey)"
            print(line)
            print("Change the first line into the second one.\n")

