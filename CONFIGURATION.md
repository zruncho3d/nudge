# Configuration

Instructions below assume Klipper.  If you use RepRapFirmware or another firmware, PRs are welcome.

#### Add NozzleAlign code to Klipper

NozzleAlign is a Klipper Extra from `Viesturz` to find the center of the probe, as well as compute the XYZ offsets relative to a different probing run.  It works with, and appears to be mostly tested on, CoreXY kinematics.

NozzleAlign plunges to find the Z position, then moves in +X, -X, then +Y, -Y directions, with a Z offset you select.

First, SSH to your Klipper system to install NozzleAlign.
```
cd ~
git clone https://github.com/viesturz/NozzleAlign
cd NozzleAlign
cp klipper/klippy/extras/tools_calibrate.py ~/klipper/klippy/extras/
sudo service klipper restart
```

Klipper should restart without issue.

#### Add NozzleAlign configuration

Add and reference a `calibrate_offsets.cfg` file with some required NozzleAlign config, as per the repo.

The one below derives from the sample, and works on an SKR Pico - (change `pin` to match!).  The comments are confusing, yes.

Notes:
* Maximize overtravel first; adjust endstop, or adjust the endstop position in software.
* Reducing `lower_z` (say, to 0.1 - 0.2) reduces the amount of overtravel needed.
* This file assumes you have a probe, and that the probe is a nozzle probe like Tap.  If you don’t have that, you’ll have to comment out the `probe: ` line so the Nudge is used as the Z side.

```
[tools_calibrate]
pin: ^gpio16
travel_speed: 100  # mms to travel sideways for XY probing
spread: 8  # mms to travel down from top for XY probing
lower_z: 0.5  # The speed (in mm/sec) to move tools down onto the probe
speed: 2.5 # The speed (in mm/sec) to retract between probes
lift_speed: 4  # Z Lift after probing done, should be greater than any Z variance between tools
final_lift_z: 6
sample_retract_dist:2
samples_tolerance: 2.0  # 0.05
samples: 1
samples_result: median # median, average
# Settings for nozzle probe calibration - optional.
probe: probe # name of the nozzle probe to use; comment out if using Nudge as Z probe
trigger_to_bottom_z: 3  # Was 0.25 # Offset from probe trigger to vertical motion bottoms out.
# decrease if the nozzle is too high, increase if too low.
```

Reference this added `calibrate_offsets.cfg` file in your printer.cfg:

```
[include calibrate_offsets.cfg]
```

Note that this include must come after the `[probe]` section.

Restart Klipper via Mainsail.

Confirm installation, and that config is in the right place, by typing `TOOL_` and seeing that `TOOL_LOCATE_SENSOR` appears.

#### Find center of probe
Put the head on the back edge (highest Y value possible).   Example:
```
G28
G0 X0 Y140
```
Jog it left/right 1mm at a time, until centered on the probe in X.

Now, move it 5mm left, then bring it forward and find the Y value.  Get it within a mm or so.  

You don’t have to be exact as you can put in the found center after the first iteration.

Create a test macro to home the printer, then move to above the probe.
```
[gcode_macro GO_TO_PROBE_START_LOCATION]
gcode:
G0 Z4
G0 X25 Y121.5
```
Note that you may want a `T0` command in there.

Put this in a macro, which will:
* Find the initial center position
* Using the initial position, probe again to find the refined position

```
[gcode_macro PROBE_NOW]
G28
GO_TO_PROBE_START_LOCATION
TOOL_LOCATE_SENSOR
```

Save and restart.  

Do it:
```
PROBE_NOW
```

A valid run looks like this in the Klipper console:

```
17:46:22
Sensor location at 25.061719,121.396875,2.337500
17:46:22
Probe made contact at 25.060156,124.133594,1.837500
17:46:18
Probe made contact at 25.060156,118.660156,1.837500
17:46:15
Probe made contact at 27.800781,121.380469,1.837500
17:46:12
Probe made contact at 22.322656,121.380469,1.837500
17:46:09
Probe made contact at 25.060156,121.380469,2.337500
17:46:07
Probe made contact at 25.000000,124.067187,1.882500
17:46:03
Probe made contact at 25.000000,118.693750,1.882500
17:46:00
Probe made contact at 27.759375,121.500000,1.882500
17:45:57
Probe made contact at 22.360937,121.500000,1.882500
17:45:54
Probe made contact at 25.000000,121.500000,2.382500
17:45:53
TOOL_LOCATE_SENSOR
17:45:43
GO_TO_PROBE
```

Run it a few times in a row; the detected center values should be very close - within a microstep.

#### Get both heads working and measure relative offset

You can probably just run the `TOOL_CALIBRATE_OFFSET` function with an appropriate macro, per the NozzleAlign documentation.  The macro will depend on your printer type.

Also, if you already have a probe (for Tap or Klicky) - you’ll need to add a second named probe.

Possible sol’ns from:
* https://github.com/tronfu/Voron-Mods/tree/main/Tridex/Auto_3-Axes_Calibration/Klippy_modules
* https://github.com/viesturz/klipper-toolchanger
* https://github.com/viesturz/TapChanger-lite/blob/main/klipper/klippy/extras/tool_probe.py

#### Automatic Persistent Calibration

Z has this on a printer that uses Nudge.

You run one macro and it finds and saves the offset for the second toolhead into `printer.cfg`.  Of course, you need something that implements the offsets on toolchanges, like `KTCC` installed and set up, which worked for me, based on the sample config.

Add macros like this:

```
# I don't understand why KTCC_T1 won't run inside a macro that calls KTCC_T0 already.
# But this workaround enables a single macro call to run both :shrug
[gcode_macro MY_SEQUENCE_FIND_AND_SAVE_OFFSET]
gcode:
  FIRST_PART_T0
  SECOND_PART_T1
  TOOL_CALIBRATE_SAVE_TOOL_OFFSET SECTION="tool 1” ATTRIBUTE="offset"
  SAVE_CONFIG

[gcode_macro FIRST_PART_T0]
gcode:
  KTCC_T0
  G0 X5 F10000
  G0 Y80 F10000
  GO_TO_PROBE_START_LOCATION
  TOOL_LOCATE_SENSOR
  G0 X5 F10000
  G0 Y65 F10000

[gcode_macro SECOND_PART_T1]
gcode:
  KTCC_T1
  G0 X125 F10000
  G0 Y79 F10000
  GO_TO_PROBE_START_LOCATION
  TOOL_CALIBRATE_TOOL_OFFSET
  G0 X125 F10000
  G0 Y65 F10000
  M400
```

#### Repeatability Testing

Expect this section to grow over time, including instructions for repeatability testing used during dev, which need some cleanup before sharing.

Recommended Klipper config:
* Set 64x microstepping in X and Y with typical 20t pulleys and 200 steps/rev motors
  * Means 0.003125mm step

#### Center-finding repeatability

You can run `printer-experiments` on your laptop for max convenience, or run it on a Pi itself too.
* Clone the [printer-experiments](https://github.com/zruncho3d/printer-experiments) repo
* Install the python deps, so you can do `python3 run_test.py -h` and see help text.  Look for `pip3` in the code and run that on the command line.

Create a simple script like test_tool_locate_sensor.sh with content like this:
```
#!/usr/bin/env bash
# Param 1: number of reps
# Param 2: suffix for file to write
python3 ./run_test.py gantry.local \
--test_type tool_locate_sensor \
--start_gcodes '["G28", "GO_TO_PROBE_START_LOCATION"]' \
--iterations $1 \
--stats \
--data_keys xyz
#\
#  --output \
#  --output_path sxyo/2023-12-23-x_positions_${1}_${2}.json
```

Set up a `GO_TO_PROBE_START_LOCATION` like the one above (modifying to match your X and Y) if you haven’t already.

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
