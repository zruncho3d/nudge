; /macros/toolprobe_v3/_lib/UseProbeAsEndstop.g
;
; Assign or restore the endstop for one axis. Per-axis swap keeps the other
; axes on their real endstops during a scan, so an inadvertent G28 X (etc.)
; can't trigger off the tool probe.
;
; Params:
;   A = 0 (X) | 1 (Y) | 2 (Z)
;   R = 1 to RESTORE the default endstop for that axis (otherwise: assign probe)
;
; Defaults restored:
;   X -> S1 P{tp3_endstopPinX}
;   Y -> S1 P{tp3_endstopPinY}
;   Z -> M574 Z0 (no physical Z endstop; matches your config.g)

if !exists(param.A)
  abort "UseProbeAsEndstop: requires A (0,1,2)"

var axis = param.A
var restore = exists(param.R) && (param.R == 1)

if var.restore
  if var.axis == 0
    M574 X1 S1 P{global.tp3_endstopPinX}
  elif var.axis == 1
    M574 Y1 S1 P{global.tp3_endstopPinY}
  elif var.axis == 2
    M574 Z0
  else
    abort "UseProbeAsEndstop: bad axis " ^ var.axis
else
  if var.axis == 0
    M574 X1 S2 K{global.tp3_probeIndex}
  elif var.axis == 1
    M574 Y1 S2 K{global.tp3_probeIndex}
  elif var.axis == 2
    M574 Z1 S2 K{global.tp3_probeIndex}
  else
    abort "UseProbeAsEndstop: bad axis " ^ var.axis
