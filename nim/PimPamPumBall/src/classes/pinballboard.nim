#nim/nimmain/src/classes/pinballboard.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdRigidBody2D
import gdext/classes/gdArea2D
import gdext/classes/gdInputEvent
import gdext/classes/gdPhysicsServer2D
import gdext/classes/gdPackedScene
import classes/ball

type PinballBoard* {.gdsync.} = ptr object of Node2D
  lose_area* {.gdexport.}: Area2D
  ball_spawn* {.gdexport.}: Node2D
  ball_scene* {.gdexport.}: GdRef[PackedScene]

proc ball_lost(self: PinballBoard): Error {.gdsync, signal.}

method ready(self: PinballBoard) {.gdsync.} =
  discard self.lose_area.connect("body_entered", self.callable("_on_body_entered"))

method process(self: PinballBoard; delta: float64) {.gdsync.} =
  discard

method input(self: PinballBoard; event: GdRef[InputEvent]) {.gdsync.} =
  discard

proc on_body_entered(self: PinballBoard, body: Node2D) {.gdsync, name: "_on_body_entered".} =
  if body.isInGroup("balls"):
    let ball: RigidBody2D = body as RigidBody2D

    if ball != nil:
      ball.name = "LostBall"
      ball.queueFree()
      destroy ball
      let ball_instance: Ball = self.ball_scene[].instantiate as Ball
      ball_instance.position = self.ball_spawn.position
      discard self.callDeferred("add_child", ball_instance)
