//
//  Post.swift
//  Recyclr
//
//  Created by Christopher Alegre on 11/7/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import UIKit
import CloudKit

//MARK:- Post Key Strings
struct PostStrings {
    static let recordTypeKey = "Post"
    fileprivate static let zipCodeKey = "zipCode"
    fileprivate static let postReferenceKey = "postReference"
    fileprivate static let glassImageKey = "glassImage"
}

//MARK:- Post Struct
class Post {
    
    var user: User?
    var zipCode: Int
    let ckRecordID: CKRecord.ID
    var postReference: CKRecord.Reference?
    var glassImage: UIImage? {
        get {
            guard let glassImageData = self.imageData else {return nil}
            return UIImage(data: glassImageData)
        } set {
            self.imageData = newValue?.jpegData(compressionQuality: 1.0)
        }
    }
    
    var imageData: Data?
    var imageAsset: CKAsset? {
        get {
            guard imageData != nil else {return nil}
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try imageData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(zipCode: Int, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), postReference: CKRecord.Reference?, glassImage: UIImage? = nil) {
        self.zipCode = zipCode
        self.ckRecordID = ckRecordID
        self.postReference = postReference
        self.glassImage = glassImage
    }
}

//MARK:- Post Extention

extension Post {
    convenience init?(ckRecord: CKRecord) {
        guard let zipCode = ckRecord[PostStrings.zipCodeKey] as? Int else {return nil}
        var foundImage: UIImage?
        if let imageAsset = ckRecord[PostStrings.glassImageKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: imageAsset.fileURL!)
                foundImage = UIImage(data: data)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
        
        let postReferance = ckRecord[PostStrings.postReferenceKey] as? CKRecord.Reference
        self.init(zipCode: zipCode, ckRecordID: ckRecord.recordID, postReference: postReferance, glassImage: foundImage)
    }
}

//MARK:- CKRecord Extention
extension CKRecord {
    
    convenience init(post: Post) {
        self.init(recordType: PostStrings.recordTypeKey, recordID: post.ckRecordID)
        guard let postReference = post.postReference else {return}
        guard let imageAsset = post.imageAsset else {return}
        self.setValuesForKeys([
            PostStrings.zipCodeKey : post.zipCode,
            PostStrings.postReferenceKey : postReference,
            PostStrings.glassImageKey : imageAsset
        ])
    }
}
