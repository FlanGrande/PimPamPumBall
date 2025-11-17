#nim/nimmain/src/classes/flipper.nim
import gdext
import gdext/classes/gdCharacterBody2D
import gdext/classes/gdNode2D
import gdext/classes/gdInput
import gdext/classes/gdInputEvent
import gdext/classes/gdSceneTree
import gdext/classes/gdTween

type
  Side = enum LEFT, RIGHT

type Flipper* {.gdsync.} = ptr object of CharacterBody2D
  side* {.gdexport.}: Side
  angular_speed* {.gdexport.}: float32 = 0.05
  base_angle* {.gdexport.}: float32 = 45.0
  max_angle* {.gdexport.}: float32 = 90.0


method ready(self: Flipper) {.gdsync.} =
  discard

method process(self: Flipper; delta: float64) {.gdsync.} =
  discard

method input(self: Flipper; event: GdRef[InputEvent]) {.gdsync.} =
  if self.side == Side.LEFT:
    if event[].isActionPressed("left_flipper"):
      let tween: GdRef[Tween] = self.getTree().createTween()
      discard tween[].tweenProperty(self, "rotation_degrees", variant(self.max_angle), self.angular_speed)
    
    if event[].isActionReleased("left_flipper"):
        let tween: GdRef[Tween] = self.getTree().createTween()
        discard tween[].tweenProperty(self, "rotation_degrees", variant(self.base_angle), self.angular_speed)

  if self.side == Side.RIGHT:
    if event[].isActionPressed("right_flipper"):
      let tween: GdRef[Tween] = self.getTree().createTween()
      discard tween[].tweenProperty(self, "rotation_degrees", variant(self.max_angle), self.angular_speed)
      
    if event[].isActionReleased("right_flipper"):
        let tween: GdRef[Tween] = self.getTree().createTween()
        discard tween[].tweenProperty(self, "rotation_degrees", variant(self.base_angle), self.angular_speed)
