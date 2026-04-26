; /macros/toolprobe_v3/CalibrateActiveTool.g
;
; Calibrate the currently selected tool's G10 offsets against the located HRP
; tool probe. Uses native G1 H4 throughout.
;
; Preconditions:
;   - LocateToolProbe.g has run (tp3_located == true)
;   - A tool is selected (state.currentTool != -1)
;
; Result: writes new G10 X/Y/Z offsets for the active tool.
; Endstops are restored on every exit path.

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"

; Defensive cleanup: in case a previous abort left endstops swapped
M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  abort "CalibrateActiveTool: home all axes first."

if state.currentTool == -1
  abort "CalibrateActiveTool: select a tool first."

if !global.tp3_located
  abort "CalibrateActiveTool: run LocateToolProbe.g first."

; Reset babystepping so the staleness check and the calibration both see a
; clean Z reference (and so the per-print Z hand-tuning doesn't bias offsets).
M290 R0 S0

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"toolprobe_v3: calibrating T" ^ state.currentTool}

; Snapshot current offsets so we apply a CORRECTION (not absolute)
var baseX = tools[state.currentTool].offsets[0]
var baseY = tools[state.currentTool].offsets[1]
var baseZ = tools[state.currentTool].offsets[2]

; --- Travel near the probe at safe Z ---
; Done BEFORE the staleness check so the Z-frame reading happens at the same
; XY where RefreshProbeZPlane / LocateToolProbe captured it. Otherwise mesh
; height variation between the macro entry XY and the probe XY shows up as a
; false-positive workspace shift.
M98 P"/macros/toolprobe_v3/_lib/MoveToProbeXY.g"

; --- Staleness check (advisory only) ---
; Approximate workspace Z offset from observable values. Different RRF versions
; report userPosition slightly differently when a tool is selected, so this
; comparison is informational and DOES NOT abort. If you ran autoz/G92 Z/G30
; since LocateToolProbe and DIDN'T refresh, the calibration will be off by the
; frame delta — the warning below tells you when this is likely.
var currentZFrame = move.axes[2].machinePosition - move.axes[2].userPosition + tools[state.currentTool].offsets[2]
if global.tp3_probeZPlaneFrame > -9998
  if abs(var.currentZFrame - global.tp3_probeZPlaneFrame) > 0.5
    echo "WARNING: workspace Z reference may have shifted since probeZPlane was measured."
    echo "  Captured frame: " ^ global.tp3_probeZPlaneFrame ^ "  Current frame: " ^ var.currentZFrame
    echo "  If you ran autoz/G92 Z/G30 since LocateToolProbe, T-1 and run RefreshProbeZPlane.g first."
    echo "  Otherwise this may be benign (RRF version reports userPosition differently with tool active)."
    echo "  Proceeding with calibration — verify Z offset afterward."

; --- Discover where the tool tip actually touches the probe ---
; The H4 trigger is physical, so this stops at first contact regardless of how
; far off the existing G10 Z is. Used to set the XY engagement depth so the
; subsequent X/Y scans always engage the dome correctly, even when the tool
; starts well above (or below) the probe due to a rough initial G10 Z.
M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: discovering tool tip Z"

M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if global.tp3_probeTriggered
  M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"
  abort "CalibrateActiveTool: probe already triggered at travel Z. Lift tp3_travelZ or check probe."

M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2

G91
G1 H4 Z{-global.tp3_toolDiscoveryPlunge} F{global.tp3_fZFast}
G90
M400

M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if !global.tp3_probeTriggered
  M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1
  G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
  echo "CalibrateActiveTool: tool tip plunge of " ^ global.tp3_toolDiscoveryPlunge ^ "mm did not contact probe."
  echo "Tool may be much shorter than expected, seed XY may be off, or probe is offline."
  echo "Increase tp3_toolDiscoveryPlunge if the tool is very short."
  abort "CalibrateActiveTool: tool tip plunge did not contact probe"

var roughTipZ = move.axes[2].userPosition

M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1

; Lift back to safe travel
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"tool tip touched probe at userZ=" ^ var.roughTipZ ^ "; XY engagement Z=" ^ (var.roughTipZ + global.tp3_toolNudgeZOffset)}

; XY engagement Z relative to the discovered tip touch position.
; toolNudgeZOffset is intentionally shallow (small negative) — tool tips are
; smaller and more fragile than the bare carriage feature used in LocateToolProbe.
var zEngage = var.roughTipZ + global.tp3_toolNudgeZOffset

; --- Bracket X around expected center ---
M98 P"/macros/toolprobe_v3/_lib/BracketAxis.g" A0 C{global.tp3_probeX} R{global.tp3_edgeStart} Z{var.zEngage}
var cx = global.tp3_lastCenter
var xSpan = global.tp3_lastSpan

; Move to refined X over expected Y before bracketing Y
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
G1 X{var.cx} Y{global.tp3_probeY} F{global.tp3_fXYTravel}

; --- Bracket Y around expected center ---
M98 P"/macros/toolprobe_v3/_lib/BracketAxis.g" A1 C{global.tp3_probeY} R{global.tp3_edgeStart} Z{var.zEngage}
var cy = global.tp3_lastCenter
var ySpan = global.tp3_lastSpan

; Span sanity (looser than LocateToolProbe; we already trust the located center)
if abs(var.xSpan - var.ySpan) > global.tp3_spanMatchTol
  M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"
  abort "CalibrateActiveTool: span asymmetry. X=" ^ var.xSpan ^ " Y=" ^ var.ySpan

; --- Z touch at refined center ---
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
G1 X{var.cx} Y{var.cy} F{global.tp3_fXYTravel}
G1 Z{global.tp3_workcellZ} F{global.tp3_fZFast}

M98 P"/macros/toolprobe_v3/_lib/TouchZNative.g"
var cz = global.tp3_lastZ

; --- Apply correction to existing offsets ---
var corrX = global.tp3_probeX - var.cx
var corrY = global.tp3_probeY - var.cy
var corrZ = global.tp3_probeZPlane - var.cz

var newX = var.baseX + var.corrX
var newY = var.baseY + var.corrY
var newZ = var.baseZ + var.corrZ

G10 P{state.currentTool} X{var.newX} Y{var.newY} Z{var.newZ}

; --- Lift, restore, report ---
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"T" ^ state.currentTool ^ " offsets X=" ^ var.newX ^ " Y=" ^ var.newY ^ " Z=" ^ var.newZ}
M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"T" ^ state.currentTool ^ " delta X=" ^ var.corrX ^ " Y=" ^ var.corrY ^ " Z=" ^ var.corrZ}
