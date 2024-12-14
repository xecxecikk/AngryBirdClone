//
//  GameScene.swift
//  AngryBirdClone
//
//  Created by XECE on 14.12.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird: SKSpriteNode!
    var box1: SKSpriteNode!
    var box2: SKSpriteNode!
    var box3: SKSpriteNode!
    var box4: SKSpriteNode!
    var box5: SKSpriteNode!
     
    var gameStarted = false
    var originalPosition: CGPoint?
    
    var score = 0
    var scoreLabel: SKLabelNode!
    
    enum Collidertype: UInt32 {
        case Bird = 1
        case Box = 2
    }

    override func didMove(to view: SKView) {
        
        // Genel Fizik Kuralları için
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.scene?.scaleMode = .aspectFit
        self.physicsWorld.contactDelegate = self
        
        // Kuş için
        bird = childNode(withName: "bird") as? SKSpriteNode
        if bird == nil {
            print("Bird node is nil!")
            return
        }
        
        let birdTexture = SKTexture(imageNamed: "bird")
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 13)
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.mass = 0.15
        originalPosition = bird.position
        
        bird.physicsBody?.contactTestBitMask = UInt32(Collidertype.Bird.rawValue)
        bird.physicsBody?.categoryBitMask = UInt32(Collidertype.Bird.rawValue)
        bird.physicsBody?.collisionBitMask = UInt32(Collidertype.Box.rawValue)
        
        // Kutular için
        let boxTexture = SKTexture(imageNamed: "brick")
        let size = CGSize(width: boxTexture.size().width / 6, height: boxTexture.size().height / 6)
        
        box1 = childNode(withName: "box1") as? SKSpriteNode
        box2 = childNode(withName: "box2") as? SKSpriteNode
        box3 = childNode(withName: "box3") as? SKSpriteNode
        box4 = childNode(withName: "box4") as? SKSpriteNode
        box5 = childNode(withName: "box5") as? SKSpriteNode
        
        let boxes = [box1, box2, box3, box4, box5]
        
        for box in boxes {
            if let box = box {
                box.physicsBody = SKPhysicsBody(rectangleOf: size)
                box.physicsBody?.isDynamic = false // Başlangıçta dinamik değil
                box.physicsBody?.affectedByGravity = false // Yerçekimi etkisi yok
                box.physicsBody?.allowsRotation = true
                box.physicsBody?.mass = 0.4
                box.physicsBody?.collisionBitMask = UInt32(Collidertype.Bird.rawValue)
            }
        }
        
        // Skor etiketini ayarla
        scoreLabel = SKLabelNode()
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontColor = .orange
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height / 4)
        scoreLabel.zPosition = 2
        self.addChild(scoreLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.collisionBitMask == Collidertype.Bird.rawValue ||  contact.bodyB.collisionBitMask == Collidertype.Bird.rawValue {
            score += 1
            scoreLabel.text = String(score)
            
            let boxes = [box1, box2, box3, box4, box5]
            for box in boxes {
                if let box = box {
                    box.physicsBody?.affectedByGravity = true // Yerçekimini aktifleştir
                    box.physicsBody?.isDynamic = true // Dinamik hale getir
                    let randomImpulseX = CGFloat.random(in: -50...50)
                    let randomImpulseY = CGFloat.random(in: 50...150)
                    let randomImpulse = CGVector(dx: randomImpulseX, dy: randomImpulseY)
                    box.physicsBody?.applyImpulse(randomImpulse)
                }
            }
        }
    }

    func touchDown(atPoint pos : CGPoint) {
        // Başlangıçta dokunmaya gerek yok, kuşu hareket ettirmek için touchUp kullanılır.
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // Başlangıçta dokunmaya gerek yok.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                let touchNodes = nodes(at: touchLocation)
                if !touchNodes.isEmpty {
                    for node in touchNodes {
                        if let sprite = node as? SKSpriteNode, sprite == bird {
                            bird.position = touchLocation
                        }
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                let touchNodes = nodes(at: touchLocation)
                if !touchNodes.isEmpty {
                    for node in touchNodes {
                        if let sprite = node as? SKSpriteNode, sprite == bird {
                            bird.position = touchLocation
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                let touchNodes = nodes(at: touchLocation)
                if !touchNodes.isEmpty {
                    for node in touchNodes {
                        if let sprite = node as? SKSpriteNode, sprite == bird {
                            let dx = -(touchLocation.x - originalPosition!.x)
                            let dy = -(touchLocation.y - originalPosition!.y)
                            let impulse = CGVector(dx: dx, dy: dy)
                            bird.physicsBody?.applyImpulse(impulse)
                            bird.physicsBody?.affectedByGravity = true
                            gameStarted = true
                        }
                    }
                }
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Cancel touch logic if needed
    }

    override func update(_ currentTime: TimeInterval) {
        if let birdPhysicsBody = bird.physicsBody {
            if birdPhysicsBody.velocity.dx <= 0.1 && birdPhysicsBody.velocity.dy <= 0.1 && birdPhysicsBody.angularVelocity <= 0.1 && gameStarted {
                bird.physicsBody?.affectedByGravity = false
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.angularVelocity = 0
                bird.zPosition = 1
                bird.position = originalPosition!
                bird.zRotation = 0
                gameStarted = false
            }
        }
    }
}
