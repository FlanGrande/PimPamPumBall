#nim/nimmain/src/classes/plunger.nim
import gdext
import gdext/classes/gdCharacterBody2D
import gdext/classes/gdNode2D
import gdext/classes/gdInput
import gdext/classes/gdInputEvent
import gdext/classes/gdSceneTree
import gdext/classes/gdTween

type Plunger* {.gdsync.} = ptr object of Node2D
  plunger_body* {.gdexport.}: CharacterBody2D
  plunger_windup_time* {.gdexport.}: float32 = 0.6
  plunger_push_time* {.gdexport.}: float32 = 0.3
  base_position* {.gdexport.}: Vector2 = vector2(0.0, 0.0)
  max_position* {.gdexport.}: Vector2 = vector2(0.0, 64.0)


method ready(self: Plunger) {.gdsync.} =
  discard

method process(self: Plunger; delta: float64) {.gdsync.} =
  discard


method input(self: Plunger; event: GdRef[InputEvent]) {.gdsync.} =
  if event[].isActionPressed("right_flipper"):
    let tween: GdRef[Tween] = self.getTree().createTween()
    discard tween[].tweenProperty(self.plunger_body, "position", variant(self.max_position), self.plunger_windup_time)
    
  if event[].isActionReleased("right_flipper"):
    let tween: GdRef[Tween] = self.getTree().createTween()
    discard tween[].tweenProperty(self.plunger_body, "position", variant(self.base_position), self.plunger_push_time)
