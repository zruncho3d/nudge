### Step 0: Fetch tools

Required:
* Allen drivers for M3 BHCS and SHCS - straight (non-ball-type) preferred

Recommended:
* Multimeter
* 3mm drill bit or (preferred) 3mm reamer

### Step 1: Choose mount type, wobbler type, and probe target length

Nudge comes in a variety of options, to fit any printer.

The key to the choice is the amount of overtravel: **overtravel** is the amount of travel beyond the edge of the bed, in X or Y, and it drives the mount and wobbler choice.

| No overtravel available... <br>and no way to add it? <br>(most moving-bed printers) | At least 6mm overtravel already available | Less than 6mm overtravel |
| --- | --- | --- |
| Use floating mount or indexed mount | Use Nudge mount by itself | Add overtravel (typically by shifting the bed forward) then use Nudge mount <br><br> OR <br><br> Make a custom detachable mount |

#### Choose mount type

First, choose the mount type for your printer.  Note:
* The location of the probe tip must be available to *all* heads; on some IDEXes (especially bed-flingers and cantilevered-bed printers like the V0), this can be a challenge.
* If using the floating or indexed mount option, go with the 2020 core type.
* If mounting to an extrusion, make a choice based on the printer type; see examples at the bottom of the table below.

| 2020 | 1515 High | 1515 Low |
| --- | --- | --- |
| ![](Renders/nudge_2020_rear.png) | ![](Renders/nudge_1515_high.png)  | ![](Renders/nudge_1515_low.png) |
| Aligned to bottom of 2020 extrusion | Aligned to bottom of 1515 extrusion | Aligned to top of 1515 extrusion |
| Trident, Tridex, V2 | F-Zero, Micron | Tri-Zero, Pandora/Pandora's Box |

#### Choose wobbler type

The wobbler come in two sizes, with tight 3mm or 5mm slip-fit holes.

If you have 6-8mm of available overtravel, you’ll want the narrowest probe target choice: an M3 pin.

Beyond 8mm of available overtravel, any target choice will work fine.  

M3 or M5 pins are preferred for ease of sourcing and ease of adjustment.  

However, many other choices will work just fine, too, if you have them handy.

**Shown below**: M3 Pin, M5 Pin, M3 BHCS with nut and internally-threaded dowel:
![](Renders/all_wobblers_side_trim.png)

An FHCS would probably work fine too.  The key is to have a flat upper surface for Z probing.

#### Choose probe target length

**It depends.**  Wait...depends on what?  Depends on bed-mount details (spacer height, bed height, extrusion height, magsheet?), overtravel, mount type, and wobbler type.  *That's a lot*, so it's best to determine the height empirically.

Generally, a longer pin is better as it reduces the forces experienced on the nozzle, which reduces belt stretch effects.

For floating and indexed mounts, anything 35mm+ should be fine.

For fixed mounts, the ideal position for the top of the probe target is about 1mm above the print surface, to provide space to trigger from XY motion, but low enough to not catch on the toolhead as it moves near the edge of the bed.

To find the ideal length for the probe target, measure from the top of the bed flexplate to the bottom of the mount (bottom of mounting extrusion with 2020 and 1515 high, and ~6mm below extrusion on 1515 low). The 1mm stick-out is roughly matched by the little bit of of clearance to the bottom of the wobbler.  Round up to the next available size (typically a 5mm increment).

If you buy a slightly-too-long pin, it can be chopped, or ignored, if you don't intend to completely max out your Z travel.

### Step 2: Buy non-printed parts

See the [BOM](BOM.md) for details on the other stuff to buy, which you probably already have handy - screws, nuts, magnets - plus the M3x6 smooth copper SHCS that you probably don't have.

### Step 3: Print the printed bits

For all Nudge parts, use standard Voron settings: 40% infill, 4 perims, 0.4 width, 5 top/bottom layers.

Use ABS or other temp-resistant material, if it will be rigidly mounted near the bed.

You want a well-calibrated printer to get glueless magnet insertions and for best accuracy.

### Step 4: Assemble and test

See this video for the build:

[![](Images/yt_thumb.png)](https://youtu.be/6eRomxUo7TI)

The video should give a good sense of what's involved, plus show some assembly tricks, but it's slightly out of date - for example, now, Nudge has a straight-through JST, rather than a right-angle JST.

I know, I know, it looks a bit long for a two-part assembly, but there's a lot going on here, and if you're aggressive with the formed threads, you may have to reprint the mount.  

So - read up, then go to town.  The order below is actually the recommended assembly order now.

#### Learn proper formed-thread tightening!
*If you overtorque a screw, you’ll have to reprint the base part.*  Nobody wants that.

Each formed-thread hole has an “easy start” (Zruncho's term) - a small clearance-size counterbore to help align the screw.  You push in to the easy start, until you get to the hole chamfer.  The screw holds itself in place.

Then, to make a good formed thread, push hard with an allen driver.  Keep turning it until you feel a bit of resistance, looking at whether the screw head is hitting anything.

To prevent stripping the formed threads, DON’T use the long side of an allen wrench; use the short end or pinch the smallest section of a driver handle.

#### Do the build

* Find a 2-pin JST-XH plug for use when adding the pins
* Prep printed parts
  * Gently clear the central wobbler hole for the pin, using a drill bit or reamer
  * Gently clear the retention-screw hole in the wobbler
* Install Magnets
 * Set your convention with a different magnet/alloy screw/mark on the stack.
 * Wobbler
   * Push down hard with fingers or against a flat surface; a magnet should push into place, securely, without glue.
   * Repeat for all 3 magnets
 * Mount
   * FLIP THE MAGNET DIRECTION!
   * Same thing; push hard
   * Repeat for all 3 magnets
 * Test that the two parts mate.  If you got the direction wrong, use the access holes in the wobbler, along with a tiny allen key, to evict the magnets and try again.
* Build wobbler
 * Push an M3x6 BHCS into the easy start
 * Form threads until fully tightened
 * Repeat for all 3 BHCS
 * Push retention-screw nut fully into bottom of wobbler
 * Insert and slightly tighten retention screw (but not enough to block insertion of the probe)
 * Add probe target (pin or screw); note that the 5mm pin will be tight with the magnets, so if adjusting the pin upwards, hold the magnets in place, or push them back down afterwards.
* Build mount
 * Push SHCSes until they hold in place and tighten a few turns
 * Add terminal plug to JST
 * Push JST fully into mount; yes, it will stick out above slightly
 * Push hard on the JST plug + terminal; keep holding as you tighten the two relevant screws.
 * Tighten 2 front SHCSes until they're fully inserted; go slow, as these screws will try to push out the square JST terminals. The screws are positioned to cut grooves into the terminals.
 * Test that the JST terminal resists some pull-out force: plug pullout/reinsert a few times.
 * Flip the core to its belly, so you can see the screw threads
 * Fully tighten rearmost 2 screws
 * Fully tighten middle two screws; look into the viewing holes to see the screw tips hit.  Don't overtighten.  You just need electrical contact and a bit of force to preload.  Keep going and it'll strip.
* Assemble
 * Put wobbler into mount and test for “clickiness”.
 * Play with it!  You have a killer fidget toy now.
* Initial Electrical test
 * Use a multimeter to confirm end-to-end continuity between JST terminals
   * If using steel screws, you should expect some resistance; up to a few hundreds ohms is OK
   * If using copper, expect single-digit or less ohms.
 * If you see no reading, make sure you have a higher (2K) ohms setting on the multimeter first.
   * Then, test each pair of neighboring screws in place to identify the issue.  If no continuity, then further tighten the relevant screws
   * Still not working?  
     * Ensure flat print
     * Ensure screws aren’t crap (heads are actually cylindrical)
     * Clean screws and ensure they’re actually conductive
     * Ensure magnets don’t have wrong polarity
* Optional for bases
 * Trim TPU to desired length
 * Push in base magnets, keeping same orientation
 * Screw in two 2x M3x25 BHCS; these are intentionally tight holes.
* Test-mount to confirm the probe type and length are about right; you can adjust slightly in place.

#### Basic electrical checkout

Here's a cool way to test the probe in Klipper, as a "filament sensor".

Add this to your `printer.cfg`, and make sure to update the pins.
```
[duplicate_pin_override]
pins: head1:PB12

[filament_switch_sensor head1_attached]
switch_pin: head1:PB12
pause_on_runout: false
```

Restart Klipper.

In your web interface for Klipper, look at the filament value; at least with Mainsail, it'll update automatically!  Tap the probe with your finger to knock it off-position slightly; the value should change.  Then have it return to center and ensure that it registers nothing.  Do this 5 times to be sure.

Switch back to the original port if needed.

Congrats!  Your probe appears to work.

#### Install in printer

This one's on you.

#### Configure software and test functionality

Move on to the [Configuration](CONFIGURATION.md) section!