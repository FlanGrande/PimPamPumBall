#nim/nimmain/src/classes/ramp.nim
import gdext
import gdext/classes/gdNode2D
import gdext/classes/gdStaticBody2D
import gdext/classes/gdRigidBody2D
import gdext/classes/gdLine2D
import gdext/classes/gdCollisionShape2D
import gdext/classes/gdCollisionPolygon2D
import gdext/classes/gdSegmentShape2D
import gdext/classes/gdCircleShape2D
import gdext/classes/gdArea2D
import gdext/classes/gdCurve
import classes/Ball

const SEG_GROUP* = "ramp_wall_segments"  # helps cleanup/rebuild

type Ramp* {.gdsync.} = ptr object of Node2D
  rampStaticBody2D* {.gdexport.}: StaticBody2D
  line2D* {.gdexport.}: Line2D
  entryTrigger1Area2D* {.gdexport.}: Area2D
  exitTrigger1Area2D* {.gdexport.}: Area2D
  entryTrigger2Area2D* {.gdexport.}: Area2D
  exitTrigger2Area2D* {.gdexport.}: Area2D
  line_width: float32
  line_points: PackedVector2Array

proc createCollisionPolygons(self: Ramp)


method ready(self: Ramp) {.gdsync.} =
  self.line_width = self.line2D.width
  self.line_points = self.line2D.points
  self.createCollisionPolygons()

  discard self.entryTrigger1Area2D.connect("body_entered", self.callable("_on_body_entered").bind(self.entryTrigger1Area2D))
  discard self.exitTrigger1Area2D.connect("body_entered", self.callable("_on_body_entered").bind(self.exitTrigger1Area2D))
  discard self.entryTrigger2Area2D.connect("body_entered", self.callable("_on_body_entered").bind(self.entryTrigger2Area2D))
  discard self.exitTrigger2Area2D.connect("body_entered", self.callable("_on_body_entered").bind(self.exitTrigger2Area2D))
  
  discard self.entryTrigger1Area2D.connect("body_exited", self.callable("_on_body_exited").bind(self.entryTrigger1Area2D))
  discard self.exitTrigger1Area2D.connect("body_exited", self.callable("_on_body_exited").bind(self.exitTrigger1Area2D))
  discard self.entryTrigger2Area2D.connect("body_exited", self.callable("_on_body_exited").bind(self.entryTrigger2Area2D))
  discard self.exitTrigger2Area2D.connect("body_exited", self.callable("_on_body_exited").bind(self.exitTrigger2Area2D))

method process(self: Ramp, delta: float64) {.gdsync.} =
  discard


proc leftNormal(dir: Vector2): Vector2 =
  # rotate 90° CCW
  result = vector2(-dir.y, dir.x)

# Proudly vibecoded to help my lack of mathing
proc offsetPolylineVariable(points: PackedVector2Array, baseWidth: float32, curve: Curve = nil): tuple[left: PackedVector2Array, right: PackedVector2Array] =
  var points_tmp = points
  let n = points.size
  if n < 2:
    return (points_tmp.duplicate(), points_tmp.duplicate())

  # cumulative arc-lengths to sample widthCurve by distance
  var cum = newSeq[float32](n)
  var total: float32 = 0
  for i in 1..<n:
    total += (points_tmp[i] - points_tmp[i-1]).length()
    cum[i] = total
  let invTotal = (if total > 0: 1.0f32 / total else: 0.0f32)

  var leftOut  = PackedVector2Array()
  var rightOut = PackedVector2Array()
  discard leftOut.resize(n)
  discard rightOut.resize(n)

  for i in 0..<n:
    let t = cum[i] * invTotal
    var wScale: float32 = 1.0
    if curve != nil:
      wScale = curve.sample(t) # 0..1 typically, but not guaranteed; clamp if you want
    let d = (baseWidth * wScale) * 0.5

    # neighbors for tangent
    let a = points_tmp[max(i-1, 0)]
    let p = points_tmp[i]
    let b = points_tmp[min(i+1, n-1)]

    var dirPrev = (p - a)
    var dirNext = (b - p)
    if dirPrev.length > 0: dirPrev = dirPrev.normalized()
    if dirNext.length > 0: dirNext = dirNext.normalized()

    if i == 0:
      # start: use first segment normal
      let n0 = leftNormal(dirNext)
      leftOut[i]  = p + n0 * d
      rightOut[i] = p - n0 * d
      continue
    elif i == n-1:
      # end: use last segment normal
      let n1 = leftNormal(dirPrev)
      leftOut[i]  = p + n1 * d
      rightOut[i] = p - n1 * d
      continue

    # interior: miter using normal bisector
    let nPrev = leftNormal(dirPrev)
    let nNext = leftNormal(dirNext)
    var bis = nPrev + nNext
    if bis.length < 1e-6:
      # straight 180° or extremely sharp turn; fall back to one side
      bis = nPrev

    # miter scale so edge stays ~d from centerline
    # cos_theta ~ projection of bisector onto one of the normals
    let cosTheta = clamp(bis.dot(nPrev), -1.0, 1.0)
    let miter = d / max(1e-6f32, cosTheta)

    leftOut[i]  = p + bis * miter
    rightOut[i] = p - bis * miter

  (left: leftOut, right: rightOut)

proc addSegmentChain(parent: Node, pts: PackedVector2Array, skipStart: int8 = 1, skipEnd: int = 1) =
  let n = pts.size
  if n < 2: return

  # Compute range of segments to include
  var firstSeg = skipStart
  var lastSeg  = max(firstSeg, (n - 1) - skipEnd)  # segment index i draws (pts[i], pts[i+1])

  for i in firstSeg ..< lastSeg:
    let a = pts[i]
    let b = pts[i + 1]
    if (b - a).length() <= 1e-5: continue

    let seg: GdRef[SegmentShape2D] = instantiate(SegmentShape2D)
    seg[].a = a
    seg[].b = b

    let cs: CollisionShape2D = instantiate(CollisionShape2D)
    cs.shape = seg[] as GdRef[Shape2D]
    # cs.addToGroup(SEG_GROUP)

    parent.addChild(cs)

# proc clearOldWallSegments(self: Ramp) =
#   for child in self.rampStaticBody2D.getChildren():
#     if child.isInGroup(SEG_GROUP):
#       self.rampStaticBody2D.removeChild(child)
#       child.queueFree()

proc createCollisionPolygons(self: Ramp) =
  if self.line_points.size < 2: return

  # self.clearOldWallSegments()

  let baseWidth = self.line2D.width / 2
  let curve: GdRef[Curve] = self.line2D.widthCurve
  let (leftPts, rightPts) = offsetPolylineVariable(self.line_points, baseWidth, curve[])

  addSegmentChain(self.rampStaticBody2D, leftPts,  skipStart = 1, skipEnd = 1)
  addSegmentChain(self.rampStaticBody2D, rightPts, skipStart = 1, skipEnd = 1)

  if self.line_points.size() >= 4:
    self.entryTrigger1Area2D.position = self.line_points[1]
    self.exitTrigger1Area2D.position = self.line_points[0]
    self.entryTrigger2Area2D.position = self.line_points[self.line_points.size() - 2]
    self.exitTrigger2Area2D.position = self.line_points[self.line_points.size() - 1]
    
    let collision_shape_1: CollisionShape2D = self.entryTrigger1Area2D.getChildren()[0] as CollisionShape2D
    let collision_shape_2: CollisionShape2D = self.exitTrigger1Area2D.getChildren()[0] as CollisionShape2D
    let collision_shape_3: CollisionShape2D = self.entryTrigger2Area2D.getChildren()[0] as CollisionShape2D
    let collision_shape_4: CollisionShape2D = self.exitTrigger2Area2D.getChildren()[0] as CollisionShape2D
    
    let collision_circle_1: CircleShape2D = collision_shape_1.shape[] as CircleShape2D
    let collision_circle_2: CircleShape2D = collision_shape_2.shape[] as CircleShape2D
    let collision_circle_3: CircleShape2D = collision_shape_3.shape[] as CircleShape2D
    let collision_circle_4: CircleShape2D = collision_shape_4.shape[] as CircleShape2D
    
    collision_circle_1.radius = self.line_width/3
    collision_circle_2.radius = self.line_width
    collision_circle_3.radius = self.line_width/3
    collision_circle_4.radius = self.line_width


proc on_body_entered(self: Ramp, body: Node2D, signal_trigger: Area2D) {.gdsync, name: "_on_body_entered".} =
  if body.isInGroup("balls"):
    let ball: Ball = body as Ball

    if ball != nil:
      # if signal_trigger.isInGroup("ramp_entry_triggers"):
      #   print("hi2")
      #   ball.changeZPlane(2)
      
      if signal_trigger.isInGroup("ramp_exit_triggers"):
        print("hi3")
        ball.changeZPlane(1)

proc on_body_exited(self: Ramp, body: Node2D, signal_trigger: Area2D) {.gdsync, name: "_on_body_exited".} =
  if body.isInGroup("balls"):
    let ball: Ball = body as Ball

    if ball != nil:
      if signal_trigger.isInGroup("ramp_entry_triggers"):
        print("hi2")
        ball.changeZPlane(2)
      
      if signal_trigger.isInGroup("ramp_exit_triggers"):
        print("hi3")
        ball.changeZPlane(1)
