//
//  GameScene.swift
//  FallInDown
//
//  Created by Neo Chou on 2019/11/7.
//  Copyright © 2019 Neo Chou. All rights reserved.
//

import SpriteKit

enum PlayColors {
    static let colors = [UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1),
                         UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1),
                         UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1),
                         UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)]
}

enum SwitchState : Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch : SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex : Int?
    
    override func didMove(to view: SKView) {
        setUpPhysics()
        layoutScene()
     
    }
    
    func setUpPhysics () {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2)
        physicsWorld.contactDelegate = self
    }
    
  
    func layoutScene () {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1)
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3 , height: frame.size.width/3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height)
        
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCatgories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        addChild(colorSwitch)
        
        spawnBall()
    }
    
    func spawnBall () {
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 30, height: 30))
        ball.colorBlendFactor = 1
        ball.name = "Ball"
        ball.size = CGSize(width: 30, height: 30)
        ball.position = CGPoint(x: frame.midX, y: frame.maxY)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCatgories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCatgories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCatgories.none
        addChild(ball)
    }
    
    func turnWheel() {
        if let newState = SwitchState(rawValue: switchState.rawValue + 1) {
            switchState = newState
        }else{
            switchState = .red
        }
        colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.25))
    }
    
    func gameOver () {
        print("GameOver!")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        turnWheel()
    }
}


extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        currentColorIndex = 0
        if contactMask == PhysicsCatgories.ballCategory | PhysicsCatgories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    print("Correct!")
                    ball.run(SKAction.fadeOut(withDuration: 0.25), completion:  {
                        ball.removeFromParent()
                        self.spawnBall()
                    })
                } else {
                    gameOver()
                }
            }
        }
    }
    
}
