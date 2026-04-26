; /macros/toolprobe_v3/_lib/DiscoverProbeZ.g
;
; Find the probe top via a single native G1 H4 plunge from travelZ.
; Output:
;   global.tp3_discoveredEngageZ = userPosition at first contact (tip frame)
;
; The caller (LocateToolProbe.g) is responsible for adding any further
; engagement depth via tp3_locateEngagementDepth.
;
; Assumes you are already positioned at (tp3_probeX, tp3_probeY).

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"

M98 P"/macros/toolprobe_v3/_lib/Status.g" S"toolprobe_v3: discovering probe Z plane"

; Verify we are not already triggered before plunging
M98 P"/macros/toolprobe_v3/_lib/Probe_IsTriggered.g"
if global.tp3_probeTriggered
  abort "DiscoverProbeZ: probe already triggered at travel Z (raise tp3_travelZ or check probe state)"

; Lift to safe Z first. No G53 — with T-1 it makes no difference, and dropping
; G53 keeps this leaf consistent with the T-active context.
G90
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
M400

; Assign probe as Z endstop, native H4 plunge, then restore Z endstop
M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2

; Plunge from travelZ down toward 0 — H4 stops on trigger
G1 H4 Z0 F{global.tp3_fZFast}
M400

; Capture in tool-tip frame (userPosition). With T-1 this equals
; machinePosition; with T-active (not the normal call site) it would be tip Z.
var touchZ = move.axes[2].userPosition

M98 P"/macros/toolprobe_v3/_lib/UseProbeAsEndstop.g" A2 R1

; Sanity: we should not have run all the way to Z0
if var.touchZ <= 0.05
  abort "DiscoverProbeZ: plunge ran to Z0 without trigger. Seed XY likely off, or probe failed."

; Lift back to safe Z
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}
M400

; Store the discovered touch Z. The caller adds tp3_locateEngagementDepth.
; Note: tp3_probeZPlane is deliberately NOT set here — LocateToolProbe's final
; TouchZNative is the single source of truth for that value.
set global.tp3_discoveredEngageZ = var.touchZ

M98 P"/macros/toolprobe_v3/_lib/Status.g" S{"toolprobe_v3: probe top Z=" ^ var.touchZ}
