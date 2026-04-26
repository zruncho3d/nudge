; /macros/toolprobe_v3/RefreshProbeZPlane.g
;
; Re-measure the located probe's Z plane in the CURRENT user frame. Run this
; after any operation that changes the workplace Z offset (autoz, manual G92 Z,
; G30 to set Z, etc.) so subsequent CalibrateActiveTool runs have a Z reference
; in the new frame.
;
; XY are unaffected by autoz (autoz only does G92 Z), so tp3_probeX/probeY are
; preserved.
;
; Preconditions:
;   - All axes homed
;   - T-1 (no tool selected)
;   - LocateToolProbe.g has been run (tp3_located == true)
;
; Recommended order of operations:
;   1. T-1
;   2. M98 P"/macros/toolprobe_v3/LocateToolProbe.g"
;   3. (autoz / klicky calibration here)
;   4. T-1
;   5. M98 P"/macros/toolprobe_v3/RefreshProbeZPlane.g"
;   6. T0  (or any tool)
;   7. M98 P"/macros/toolprobe_v3/CalibrateActiveTool.g"

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"
M98 P"/macros/toolprobe_v3/_lib/EnsureSafeStart.g"

if !global.tp3_located
  abort "RefreshProbeZPlane: run LocateToolProbe.g first."

; Reset babystepping so the captured Z frame is on the unbiased reference
M290 R0 S0

M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: refreshing probe Z plane in current user frame"

; --- Travel to the located XY at safe Z, then drop near probe ---
G90
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
G1 X{global.tp3_probeX} Y{global.tp3_probeY} F{global.tp3_fXYTravel}
G1 Z{global.tp3_workcellZ} F{global.tp3_fZFast}

; --- Precision Z touch (slow plunge with backoff) ---
M98 P"/macros/toolprobe_v3/_lib/TouchZNative.g"

; --- Update probeZPlane and the captured workspace frame ---
; With T-1 active, workplace Z offset = machinePosition - userPosition.
set global.tp3_probeZPlane = global.tp3_lastZ
set global.tp3_probeZPlaneFrame = move.axes[2].machinePosition - move.axes[2].userPosition

; --- Lift, restore, report ---
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"toolprobe_v3: probeZPlane=" ^ global.tp3_probeZPlane ^ " (workspace Z offset=" ^ global.tp3_probeZPlaneFrame ^ ")"}
