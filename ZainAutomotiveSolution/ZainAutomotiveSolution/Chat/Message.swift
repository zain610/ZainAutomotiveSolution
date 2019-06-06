//
//  Message.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 09/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//
import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
    
    var id: String?
    var content: String
    var sentDate: Date
    var sender: Sender
    
    var kind: MessageKind {
            return .text(content)
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var image: MediaItem? = nil
    var downloadURL: URL? = nil
    
    init(user: User, content: String) {
        print(user.uid)
        sender = Sender(id: user.uid, displayName: "zains98")
        self.content = content
        
        sentDate = Date()
        id = nil
        
        switch kind {
        case .text(let text):
            self.content = text
        default:
            self.content = ""
        }
    }
    
    init(user: User, image: MediaItem) {
        sender = Sender(id: user.uid, displayName: "zains98")
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let sentDate = data["created"] as? Date else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate
        sender = Sender(id: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
    }
    var description: String {
        return self.messageText
    }
    
    var messageText: String {
        switch kind {
        case .text(let text):
            return text
        default:
            return ""
        }
    }
    
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.id,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
