; /macros/toolprobe_v3/LocateToolProbe.g
;
; Locate the fixed (HRP) tool probe XY center and Z plane in the machine frame.
; Uses native G1 H4 probing throughout, with deterministic span / repeatability
; validation borrowed from the v2 design.
;
; Preconditions:
;   - All axes homed
;   - T-1 (no tool selected)
;
; Result globals (machine frame, T-1):
;   global.tp3_probeX, global.tp3_probeY, global.tp3_probeZPlane, global.tp3_located = true
;
; Endstops are restored on every exit path (success or abort).

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"
M98 P"/macros/toolprobe_v3/_lib/EnsureSafeStart.g"

; Reset babystepping so the captured Z frame is on the unbiased reference
M290 R0 S0

M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: locating fixed probe"

; --- Travel to seed XY ---
M98 P"/macros/toolprobe_v3/_lib/MoveToProbeXY.g"

; --- Discover the probe top via Z plunge ---
M98 P"/macros/toolprobe_v3/_lib/DiscoverProbeZ.g"
; Engage tp3_locateEngagementDepth mm BELOW the discovered touch (carriage
; geometry knob — see UserConfig.g 'CARRIAGE GEOMETRY' section).
var zEngage = global.tp3_discoveredEngageZ - global.tp3_locateEngagementDepth

; ============================================================================
; PASS 1: bracket around the seed
; ============================================================================
M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: pass 1 (coarse)"

M98 P"/macros/toolprobe_v3/_lib/BracketAxis.g" A0 C{global.tp3_probeX} R{global.tp3_edgeStart} Z{var.zEngage}
var cx1 = global.tp3_lastCenter
var xSpan = global.tp3_lastSpan

; Move to refined X over seed Y before Y bracket
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
G1 X{var.cx1} Y{global.tp3_probeY} F{global.tp3_fXYTravel}

M98 P"/macros/toolprobe_v3/_lib/BracketAxis.g" A1 C{global.tp3_probeY} R{global.tp3_edgeStart} Z{var.zEngage}
var cy1 = global.tp3_lastCenter
var ySpan = global.tp3_lastSpan

; --- Span validation ---
if var.xSpan < global.tp3_spanMin || var.xSpan > global.tp3_spanMax
  M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"
  abort "LocateToolProbe: X span out of range: " ^ var.xSpan

if var.ySpan < global.tp3_spanMin || var.ySpan > global.tp3_spanMax
  M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"
  abort "LocateToolProbe: Y span out of range: " ^ var.ySpan

if abs(var.xSpan - var.ySpan) > global.tp3_spanMatchTol
  M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"
  abort "LocateToolProbe: span asymmetry. X=" ^ var.xSpan ^ " Y=" ^ var.ySpan

; ============================================================================
; PASS 2: refine around the discovered center
; ============================================================================
M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: pass 2 (refine)"

var rx = (var.xSpan / 2) + global.tp3_refineMargin
var ry = (var.ySpan / 2) + global.tp3_refineMargin

G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
G1 X{var.cx1} Y{var.cy1} F{global.tp3_fXYTravel}

M98 P"/macros/toolprobe_v3/_lib/BracketAxis.g" A0 C{var.cx1} R{var.rx} Z{var.zEngage}
var cx2 = global.tp3_lastCenter

G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
G1 X{var.cx2} Y{var.cy1} F{global.tp3_fXYTravel}

M98 P"/macros/toolprobe_v3/_lib/BracketAxis.g" A1 C{var.cy1} R{var.ry} Z{var.zEngage}
var cy2 = global.tp3_lastCenter

; --- Center repeatability check ---
var dxc = abs(var.cx2 - var.cx1)
var dyc = abs(var.cy2 - var.cy1)
if var.dxc > global.tp3_centerRepeatTol || var.dyc > global.tp3_centerRepeatTol
  M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"
  abort "LocateToolProbe: center not repeatable. Δx=" ^ var.dxc ^ " Δy=" ^ var.dyc

; ============================================================================
; FINAL Z TOUCH at refined center
; ============================================================================
M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: final Z touch"

G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
G1 X{var.cx2} Y{var.cy2} F{global.tp3_fXYTravel}
G1 Z{global.tp3_workcellZ} F{global.tp3_fZFast}

M98 P"/macros/toolprobe_v3/_lib/TouchZNative.g"
var cz = global.tp3_lastZ

; --- Save located probe ---
; Capture the workspace Z offset that was active when probeZPlane was measured.
; CalibrateActiveTool uses this to detect "autoz happened since locate" and
; demand a RefreshProbeZPlane.g run before producing wrong Z calibrations.
; With T-1 active, workplace Z offset = machinePosition - userPosition.
set global.tp3_probeX = var.cx2
set global.tp3_probeY = var.cy2
set global.tp3_probeZPlane = var.cz
set global.tp3_probeZPlaneFrame = move.axes[2].machinePosition - move.axes[2].userPosition
set global.tp3_located = true

; --- Lift, restore, report ---
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"toolprobe_v3: located X=" ^ global.tp3_probeX ^ " Y=" ^ global.tp3_probeY ^ " Z=" ^ global.tp3_probeZPlane}
