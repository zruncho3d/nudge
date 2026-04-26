; /macros/toolprobe_v3/_lib/MoveToProbeXY.g
; Safe travel to (tp3_probeX, tp3_probeY) at travelZ, with optional dock-band
; avoidance routing. Caller drops Z afterward.

M98 P"/macros/toolprobe_v3/globals.g"
M98 P"/macros/toolprobe_v3/state.g"

; Note: no G53 — with workplace offsets at 0 and a tool selected, user-frame
; moves correctly position the TOOL TIP (not the carriage) at the probe XY.
; G53 would crash a tool extending below the carriage at travelZ.
;
; Dock-band routing assumption: with T-active, the tool's Y offset is small
; relative to (corridorY - dockYMin/Max). Typical Jubilee setups satisfy this.
G90
G1 Z{global.tp3_travelZ} F{global.tp3_fZFast}

var routed = false
if global.tp3_dockYMin <= global.tp3_dockYMax
  var nowInBand = (move.axes[1].userPosition >= global.tp3_dockYMin) && (move.axes[1].userPosition <= global.tp3_dockYMax)
  var tgtInBand = (global.tp3_probeY >= global.tp3_dockYMin) && (global.tp3_probeY <= global.tp3_dockYMax)
  if var.nowInBand || var.tgtInBand
    G1 Y{global.tp3_corridorY} F{global.tp3_fXYTravel}
    G1 X{global.tp3_probeX} F{global.tp3_fXYTravel}
    G1 Y{global.tp3_probeY} F{global.tp3_fXYTravel}
    set var.routed = true

if !var.routed
  G1 X{global.tp3_probeX} Y{global.tp3_probeY} F{global.tp3_fXYTravel}
