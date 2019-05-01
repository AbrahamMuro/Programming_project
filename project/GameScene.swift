//
//  GameScene.swift
//  project
//
//  Created by Abraham Muro on 4/6/19.
//  Copyright © 2019 Abraham Muro. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory
{
    static let Puma: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Wall: UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var Ground = SKSpriteNode()
    var Puma = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var inicioJuego = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    let title = SKLabelNode()
    let developer = SKLabelNode()
    var died = Bool()
    var restartBTN = SKSpriteNode()
    

func restarScene ()
{
    self.removeAllChildren()
    self.removeAllActions()
    died = false
    inicioJuego = false
    score = 0
    createScene()
}
    
func createScene()
{
    self.physicsWorld.contactDelegate = self
        for i in 0..<2
        {
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x:CGFloat(i) * -400, y: -700)
        background.size = CGSize(width: 800, height: 2000)
        background.name = "fondo"
        self.addChild(background)
        }

    
    scoreLbl.position = CGPoint(x:20, y:500)
    scoreLbl.text = "\(score)"
    scoreLbl.fontName = "Prisma"
    scoreLbl.fontSize = 70
    scoreLbl.zPosition = 5
    self.addChild(scoreLbl)
    
    title.position = CGPoint(x: -20, y: 50)
    title.text = "GO Pumas"
    title.fontName = "The Brandy"
    title .fontSize = 100
    self.addChild(title)
    
    developer.position = CGPoint(x: -60, y: -100)
    developer.text = "Developer: Abraham Muro"
    developer.fontName = "The Brandy"
    developer .fontSize = 30
    self.addChild(developer)
    
    Puma = SKSpriteNode(imageNamed: "puma")
    Puma.position = CGPoint(x:-40, y: -10)
    
    Puma.physicsBody = SKPhysicsBody(circleOfRadius: Puma.frame.height/2)
    Puma.physicsBody?.categoryBitMask = PhysicsCategory.Puma
    Puma.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
    Puma.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
    Puma.physicsBody?.affectedByGravity = false
    Puma.physicsBody?.isDynamic = true
    
    Puma.zPosition = 2
    self.addChild(Puma)
}
    override func didMove(to view: SKView)
    {
        createScene()
    }
    
    func crearBoton()
    {
        restartBTN = SKSpriteNode(imageNamed: "retry")
        restartBTN.size = CGSize(width: 300, height: 100)
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        restartBTN.setScale(0.5)
        restartBTN.run(SKAction.scale(by: 2.0, duration: 0.5))
        self.addChild(restartBTN)
    }

    func didBegin(_ contact: SKPhysicsContact)
    {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Puma{
            
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        }
        else if firstBody.categoryBitMask == PhysicsCategory.Puma && secondBody.categoryBitMask == PhysicsCategory.Score {
            
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
            
        }
        else if firstBody.categoryBitMask == PhysicsCategory.Puma && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Puma
        {
            
            enumerateChildNodes(withName: "Fondo", using: ({
                node, error in()
                
                node.speed = 0
                
                self.removeAllActions()
            }))
            
            if died == false
            {
                died = true
                 crearBoton()
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if inicioJuego == false
        {
            inicioJuego = true
            Puma.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run {
                ()in
                (self.createWalls())
            }
            
            
            let delay = SKAction.wait(forDuration: 0.4)
            let SpawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: (-distance)*30, y: CGFloat.random(min: 5, max: 10), duration: TimeInterval(0.020 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Puma.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Puma.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 180))
            
        }else {
            if died == true
            {
                
            }
            else{
            Puma.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Puma.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 180))
            }
        }
        
        for touch in touches
        {
            let location = touch.location(in: self)
            if died == true{
                if restartBTN.contains(location){
                    restarScene()
                }
            }
        }
        
    }

    func createWalls()
    {
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        scoreNode.size = CGSize(width: 50 , height: 50)
        scoreNode.position = CGPoint(x: 2, y: 50)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Puma
        scoreNode.color = SKColor.blue
        
        wallPair = SKNode()
        wallPair.name = "Fondo"
        
        let topWall = SKSpriteNode(imageNamed: "wall1")
        let btmWall = SKSpriteNode(imageNamed: "wall")
        
        topWall.position = CGPoint(x: -2, y: 400)
        btmWall.position = CGPoint(x: -2, y: -400)
        
        topWall.setScale(1.0)
        btmWall.setScale(1.0)
        
        topWall.physicsBody  = SKPhysicsBody(rectangleOf: btmWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Puma
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Puma
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody  = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Puma
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Puma
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
    

        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let funcionAleatoria = CGFloat.random(min: 200, max: 500)
        wallPair.position.x = wallPair.position.x + funcionAleatoria
        
        wallPair.addChild(scoreNode)
        wallPair.run(moveAndRemove)
        self.addChild(wallPair)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
        if inicioJuego == true
        {
            if died == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    
                    let bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                        
                    }
                    
                }))
                
            }
        }
    }
        
}
