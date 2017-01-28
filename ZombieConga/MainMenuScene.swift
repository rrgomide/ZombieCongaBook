import Foundation
import SpriteKit

class MainMenuScene: SKScene {
  
  override func didMove(to view: SKView) {
    
    var background: SKSpriteNode
    background = SKSpriteNode.init(imageNamed: "MainMenu.png")
    background.position = centerPosition(size: self.size)
    self.addChild(background)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    //sceneTapped()
    let gameScene = GameScene(size: self.size)
    gameScene.scaleMode = self.scaleMode
    let reveal = SKTransition.doorway(withDuration: 1.5)
    self.view?.presentScene(gameScene, transition: reveal)
  }
}
