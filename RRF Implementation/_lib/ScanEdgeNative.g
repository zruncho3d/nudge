; /macros/toolprobe_v3/_lib/ScanEdgeNative.g
;
; Single-axis edge scan using native G1 H4 probing. The probe is assigned as
; the endstop for ONLY this axis for the duration of the scan, then restored
; immediately after the move completes.
;
; Params:
;   A = axis (0 = X, 1 = Y)
;   D = direction of scan motion (+1 or -1)
;   S = absolute START coordinate on that axis (machine frame; should be
;       offset AWAY from the expected edge so the move starts untriggered)
;   Z = engagement Z (machine frame)
;
; Output:
;   global.tp3_lastEdge = machine-frame coordinate where the probe tripped

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"

if !exists(param.A) || !exists(param.D) || !exists(param.S) || !exists(param.Z)
  abort "ScanEdgeNative: requires A, D, S, Z"

var axisIsX = (param.A == 0)
var dir = (param.D > 0) ? 1 : -1
var startCoord = param.S
var zEngage = param.Z

; Total scan window: from start, scan up to 2 * edgeStart through center
var maxScan = 2 * global.tp3_edgeStart

; --- Move to start at safe Z ---
; Note: no G53 — with workplace offsets at 0, user-frame moves give the same
; machine positions when T-1 AND correctly target the tool tip when T-active.
; G53 here would crash a tool extending below the carriage, and would ignore
; tool offsets when bracketing the dome.
G90
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
if var.axisIsX
  G1 X{var.startCoord} F{global.tp3_fXYTravel}
else
  G1 Y{var.startCoord} F{global.tp3_fXYTravel}

; --- Drop to engagement Z ---
G1 Z{var.zEngage} F{global.tp3_fZFast}
M400
G4 P100  ; settle

; --- Verify untriggered start ---
M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if global.tp3_probeTriggered
  ; Lift before erroring so retry is safer
  G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
  echo "ScanEdgeNative: probe already triggered at scan start. zEngage=" ^ var.zEngage
  echo "Contact feature cannot dive to engagement depth."
  echo "T-1 (LocateToolProbe): reduce tp3_locateEngagementDepth in UserConfig.g."
  echo "T-active (CalibrateActiveTool): raise tp3_toolNudgeZOffset toward 0."
  abort "ScanEdgeNative: contact feature cannot reach engagement depth"

; --- Native H4 scan ---
M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A{param.A}

G91
if var.axisIsX
  G1 H4 X{var.dir * var.maxScan} F{global.tp3_fXYScan}
else
  G1 H4 Y{var.dir * var.maxScan} F{global.tp3_fXYScan}
G90
M400  ; ensure motion finished and OM updated

; --- Capture stop position ---
; userPosition reflects the TOOL TIP position (when a tool is selected) and
; equals machinePosition when T-1. Using userPosition makes the offset formula
; in CalibrateActiveTool come out correct in both contexts.
var hitPos = var.axisIsX ? move.axes[0].userPosition : move.axes[1].userPosition

; --- Restore endstop for this axis immediately ---
M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A{param.A} R1

; --- Did the move actually trigger, or did it run to full travel? ---
var traveled = (var.hitPos - var.startCoord) * var.dir
if var.traveled >= (var.maxScan - 0.005)
  ; Lift before erroring
  G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
  abort "ScanEdgeNative: probe did not trigger within " ^ var.maxScan ^ "mm scan."

set global.tp3_lastEdge = var.hitPos

; --- Lift after touch so cross moves don't drag ---
G91
G1 Z{global.tp3_betweenTouchZLift} F{global.tp3_fZFast}
G90

var axisName = var.axisIsX ? "X" : "Y"
var dirName = (var.dir > 0) ? "+" : "-"
M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"edge " ^ var.axisName ^ var.dirName ^ " = " ^ var.hitPos}
