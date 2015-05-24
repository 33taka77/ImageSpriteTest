//
//  GameScene.swift
//  SpriteImageTest
//
//  Created by AizawaTakashi on 2015/05/23.
//  Copyright (c) 2015年 AizawaTakashi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var screenSize:CGSize
    var colume:Int = 3
    let intervalSpace:CGFloat = 2.0
    let aroundSpace:CGFloat = 2.0
    let imageManager:ImageManager!
    var imageSpriteArray:[ImageSprite] = []
    var imagesForDraw:[ImageSprite] = []
    
    override init() {
        screenSize = CGSizeMake(0, 0)
        imageManager = AssetManager.sharedInstance
        super.init()
        imageManager.setupData()
    }

    required init?(coder aDecoder: NSCoder) {
        screenSize = CGSizeMake(0, 0)
        imageManager = AssetManager.sharedInstance
        super.init(coder: aDecoder)
        imageManager.setupData()
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        screenSize = CGSizeMake(self.view!.frame.width,self.view!.frame.height)
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
        self.buildImageSprite()
        self.prepareImageSpriteToDraw(0, endHeight: screenSize.height)

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        println("C")
        
        for imageSprite in imagesForDraw {
            let node = imageSprite.sprite
            if !self.containObject(self.children, object: node) {
            //if !contains(self.children as! [SKSpriteNode], node) {
                self.addChild(node)
            }
        }
    }
    
    private func containObject ( array:[AnyObject], object:AnyObject )->Bool {
        for obj in array {
            if obj === object {
                return true
            }
        }
        return false
    }
// private functions 
    private func buildImageSprite() {
        let numOfImage = imageManager.getImageCount(0)
        let spriteWidth = (screenSize.width - aroundSpace*2 - CGFloat(colume-1)*intervalSpace) / CGFloat(colume)
        var totalHeight:CGFloat = 0
        for var i = 0; i < numOfImage; i++ {
            let index = NSIndexPath(forRow: i, inSection: 0)
            let imageObject:ImageObject = imageManager.getImageObjectIndexAt(index)!
            let sizeOfOriginal = imageObject.getSize()
            let size = CGSizeMake(spriteWidth, spriteWidth/sizeOfOriginal.width*sizeOfOriginal.height)
            let imageSprite:ImageSprite = ImageSprite(targetWidth:spriteWidth, size:size, scene:self)
            let pos:CGPoint
            if i < self.colume {
                let x = spriteWidth*CGFloat(i) + self.aroundSpace + self.intervalSpace*CGFloat(i)
                let y = 0+self.aroundSpace
                pos = CGPointMake(x, y)
            }else if i % self.colume != 0{
                let x = spriteWidth*CGFloat(i % self.colume) + self.aroundSpace + self.intervalSpace*CGFloat(i)
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                let y = prevSprite.posotion.y + prevSprite.targetSize.height + self.intervalSpace
                pos = CGPointMake(x, y)
            }else{
                let x = self.aroundSpace
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                let y = prevSprite.posotion.y + prevSprite.targetSize.height + self.intervalSpace
                pos = CGPointMake(x, y)
            }
            if totalHeight < pos.y + imageSprite.targetSize.height {
                totalHeight = pos.y + imageSprite.targetSize.height
            }
            imageSprite.setPosition(pos)
            self.imageSpriteArray.append(imageSprite)

            
        }
    }
    private func prepareImageSpriteToDraw( startHeight:CGFloat, endHeight:CGFloat ) {
        //var returnImageSprite:[ImageSprite] = []
        var totalHeight:CGFloat = 0
        for var i = 0; i < self.imageSpriteArray.count; i++ {
            let currentHeight = self.imageSpriteArray[i].posotion.y + self.imageSpriteArray[i].targetSize.height
            if self.imageSpriteArray[i].posotion.y > startHeight && currentHeight < endHeight {
                let index = NSIndexPath(forRow: i, inSection: 0)
                let imageObject:ImageObject = imageManager.getImageObjectIndexAt(index)!
                imageObject.getThumbnail({ (image) -> Void in
                    let imageSprite = self.imageSpriteArray[index.row]
                    imageSprite.setImageData(image)
                    self.imagesForDraw.append(imageSprite)
                })
            }
        }
    }
}
