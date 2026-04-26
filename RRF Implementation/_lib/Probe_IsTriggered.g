; /macros/toolprobe_v3/_lib/Probe_IsTriggered.g
; Status query (no motion). Sets global.tp3_probeTriggered based on the probe
; reading. Used to verify untriggered start state, NOT as a probing primitive.
; All actual probing is done with native G1 H4 moves.

M98 P"/macros/toolprobe_v3/globals.g"

if !exists(global.tp3_probeTriggered)
  global tp3_probeTriggered = false

var v = sensors.probes[global.tp3_probeIndex].value[0]
set global.tp3_probeTriggered = (var.v >= global.tp3_probeTrigMin) && (var.v <= global.tp3_probeTrigMax)
