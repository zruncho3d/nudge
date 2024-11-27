# Overview

btc_nudge.cfg provides macros to utilize this excellent tool by zruncho. These macros was developed as part of the [Lineux toolchanger](https://github.com/Bikin-Creative/Lineux-Toolchanger)
project. They are provided for users of toolchangers other than using viesturz excellent plugin.

# Instructions

Edit `btc_nudge.cfg` as below:

```
[gcode_button nudge_sensor_pin]
pin: ^PG15
press_gcode:
release_gcode:
# Enter pin number your nudge tool is connected to. Leave the rest as is.
```

```
[gcode_macro _nudge_variables]
variable_numoftool: [0, 1, 2, 3]     # Installed tools
variable_nudge_resolution: 0.05      # Resolution should be between 0.01 - 0.1
variable_nudge_travel_speed: 100
# Installed tools. In case a tool is disabled, eg. for servicing, enter example [0, 1, 3], where tool 2 is disabled
# resolution must be between 0.01 - 0.1. Probing will be very very slow at highest resolution of 0.01. For faster probing, use lower resolution of 0.1.
# travel_speed, set at your usual travel speed
```

Save and restart firmware.

Home All

Z Tilt/Quad Gantry

Home Z

Move nozzle to a position about center of probe, and about 3mm above probe

NUDGE_FIND_TOOL_OFFSETS

When done, retrieve all tools offsets from console as describe below:

![](https://github.com/Bikin-Creative/Lineux-Toolchanger/blob/main/Images/nudge_result.jpg)

```
Calculated offsets for this tool:
Z: -1.65
X: -0.48
Y: 0.45
--- End Tool Offset Calibration ---
```

By using the numbers above, edit `tool_x.cfg` and enter these offsets. Scroll thru the console to get offsets for all tools.
