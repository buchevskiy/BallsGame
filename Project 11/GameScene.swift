//
//  GameScene.swift
//  Project 11
//
//  Created by Андрей Бучевский on 26.12.2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isGameEnded: Bool = false {
        didSet {
            if isGameEnded {
                removeAllChildren()
                startNewGame()
            }
        }
    }
    
    var ballsLabel: SKLabelNode!
    var ballsCount = 0 {
        didSet {
            ballsLabel.text = "Balls: \(ballsCount)"
            if  ballsCount == 0 {
                isGameEnded = true
            }
        }
    }
    
    var slotsCount = 20 {
        didSet {
            if slotsCount == 0 {
                startNewRound()
            }
        }
    }
    var balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
  

    override func didMove(to view: SKView) {

        startNewGame()
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let ball = SKSpriteNode(imageNamed: balls[Int.random(in: balls.indices)])
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        
        ball.position = CGPoint(x: location.x, y: 700)
        ball.name = "ball"
        addChild(ball)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            ballsCount += 1
            destroy(ball)
        } else if object.name == "bad" {
            ballsCount -= 1
            destroy(ball)
        } else if object.name == "box" {
            slotsCount -= 1
            destroy(object)
        }
    }
    func destroy(_ ball: SKNode) {
        if ball.name == "ball" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = ball.position
                addChild(fireParticles)
            }
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}

        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
    
    func startNewRound() {
        ballsCount += 5
        slotsCount = 20
        for _ in 1...20 {
            let size = CGSize(width: Int.random(in: 16...128), height: 16)
            let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
            box.zRotation = CGFloat.random(in: 0...3)
            box.position = CGPoint(x: Int.random(in: 50...950), y: Int.random(in: 200...500))
            box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
            box.physicsBody?.isDynamic = false
            box.name = "box"
            addChild(box)
        }
    }
    
    func startNewGame() {
        isGameEnded = false
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls: 5"
        ballsLabel.position = CGPoint(x: 80, y: 700)
        addChild(ballsLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        startNewRound()
    }
}
