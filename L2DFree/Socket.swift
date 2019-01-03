//
//  Socket.swift
//  L2DFree
//
//  Created by Hao Nguyen on 9/6/18.
//  Copyright © 2018 Hao Nguyen. All rights reserved.
//

import UIKit

protocol SocketDelegate: class {
    func socketDidOpen()
    func socketError(_ error: Error!)
    func socketReceive(_ message: Any)
    func socketClose(_ code: Int, reason: String)
}

class Socket: NSObject {
    
    private var client: SRWebSocket!
    weak var delegate: SocketDelegate?
    
    func connectTo(_ server: String) {
        client = SRWebSocket(url: URL(string: server))
        client.delegate = self
        client.open()
    }
    
    func sendPoints(_ points: [CGPoint]) {
        guard client.readyState == SR_OPEN else {
            print("socket is not open")
            delegate?.socketError(NSError(domain: "com.websocket", code: Int(client!.readyState.rawValue), userInfo: [NSLocalizedDescriptionKey: "Socket is not open"]))
            return
        }
        client.send(try! NSKeyedArchiver.archivedData(withRootObject: points, requiringSecureCoding: false))
    }
    
    func closeSocket() {
        client.close()
    }
}

extension Socket: SRWebSocketDelegate {
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("socket open")
        delegate?.socketDidOpen()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        delegate?.socketError(error)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        print("received: \(String(describing: message))")
        delegate?.socketReceive(message)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("Socket close. Code: \(code). Reason: \(String(describing: reason))")
        delegate?.socketClose(code, reason: reason)
    }
}
