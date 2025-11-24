#nim/nimmain/src/classes/ball.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdRigidBody2D

type Ball* {.gdsync.} = ptr object of RigidBody2D
  z_plane: uint32 = 1 # Pinball board plane


method ready(self: Ball) {.gdsync.} =
  # let parent: PinballBoard = self.getParent() as PinballBoard
  # discard parent.connect("ball_lost", self.callable("_on_ball_lost"))
  discard

method process(self: Ball; delta: float64) {.gdsync.} =
  discard


proc changeZPlane*(self: Ball, new_plane: uint32) =
  self.z_plane = new_plane
  self.collisionLayer = new_plane
  self.collisionMask = new_plane
  
  if new_plane == 2:
    self.zIndex = 3
  else:
    self.zIndex = 0


# proc on_ball_lost(self: Ball) {.gdsync, name: "_on_ball_lost".} =
#   self.queueFree()
