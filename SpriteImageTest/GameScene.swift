//
//  GameScene.swift
//  SpriteImageTest
//
//  Created by AizawaTakashi on 2015/05/23.
//  Copyright (c) 2015年 AizawaTakashi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    enum TouchKind {
        case none
        case flicScrollDown
        case filckScrollUp
        case pinchout
        case pinchin
        case tapSingle
        case tapDouble
    }
    class TouchEventInfo {
        var prevPoint:CGPoint = CGPointMake(0, 0)
        var prevTime:CFTimeInterval = 0
        var kindOfTouch:TouchKind = TouchKind.none
        var speed:CGFloat = 0
        var intervalTime:CFTimeInterval!
    }
    
    let maxColume:Int = 6
    let scrollAccellParameter:CGFloat = 0.3
    let decleaseSpeedParam:CGFloat = 4
    
    let xOffset47Inch:CGFloat = 19
    let yOffset47InchCase1:CGFloat = 13
    let yOffset47InchCase2:CGFloat = 28
    let xOffset55Inch:CGFloat = 19
    let yOffset55InchCase1:CGFloat = 13
    let yOffset55InchCase2:CGFloat = 20
    let xOffset4Inch:CGFloat = 19
    let yOffset4InchCase1:CGFloat = 13
    let yOffset4InchCase2:CGFloat = 20
    let xOffset35Inch:CGFloat = 19
    let yOffset35InchCase1:CGFloat = 13
    let yOffset35InchCase2:CGFloat = 20
    
    var screenSize:CGSize
    var colume:Int = 4
    let intervalSpace:CGFloat = 0.0
    let aroundSpace:CGFloat = 2.0
    let imageManager:ImageManager!
    var imageSpriteArray:[ImageSprite] = []
    var imagesForDraw:[ImageSprite] = []
    var xOffset:CGFloat = 19
    var yOffset:CGFloat = 13
    var touchObject:TouchEventInfo!
    var pinchCount:Int = 0
    
    override init() {
        screenSize = CGSizeMake(0, 0)
        imageManager = AssetManager.sharedInstance
        super.init()
        imageManager.setupData()
        touchObject = TouchEventInfo()
    }

    required init?(coder aDecoder: NSCoder) {
        screenSize = CGSizeMake(0, 0)
        imageManager = AssetManager.sharedInstance
        super.init(coder: aDecoder)
        imageManager.setupData()
        touchObject = TouchEventInfo()
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
        self.prepareImageSpriteToDraw(0, endHeight: screenSize.height+200)

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            touchObject.prevPoint = location
            touchObject.prevTime = touch.timestamp
        }
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            let distance:CGFloat = location.y - touchObject.prevPoint.y
            let time = touch.timestamp - touchObject.prevTime
            let speed = distance / CGFloat(time)
            touchObject.speed = abs(speed)
            if location.y > touchObject.prevPoint.y {
                touchObject.kindOfTouch = TouchKind.flicScrollDown
            }else{
                touchObject.kindOfTouch = TouchKind.filckScrollUp
            }
            touchObject.intervalTime = touch.timestamp
        }
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            if touch.tapCount == 1 {
                
                let distance = touchObject.prevPoint.y - location.y
                scrollImageSprite(distance)
            }
        }
    }
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //println("C")
        switch touchObject.kindOfTouch {
        case .flicScrollDown:
            println("")
            let distance = touchObject.speed * scrollAccellParameter
            scrollImageSprite(-distance)
            touchObject.speed -= CGFloat(currentTime - touchObject.intervalTime) * decleaseSpeedParam
            if touchObject.speed < 0 {
                touchObject.speed = 0
                touchObject.kindOfTouch = TouchKind.none
            }
        case .filckScrollUp:
            println("")
            let distance = touchObject.speed * scrollAccellParameter
            scrollImageSprite(distance)
            touchObject.speed -= CGFloat(currentTime - touchObject.intervalTime) * decleaseSpeedParam
            if touchObject.speed < 0 {
                touchObject.speed = 0
                touchObject.kindOfTouch = TouchKind.none
            }
        default:
            println("")
        }
        for imageSprite in imagesForDraw {
            let node = imageSprite.sprite
            if node != nil {
                let (isExist:Bool,index:Int) = self.containObject(self.children, object: node)
                if !isExist {
                //if !contains(self.children as! [SKSpriteNode], node) {
                    self.addChild(node)
                }
            }
        }
    }
    
    func changeScale( scale:CGFloat ) {
        pinchCount++
        if pinchCount < 10 {
            return
        }
        if scale > 1.0 {
            colume = colume - 1
            if colume < 1 {
                colume = 1
            }
        }else{
            colume = colume + 1
            if colume > maxColume {
                colume = maxColume
            }
        }
        changeColume()
        pinchCount = 0
    }
    
    // private functions
    private func changeColume() {
        let spriteWidth = (screenSize.width - aroundSpace*2 - CGFloat(colume-1)*intervalSpace + xOffset*CGFloat(colume))  / CGFloat(colume)
        for var i = 0; i < imageSpriteArray.count; i++ {
            let imageSprite:ImageSprite = imageSpriteArray[i]
            let pos:CGPoint
            if i < self.colume {
                let x = (spriteWidth-xOffset)*CGFloat(i) + self.aroundSpace + self.intervalSpace*CGFloat(i)
                let y = 0+self.aroundSpace
                pos = CGPointMake(x, y)
            }else if i % self.colume != 0 {
                let x = (spriteWidth-xOffset)*CGFloat(i % self.colume) + self.aroundSpace + self.intervalSpace*CGFloat(i % self.colume)
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                if prevSprite.originalSize.height > prevSprite.originalSize.width {
                    yOffset = yOffset47InchCase2
                }else{
                    yOffset = yOffset47InchCase1
                }
                let y = prevSprite.posotion.y + prevSprite.targetSize.height + self.intervalSpace - yOffset
                pos = CGPointMake(x, y)
            }else{
                let x = self.aroundSpace
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                if prevSprite.originalSize.height > prevSprite.originalSize.width {
                    yOffset = yOffset47InchCase2
                }else{
                    yOffset = yOffset47InchCase1
                }
                let y = prevSprite.posotion.y + prevSprite.targetSize.height + self.intervalSpace - yOffset
                pos = CGPointMake(x, y)
            }
            imageSprite.setTargetSize(CGSizeMake(spriteWidth, spriteWidth*imageSprite.originalSize.height/imageSprite.originalSize.width))
            imageSprite.setPosition(pos)
            imageSprite.moveWithAction()
        }
    }
    
    
    private func containObject ( array:[AnyObject], object:AnyObject )->(Bool,Int) {
        for (index, obj) in enumerate(array) {
            if obj === object {
                return (true,index)
            }
        }
        return (false,-1)
    }
    private func buildImageSprite() {
        let numOfImage = imageManager.getImageCount(0)
        let spriteWidth = (screenSize.width - aroundSpace*2 - CGFloat(colume-1)*intervalSpace + xOffset*CGFloat(colume))  / CGFloat(colume)
        var totalHeight:CGFloat = 0
        for var i = 0; i < numOfImage; i++ {
            let index = NSIndexPath(forRow: i, inSection: 0)
            let imageObject:ImageObject = imageManager.getImageObjectIndexAt(index)!
            let sizeOfOriginal = imageObject.getSize()
            let size = CGSizeMake(spriteWidth, spriteWidth/sizeOfOriginal.width*sizeOfOriginal.height)
            let imageSprite:ImageSprite = ImageSprite(index: index, targetWidth:spriteWidth, size:size, scene:self)
            let pos:CGPoint
            if i < self.colume {
                let x = (spriteWidth-xOffset)*CGFloat(i) + self.aroundSpace + self.intervalSpace*CGFloat(i)
                let y = 0+self.aroundSpace
                pos = CGPointMake(x, y)
            }else if i % self.colume != 0 {
                let x = (spriteWidth-xOffset)*CGFloat(i % self.colume) + self.aroundSpace + self.intervalSpace*CGFloat(i % self.colume)
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                if prevSprite.originalSize.height > prevSprite.originalSize.width {
                    yOffset = yOffset47InchCase2
                }else{
                    yOffset = yOffset47InchCase1
                }
                let y = prevSprite.posotion.y + prevSprite.targetSize.height + self.intervalSpace - yOffset
                pos = CGPointMake(x, y)
            }else{
                let x = self.aroundSpace
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                if prevSprite.originalSize.height > prevSprite.originalSize.width {
                    yOffset = yOffset47InchCase2
                }else{
                    yOffset = yOffset47InchCase1
                }
                let y = prevSprite.posotion.y + prevSprite.targetSize.height + self.intervalSpace - yOffset
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
                imageObject.getImageWithSize(self.imageSpriteArray[index.row].originalSize, callback: { (image) -> Void in
                    let imageSprite = self.imageSpriteArray[index.row]
                    imageSprite.setImageData(image)
                    self.imagesForDraw.append(imageSprite)
                })
            }
        }
    }
    private func removeImageSprite( startHeight:CGFloat, endHeight:CGFloat ) {
        var removeImage:[AnyObject] = []
        for var index = 0; index < imagesForDraw.count; index++  {
            let imageSprite = imagesForDraw[index]
            let currentHeight = imageSprite.posotion.y + imageSprite.targetSize.height
            if currentHeight > endHeight || currentHeight < startHeight {
                if imageSprite.sprite != nil {
                    let (isExist:Bool,index:Int) = self.containObject(self.children, object: imageSprite.sprite)
                    if isExist == true {
                        removeImage.append(imageSprite.sprite)
                        imageSprite.sprite = nil
                        if index < imagesForDraw.count {
                            imagesForDraw.removeAtIndex(index)
                        }
                    }
                }
            }
        }
        self.removeChildrenInArray(removeImage)
    }
    private func scrollImageSprite( distance:CGFloat ) {
        for imageSprite in imageSpriteArray{
            imageSprite.posotion = CGPointMake(imageSprite.posotion.x, imageSprite.posotion.y+distance)
            imageSprite.move()
        }
        removeImageSprite(-200, endHeight: screenSize.height+200)
        //prepareImageSpriteToDraw(-200, endHeight: screenSize.height+200)
        
    }
}
