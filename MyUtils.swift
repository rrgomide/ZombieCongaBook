import Foundation
import CoreGraphics
import AVFoundation

let π = CGFloat.pi
var backgroundMusicPlayer: AVAudioPlayer!

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
  
  left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
  
  left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  
  return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (left: inout CGPoint, right: CGPoint) {

  left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {

  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (point: inout CGPoint, scalar: CGFloat) {

  point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {

  return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= ( left: inout CGPoint, right: CGPoint) {

  left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {

  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (point: inout CGPoint, scalar: CGFloat) {

  point = point / scalar
}

#if !(arch(x86_64) || arch(arm64))
  
  func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
  
    return CGFloat(atan2f(Float(y), Float(x)))
  }
  
  func sqrt(a: CGFloat) -> CGFloat {
  
    return CGFloat(sqrtf(Float(a)))
  }
  
#endif

extension CGPoint {
  
  func length() -> CGFloat {
  
    return sqrt((x * x) + (y * y))
  }
  
  func normalized() -> CGPoint {
  
    return self / length()
  }
  
  var angle: CGFloat {
  
    return atan2(y, x)
  }
}

func shortestAngleBetween(angle1: CGFloat,
                          angle2: CGFloat) -> CGFloat {
  
  let twoπ = π * 2.0
  
  var angle =
    (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
  
  if angle >= π {
    
    angle = angle - twoπ
  }
  
  //if angle <= π {
  if angle <= -π {
  
    angle = angle + twoπ
  }
  
  return angle
}

extension CGFloat {
  
  func sign() -> CGFloat {
    
    return self >= 0.0 ? 1.0 : -1.0
  }
  
  static func random() -> CGFloat {
    
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
  }
  
  static func random(min: CGFloat, max: CGFloat) -> CGFloat {
    
    assert(min < max)
    return CGFloat.random() * (max - min) + min
  }
}

func playBackgroundMusic(fileName: String) {
  
  let resourceURL =
    Bundle.main.url(forResource: fileName, withExtension: nil)

  guard let url = resourceURL
    else {
      print("Could not find file \(fileName)")
      return
  }
  
  do {
    
    try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
    
  }
  catch {
    
    print("Could not create audio player")
    return
  }
}

func centerPosition(size: CGSize) -> CGPoint {
  
  return CGPoint(x: size.width/2, y: size.height/2)
}

func sceneTapped() {
  
  
}














