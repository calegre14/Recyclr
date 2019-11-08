//
//  UserControllers.swift
//  Recyclr
//
//  Created by Christopher Alegre on 11/7/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import UIKit
import CloudKit

class UserController {
    static let userShared = UserController()
    var currentUser: User?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    private func fetchAppleUserReference(completion: @escaping (CKRecord.Reference?) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let recordID = recordID
                else { completion(nil); return
            }
            let reference = CKRecord.Reference(recordID: recordID, action: .none)
            completion(reference)
        }
    }
    
    func createUser(username: String, bio: String, profilePicture: UIImage, completion: @escaping (Bool) -> Void) {
        fetchAppleUserReference { (reference) in
            guard let reference = reference
                else { completion(false); return
            }
            let newUser = User(username: username, bio: bio, appleUserReference: reference, profilePhoto: profilePicture)
            let record = CKRecord(user: newUser)
            self.publicDB.save(record) { (record, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let record = record,
                    let savedUser = User(ckRecord: record) else {
                        completion(false)
                        return
                }
                self.currentUser = savedUser
                completion(true)
                print("Created user: \(record.recordID.recordName) successfully")
            }
        }
    }
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        fetchAppleUserReference { (reference) in
            guard let reference = reference else {
                completion(false)
                return
            }
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserReferenceKey, reference])
            let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
            self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let record = records?.first,
                    let foundUser = User(ckRecord: record) else {
                        completion(false)
                        return
                }
                self.currentUser = foundUser
                completion(true)
                print("Feched User: \(record.recordID.recordName) successfully")
            }
        }
    }
    
    func fetchUserFor(_ post: Post, completion: @escaping (User?) -> Void) {
        guard let userID = post.postReference?.recordID else {
            completion(nil)
            return
        }
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["recordID", userID])
        let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            guard let record = records?.first,
                let foundUser = User(ckRecord: record) else {
                    completion(nil)
                    return
            }
            completion(foundUser)
        }
    }
    
    func updateUser(_ user: User) {
        
    }
    
    func deleteUser(_ user: User) {
        
    }
}
