//
//  ChatService.swift
//  ZainAutomotiveSolution
//
//  Created by Zain Shroff on 30/05/19.
//  Copyright © 2019 Zain Shroff. All rights reserved.
//

import Foundation
import Scaledrone

class ChatService {
    private let scaledrone: Scaledrone
    private let messageCallback: (Message)-> Void
    
    private var room: ScaledroneRoom?
    
    init(member: Member, onRecievedMessage: @escaping (Message)-> Void) {
        self.messageCallback = onRecievedMessage
        self.scaledrone = Scaledrone(
            channelID: "ObHtumE50JPXKBxc",
            data: member.toJSON)
        scaledrone.delegate = self
    }
    
    func connect() {
        scaledrone.connect()
    }
    func sendMessage(_ message: String) {
        room?.publish(message: message)
    }
}
extension ChatService: ScaledroneDelegate {
    func scaledroneDidConnect(scaledrone: Scaledrone, error: Error?) {
        print("Connected to Scaledrone")
        room = scaledrone.subscribe(roomName: "observable-room")
        room?.delegate = self
    }
    
    func scaledroneDidReceiveError(scaledrone: Scaledrone, error: Error?) {
        print("Scaledrone error", error ?? "")

    }
    
    func scaledroneDidDisconnect(scaledrone: Scaledrone, error: Error?) {
        print("Scaledrone disconnected", error ?? "")

    }
}
extension ChatService: ScaledroneRoomDelegate {
    func scaledroneRoomDidConnect(room: ScaledroneRoom, error: Error?) {
        print("Connected to room!")

    }
    
    func scaledroneRoomDidReceiveMessage(
        room: ScaledroneRoom,
        message: Any,
        member: ScaledroneMember?) {
        
        guard
            let text = message as? String,
            let memberData = member?.clientData,
            let member = Member(fromJSON: memberData)
            else {
                print("Could not parse data.")
                return
        }
        
        let message = Message(
            member: member,
            text: text,
            messageId: UUID().uuidString)
        messageCallback(message)
    }
}

