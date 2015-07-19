//
//  PhotoPickerHelper.swift
//  PhotoPicker
//
//  Created by mxy on 15/7/15.
//  Copyright © 2015年 mxy. All rights reserved.
//

import Foundation
import Photos

public class PhotoPickerHelper {
    let assetCountChageNotification = "AssetCountChageNotification"
    let overMaxSelectedNumberNotification = "OverMaxSelectedNumberNotification"
    // 允许选择的照片的最大数
    let allowMaxSelectedAssets = 9
    // 所有的照片分组
    var photoGroups = [PhotoGroup]()
    var selectedPhotos: Set = Set<PHAsset>()
    var imageManager: PHImageManager!
    
    public static let sharedInstance = {
            return PhotoPickerHelper()
        }()
    
    private init() {
        self.imageManager = PHImageManager.defaultManager()
        
        // 所有图片
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        let assetsFetchResults = PHAsset.fetchAssetsWithOptions(options)
//        if assetsFetchResults.count > 0 {
//            // TODO: 国际化
//            let photoGroup = PhotoGroup(groupName: "相机胶卷", assetsFetchResult: assetsFetchResults)
//            self.photoGroups += [photoGroup]
//        }
        
        // 默认图片分组
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype:.AlbumRegular , options: nil)
        for var i = 0; i < smartAlbums.count; i++ {
            let collection = smartAlbums[i] as! PHAssetCollection
            let assetsFetchResults = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
            if assetsFetchResults.count > 0 {
                let photoGroup = PhotoGroup(groupName: collection.localizedTitle, assetsFetchResult: assetsFetchResults)
                // TODO: - 这里这样判断有问题 国际化的时候会出问题
                if collection.localizedTitle == "相机胶卷" {
                    self.photoGroups.insert(photoGroup, atIndex: 0)
                } else {
                    self.photoGroups += [photoGroup]
                }
            }
        }
        
        // 用户自定义分组
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
        for var i = 0; i < topLevelUserCollections.count; i++ {
            let collection = topLevelUserCollections[i] as! PHAssetCollection
            let assetsFetchResults = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
            if assetsFetchResults.count > 0 {
                let photoGroup = PhotoGroup(groupName: collection.localizedTitle, assetsFetchResult: assetsFetchResults)
                self.photoGroups += [photoGroup]
            }
        }
    }
    
    // 获取某个分组的第一张照片缩略图
    func firstPhotoThumbnails(photoGroup: PhotoGroup, resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void) {
        self.photoThumbnails(photoGroup.assetsFetchResult.firstObject as! PHAsset, resultHandler: resultHandler)
    }
    
    // 获取分组内的照片
    
    // 获取某一张照片缩略图
    public func photoThumbnails(asset: PHAsset!, resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void) {
//        let scale = UIScreen.mainScreen().scale
//        let options = PHImageRequestOptions()
//        options.resizeMode = .Fast
//
//        self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 88 * scale, height: 88 * scale), contentMode: .AspectFill, options: options, resultHandler: resultHandler)
        return self.photoImage(CGSize(width: 88, height: 88), asset: asset, resultHandler: resultHandler)
    }
    
    public func photoImage(targetSize: CGSize, asset: PHAsset!, resultHandler: (UIImage?, [NSObject : AnyObject]?) -> Void) {
        let scale = UIScreen.mainScreen().scale
        let options = PHImageRequestOptions()
        options.resizeMode = .Fast
        
        self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: targetSize.width * scale, height: targetSize.height * scale), contentMode: .AspectFill, options: options, resultHandler: resultHandler)
    }
    
    // MARK: - selected 
    func addSelectedAsset(asset: PHAsset) {
        let assetSet: Set = [asset]
        self.selectedPhotos = self.selectedPhotos.union(assetSet)
        self.sendAssetCountChangeNotification()
    }
    
    func removeSelectedAsset(asset: PHAsset) {
        let assetSet: Set = [asset]
        self.selectedPhotos = self.selectedPhotos.subtract(assetSet)
        self.sendAssetCountChangeNotification()
    }
    
    func isSelected(asset: PHAsset) -> Bool {
        if self.selectedPhotos.contains(asset) {
            return true
        } else {
            return false
        }
    }
    
    func clearSelectedAsset() {
        self.selectedPhotos.removeAll()
    }
    
    // NSNotificationCenter
    private func sendAssetCountChangeNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(self.assetCountChageNotification, object: nil)
    }
    
}


struct PhotoGroup {
    var groupName: String!
    var photoCount: Int! {
        return self.assetsFetchResult.count
    }
    // 每一个项目对应的Asserts
    var assetsFetchResult: PHFetchResult!
    
}