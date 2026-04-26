; /macros/toolprobe_v3/_lib/EnsureSafeStart.g
; Common pre-flight for top-level toolprobe_v3 entries.
;
; - Restores any stale endstop swap from a previous aborted run
; - Verifies XYZ are homed
; - Verifies T-1 (no tool selected)

M98 P"/macros/toolprobe_v3/_lib/RestoreEndstops.g"

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  abort "toolprobe_v3: home all axes first."

if state.currentTool != -1
  abort "toolprobe_v3: deselect tool first (T-1)."
