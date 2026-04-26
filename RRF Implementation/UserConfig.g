; /macros/toolprobe_v3/UserConfig.g
;
; Operator-editable tuning for toolprobe_v3.
; Edit the values below, then run this file to apply. It updates tunables and
; SEED guesses but never overwrites the located probe XY/Z unless you flip
; the resetEstimateToSeed switch.

; =============================================================================
; OPTIONAL: reset runtime estimate to seed
; =============================================================================
; Set true once when you want LocateToolProbe to start from a fresh seed.
; After a successful run, set back to false.
var resetEstimateToSeed = false


; =============================================================================
; *** CARRIAGE GEOMETRY — read this first ***
; =============================================================================
; LocateToolProbe (T-1) uses your BARE CARRIAGE to bracket the probe dome.
; After the first downward touch, the carriage drops this many mm further so
; the carriage's contact feature can engage the dome's SIDE for the X/Y scans.
; Pick the value that matches your hardware:
;
;   - Nudge / probe peg sticking 5+mm below the carriage:  1.0 - 1.5
;   - Small contact pin (1-2mm below the carriage body):   0.3 - 0.7
;   - Flat carriage bottom, no dedicated probe feature:    0.0 - 0.1
;
; Symptom -> too large: LocateToolProbe aborts with
;            "ScanEdgeNative: probe already triggered at scan start"
;            (the carriage is being pushed past where it can physically go).
; Symptom -> too small: LocateToolProbe aborts with
;            "probe did not trigger within 12mm scan"
;            (the contact feature isn't engaged with the dome's side).
var locateEngagementDepth = 0.5

; CalibrateActiveTool engagement (tool tip touches dome's side at this depth)
; Negative = below the discovered tip-touch point. Keep shallow for tool tips.
var toolNudgeZOffset = -0.20


; =============================================================================
; SEED VALUES (rough estimates, machine frame, T-1)
; =============================================================================
var seedX = 263.8675
var seedY = 309.9875
var seedZGuess = 4.140
var domeZ = 0.5


; =============================================================================
; PROBE SELECTION
; =============================================================================
var probeIndex = 3
var trigMin = 900
var trigMax = 1100


; =============================================================================
; ENDSTOP PINS (must match config.g)
; =============================================================================
var endstopPinX = "^io2"
var endstopPinY = "^io1"


; =============================================================================
; Z POLICY
; =============================================================================
var travelZ = 15
var workcellZ = 8
var betweenTouchZLift = 0.5
; locateEngagementDepth and toolNudgeZOffset live in the CARRIAGE GEOMETRY
; section near the top of this file.


; =============================================================================
; XY GEOMETRY / VALIDATION
; =============================================================================
var edgeStart = 6.0
var refineMargin = 0.5

var spanMin = 1.0
var spanMax = 12.0
var spanMatchTol = 1.0
var centerRepeatTol = 0.05


; =============================================================================
; Z TOUCH
; =============================================================================
var zFastPlunge = 10.0
var zSlowPlunge = 2.0
var zBackoff = 1.0


; =============================================================================
; FEEDRATES
; =============================================================================
var fZFast = 600
var fZSlow = 50
var fXYTravel = 6000
var fXYScan = 50


; =============================================================================
; DOCK BAND
; =============================================================================
var dockYMin = 9999     ; set <= dockYMax to enable
var dockYMax = -9999
var corridorY = 150


; =============================================================================
; APPLY (create-if-missing, else set)
; =============================================================================
M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"

set global.tp3_probeSeedX = var.seedX
set global.tp3_probeSeedY = var.seedY
set global.tp3_probeSeedZGuess = var.seedZGuess
set global.tp3_probeDomeZ = var.domeZ

set global.tp3_probeIndex = var.probeIndex
set global.tp3_probeTrigMin = var.trigMin
set global.tp3_probeTrigMax = var.trigMax

set global.tp3_endstopPinX = var.endstopPinX
set global.tp3_endstopPinY = var.endstopPinY

set global.tp3_travelZ = var.travelZ
set global.tp3_workcellZ = var.workcellZ
set global.tp3_betweenTouchZLift = var.betweenTouchZLift
set global.tp3_locateEngagementDepth = var.locateEngagementDepth
set global.tp3_toolNudgeZOffset = var.toolNudgeZOffset

set global.tp3_edgeStart = var.edgeStart
set global.tp3_refineMargin = var.refineMargin

set global.tp3_spanMin = var.spanMin
set global.tp3_spanMax = var.spanMax
set global.tp3_spanMatchTol = var.spanMatchTol
set global.tp3_centerRepeatTol = var.centerRepeatTol

set global.tp3_zFastPlunge = var.zFastPlunge
set global.tp3_zSlowPlunge = var.zSlowPlunge
set global.tp3_zBackoff = var.zBackoff

set global.tp3_fZFast = var.fZFast
set global.tp3_fZSlow = var.fZSlow
set global.tp3_fXYTravel = var.fXYTravel
set global.tp3_fXYScan = var.fXYScan

set global.tp3_dockYMin = var.dockYMin
set global.tp3_dockYMax = var.dockYMax
set global.tp3_corridorY = var.corridorY

if var.resetEstimateToSeed
  set global.tp3_probeX = var.seedX
  set global.tp3_probeY = var.seedY
  set global.tp3_probeZPlane = var.seedZGuess
  set global.tp3_located = false
  M118 P0 S"toolprobe_v3: estimate reset to seed (tp3_located=false)"
else
  M118 P0 S"toolprobe_v3: tunables applied (estimate preserved)"
