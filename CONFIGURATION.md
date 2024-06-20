# Configuration

Instructions below assume Klipper.  If you use RepRapFirmware or another firmware, PRs are welcome.

#### Add klipper-toolchanger code to Klipper

Formerly called NozzleAlign, the `tools_calibrate` code by Viesturz in the `klipper-toolchanger` repo finds the center of the probe, as well as computes the XYZ offsets relative to a different probing run.  CoreXY toolchangers have always been supported, and as of 2024-06-19 and a [patch by RCF](https://github.com/viesturz/klipper-toolchanger/pull/23/commits), IDEX support is merged into the mainline.

This code plunges to find the Z position, then moves in +X, -X, then -Y, +Y directions, with a Z offset you select.

These instructions come from Viersturz’ [klipper-toolchanger](https://github.com/viesturz/klipper-toolchanger) repo.

First, SSH to your Klipper system, then install the klipper-toolchanger code:
```
wget -O - https://raw.githubusercontent.com/viesturz/klipper-toolchanger/main/install.sh | bash
```
Klipper should restart without issue.

As best practice, enable easy updates: add this chunk to Moonraker.conf and restart Klipper when prompted:
```
[update_manager klipper-toolchanger]
type: git_repo
channel: dev
path: ~/klipper-toolchanger
origin: https://github.com/viesturz/klipper-toolchanger.git
managed_services: klipper
primary_branch: main
install_script: install.sh
```

#### Add recommended Klipper config

* Set 64x microstepping in X and Y with typical 20t pulleys and 200 steps/rev motors
  * Means 0.003125mm step

#### Add NozzleAlign config

Add the `calibrate_offsets.cfg` sample below, read the comments, and make sure your pin name and travel are set to match your deployment.

```
[tools_calibrate]
# Nudge config
#
# These two values should be changed or checked.
#
# 'pin' should reference the pin used for Nudge.
pin: z:PC0
# 'spread' is the amount of X or Y motion used in the probing sequence.
# Think of it as the clearance from the center, to accomodate the pin's diameter and any
# initial starting-point inaccuracy.
# For larger pins (5mm), increase this to 3.5mm+.
#   Increase this and/or improve the accuracy of the starting point if the probe triggers too early.
#   Decrease this and/or improve the accuracy of the starting point if the motion
#     pushes your printer beyond the allowed travel amount.
spread: 3
#
# Config below is unlikely to need changes.
#
# 'lower_z' is the distance below the probe tip in Z, used to ensure a hit.
#   Increase this to have more of the nozzle hit during probing.
#   Values as low as 0.1mm may work, and will minimize the need for overtravel.
lower_z: 0.2
travel_speed: 100
speed: 2.5
lift_speed: 4
final_lift_z: 4
sample_retract_dist: 2
samples_tolerance: 0.05
samples: 1
samples_result: median
trigger_to_bottom_z: 3
# If using a built-in Z probe to find the Nudge pin top, reference it here.
# This is only relevant for the flipped configuration, to provide resistance to pushing, for Tap/Boop/Poke/etc.
# Most should leave this commented out.
#probe: probe
```

Reference this added `calibrate_offsets.cfg` file in your printer.cfg:

```
[include calibrate_offsets.cfg]
```

Note that this include must come after the `[probe]` section.

Restart Klipper via Mainsail.

Confirm installation, and that config is in the right place, by typing `TOOL_` and seeing that `TOOL_LOCATE_SENSOR` appears.

#### Maximize and confirm travel

Maximize overtravel first: adjust the X or Y endstop, or adjust the endstop position in config.

The examples below assume a rear-mount Nudge on a 300mm-bed printer; adjust as needed.

```
G28
G0 X150 Y300
```

Ensure that the nozzle has at least 1mm clearance to the edge of the pin.  

#### Find center of probe

You don’t have to be exact as you can put in the precise center after the first iteration.

Do your best, visually, to align to the center of the probe.

#### Set up Klipper macros

The examples below derive from Viesturz' repo.

Copy the macros below, updating the X and Y positions in `NUDGE_MOVE_OVER_PROBE`, and matching your number of tools.
```
[gcode_macro NUDGE_MOVE_OVER_PROBE]
gcode:
  G0 Z3
  # Put your specific values here!
  # Update them too, after the first run.
  G0 X175 F9000
  G0 Y304 F9000

[gcode_macro NUDGE_FIND_TOOL_OFFSET]
gcode:
  NUDGE_MOVE_OVER_PROBE
  TOOL_LOCATE_SENSOR

[gcode_macro NUDGE_FIND_TOOL_OFFSETS]
gcode:
    T0
    M109 S150  # Heat up as much as possible without oozing to account for any thermal deformations
    NUDGE_MOVE_OVER_PROBE
    M104 S0
    # Match your number of tools:
    #   [1, 2, 3] for a 4-head toolchanger.
    #   [1] for IDEX or Dual Gantry.
    {% for tool in [1] %}
        T{tool}
        M109 S150
        NUDGE_MOVE_OVER_PROBE
        TOOL_CALIBRATE_TOOL_OFFSET
        M104 S0
    {% endfor %}
```

Save and restart.  

#### Do a Nudge probe

Do it:
```
G28
NUDGE_FIND_TOOL_OFFSET
```

A valid run looks like this in the Klipper console:

```
17:46:22
Sensor location at 25.061719,121.396875,2.337500
17:46:22
Probe made contact at 25.060156,124.133594,1.837500
17:46:18
...
...
...
Probe made contact at 22.360937,121.500000,1.882500
17:45:54
Probe made contact at 25.000000,121.500000,2.382500
17:45:53
TOOL_LOCATE_SENSOR
17:45:43
GO_TO_PROBE
```

Run it a few times in a row; the detected center values should be very close - within a microstep.

#### Get offsets via Nudge

Now, you should be able to automatically have this all work:

```
NUDGE_FIND_TOOL_OFFSETS
```

Note the output at the end, which shows offsets.  

Recommended: run this a few times; any variation beyond 0.01-0.02mm in X or Y suggests that the nozzle could use cleaning, or the mount is insufficiently rigid.

A bunch of probing to break it in can't hurt, either.

Copy the offset values you see into the configuration for each head.

####  Clean your nozzles

Dried crud will definitely show in your measurements, and possibly cause them to fail.

Hot crud will mess up the measurements too.

You want a clean nozzle for good results.

#### Center-finding repeatability

You can run `printer-experiments` on your laptop for max convenience, or run it on a Pi itself too.
* Clone the [printer-experiments](https://github.com/zruncho3d/printer-experiments) repo
* Install the python deps, so you can do `python3 run_test.py -h` and see help text.  Look for `pip3` in the code and run that on the command line.

Create a simple script like `test_tool_locate_sensor.sh` with content like this:
```
#!/usr/bin/env bash
# Param 1: number of reps
# Param 2: suffix for file to write
python3 ./run_test.py gantry.local \
--test_type tool_locate_sensor \
--start_gcodes '["G28", "NUDGE_MOVE_OVER_PROBE"]' \
--iterations $1 \
--stats \
--data_keys xyz
#\
#  --output \
#  --output_path myprintername/2023-12-23-x_positions_${1}_${2}.json
```

Run the script, and watch as it prints out glorious data.  The parameter (`$1` in bash) is the number of iterations.   For example, for 3 iterations: `bash test_tool_locate_sensor.sh 3`.

At the end of the run, the script will print out ranges and Std Devs for each specified `data_key` axis (here, `x`, `y`, and `z`).  Sample output from `Telxoid` showing something interesting:

```
Printing stats for x:
  Range: 0.0219
  Min: 100.6094
  Max: 100.6312
  Median: 100.6188
  Standard Deviation: 0.0049
Printing stats for y:
  Range: 0.0844
  Min: 251.0781
  Max: 251.1625
  Median: 251.1203
  Standard Deviation: 0.0228
```
