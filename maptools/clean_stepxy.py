import re
import fileinput
from tkinter import filedialog
print("This program replaces all instances of step_x and step_y with their corresponding pixel_x and pixel_y equivalents.")
print("Navigate to the 'maps' folder and select the .dmm file to clean up...")
print("(Backing up your file before running this script is recommended!)")
for line in fileinput.input(filedialog.askopenfilename(), inplace = 1):
    #"q" = (/obj/structure/table,/obj/machinery/pos{name = "Chemistry Point of Sale"; step_x = -1; step_y = 1; department = "Medical"},/turf/simulated/floor{dir = 4; icon_state = "whiteyellow"},/area/medical/chemistry)
    for item in re.findall('\{(.*?)\}',line):
        #name = "Chemistry Point of Sale"; step_x = -1; step_y = 1; department = "Medical"
        if(item.find("step_x") >= 0 or item.find("step_y") >= 0 or item.find("step_w") >= 0 or item.find("step_z") >= 0 or item.find("pixel_w") >= 0 or item.find("pixel_z") >= 0): #if it's lazy and it works
            pixel_x = 0;
            pixel_y = 0;
            var_dict = {}

            for var in item.split("; "):
                #name = "Chemistry Point of Sale"
                var = var.split(" = ");
                var_dict[var[0]] = var[1]

            for s in ["pixel_x", "pixel_w", "step_x", "step_w"]:
                if s in var_dict:
                    pixel_x += int(var_dict[s])
                    del var_dict[s]
            for s in ["pixel_y", "pixel_z", "step_y", "step_z"]:
                if s in var_dict:
                    pixel_y += int(var_dict[s])
                    del var_dict[s]

            var_dict["pixel_x"] = str(pixel_x)
            var_dict["pixel_y"] = str(pixel_y)

            tmp = []
            for var in var_dict:
                tmp.append(var + " = " + var_dict[var])
            line = line.replace(item, "; ".join(tmp))
    print(line, end="")
