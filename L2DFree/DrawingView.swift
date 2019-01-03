//
//  DrawingView.swift
//  L2DFree
//
//  Created by Hao Nguyen on 1/2/19.
//  Copyright © 2019 Hao Nguyen. All rights reserved.
//

import UIKit

class DrawingView: UIView {

    var drawColor = UIColor.black    // A color for drawing
    var lineWidth: CGFloat = 5              // A line width
    
    private var lastPoint: CGPoint!         // A point for storing the last position
    private var bezierPath: UIBezierPath!   // A bezier path
    private var pointCounter: Int = 0       // A counter of points
    private let pointLimit: Int = 128       // A limit of the points
    private var preRenderImage: UIImage!    // A pre-render image
    
    private var points: [CGPoint] = []
    weak var delegate: DrawingViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initBezierPath()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initBezierPath()
    }
    
    func initBezierPath() {
        bezierPath = UIBezierPath()
        bezierPath.lineCapStyle = .round //kCGLineCapRound
        bezierPath.lineJoinStyle = .round //kCGLineJoinRound
    }
    
    func renderToImage() {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        if preRenderImage != nil {
            preRenderImage.draw(in: self.bounds)
        }
        
        bezierPath.lineWidth = lineWidth
        drawColor.setFill()
        drawColor.setStroke()
        bezierPath.stroke()
        
        preRenderImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if preRenderImage != nil {
            preRenderImage.draw(in: self.bounds)
        }
        
        bezierPath.lineWidth = lineWidth
        drawColor.setFill()
        drawColor.setStroke()
        bezierPath.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began")
        let touch: AnyObject? = touches.first
        lastPoint = touch!.location(in: self)
        pointCounter = 0
        
        points.append(lastPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches moved")
        let touch: AnyObject? = touches.first
        let newPoint = touch!.location(in: self)
        
        bezierPath.move(to: lastPoint)
        bezierPath.addLine(to: newPoint)
        lastPoint = newPoint
        
        pointCounter += 1
        points.append(lastPoint)
        
        if pointCounter == pointLimit {
            pointCounter = 0
            renderToImage()
            setNeedsDisplay()
            bezierPath.removeAllPoints()
        }
        else {
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        pointCounter = 0
        renderToImage()
        setNeedsDisplay()
        bezierPath.removeAllPoints()
        
        delegate?.endDrawWith(points: points)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches cancelled")
        touchesEnded(touches, with: event)
    }
    
    func clear() {
        points.removeAll()
        preRenderImage = nil
        bezierPath.removeAllPoints()
        setNeedsDisplay()
    }
    
    func hasLines() -> Bool {
        return preRenderImage != nil || !bezierPath.isEmpty
    }
}

protocol DrawingViewDelegate: class {
    func endDrawWith(points: [CGPoint]?)
}
