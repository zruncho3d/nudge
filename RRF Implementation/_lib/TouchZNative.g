; /macros/toolprobe_v3/_lib/TouchZNative.g
;
; Native G1 H4 Z touch: untriggered-check -> fast plunge -> backoff ->
; slow plunge. Records the slow trigger position.
;
; Caller must already have positioned the head at (probeX, probeY, workcellZ)
; with the probe untriggered.
;
; Output:
;   global.tp3_lastZ = machine-frame Z coord at slow trigger

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"

; --- Verify untriggered start ---
M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if global.tp3_probeTriggered
  abort "TouchZNative: probe already triggered. Raise tp3_workcellZ."

; --- Assign Z probe ---
M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2

; --- Fast plunge ---
G91
G1 H4 Z{-global.tp3_zFastPlunge} F{global.tp3_fZFast}
G90
M400

; H4 stops on trigger; sanity check
M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if !global.tp3_probeTriggered
  M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1
  abort "TouchZNative: fast plunge ran out without trigger. Lower tp3_workcellZ or raise tp3_zFastPlunge."

; --- Backoff to release contact ---
G91
G1 Z{global.tp3_zBackoff} F{global.tp3_fZFast}
G90
M400

M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if global.tp3_probeTriggered
  M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1
  abort "TouchZNative: probe did not release after backoff. Increase tp3_zBackoff."

; --- Slow plunge ---
G91
G1 H4 Z{-global.tp3_zSlowPlunge} F{global.tp3_fZSlow}
G90
M400

M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if !global.tp3_probeTriggered
  M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1
  abort "TouchZNative: slow plunge ran out without trigger. Increase tp3_zSlowPlunge."

; userPosition gives tip Z (T-active) or carriage Z (T-1 — they're equal). The
; CalibrateActiveTool offset math relies on this being the tool-tip frame.
set global.tp3_lastZ = move.axes[2].userPosition

; --- Restore Z endstop and lift ---
M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1

G91
G1 Z{global.tp3_zBackoff + global.tp3_betweenTouchZLift} F{global.tp3_fZFast}
G90

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"Z touch = " ^ global.tp3_lastZ}
