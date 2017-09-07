//
//  HandleView.swift
//  SplitKit
//
//  Created by Matteo Gavagnin on 07/09/2017.
//  Copyright © 2017 Dolomate.
//  See LICENSE file for more details.
//

import UIKit

internal let handleSize = CGSize(width: 32, height: 32)
internal let draggingAnimationDuration : TimeInterval = 0.15

/// Handle View to drag the separator inspired by the one used by Apple's Swift Playgrounds app for iPad
internal class HandleView: UIView {
    
    var barColor : UIColor = UIColor(red: 233/255, green: 90/255, blue: 57/255, alpha: 1.0) {
        didSet {
            leftBar?.fillColor = barColor.cgColor
            rightBar?.fillColor = barColor.cgColor
        }
    }
    
    fileprivate let snapOffset : CGFloat = 8
    
    var snapped : Snapped = .none {
        didSet {
            let baseFrame = CGRect(x: (bounds.size.width - barHeight) / 2, y: (bounds.size.height - barHeight) / 2, width: barHeight, height: barHeight)
            guard let bars = bars else { return }
            bars.frame = baseFrame
            switch snapped {
            case .none:
                break
            case .lead:
                bars.frame.origin.x = bars.frame.origin.x + snapOffset
                break
            case .trail:
                bars.frame.origin.x = bars.frame.origin.x - snapOffset
                break
            case .top:
                bars.frame.origin.y = bars.frame.origin.y + snapOffset
                break
            case .bottom:
                bars.frame.origin.y = bars.frame.origin.y - snapOffset
                break
            }
            UIView.animate(withDuration: draggingAnimationDuration, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
                self.layoutIfNeeded()
            }) { (complete) in
                
            }
        }
    }
    
    let cornerRadius : CGFloat = 8.0
    let backgroundGray = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
    let barHeight : CGFloat = 10.0
    let barWidth : CGFloat = 2.0
    var bars : CALayer?
    var leftBar : CAShapeLayer?
    var rightBar : CAShapeLayer?
    
    fileprivate var arrangement : Arrangement = .horizontal {
        didSet {
            guard let bars = bars else { return }
            switch arrangement {
            case .horizontal:
                bars.transform = CATransform3DIdentity
                break
            case .vertical:
                bars.transform = CATransform3DMakeRotation(CGFloat.pi / 2.0, 0, 0, 1)
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init(_ arrangement: Arrangement) {
        self.init(frame: CGRect(x: 0, y: 0, width: handleSize.width, height: handleSize.height))
        defer {
            self.arrangement = arrangement
            self.snapped = .none
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        bounds.size = handleSize
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        backgroundColor = backgroundGray
        alpha = 0.0
        bars = barsLayer
        guard let bars = bars else { return }
        layer.addSublayer(bars)
    }
    
    lazy var barsLayer : CALayer = {
        let barsLayer = CALayer()
        barsLayer.frame = CGRect(x: (bounds.size.width - barHeight) / 2, y: (bounds.size.height - barHeight) / 2, width: barHeight, height: barHeight)
        leftBar = verticalBar()
        if let leftBar = leftBar {
            leftBar.frame.origin.x = barWidth
            barsLayer.addSublayer(leftBar)
        }
        
        rightBar = verticalBar()
        if let rightBar = rightBar {
            rightBar.frame.origin.x = barWidth * 3
            barsLayer.addSublayer(rightBar)
        }
        
        return barsLayer
    }()
    
    func verticalBar() -> CAShapeLayer {
        let verticalBar = CAShapeLayer()
        verticalBar.frame = CGRect(x: 0, y: 0, width: barWidth, height: barHeight)
        verticalBar.path = UIBezierPath(roundedRect: verticalBar.bounds, cornerRadius: verticalBar.bounds.width / 2.0).cgPath
        verticalBar.fillColor = barColor.cgColor
        return verticalBar
    }
}
