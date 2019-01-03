//
//  ViewController.swift
//  L2DFree
//
//  Created by Hao Nguyen on 9/6/18.
//  Copyright © 2018 Hao Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var drawingView: DrawingView!
    
    let socket = Socket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        drawingView.delegate = self
        socket.connectTo("ws://haonguyen.me:9000")
    }
    
    @IBAction func clearDraws(_ sender: Any) {
        drawingView.clear()
    }
}

extension ViewController: DrawingViewDelegate {
    func endDrawWith(points: [CGPoint]?) {
        guard let points = points else {
            print("!!! No Points !!!")
            return
        }
        print("===== End draw ====== Points: \(points.count)")
        
        socket.sendPoints(points)
    }
}
