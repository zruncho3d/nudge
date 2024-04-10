## FAQ

### Why does this exist?

It’s pretty simple: **All calibration is toil.  It’s wasted effort.**

The more knowledge someone needs to add a second toolhead to their printer... the fewer people will try adding that second toolhead.  And if you’re gonna add automatic calibration, it shouldn’t require work either.  It should run automatically before every print, just like bed leveling, so no matter the change, you get perfect alignment.

Because calibration represents work, Double Dragon has been idle for 2 yrs and Dueling Zero has never had a non-calibration two-head print.  They've been waiting for something like this.

You don’t NEED automatic offset calibration, but we can do better.

It’s time to make multi-toolhead setups mainstream, and this is one of the keys.  Auto offset calibration is up there with firmware support, example macros, slicer support, and validated hardware designs.

### Why no servo-deployed version?

Extra cost, unnecessary, potential point of failure, and configuration complexity.

Feel free to make it, especially to support printers with no overtravel - but make sure to quantify the repeatability.  

### Why use formed threads here, vs heatsets?

In this application, they reduce the needed XY space, which helps fit inside a bedframe with smaller builds (especially Tri-Zero with Double Dragon).

Heatsets require some skill to align, add to the BOM, slow down the build, and would compromise midpiece packaging.  For applications where screws are unlikely to ever be retightened, like a probe, they make sense.

The key phrase is *in this application*.  Yes, formed threads can strip - if you’re a gorilla, or if the holes are too big.

### Isn't this all dependent on perfectly drilled nozzles?

Sure, it's true that the touch-probe-against-nozzle approach works best when the center of the nozzle hole aligns to the rest of the nozzle.  Otherwise, you'll get a consistent error.

Unless you're using super-cheap nozzles, that shouldn't be the case, though.

It is possible that the nozzle-drilling error outweights the error introduced from the touch probe, but this would need some testing against another calibration system, such as a vision-based one.  Speaking of which...

### Why not [X] for probe alignment?

Other choices may work fine for you, and perform identically; the real differentiators here are the “batteries-included” mounting options, high level of quantified testing, and minimized required overtravel.

Compared to Viesturz' NozzleAlign probe (linear rail with target), the Z height is much faster and easier to adjust in-situ with Nudge and it does not encroach into the build space.

Compared to Viesturz’ Ball Probe, the parts are all easily available and require no grinding or custom sourcing.

Compared to “NozzleAlign Lite” (a 2020 endstop with an M6 acorn nut glued on top), acorn nut alignment quality, long-term wear, and pin rotation creating error when combined with acorn nut to pin misalignment, and  are not concerns.

Compared to vision-based systems, there is no concern about long-term longevity in a heated chamber, or code installation and configuration, and the method is less sensitive to nozzle occlusion from crud.

### Do I really need copper screws?  I can’t find those.

Steel will work fine, but the connectivity will be slightly harder to test, and the resistance may vary each time it’s touched.  

Copper is easier to test and can use lower magnet forces as a result.

If you can't source the copper ones, try it with steel first.  In tests, it has worked fine, despite a higher measured resistance.

### Can I flip the Nudge if already have Tap and don’t want two things moving during probing?

**Yes!**  There are two ways to mount Nudge.  Normal (XYZ) mode and flipped (XY-only) mode.  In XY-only mode, you need something Tap-like.  This isn't advertised on the main page, just to reduce

* XYZ Probe - can be pushed downwards, and serve as a Z target.  Requires a probe target with a flat top - a pin, FHCS, or internally-threaded dowel.  Use with any non-moving-toolhead printer.

* XY Probe - so named because you can’t do Z calibration with it.  It won’t move downwards.  For this option, the mount is simply flipped.  The target then becomes a shorter length.  Benefit: can use more choices of target, such as a SHCS or BHCS, and possibly better Z probing with moving-nozzle Z probes (Tap, Boop, Poke, etc).

