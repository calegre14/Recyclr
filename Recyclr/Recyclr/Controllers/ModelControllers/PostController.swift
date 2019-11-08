//
//  PostController.swift
//  Recyclr
//
//  Created by Christopher Alegre on 11/7/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    static let postShared = PostController()
    let publicDB = CKContainer.default().publicCloudDatabase
    var posts: [Post] = []
    
//    MARK:- CRUD Functions
    func createPost(zipCode: Int, glassImage: UIImage?, completion: @escaping (_ success: Bool) -> Void) {
        guard let currentUser = UserController.userShared.currentUser else {
            completion(false)
            return
        }
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        let newPost = Post(zipCode: zipCode, postReference: reference, glassImage: glassImage)
        let postRecord = CKRecord(post: newPost)
        
        publicDB.save(postRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let record = record,
                let savedPost = Post(ckRecord: record) else {
                    completion(false)
                    return
            }
            self.posts.append(savedPost)
            completion(true)
        }
    }
    
    func updatePost(post: Post, completion: @escaping (_ success: Bool) -> Void) {
        guard post.postReference?.recordID == UserController.userShared.currentUser?.recordID else {
            completion(false)
            return
        }
        let recordsToUpdate = CKRecord(post: post)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordsToUpdate], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = {records, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard recordsToUpdate == records?.first else {
                print("Unexpected Record attempted update")
                completion(false)
                return
            }
            print("Updated \(recordsToUpdate.recordID) successfully in CloudKit")
            completion(true)
        }
        publicDB.add(operation)
    }
    
    func deletePost(post: Post, completion: @escaping (_ success: Bool) -> Void) {
        guard post.postReference?.recordID == UserController.userShared.currentUser?.recordID else {
            completion(false)
            return
        }
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [post.ckRecordID])
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = {_, recordIDs, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard post.ckRecordID == recordIDs?.first else {
                print("Unexpected Recored attempted to delete")
                completion(false)
                return
            }
            print("Deleted \(post.ckRecordID) successfully in CloudKit")
            completion(true)
        }
        publicDB.add(operation)
    }
    
    func fetchAllPosts(completion: @escaping (_ success: Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostStrings.recordTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (foundRecords, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let records = foundRecords else {
                completion(false)
                return
            }
            let posts = records.compactMap({ Post(ckRecord: $0) })
            self.posts = posts
            completion(true)
        }
    }
}
