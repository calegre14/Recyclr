//
//  Comment.swift
//  Recyclr
//
//  Created by Christopher Alegre on 11/7/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import Foundation
import CloudKit

//MARK:- Comment Keys
struct CommentKeys {
    static let commentRecordTypeKey = "Comment"
    fileprivate static let commentTextKey = "commentText"
    fileprivate static let creationDateKey = "creationDate"
    fileprivate static let commentReference = "commentReference"
}

//MARK: Comment Struct
class Comment {
    
    var user: User?
    let commentText: String
    let creationDate: Date
    let ckRecordID: CKRecord.ID
    let commentReference: CKRecord.Reference
        
    init(commentText: String, creationDate: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentReference: CKRecord.Reference) {
        self.commentText = commentText
        self.creationDate = creationDate
        self.ckRecordID = ckRecordID
        self.commentReference = commentReference
    }
}

//MARK: Comment Extention
extension Comment {
    convenience init?(ckRecord: CKRecord) {
        guard let commentText = ckRecord[CommentKeys.commentTextKey] as? String,
            let creationDate = ckRecord[CommentKeys.creationDateKey] as? Date,
            let commentReference = ckRecord[CommentKeys.commentReference] as? CKRecord.Reference
            else {return nil}
        
        self.init(commentText: commentText, creationDate: creationDate, ckRecordID: ckRecord.recordID, commentReference: commentReference)
    }
}

//MARK: CKRecord Extention
extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: CommentKeys.commentRecordTypeKey, recordID: comment.ckRecordID)
        setValuesForKeys([
            CommentKeys.commentTextKey : comment.commentText,
            CommentKeys.creationDateKey : comment.creationDate,
            CommentKeys.commentReference : comment.commentReference
        ])
    }
}
