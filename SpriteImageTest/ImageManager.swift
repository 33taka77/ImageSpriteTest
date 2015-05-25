//
//  ImageManager.swift
//  MyPhoto
//
//  Created by AizawaTakashi on 2015/05/17.
//  Copyright (c) 2015年 AizawaTakashi. All rights reserved.
//

import Foundation
import UIKit

class ImageManager:ImageBaseService {
    var sourse:ImageSourse = ImageSourse.Local
    init() {
        self.sourse = ImageSourse.Local
    }
    init( sourse:ImageSourse) {
        self.sourse = sourse
    }
    func setupData() {
    }
    func getSectionCount()->Int {
        return 0
    }
    func getSectionArray()->[String] {
        return []
    }
    func getImageCount(section:Int)->Int {
        return 0
    }
    func getImages(section:Int)->[Item] {
        return []
    }
    func getImageObjectIndexAt(index:NSIndexPath)->ImageObject? {
        return nil
    }
    func getSize() -> CGSize {
        return CGSizeMake(0, 0)
    }
}

class ImageObject:Item {
    func getThumbnail( callback: (UIImage)->Void ) {
    }
    func getImageWithSize(size:CGSize, callback: (UIImage)->Void ){
    }
    func getSize()->CGSize {
        return CGSizeMake(0, 0)
    }
}

enum ImageSourse {
    case Local
    case Flickr
    case GoogleDrive
    case DropBox
}

enum ImageSize {
    case Large
    case Middle
    case Small
}

protocol ImageBaseService {
    func setupData()
    func getSectionCount()->Int
    func getSectionArray()->[String]
    func getImageCount(section:Int)->Int
    func getImages(section:Int)->[Item]
    func getImageObjectIndexAt(index:NSIndexPath)->ImageObject?
    func getSize()->CGSize
}