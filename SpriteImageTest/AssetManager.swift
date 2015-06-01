//
//  AssetManager.swift
//  MyPhoto
//
//  Created by AizawaTakashi on 2015/05/16.
//  Copyright (c) 2015年 AizawaTakashi. All rights reserved.
//

import Foundation
import Photos


class AssetManager:ImageManager {
    static private var initialize = false
    private var sectionLevel:SectionLevel = SectionLevel.Middle
    private var itemsBySection:[SectionInfo] = []
    private var list:AssetList!
    //static let sharedInstance = AssetManager()
    class var sharedInstance:AssetManager {
        struct Static{
            static let instance:AssetManager = AssetManager()
        }
        return Static.instance
    }

    var sectionCount:Int {
        get{
            var count:Int
            switch sectionLevel {
            case .Large:
                count = 1
            case .Middle:
                count = self.list.collection.count
            case .Small:
                count = 0
                for collection in self.list.collection {
                    for assets in (collection as! AssetList).collection{
                        count++
                    }
                }
            default:
                println("error")
            }
            return count
        }
    }
    
    override init() {
        super.init(sourse:ImageSourse.Local)
        list = AssetList(collection: nil)
        //fetchAssetInfo()
    }
    
    // -- ImageManager class override --
    override func setupData() {
        fetchAssetInfo()
        getSections(true)
    }
    override func getSectionCount()->Int {
        return self.sectionCount
    }
    override func getSectionArray()->[String] {
        let sections:[String]
        if AssetManager.initialize == false {
            AssetManager.initialize = true
            sections = getSections(true)
        }else{
            sections = getSections(false)
        }
        return sections
    }
    override func getImageCount(section:Int)->Int {
        let sectionInfo = itemsBySection[section]
        return sectionInfo.assets.count
    }
    override func getImages(section:Int)->[Item] {
        let sectionInfo = itemsBySection[section]
        return sectionInfo.assets
    }
    override func getImageObjectIndexAt(index:NSIndexPath)->ImageObject? {
        let sectionInfo = itemsBySection[index.section]
        return sectionInfo.assets[index.row]
    }
    // --------------------------------------
    
    func fetchAssetInfo() {
        let optionCollectionList:PHFetchOptions = PHFetchOptions()
        optionCollectionList.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        let collList:PHFetchResult = PHCollectionList.fetchCollectionListsWithType(PHCollectionListType.MomentList, subtype: PHCollectionListSubtype.Any, options: optionCollectionList)
        collList.enumerateObjectsUsingBlock { (obj, Index, flag) -> Void in
            let collectionList: PHCollectionList = obj as! PHCollectionList
            let items:AssetList = AssetList(collection: collectionList)
            self.list.addItem(items)
            let moments:PHFetchResult! = PHAssetCollection.fetchMomentsInMomentList(collectionList, options: optionCollectionList)
            moments.enumerateObjectsUsingBlock { (object, index, flag) -> Void in
                let assetCollection:PHAssetCollection = object as! PHAssetCollection
                let collection:AssetList = AssetList(collection: assetCollection)
                items.addItem(collection)
                let optionAsset:PHFetchOptions = PHFetchOptions()
                optionAsset.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let assets:PHFetchResult! = PHAsset.fetchAssetsInAssetCollection(object as! PHAssetCollection, options: optionAsset)
                assets.enumerateObjectsUsingBlock({ (asset, indexOfAsset, flag) -> Void in
                    let tempObj:PHAsset? = asset as? PHAsset
                    if (tempObj != nil){
                        let asset:Asset = Asset(asset: tempObj!)
                        collection.addItem(asset)
                    }
                })
            }
        }
    }
    func getSections( buildFlag:Bool )->[String] {
        if buildFlag == true {
            buildSectionData()
            AssetManager.initialize = true
        }
        var sectionString:[String] = []
        for sectionItem in itemsBySection {
            let str = sectionItem.titleString
            sectionString.append(str)
        }
        return sectionString
    }
    func buildSectionData() {
        var sections:[SectionInfo] = []
        switch sectionLevel {
        case .Large:
            var section = SectionInfo()
            section.titleString = "All Images"
            sections.append(section)
            for collectionList in list.collection {
                let coll = collectionList as! AssetList
                for collection in coll.collection {
                    let items = collection as! AssetList
                    for asset in items.collection {
                        section.assets.append(asset as! Asset)
                    }
                }
            }
            itemsBySection.append(section)
        case .Middle:
            for collection in list.collection {
                let collectionList:PHCollectionList = (collection as! AssetList).collectionObject as! PHCollectionList
                var section = SectionInfo()
                section.endDate = collectionList.endDate
                section.startDate = collectionList.startDate
                var str:String = ""
                if let num = collectionList.localizedLocationNames {
                    for location in collectionList.localizedLocationNames {
                        str += (location as! String) + " "
                    }
                }
                section.locationString = str
                let dataFormatter:NSDateFormatter = NSDateFormatter()
                dataFormatter.dateFormat = "YYYY/MM/dd"
                let titleString:String = dataFormatter.stringFromDate(section.startDate) + "--" + dataFormatter.stringFromDate(section.endDate)
                section.titleString = titleString
                //section.titleString = collectionList.localizedTitle
                sections.append(section)
                let collections = collection as! AssetList
                for cln in collections.collection {
                    let items = cln as! AssetList
                    for asset in items.collection {
                        section.assets.append( asset as! Asset )
                    }
                }
                itemsBySection.append(section)
            }
        case .Small:
            for collection in list.collection {
                let assetList:AssetList = collection as! AssetList
                for assets in assetList.collection {
                    let assetsList:PHAssetCollection = (assets as! AssetList).collectionObject as! PHAssetCollection
                    var section = SectionInfo()
                    section.startDate = assetsList.startDate
                    section.endDate = assetsList.endDate
                    var str:String = ""
                    if let strs = assetsList.localizedLocationNames {
                        for location in assetsList.localizedLocationNames {
                            str += (location as! String) + " "
                        }
                    }
                    section.locationString = str
                    let dataFormatter:NSDateFormatter = NSDateFormatter()
                    dataFormatter.dateFormat = "YYYY/MM/dd"
                    let titleString:String = dataFormatter.stringFromDate(section.startDate) + "--" + dataFormatter.stringFromDate(section.endDate)
                    section.titleString = titleString
                    //section.titleString = assetsList.localizedTitle
                    let items = assets as! AssetList
                    for item in items.collection {
                        let asset = item as! Asset
                        section.assets.append( asset )
                    }
                    itemsBySection.append(section)
                }
            }
        default:
            println("error")
        }
    }
    
}

class SectionInfo {
    var startDate:NSDate!
    var endDate:NSDate!
    var locationString:String!
    var titleString:String!
    var assets:[Asset] = []
}

class AssetList:Item {
    var collection:[Item] = []
    var collectionObject:AnyObject!
    init(collection:AnyObject?) {
        super.init(type: ItemType.List)
        self.collectionObject = collection
    }
    func addItem( item:Item ) {
        collection.append(item)
    }
}

class Asset:ImageObject {
    var asset:PHAsset!
    init(asset:PHAsset) {
        super.init(type: ItemType.Asset)
        self.asset = asset
    }
    override func getThumbnail( callback: (image:UIImage)->Void ) {
        var imageData:UIImage?
        let option = PHImageRequestOptions()
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(512, 512), contentMode:       PHImageContentMode.AspectFit, options: option, resultHandler: { (image, info) -> Void in
            callback(image: image)
        })
    }
    override func getImageWithSize(size: CGSize, callback: (image:UIImage)->Void ) {
        var imageData:UIImage?
        let option = PHImageRequestOptions()
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        option.resizeMode  = PHImageRequestOptionsResizeMode.Fast
        option.normalizedCropRect = CGRectMake(0, 0, size.width, size.height)
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode:PHImageContentMode.AspectFit, options: option, resultHandler: { (image, info) -> Void in
        callback(image: image)
        })
    }
    override func getSize()->CGSize {
        return CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight))
    }
}

class Item {
    let itemType:ItemType
    init(type:ItemType) {
        itemType = type
    }
}

enum ItemType {
    case List
    case Asset
}

enum SectionLevel {
    case Large
    case Middle
    case Small
}

