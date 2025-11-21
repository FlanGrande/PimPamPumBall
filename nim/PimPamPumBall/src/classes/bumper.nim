#nim/nimmain/src/classes/bumper.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdStaticBody2D
import gdext/classes/gdRigidBody2D
import gdext/classes/gdArea2D
import gdext/classes/gdCollisionShape2D


type Bumper* {.gdsync.} = ptr object of Node2D
  bouncy_area* {.gdexport.}: Area2D
  bounce_force* {.gdexport.}: float32


method ready(self: Bumper) {.gdsync.} =
  discard self.bouncy_area.connect("body_entered", self.callable("_on_body_entered"))


method process(self: Bumper; delta: float64) {.gdsync.} =
  discard

proc ball_collided(self: Bumper, body: Node2D) {.gdsync, name: "_on_body_entered".} =
  if body.isInGroup("balls"):
    let ball: RigidBody2D = body as RigidBody2D

    if ball != nil:
      var impulse_direction: Vector2 = self.position.directionTo(ball.position)
      let impulse_vector = impulse_direction * self.bounce_force

      ball.linear_velocity = vector2(0.0, 0.0)
      ball.applyImpulse(impulse_vector)
