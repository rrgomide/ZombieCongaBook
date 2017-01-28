import SpriteKit

class GameScene: SKScene {
  
  let zombie = SKSpriteNode(imageNamed: "zombie1")
  var lastUpdateTime : TimeInterval = 0.0
  var dt : TimeInterval = 0.0
  var zombieMovePointsPerSec = CGFloat(600.0)
  let catMovePointsPerSec = CGFloat(480.0)
  var velocity = CGPoint.zero
  let playableRect: CGRect
  var lastTouchLocation = CGPoint.zero
  let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
  let zombieAnimation: SKAction
  var isZombieInvincible = false
  var lives = 5
  var gameOver = false  
  
  let catCollisionSound: SKAction =
    SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
 
  let enemyCollisionSound: SKAction =
    SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
  
  let cameraNode = SKCameraNode()
  let cameraMovePointsPerSec: CGFloat = 200.0

  let livesLabel = SKLabelNode(fontNamed: "Glimstick")
  let catsLabel = SKLabelNode(fontNamed: "Glimstick")
  
  override init(size: CGSize) {
    
    let maxAspectRatio: CGFloat = (16.0 / 9.0)
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight) / 2.0
    
    playableRect =
      CGRect(x: CGFloat(0),
             y: playableMargin,
             width: size.width,
             height: playableHeight)
    
    var textures: [SKTexture] = []
    
    for i in 1...4 {
      
      textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    
    textures.append(textures[2])
    textures.append(textures[1])
    
    zombie.zPosition = 100
    
    zombieAnimation =
      SKAction.animate(with: textures, timePerFrame: 0.1)
    
    super.init(size: size)
  }
  
  required init(coder aDecoder: NSCoder) {
    
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    
    playBackgroundMusic(fileName: "backgroundMusic.mp3")
    
    backgroundColor = SKColor.black
    
    /*
    let background =
      SKSpriteNode(imageNamed: "background1")
    
    background.position =
      CGPoint(x: size.width/2,
              y: size.height/2)
    
    background.anchorPoint =
      CGPoint(x: 0.5,
              y: 0.5)
    //background.position = CGPoint.zero
    //background.anchorPoint = CGPoint.zero
 
    let background = backgroundNode()
    background.anchorPoint = CGPoint.zero
    background.position = CGPoint.zero
    background.name = "background"
    */
    
    for i in 0...1 {
      
      let background = backgroundNode()
      background.anchorPoint = CGPoint.zero
      background.position =
        CGPoint(x: CGFloat(i) * background.size.width, y: 0)
      background.name = "background"
      addChild(background)
    }
 
    //Making sure no other sprites comes behind the background
    //background.zPosition = -1
    
    zombie.position =
      CGPoint(x: 400,
              y: 400)
    
    lastTouchLocation = zombie.position
    
    zombie.anchorPoint =
      CGPoint(
        x: 0.5,
        y: 0.5)
    
    //zombie.setScale(2)
    //zombie.scale(to: CGSize(width: (zombie.size.width * 2),
    //                         height: zombie.size.height * 2))
    
    //addChild(background)
    addChild(zombie)
    
    //zombie.run(SKAction.repeatForever(zombieAnimation))
    //startZombieAnimation()
    
    //spawnEnemy()
    //spawnEnemyV()
    //spawnEnemyReverse()
    //spawnEnemyOfficial()
    
    run(
      SKAction.repeatForever(
        SKAction.sequence(
          [SKAction.run() {
          
            [weak self] in self?.spawnEnemyOfficial()
          },
          SKAction.wait(forDuration: 2.0)]))
    )
    
    run(
      SKAction.repeatForever(
        SKAction.sequence(
          [SKAction.run() {
            [weak self] in self?.spawnCat()},
           SKAction.wait(forDuration: 1.0)]))
    )
    
    //background.zRotation = CGFloat(M_PI) / 8
    //debugDrawPlayableArea()
    addChild(cameraNode)
    self.camera = cameraNode
    cameraNode.position = centerPosition(size: self.size)

    livesLabel.text = "Lives: \(self.lives)"
    livesLabel.fontColor = SKColor.black
    livesLabel.fontSize = 100
    livesLabel.zPosition = 150
    livesLabel.horizontalAlignmentMode = .left 
    livesLabel.verticalAlignmentMode = .bottom 
    livesLabel.position = 
      CGPoint(x : -playableRect.size.width/2 + CGFloat(20),
              y : -playableRect.size.height/2 + CGFloat(20))
    cameraNode.addChild(livesLabel)
    
    catsLabel.text = "Cats: 0"
    catsLabel.fontColor = SKColor.black
    catsLabel.fontSize = 100
    catsLabel.zPosition = 150
    catsLabel.horizontalAlignmentMode = .right
    catsLabel.verticalAlignmentMode = .bottom
    catsLabel.position =
      CGPoint(x: playableRect.size.width/2 - CGFloat(20),
              y: -playableRect.size.height/2 + CGFloat(20))
    cameraNode.addChild(catsLabel)
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    //zombie.position =
    //  CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
    if lastUpdateTime > 0 {
      
      dt = currentTime - lastUpdateTime
    }
    else {
      dt = 0.0
    }
    
    lastUpdateTime = currentTime
    
    /*
    if (lastTouchLocation - zombie.position).length() <=
       (zombieMovePointsPerSec * CGFloat(dt)) {
      
      zombie.position = lastTouchLocation
      velocity = CGPoint.zero
      stopZombieAnimation()
    }
    else {
    */
      move(sprite: zombie,
           velocity: velocity)
      
      rotate(sprite: zombie,
             direction: velocity,
             rotateRadiansPerSec: zombieRotateRadiansPerSec)
      //print("\(dt * 1000) milliseconds since last update")
    //}
    
    boundsCheckZombie()
    moveTrain()
    moveCamera()
    livesLabel.text = "Lives: \(self.lives)"

    //checkCollisions()
    if lives <= 0 && !gameOver {
      
      gameOver = true
      print("You lose")
      backgroundMusicPlayer.stop()
      
      let gameOverScene = GameOverScene(size: self.size, won: false)
      gameOverScene.scaleMode = self.scaleMode
      
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    //cameraNode.position = zombie.position
  }
  
  override func didEvaluateActions() {
    
    checkCollisions()
  }
  
  func move(sprite: SKSpriteNode, velocity: CGPoint) {
    
    let amountToMove = velocity * CGFloat(dt);
    //CGPoint(x: velocity.x * CGFloat(dt),
    //        y: velocity.y * CGFloat(dt))
    
    //print("Amount to move - \(amountToMove)")
    
    sprite.position += amountToMove
    //CGPoint(x: sprite.position.x + amountToMove.x,
    //        y: sprite.position.y + amountToMove.y)
  }
  
  func moveZombieToward(_ location: CGPoint) {
    
    startZombieAnimation()
    
    let offset = location - zombie.position
    //CGPoint(x: location.x - zombie.position.x,
    //        y: location.y - zombie.position.y)
    
    //let length =
    //  sqrt(offset.x * offset.x + offset.y * offset.y)
    
    //let direction = offset / offset.length()
    //CGPoint(x: offset.x / CGFloat(length),
    //        y: offset.y / CGFloat(length))
    
    velocity = offset.normalized() * zombieMovePointsPerSec
    //CGPoint(x: direction.x * zombieMovePointsPerSec,
    //        y: direction.y * zombieMovePointsPerSec)
    
  }
  
  func sceneTouched(touchLocation: CGPoint) {
    
    lastTouchLocation = touchLocation
    moveZombieToward(touchLocation)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }
  
  func boundsCheckZombie() {
    
    //let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
    //let upperRight = CGPoint(x: size.width, y: playableRect.maxY)
    
    let bottomLeft =
      CGPoint(x: cameraRect.minX, y: cameraRect.minY)
    
    let topRight =
      CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
    
    if zombie.position.x <= bottomLeft.x {
      
      zombie.position.x = bottomLeft.x
      //velocity.x = -velocity.x
      velocity.x = abs(velocity.x)
    }
    
    if zombie.position.x >= topRight.x {
      
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    
    if zombie.position.y <= bottomLeft.y {
      
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    
    if zombie.position.y >= topRight.y {
      
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }
  
  func debugDrawPlayableArea() {
    
    let shape = SKShapeNode()
    let path = CGMutablePath()
    path.addRect(playableRect)
    shape.path = path
    shape.strokeColor = SKColor.red
    shape.lineWidth = 4.0
    addChild(shape)
  }
  
  func rotate(sprite: SKSpriteNode,
              direction: CGPoint,
              rotateRadiansPerSec: CGFloat) {
    
    let shortest =
      shortestAngleBetween(angle1: sprite.zRotation,
                           angle2: direction.angle)
    
    let amountToRotate =
      min(rotateRadiansPerSec * CGFloat(dt),
          abs(shortest))
    
    sprite.zRotation += shortest.sign() * amountToRotate
  }
  
  func spawnEnemy() {
    
    let enemy = SKSpriteNode(imageNamed: "enemy")
    
    enemy.position =
      CGPoint(x: size.width + enemy.size.width/2,
              y: size.height/2)
    
    addChild(enemy)
    
    let actionMove =
      SKAction.move(to: CGPoint(x: -enemy.size.width/2,
                                y: enemy.position.y),
                    duration: 2.0)
    
    enemy.run(actionMove)
  }
  
  func spawnEnemyV() {
    
    let enemy = SKSpriteNode(imageNamed: "enemy")
    
    enemy.position =
      CGPoint(x: size.width + enemy.size.width/2,
              y: size.height/2)
    
    addChild(enemy)
    
    let actionMidMove =
      SKAction.move(to: CGPoint(x: size.width/2,
                                y: playableRect.minY + enemy.size.height/2),
                    duration: 2.0)
    
    let logMessage = SKAction.run() {
      
      print("Reached bottom!")
    }
    
    let wait = SKAction.wait(forDuration: 0.75)
    
    let actionMove =
      SKAction.move(to: CGPoint(x: -enemy.size.width/2,
                                y: enemy.position.y),
                    duration: 2.0)
    
    let sequence =
      SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
    
    enemy.run(sequence)
  }
  
  func spawnEnemyReverse() {
    
    let enemy = SKSpriteNode(imageNamed: "enemy")
    
    enemy.position =
      CGPoint(x: size.width + enemy.size.width/2,
              y: size.height/2)
    
    addChild(enemy)
    
    let actionMidMove =
      SKAction.moveBy(x: -size.width/2 - enemy.size.width/2,
                      y: playableRect.height/2 - enemy.size.height/2,
                      duration: 1.5)
    
    let logMessage = SKAction.run() {
      
      print("Reached bottom!")
    }
    
    let wait = SKAction.wait(forDuration: 0.9)
    
    let actionMove =
      SKAction.moveBy(x: -size.width/2 - enemy.size.width/2,
                      y: -playableRect.height/2 + enemy.size.height/2,
                      duration: 1.5)
    let reverseMid = actionMidMove.reversed()
    let reverseMove = actionMove.reversed()
    
    let sequence =
      SKAction.sequence([actionMidMove, logMessage, wait, actionMove,
                         reverseMove, logMessage, wait, reverseMid])
    
    let repeatAction = SKAction.repeatForever(sequence)
    
    enemy.run(repeatAction)
  }
  
  func spawnEnemyOfficial() {
    
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    let random = CGFloat.random(min: playableRect.minY + enemy.size.height/2,
                                max: playableRect.maxY - enemy.size.height/2)
    
    //print("Generated number: \(random)")
    
    //enemy.position =
    //  CGPoint(x: size.width + enemy.size.width/2,
    //          y: random)
    enemy.zPosition = 50
    enemy.position =
      CGPoint(x: cameraRect.maxX + enemy.size.width/2,
              y: random)
    
    addChild(enemy)
    
    //let actionMove =
    //  SKAction.moveTo(x: -enemy.size.width/2,
    //                  duration: 2.0)
    //let actionMove =
    //  SKAction.moveTo(x: cameraRect.minX, duration: 2.0)
    let actionMove =
      SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 2.0)
    
    let actionRemove =
      SKAction.removeFromParent()
    
    enemy.run(SKAction.sequence([actionMove, actionRemove]))
  }
  
  func startZombieAnimation() {
    
    if zombie.action(forKey: "animation") == nil {
      
      zombie.run(SKAction.repeatForever(zombieAnimation),
                 withKey: "animation")
    }
  }
  
  func stopZombieAnimation() {
    
    zombie.removeAction(forKey: "animation")
  }
  
  func spawnCat() {
    
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    
    cat.position =
      CGPoint(x: CGFloat.random(min: cameraRect.minX,
                                max: cameraRect.maxX),
              y: CGFloat.random(min: cameraRect.minY,
                                max: cameraRect.maxY))
    cat.zPosition = 50
    cat.setScale(0)
    addChild(cat)
    
    let appear = SKAction.scale(to: 1.0, duration: 0.5)
    //let wait = SKAction.wait(forDuration: 10.0)
    let disappear = SKAction.scale(to: 0, duration: 0.5)
    let remove = SKAction.removeFromParent()
    
    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
    let rightWiggle = leftWiggle.reversed()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
    //let wiggleWait = SKAction.repeat(fullWiggle, count: 10)
    
    let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
    let scaleDown = scaleUp.reversed()
    let fullScale =
      SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeat(group, count: 10)
    
    let actions = [appear, groupWait, disappear, remove]
    cat.run(SKAction.sequence(actions))
    
  }
  
  func zombieHit(cat: SKSpriteNode) {
    
    //cat.removeFromParent()
    //run(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false))
    cat.name = "train"
    cat.removeAllActions()
    cat.setScale(1.0)
    cat.zRotation = 0
    cat.run(
      SKAction.colorize(
        with: SKColor.green,
        colorBlendFactor: 1.0,
        duration: 0.2))
    
    run(catCollisionSound)
  }
  
  func zombieHit(enemy: SKSpriteNode) {
    
    //enemy.removeFromParent()
    //run(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false))
    //run(enemyCollisionSound)
    isZombieInvincible = true
    
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction =
      SKAction.customAction(
        withDuration: duration)
        { node, elapsedTime in
          let slice = duration / blinkTimes
          let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
          node.isHidden = remainder > slice / 2
        }
    
    //zombie.run(blinkAction)
    //zombie.isHidden = false
    //isZombieInvincible = false
    
    let setHidden = SKAction.run() { [weak self] in
      self?.zombie.isHidden = false
      self?.isZombieInvincible = false
    }
    zombie.run(SKAction.sequence([blinkAction, setHidden]))
    
    run(enemyCollisionSound)
    loseCats()
    lives -= 1
    print("Lives - \(lives)")
  }
  
  func checkCollisions() {
  
    var hitCats: [SKSpriteNode] = []
    
    enumerateChildNodes(withName: "cat") { node, _ in
      
      let cat = node as! SKSpriteNode
      
      if cat.frame.intersects(self.zombie.frame) {
        
        hitCats.append(cat)
      }
      
      for cat in hitCats {
        
        self.zombieHit(cat: cat)
      }
    }
    
    if isZombieInvincible {
      return
    }
    
    var hitEnemies: [SKSpriteNode] = []
    
    enumerateChildNodes(withName: "enemy") { node, _ in
      
      let enemy = node as! SKSpriteNode
      
      if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame) {
        
        hitEnemies.append(enemy)
      }
      
      for enemy in hitEnemies {
        
        self.zombieHit(enemy: enemy)
      }
    }
  }
  
  func moveTrain() {
    
    var trainCount = 0
    var targetPosition = zombie.position
    
    enumerateChildNodes(withName: "train") { node, stop in
     
      trainCount += 1
      
      if !node.hasActions() {
        
        let actionDuration = 0.3
        let offset = targetPosition - node.position
        let direction = offset.normalized()
        let amountToMovePerSec = direction * self.catMovePointsPerSec
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction =
          SKAction.moveBy(x: amountToMove.x,
                          y: amountToMove.y,
                          duration: actionDuration)
        node.run(moveAction)
      }
      
      targetPosition = node.position
      
      print("Zombie cats - \(trainCount)")
      self.catsLabel.text = "Cats: \(trainCount)"
      
      if trainCount >= 10 && !self.gameOver {
        
        print("You win!")
        backgroundMusicPlayer.stop()
        
        let gameOverScene = GameOverScene(size: self.size, won: true)
        gameOverScene.scaleMode = self.scaleMode
        
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(gameOverScene, transition: reveal)
      }
    }
  }
  
  func loseCats() {
    
    var loseCount = 0
    
    enumerateChildNodes(withName: "train") { node, stop in
      
      var randomSpot = node.position
      
      randomSpot.x += CGFloat.random(min: -100, max: 100)
      randomSpot.y += CGFloat.random(min: -100, max: 100)
      
      node.name = ""

      node.run (
      
        SKAction.sequence([
          
            SKAction.group([
              
                SKAction.rotate(byAngle: π * 4, duration: 1.0),
                SKAction.move(to: randomSpot, duration: 1.0),
                SKAction.scale(to: 0, duration: 1.0)
              ]),
            SKAction.removeFromParent()
          ]))
      
        loseCount += 1
      
      if loseCount >= 2 {
        
        stop[0] = true
      }
    }
  }
  
  func backgroundNode() -> SKSpriteNode {
    
    let backgroundNode = SKSpriteNode()
    backgroundNode.anchorPoint = CGPoint.zero
    backgroundNode.name = "background"
    
    let background1 = SKSpriteNode(imageNamed: "background1")
    background1.anchorPoint = CGPoint.zero
    background1.position = CGPoint(x: 0, y: 0)
    backgroundNode.addChild(background1)
    
    let background2 = SKSpriteNode(imageNamed: "background2")
    background2.anchorPoint = CGPoint.zero
    background2.position = CGPoint(x: background1.size.width, y: 0)
    backgroundNode.addChild(background2)
    
    backgroundNode.size =
      CGSize(width: background1.size.width + background2.size.width,
             height: background1.size.height)
    return backgroundNode
  }
  
  func moveCamera() {
    
    let backgroundVelocity =
      CGPoint(x: cameraMovePointsPerSec, y: 0)
    
    let amountToMove =
      backgroundVelocity * CGFloat(dt)
    
    cameraNode.position += amountToMove
    
    enumerateChildNodes(withName: "background") { node, _ in
      
      let background = node as! SKSpriteNode
      
      if background.position.x + background.size.width <
        self.cameraRect.origin.x {
        
        background.position =
          CGPoint(x: background.position.x + background.size.width * 2,
                  y: background.position.y)
      }
    }
  }
  
  var cameraRect: CGRect {
    
    let x = cameraNode.position.x - size.width/2 +
            (size.width - playableRect.width)/2
    
    let y = cameraNode.position.y - size.height/2 +
            (size.height - playableRect.height)/2
    
    return CGRect(
      x: x,
      y: y,
      width: playableRect.width,
      height: playableRect.height
    )
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
