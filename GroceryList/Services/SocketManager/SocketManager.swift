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
    private var key = "v1dFON7iBTbGRVrAsS6tNmR9v9GKEkrv"
    private var chanelName = "test"
    private var portNumber = 6001
    
    // MARK: - InitPusher
    private lazy var options = PusherClientOptions(
        host: .host(hostName),
        port: portNumber)
    
    private lazy var pusher = Pusher(key: key, options: options)
    
    // MARK: -
    func connect() {
        pusher.delegate = self
        pusher.connect()
        
        let myChannel = pusher.subscribe(chanelName)
        
        myChannel.bind(eventName: chanelName, callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print(message)
                }
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
        print(message)
    }
    
    func subscribedToChannel(name: String) {
        print(name)
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print(name, data, error)
    }
    
    func receivedError(error: PusherError) {
        let message = error.message
        if let code = error.code {
            print(code)
        }
    }
    
    func failedToDecryptEvent(eventName: String, channelName: String, data: String?) {
        print(eventName, channelName, data)
    }
    
}