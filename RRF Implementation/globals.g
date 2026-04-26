; /macros/toolprobe_v3/globals.g
;
; toolprobe_v3 — best of both worlds:
;   - Native G1 H4 probing (firmware-level, fast, accurate)  -- from original toolprobe/
;   - Config / state / user-config separation                -- from toolprobe_v2/
;   - Span + center-repeatability validation                 -- from toolprobe_v2/
;   - Dome geometry awareness                                -- from toolprobe_v2/
;   - Per-axis M574 swap, scoped at the top-level macro      -- new
;   - M118 status for DWC visibility                         -- new
;
; Naming: all globals live under the `tp3_` namespace so v3 coexists with v2
; during the transition. Edit values via UserConfig.g, not here.

; =============================================================================
; PROBE SELECTION
; =============================================================================

; Tool probe index in your M558/G31 setup (your config has K3 = tool probe)
if !exists(global.tp3_probeIndex)
  global tp3_probeIndex = 3

; Trigger band for digital probes (P8 reports 0 / 1000)
if !exists(global.tp3_probeTrigMin)
  global tp3_probeTrigMin = 900
if !exists(global.tp3_probeTrigMax)
  global tp3_probeTrigMax = 1100


; =============================================================================
; ENDSTOP RESTORE PINS
; v3 owns its own pin globals so it does not depend on the older
; SetProbeConfig.g globals. Keep these in sync with config.g.
; =============================================================================

if !exists(global.tp3_endstopPinX)
  global tp3_endstopPinX = "^io2"
if !exists(global.tp3_endstopPinY)
  global tp3_endstopPinY = "^io1"


; =============================================================================
; SEED VALUES (rough manual estimates, machine frame, T-1 active)
; After homing these should put the carriage within the probe footprint.
; Refined values are written to state.g at runtime.
; =============================================================================

if !exists(global.tp3_probeSeedX)
  global tp3_probeSeedX = 263.8675
if !exists(global.tp3_probeSeedY)
  global tp3_probeSeedY = 309.9875

; Rough estimate of the probe-top Z (machine frame).
; Used only to place XY edge scans into the engagement band; true plane is
; measured by DiscoverProbeZ + TouchZNative.
if !exists(global.tp3_probeSeedZGuess)
  global tp3_probeSeedZGuess = 4.140

; Vertical correction from contact plane to dome centerline.
; Used by tool-tip probing, not by LocateToolProbe itself.
if !exists(global.tp3_probeDomeZ)
  global tp3_probeDomeZ = 0.5


; =============================================================================
; Z POLICY
; =============================================================================

; Global travel Z (machine frame) used between regions
if !exists(global.tp3_travelZ)
  global tp3_travelZ = 15

; Local "above the probe" Z used as start point for Z touches
if !exists(global.tp3_workcellZ)
  global tp3_workcellZ = 8

; Lift after each XY edge touch so cross moves don't drag the dome
if !exists(global.tp3_betweenTouchZLift)
  global tp3_betweenTouchZLift = 0.5

; ===== CARRIAGE GEOMETRY — engagement depth for LocateToolProbe (T-1) =====
; LocateToolProbe brackets the probe dome with the BARE CARRIAGE (T-1). After
; the first downward touch, the carriage drops THIS many mm further so the
; carriage's contact feature engages the dome's SIDE for the X/Y scans.
;
;   - Has a Nudge / probe peg sticking 5+mm below the carriage:  1.0 - 1.5
;   - Has a small contact pin (1-2mm below carriage body):       0.3 - 0.7
;   - Just a flat carriage bottom (no dedicated probe feature):  0.0 - 0.1
;
; If you see "ScanEdgeNative: probe already triggered at scan start" during
; LocateToolProbe, this value is too large for your contact feature — reduce
; it. If you see "probe did not trigger within 12mm scan", increase it.
if !exists(global.tp3_locateEngagementDepth)
  global tp3_locateEngagementDepth = 0.5

; ===== TOOL TIP GEOMETRY — engagement depth for CalibrateActiveTool =====
; After the tip-discovery touch, the tip drops THIS many mm further for the
; XY tip scans. Tool tips are usually small and fragile, so keep this shallow.
; Negative number = below the discovered touch point.
if !exists(global.tp3_toolNudgeZOffset)
  global tp3_toolNudgeZOffset = -0.20


; =============================================================================
; XY GEOMETRY
; =============================================================================

; Half-window used to start an edge scan: probe is expected to be within
; tp3_edgeStart of the seed/refined center along each axis.
if !exists(global.tp3_edgeStart)
  global tp3_edgeStart = 6.0

; Refine pass margin added beyond half-span before the second edge scan
if !exists(global.tp3_refineMargin)
  global tp3_refineMargin = 0.5


; =============================================================================
; VALIDATION
; =============================================================================

; Acceptable measured span across the dome at engagement Z
if !exists(global.tp3_spanMin)
  global tp3_spanMin = 1.0
if !exists(global.tp3_spanMax)
  global tp3_spanMax = 12.0

; Allowed mismatch between X and Y spans (symmetry sanity check)
if !exists(global.tp3_spanMatchTol)
  global tp3_spanMatchTol = 1.0

; Allowed center movement between coarse and refine passes
if !exists(global.tp3_centerRepeatTol)
  global tp3_centerRepeatTol = 0.05


; =============================================================================
; Z TOUCH PARAMETERS
; =============================================================================

if !exists(global.tp3_zFastPlunge)
  global tp3_zFastPlunge = 10.0
if !exists(global.tp3_zSlowPlunge)
  global tp3_zSlowPlunge = 2.0
if !exists(global.tp3_zBackoff)
  global tp3_zBackoff = 1.0

; Plunge distance used by CalibrateActiveTool to discover where the actual
; tool tip touches the probe (handles existing G10 Z offset error). Must be
; larger than the gap from travelZ to the probe top in the worst-case tool
; offset error you expect.
if !exists(global.tp3_toolDiscoveryPlunge)
  global tp3_toolDiscoveryPlunge = 20


; =============================================================================
; FEEDRATES (mm/min)
; =============================================================================

if !exists(global.tp3_fZFast)
  global tp3_fZFast = 600
if !exists(global.tp3_fZSlow)
  global tp3_fZSlow = 50
if !exists(global.tp3_fXYTravel)
  global tp3_fXYTravel = 6000
if !exists(global.tp3_fXYScan)
  global tp3_fXYScan = 50


; =============================================================================
; DOCK BAND (Y range to avoid for cross-bed travel)
; =============================================================================

if !exists(global.tp3_dockYMin)
  global tp3_dockYMin = 9999       ; disabled if min > max
if !exists(global.tp3_dockYMax)
  global tp3_dockYMax = -9999
if !exists(global.tp3_corridorY)
  global tp3_corridorY = 150       ; safe Y outside the dock band
