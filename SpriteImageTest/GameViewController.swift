//
//  GameViewController.swift
//  SpriteImageTest
//
//  Created by AizawaTakashi on 2015/05/23.
//  Copyright (c) 2015年 AizawaTakashi. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

protocol SpriteViewDelegate {
    func numOfSections()->Int
    func sectionTitleString()->String
    func numOfItemsInSection( section:Int )->Int
}

class GameViewController: UIViewController {

    var delegate:SpriteViewDelegate!
    
    var numOfSection:Int = 1
    
    @IBAction func pinchEvent(sender: AnyObject) {
        let pinchRecognizer:UIPinchGestureRecognizer = sender as! UIPinchGestureRecognizer
        let scale = pinchRecognizer.scale
        let skView = self.view as! SKView
        let myScene:GameScene = skView.scene as! GameScene
        myScene.changeScale(scale)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            numOfSection = self.delegate.numOfSections()
            
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
