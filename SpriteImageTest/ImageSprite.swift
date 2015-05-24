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
    private let scene:SKScene
    private var image:UIImage!
    var posotion:CGPoint
    var sprite:SKSpriteNode!
    private let originalSize:CGSize
    var targetSize:CGSize
    var scale:CGFloat {
        get {
            return self.targetSize.width/self.originalSize.width
        }
    }
    
    var nodePosition:CGPoint {
        get {
            return self.scene.convertPointFromView(self.posotion)
        }
    }
    init(targetWidth:CGFloat, size:CGSize, scene:SKScene!) {
        self.originalSize =  size
        self.targetSize = self.originalSize
        self.posotion = CGPointMake(0, 0)
        self.scene = scene
        self.sprite = nil
        self.image = nil
        self.setTargetSize(CGSizeMake(targetWidth, targetWidth/self.originalSize.width * self.originalSize.height))
    }
    init(imageData:UIImage!,targetWidth:CGFloat, scene:SKScene!) {
        self.image = imageData
        self.originalSize =  imageData.size
        self.targetSize = self.originalSize
        self.posotion = CGPointMake(0, 0)
        self.scene = scene
        let imageTexture = SKTexture(image: imageData)
        self.sprite = SKSpriteNode(texture: imageTexture)
        self.sprite.anchorPoint = CGPoint(x: 0, y: 1)
        self.setTargetSize(CGSizeMake(targetWidth, targetWidth/self.originalSize.width * self.originalSize.height))
    }
    func setTargetSize( targetSize:CGSize ) {
        self.targetSize = targetSize
    }
    func setPosition( position:CGPoint ) {
        self.posotion = position
    }
    func setImageData( imageData:UIImage ) {
        self.image = imageData
        let imageTexture = SKTexture(image: imageData)
        self.sprite = SKSpriteNode(texture: imageTexture)
        self.sprite.anchorPoint = CGPoint(x: 0, y: 1)
        sprite.xScale = self.scale
        sprite.yScale = self.scale
        let nodePos = self.nodePosition
        self.sprite.position = nodePos
    }
}