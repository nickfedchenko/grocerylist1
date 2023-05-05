//
//  SocketManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 06.02.2023.
//

import PusherSwift
import UIKit

class SocketManager: PusherDelegate {
    // MARK: - Singletone
    static var shared = SocketManager()
    
    // MARK: - Constants
    private var hostName = "mpusher.ru"
    private var key = "IfmOiX4mZXFd9MVbMGTwdBHnzNT6ZlS6"
    private var chanelName = "groceryList_" + (UserAccountManager.shared.getUser()?.token ?? "")
    private var portNumber = 6001
    
    // MARK: - InitPusher
    private lazy var options = PusherClientOptions(
        host: .host(hostName),
        port: portNumber)
    
    private lazy var pusher = Pusher(key: key, options: options)
    
    // MARK: -
    func connect() {
        guard UserAccountManager.shared.getUser() != nil else { return }
        pusher.delegate = self
        pusher.connect()
        
        let myChannel = pusher.subscribe(chanelName)
        
        myChannel.bind(eventName: "updated", eventCallback: { (event: PusherEvent) -> Void in
//            SharedListManager.shared.fetchMyGroceryLists()
            if let data: Data = event.data?.data(using: .utf8) {
                guard let decoded = try? JSONDecoder().decode(SocketResponse.self, from: data) else { return }
                SharedListManager.shared.saveListFromSocket(response: decoded)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        })
        
        myChannel.bind(eventName: "delete", eventCallback: { (event: PusherEvent) -> Void in
//            SharedListManager.shared.fetchMyGroceryLists()
            if let data: Data = event.data?.data(using: .utf8) {
                guard let decoded = try? JSONDecoder().decode(SocketDeleteResponse.self, from: data) else { return }
                SharedListManager.shared.deleteListFromSocket(response: decoded)
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            myChannel.trigger(eventName: "push", data: "sendMessage")
        }
      
    }
    
    func sendMessage() {
     
    }
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        print(old.stringValue(), new.stringValue())
        
    }
    
    func debugLog(message: String) {
    }
    
    func subscribedToChannel(name: String) {
        print(name)
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print(name, data ?? "data nil", error?.localizedDescription ?? "error nil")
    }
    
    func receivedError(error: PusherError) {
        let message = error.message
        print("error message: " + message)
        if let code = error.code {
            print(code)
        }
    }
    
    func failedToDecryptEvent(eventName: String, channelName: String, data: String?) {
        print(eventName, channelName, data ?? "data nil")
    }
    
}

struct SocketResponse: Codable {
    var sendForUserToken: String
    var groceryList: SharedGroceryList
    var listUsers: [User]
    var listId: String
}

struct SocketDeleteResponse: Codable {
    var sendForUserToken: String
    var listId: String
}
