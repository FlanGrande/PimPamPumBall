#nim/nimmain/src/classes/main.nim
import gdext
import gdext/classes/gdSceneTree
import gdext/classes/gdNode2D
import gdext/classes/gdInputEvent

type Main* {.gdsync.} = ptr object of Node2D


method ready(self: Main) {.gdsync.} =
  discard

method process(self: Main; delta: float64) {.gdsync.} =
  discard

method input(self: Main; event: GdRef[InputEvent]) {.gdsync.} =
  if(event[].is_action_pressed("quit")):
    self.getTree().quit()
