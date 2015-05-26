//
//  ImageSprite.swift
//  SpriteImageTest
//
//  Created by AizawaTakashi on 2015/05/23.
//  Copyright (c) 2015年 AizawaTakashi. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class ImageSprite {
    private let scene:GameScene
    private var image:UIImage!
    var posotion:CGPoint
    var sprite:SKSpriteNode!
    var originalSize:CGSize
    var targetSize:CGSize
    var indexPath:NSIndexPath!
    var scale:CGFloat {
        get {
            return (self.targetSize.width)/self.originalSize.width
        }
    }
    
    var nodePosition:CGPoint {
        get {
            return self.scene.convertPointFromView(self.posotion)
        }
    }
    init(index:NSIndexPath, targetWidth:CGFloat, size:CGSize, scene:GameScene!) {
        self.originalSize =  size
        self.targetSize = self.originalSize
        self.posotion = CGPointMake(0, 0)
        self.scene = scene
        self.image = nil
        self.indexPath = index
        self.setTargetSize(CGSizeMake(targetWidth, targetWidth/self.originalSize.width * self.originalSize.height))
    }
    init(index:NSIndexPath, imageData:UIImage!,targetWidth:CGFloat, scene:GameScene!) {
        self.image = imageData
        self.originalSize =  imageData.size
        self.targetSize = self.originalSize
        self.posotion = CGPointMake(0, 0)
        self.scene = scene
        self.indexPath = index
        let imageTexture = SKTexture(image: imageData)
        self.sprite = SKSpriteNode(texture: imageTexture)
        self.sprite.anchorPoint = CGPoint(x: 0, y: 1)
        self.setTargetSize(CGSizeMake(targetWidth+self.scene.xOffset, (targetWidth+self.scene.xOffset)/self.originalSize.width * self.originalSize.height))
    }
    func setTargetSize( targetSize:CGSize ) {
        self.targetSize = targetSize
    }
    func setPosition( position:CGPoint ) {
        self.posotion = position
    }
    func setImageData( imageData:UIImage ) {
        let size:CGSize = imageData.size
        self.originalSize = size
        self.image = imageData
        let imageTexture = SKTexture(image: imageData)
        self.sprite = SKSpriteNode(texture: imageTexture)
        self.sprite.anchorPoint = CGPoint(x: 0, y: 1)
        sprite.xScale = self.scale
        sprite.yScale = self.scale
        let nodePos = self.nodePosition
        self.sprite.position = nodePos
    }
    func move() {
        if self.sprite != nil {
            self.sprite.position = self.nodePosition
        }else{
            let imageManager = AssetManager.sharedInstance
            let imgObj:ImageObject = imageManager.getImageObjectIndexAt(self.indexPath)!
            imgObj.getImageWithSize(self.originalSize, callback: { (image) -> Void in
                self.setImageData(image)
                self.scene.addChild(self.sprite)
            })
        }
    }
    func moveWithAction() {
        if self.sprite != nil {
            let moveAction:SKAction = SKAction.moveTo(self.nodePosition, duration: 0.2)
            let prevSize:CGSize = self.sprite.size
            let newSize:CGSize = self.targetSize
            let scale:CGFloat = self.targetSize.width/self.sprite.size.width
            let scaleAction:SKAction = SKAction.scaleTo(scale, duration: 0.2)
            //let scaleXAction:SKAction = SKAction.scaleXTo(scale, duration: 0.2)
            //let scaleYAction:SKAction = SKAction.scaleYTo(scale, duration: 0.2)
            //let actionArray = [moveAction, scaleXAction,scaleYAction]
            let actionArray = [moveAction, scaleAction]
            let action = SKAction.sequence(actionArray)
            self.sprite.runAction(action)
        }
    }
}