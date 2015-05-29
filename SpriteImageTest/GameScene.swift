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
    class SectionInfo {
        var titleNode:SKLabelNode
        var sectionSprite:SKSpriteNode
        var titlePosition:CGPoint
        var sectionPosition:CGPoint
        
        init( title:String, imageName:String ) {
            let imageTexture = SKTexture(imageNamed: imageName)
            sectionSprite = SKSpriteNode(texture: imageTexture)
            titleNode = SKLabelNode(text: title)
            titleNode.fontColor = UIColor.whiteColor()
            titleNode.fontSize = 12
            titlePosition = CGPointMake(0, 0)
            sectionPosition = CGPointMake(0, 0)
        }
    }
    
    let maxColume:Int = 6
    let scrollAccellParameter:CGFloat = 0.3
    let decleaseSpeedParam:CGFloat = 4
    
    let xOffset47Inchx1:CGFloat = 19
    let yOffset47InchCase1x1:CGFloat = 13
    let yOffset47InchCase2x1:CGFloat = 28

    let xOffset47Inchx2:CGFloat = 28
    let yOffset47InchCase1x2:CGFloat = 19
    let yOffset47InchCase2x2:CGFloat = 42
   
    let xOffset47Inchx3:CGFloat = 19
    let yOffset47InchCase1x3:CGFloat = 13
    let yOffset47InchCase2x3:CGFloat = 28

    let xOffset47Inchx4:CGFloat = 14
    let yOffset47InchCase1x4:CGFloat = 11
    let yOffset47InchCase2x4:CGFloat = 28

    let xOffset47Inchx5:CGFloat = 11
    let yOffset47InchCase1x5:CGFloat = 8
    let yOffset47InchCase2x5:CGFloat = 17

    let xOffset47Inchx6:CGFloat = 10
    let yOffset47InchCase1x6:CGFloat = 7
    let yOffset47InchCase2x6:CGFloat = 15

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
    var colume:Int = 5 {
        didSet{
            getOffset(false)
        }
    }
    let intervalSpace:CGFloat = 0.0
    let aroundSpace:CGFloat = 2.0
    let imageManager:ImageManager!
    var imageSpriteArray:[ImageSprite] = []
    var imagesForDraw:[ImageSprite] = []
    var xOffset:CGFloat = 19
    var yOffset:CGFloat = 13
    var touchObject:TouchEventInfo!
    var pinchCount:Int = 0
    var sectionTitles:[SectionInfo] = []
    
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
        getOffset(true)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        screenSize = CGSizeMake(self.view!.frame.width,self.view!.frame.height)
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        
        self.addChild(myLabel)
        //let currentHeight = buildImageInSection( 0, startYpos:0, initializeFlag:true )
        buildTotalImages(true)
        //self.buildImageSprite()
        self.prepareImageSpriteToDraw(0, endHeight: screenSize.height+500)
        getOffset(true)

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
        removeImageSprite(-200, endHeight: screenSize.height+200)
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
            if colume < 2 {
                colume = 2
            }
        }else{
            colume = colume + 1
            if colume > maxColume {
                colume = maxColume
            }
        }
       // crashImages()
        //let timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "timerFunc", userInfo: nil, repeats: false)
        //changeColume()
        //let currentHeight = buildImageInSection( 0, startYpos:0, initializeFlag:false )
        buildTotalImages(false)
        pinchCount = 0
    }
    
    // private functions
    func timerFunc() {
        //changeColume()
        buildTotalImages(false)
    }
    
    private func crashImages() {
        for imageSprite in imagesForDraw {
            if imageSprite.sprite != nil {
                imageSprite.sprite.physicsBody = SKPhysicsBody(rectangleOfSize: imageSprite.sprite.size)
                imageSprite.sprite.physicsBody?.applyForce(CGVectorMake(1.0, 1.0))
            }
        }
    }
    private func removeAllImageSprite() {
        var removeImage:[AnyObject] = []
        for var i = 0; i < imagesForDraw.count; i++ {
            let imageSprite = imageSpriteArray[i]
            if imageSprite.sprite != nil {
                removeImage.append(imageSprite.sprite)
                imageSprite.sprite = nil
                imagesForDraw.removeAtIndex(i)
            }
        }
        self.removeChildrenInArray(removeImage)
    }
    private func changeColume() {
        let spriteWidth = (screenSize.width - aroundSpace*2 - CGFloat(colume-1)*intervalSpace + xOffset*CGFloat(colume))  / CGFloat(colume)
        for var i = 0; i < imageSpriteArray.count; i++ {
            let imageSprite:ImageSprite = imageSpriteArray[i]
            if imageSprite.sprite != nil {
                imageSprite.sprite.physicsBody = nil
            }
            let pos:CGPoint
            println("spriteWidth = \(spriteWidth)")
            let x = (spriteWidth-xOffset)*CGFloat(i % self.colume) + self.aroundSpace + self.intervalSpace*CGFloat(i % self.colume)
            println("x= \(x)")
            println("xOffset= \(xOffset)")
            let num = i  % self.colume
            println("i % self.colume= \(num)")
            println("self.aroundSpace= \(self.aroundSpace)")
            println("self.intervalSpace= \(self.intervalSpace)")
            if i < self.colume {
                let y = 0+self.aroundSpace
                pos = CGPointMake(x, y)
            }else{
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                if prevSprite.originalSize.height > prevSprite.originalSize.width {
                    getOffset(true)
                }else{
                    getOffset(false)
                }
                let y = prevSprite.posotion.y + prevSprite.targetSize.height + self.intervalSpace - yOffset
                pos = CGPointMake(x, y)
            }
            imageSprite.setTargetSize(CGSizeMake(spriteWidth, spriteWidth*imageSprite.originalSize.height/imageSprite.originalSize.width))
            imageSprite.setPosition(pos)
            imageSprite.moveWithAction()
            //removeImageSprite(-200, endHeight: screenSize.height+500)
        }
    }
    private func getOffset( isVirtical:Bool ) {
        switch self.colume {
        case 1:
            xOffset = xOffset47Inchx1
            if isVirtical {
                yOffset = yOffset47InchCase1x2
            }else{
                yOffset = yOffset47InchCase1x1
            }
        case 2:
            xOffset = xOffset47Inchx2
            if isVirtical {
                yOffset = yOffset47InchCase2x2
            }else{
                yOffset = yOffset47InchCase1x2
            }
        case 3:
            xOffset = xOffset47Inchx3
            if isVirtical {
                yOffset = yOffset47InchCase2x3
            }else{
                yOffset = yOffset47InchCase1x3
            }
       case 4:
            xOffset = xOffset47Inchx4
            if isVirtical {
                yOffset = yOffset47InchCase2x4
            }else{
                yOffset = yOffset47InchCase1x4
            }
        case 5:
            xOffset = xOffset47Inchx5
            if isVirtical {
                yOffset = yOffset47InchCase2x5
            }else{
                yOffset = yOffset47InchCase1x5
            }
        case 6:
            xOffset = xOffset47Inchx6
            if isVirtical {
                yOffset = yOffset47InchCase2x6
            }else{
                yOffset = yOffset47InchCase1x6
            }
       default:
            println("error")
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
    private func buildTotalImages( initializeFlag:Bool ) {
        if initializeFlag == true {
            let sections = imageManager.getSectionArray()
            for sectionTitleString in sections {
                let sectionSprite = SectionInfo(title: sectionTitleString, imageName: "SectionBar.png")
                self.addChild(sectionSprite.sectionSprite)
                self.addChild(sectionSprite.titleNode)
                sectionTitles.append(sectionSprite)
            }
        }else{
            
        }
        var sectionStartPosition:CGFloat = 0
        for (index,sectionSprite) in enumerate(sectionTitles) {
            sectionSprite.sectionSprite.size.width = self.view!.frame.width
            sectionSprite.sectionSprite.size.height = 30
            sectionSprite.sectionSprite.anchorPoint =  CGPoint(x: 0, y: 1)
            let sectionPosition = CGPointMake(0, sectionStartPosition)
            sectionSprite.sectionPosition = sectionPosition
            sectionSprite.sectionSprite.position = self.convertPointFromView(sectionPosition)
            let position = CGPointMake(50, sectionStartPosition+sectionSprite.sectionSprite.size.height/2)
            sectionSprite.titlePosition = position
            sectionSprite.titleNode.position = self.convertPointFromView(position)
            sectionStartPosition += sectionSprite.sectionSprite.size.height
            sectionStartPosition = buildImageInSection(index, startYpos:sectionStartPosition, initializeFlag:initializeFlag)
        }
    }
    private func buildImageInSection( section:Int, startYpos:CGFloat, initializeFlag:Bool )->CGFloat {
        let numOfImage = imageManager.getImageCount(section)
        let spriteWidth = (screenSize.width - aroundSpace*2 - CGFloat(colume-1)*intervalSpace + xOffset*CGFloat(colume))  / CGFloat(colume)
        var totalHeight:CGFloat = 0
        for var i = 0; i < numOfImage; i++ {
            let imageSprite:ImageSprite
            if initializeFlag == true {
                let index = NSIndexPath(forRow: i, inSection: section)
                let imageObject:ImageObject = imageManager.getImageObjectIndexAt(index)!
                let sizeOfOriginal = imageObject.getSize()
                let size = CGSizeMake(spriteWidth, spriteWidth/sizeOfOriginal.width*sizeOfOriginal.height)
                imageSprite = ImageSprite(index: index, targetWidth:spriteWidth, size:size, scene:self)
            }else{
                imageSprite = imageSpriteArray[i]
                if imageSprite.sprite != nil {
                    imageSprite.sprite.physicsBody = nil
                }
            }
            let pos:CGPoint
            println("spriteWidth = \(spriteWidth)")
            let x = (spriteWidth-xOffset)*CGFloat(i % self.colume) + self.aroundSpace + self.intervalSpace*CGFloat(i % self.colume)
            println("x= \(x)")
            println("xOffset= \(xOffset)")
            let num = i  % self.colume
            println("i % self.colume= \(num)")
            println("self.aroundSpace= \(self.aroundSpace)")
            println("self.intervalSpace= \(self.intervalSpace)")
            if i < self.colume {
                let y = 0+self.aroundSpace + startYpos
                pos = CGPointMake(x, y)
            }else{
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                if prevSprite.originalSize.height > prevSprite.originalSize.width {
                    getOffset(true)
                }else{
                    getOffset(false)
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
        return totalHeight
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
            println("spriteWidth = \(spriteWidth)")
            let x = (spriteWidth-xOffset)*CGFloat(i % self.colume) + self.aroundSpace + self.intervalSpace*CGFloat(i % self.colume)
            println("x= \(x)")
            println("xOffset= \(xOffset)")
            let num = i  % self.colume
            println("i % self.colume= \(num)")
            println("self.aroundSpace= \(self.aroundSpace)")
            println("self.intervalSpace= \(self.intervalSpace)")
            if i < self.colume {
                let y = 0+self.aroundSpace
                pos = CGPointMake(x, y)
            }else{
                let prevSprite:ImageSprite = self.imageSpriteArray[i-self.colume]
                if prevSprite.originalSize.height > prevSprite.originalSize.width {
                    getOffset(true)
                }else{
                    getOffset(false)
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
                let index = self.imageSpriteArray[i].indexPath
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
        let count = imagesForDraw.count
        for var index = 0; index < imagesForDraw.count; index++  {
            let imageSprite = imagesForDraw[index]
            let currentHeight = imageSprite.posotion.y + imageSprite.targetSize.height
            if currentHeight > endHeight || currentHeight < startHeight {
                if imageSprite.sprite != nil {
                    let (isExist:Bool,index:Int) = self.containObject(self.children, object: imageSprite.sprite)
                    if isExist == true {
                        if index < imagesForDraw.count {
                            removeImage.append(imageSprite.sprite)
                            imageSprite.sprite = nil
                            imagesForDraw.removeAtIndex(index)
                        }else{
                            //println("error")
                        }
                    }
                }
            }
        }
        self.removeChildrenInArray(removeImage)
    }
    
    private func scrollImageSprite( distance:CGFloat ) {
        for section in sectionTitles {
            let sectionPos = CGPointMake(section.sectionPosition.x, section.sectionPosition.y+distance)
            section.sectionSprite.position = convertPointFromView(sectionPos)
            let titlePos = CGPointMake(section.titlePosition.x, section.titlePosition.y+distance)
            section.titleNode.position = convertPointFromView(titlePos)
        }
        for imageSprite in imageSpriteArray{
            imageSprite.posotion = CGPointMake(imageSprite.posotion.x, imageSprite.posotion.y+distance)
            imageSprite.move()
        }
        removeImageSprite(-200, endHeight: screenSize.height+200)
        //prepareImageSpriteToDraw(-200, endHeight: screenSize.height+200)
        
    }
}
