//
//  SplitKit.swift
//  SplitKit
//
//  Created by Matteo Gavagnin on 01/09/2017.
//  Copyright © 2017 Dolomate.
//  See LICENSE file for more details.
//

import UIKit

/// Split controller disposition
///
/// - horizontal: two controllers will be disposed side by side, first one on the leading side
/// - vertical: two controllers will be disposed one on top of the other, first on top
@objc(DOLSplitKitDisposition)
public enum SplitKitDisposition: Int {
    case horizontal = 0
    case vertical = 1
}

import UIKit.UIGestureRecognizerSubclass

@objc(DOLInstantPanGestureRecognizer)
fileprivate class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    fileprivate override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizerState.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began
    }
}

fileprivate let handleSize = CGSize(width: 32, height: 32)

@objc(DOLSnappedSide)
public enum SnappedSide: Int {
    case none = 0
    case lead = 1
    case trail = 2
    case top = 3
    case bottom = 4
}

fileprivate let draggingAnimationDuration : TimeInterval = 0.15

/// Handle View to drag the separator inspired by the one used by Apple's Swift Playgrounds app for iPad
@objc(DOLHandleView)
fileprivate class HandleView: UIView {
    
    var barColor : UIColor = UIColor(red: 233/255, green: 90/255, blue: 57/255, alpha: 1.0) {
        didSet {
            leftBar?.fillColor = barColor.cgColor
            rightBar?.fillColor = barColor.cgColor
        }
    }
    
    fileprivate let snapOffset : CGFloat = 8
    
    var snapped : SnappedSide = .none {
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
    
    fileprivate var disposition : SplitKitDisposition = .horizontal {
        didSet {
            guard let bars = bars else { return }
            switch disposition {
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
    
    convenience init(_ disposition: SplitKitDisposition) {
        self.init(frame: CGRect(x: 0, y: 0, width: handleSize.width, height: handleSize.height))
        defer {
            self.disposition = disposition
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
        barsLayer.frame = CGRect(x: (self.bounds.size.width - self.barHeight) / 2,
                                 y: (self.bounds.size.height - self.barHeight) / 2,
                                 width: self.barHeight,
                                 height: self.barHeight)
        self.leftBar = self.verticalBar()
        if let leftBar = self.leftBar {
            leftBar.frame.origin.x = self.barWidth
            barsLayer.addSublayer(leftBar)
        }
        
        self.rightBar = self.verticalBar()
        if let rightBar = self.rightBar {
            rightBar.frame.origin.x = self.barWidth * 3
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

/// Simple container controller that let you dispose two child controllers side by side or one on top of the other, supporting gesture to resize the different areas. Vertical and Horizontal disposition is supported.
@objc(DOLSplitKitViewController)
open class SplitKitViewController: UIViewController {

    /// Specify the animation duration to change split orientation between horizontal to vertical and vice versa. Default is 0.25 seconds.
    public var invertAnimationDuration : TimeInterval = 0.25

    // Default value is similar to the UINavigationBar shadow.
    
    /// Specify the split separator color
    public var separatorColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3) {
        didSet {
            horizontalSeparatorHair.backgroundColor = separatorColor
            verticalSeparatorHair.backgroundColor = separatorColor
        }
    }
    
    /// Specify the split separator color while being dragged
    public var separatorSelectedColor : UIColor = UIColor(red: 233/255, green: 90/255, blue: 57/255, alpha: 1.0) {
        didSet {
            horizontalHandle.barColor = separatorSelectedColor
            verticalHandle.barColor = separatorSelectedColor
        }
    }
    
    fileprivate var shouldAnimateSplitChange = false
    
    /// Change the controllers disposition:
    /// - side by side with `.horizontal`
    /// - top and bottom with `.vertical`
    public var splitDisposition : SplitKitDisposition = .horizontal {
        didSet {
            let duration = shouldAnimateSplitChange ? invertAnimationDuration : 0.0
            
            switch splitDisposition {
            case .horizontal:
                firstViewTrailingConstraint.isActive = false
                firstViewHeightConstraint.isActive = false
                secondViewFirstTopConstraint.isActive = false
                secondViewLeadingConstraint.isActive = false
                horizontalSeparatorView.isHidden = false
                firstViewBottomConstraint.isActive = true
                firstViewWidthConstraint.isActive = true
                secondViewFirstLeadingConstraint.isActive = true
                secondViewTopConstraint.isActive = true
                verticalSeparatorView.isHidden = true
                
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
                })
                break
            case .vertical:
                
                firstViewBottomConstraint.isActive = false
                firstViewWidthConstraint.isActive = false
                secondViewFirstLeadingConstraint.isActive = false
                secondViewTopConstraint.isActive = false
                verticalSeparatorView.isHidden = false
                firstViewTrailingConstraint.isActive = true
                firstViewHeightConstraint.isActive = true
                secondViewFirstTopConstraint.isActive = true
                secondViewLeadingConstraint.isActive = true
                horizontalSeparatorView.isHidden = true
                
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                    }, completion: { (completed) in
                        
                })
                break
            }
        }
    }
    
    /// Switch to the other disposition
    ///
    /// - Parameter sender: the button that triggered the orientation change
    @IBAction func switchDisposition(_ sender: Any? = nil) {
        switch splitDisposition {
        case .horizontal:
            splitDisposition = .vertical
            break
        case .vertical:
            splitDisposition = .horizontal
            break
        }
    }
    
    /// Set the top or leading controller
    public var firstChild : UIViewController? {
        didSet {
            if let oldController = oldValue {
                oldController.willMove(toParentViewController: nil)
                oldController.view.removeFromSuperview()
                oldController.removeFromParentViewController()
            }
            if let child = firstChild {
                addChildViewController(child)
                child.view.frame = firstContainerView.bounds
                child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                firstContainerView.addSubview(child.view)
                child.didMove(toParentViewController: self)
            }
        }
    }
    
    /// Set the bottom or trailing controller
    public var secondChild : UIViewController? {
        didSet {
            if let oldController = oldValue {
                oldController.willMove(toParentViewController: nil)
                oldController.view.removeFromSuperview()
                oldController.removeFromParentViewController()
            }
            if let child = secondChild {
                addChildViewController(child)
                child.view.frame = secondContainerView.bounds
                child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                secondContainerView.addSubview(child.view)
                child.didMove(toParentViewController: self)
            }
        }
    }

    private let horizontalSeparatorView = UIView()
    private let verticalSeparatorView = UIView()
    
    private let firstContainerView = UIView()
    private let secondContainerView = UIView()
    
    private var firstViewTopConstraint : NSLayoutConstraint!
    private var firstViewBottomConstraint : NSLayoutConstraint!
    private var firstViewLeadingConstraint : NSLayoutConstraint!
    private var firstViewTrailingConstraint : NSLayoutConstraint!
    private var firstViewWidthConstraint : NSLayoutConstraint!
    private var firstViewHeightConstraint : NSLayoutConstraint!
    
    private var secondViewTopConstraint : NSLayoutConstraint!
    private var secondViewBottomConstraint : NSLayoutConstraint!
    private var secondViewLeadingConstraint : NSLayoutConstraint!
    private var secondViewTrailingConstraint : NSLayoutConstraint!
    private var secondViewFirstLeadingConstraint : NSLayoutConstraint!
    private var secondViewFirstTopConstraint : NSLayoutConstraint!
    
    private var bottomKeyboardHeight : CGFloat = 0.0
    
    private let horizontalSeparatorHair = UIView()
    private var horizontalSeparatorWidthConstraint : NSLayoutConstraint!
    
    private let verticalSeparatorHair = UIView()
    private var verticalSeparatorHeightConstraint : NSLayoutConstraint!
    
    private let horizontalHandle = HandleView(.horizontal)
    private let verticalHandle = HandleView(.vertical)
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        firstContainerView.frame = view.bounds
        firstContainerView.accessibilityIdentifier = "FirstContainerView"
        firstContainerView.backgroundColor = .white
        firstContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(firstContainerView)
        if #available(iOS 11.0, *) {
            firstViewTopConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .top, relatedBy: .equal, toItem: firstContainerView, attribute: .top, multiplier: 1, constant: 0)
            firstViewBottomConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: firstContainerView, attribute: .bottom, multiplier: 1, constant: 0)
            firstViewLeadingConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: firstContainerView, attribute: .leading, multiplier: 1, constant: 0)
            firstViewTrailingConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .trailing, relatedBy: .equal, toItem: firstContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        } else {
            firstViewTopConstraint = NSLayoutConstraint(item: topLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: firstContainerView, attribute: .top, multiplier: 1, constant: 0)
            firstViewBottomConstraint = NSLayoutConstraint(item: bottomLayoutGuide, attribute: .top, relatedBy: .equal, toItem: firstContainerView, attribute: .bottom, multiplier: 1, constant: 0)
            firstViewLeadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: firstContainerView, attribute: .leading, multiplier: 1, constant: 0)
            firstViewTrailingConstraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: firstContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        }
        view.addConstraint(firstViewTopConstraint!)
        view.addConstraint(firstViewBottomConstraint!)
        view.addConstraint(firstViewLeadingConstraint!)
        firstViewTrailingConstraint.isActive = false
        view.addConstraint(firstViewTrailingConstraint!)
        
        if #available(iOS 11.0, *) {
            firstViewWidthConstraint = NSLayoutConstraint(item: firstContainerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (view.bounds.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right) / 2.0)
            firstViewHeightConstraint = NSLayoutConstraint(item: firstContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (view.bounds.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) / 2.0)
        } else {
            firstViewWidthConstraint = NSLayoutConstraint(item: firstContainerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.bounds.size.width / 2.0)
            firstViewHeightConstraint = NSLayoutConstraint(item: firstContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (view.bounds.size.height - topLayoutGuide.length - bottomLayoutGuide.length) / 2.0)
        }
        view.addConstraint(firstViewWidthConstraint!)
        
        firstViewHeightConstraint.isActive = false
        view.addConstraint(firstViewHeightConstraint!)
        
        secondContainerView.frame = view.bounds
        secondContainerView.accessibilityIdentifier = "SecondContainerView"
        secondContainerView.backgroundColor = .white
        secondContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secondContainerView)
        
        if #available(iOS 11.0, *) {
            secondViewTopConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .top, relatedBy: .equal, toItem: secondContainerView, attribute: .top, multiplier: 1, constant: 0)
            secondViewBottomConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: secondContainerView, attribute: .bottom, multiplier: 1, constant: 0)
            secondViewLeadingConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .leading, relatedBy: .equal, toItem: secondContainerView, attribute: .leading, multiplier: 1, constant: 0)
            secondViewTrailingConstraint = NSLayoutConstraint(item: view.safeAreaLayoutGuide, attribute: .trailing, relatedBy: .equal, toItem: secondContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        } else {
            secondViewTopConstraint = NSLayoutConstraint(item: topLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: secondContainerView, attribute: .top, multiplier: 1, constant: 0)
            secondViewBottomConstraint = NSLayoutConstraint(item: bottomLayoutGuide, attribute: .top, relatedBy: .equal, toItem: secondContainerView, attribute: .bottom, multiplier: 1, constant: 0)
            secondViewLeadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: secondContainerView, attribute: .leading, multiplier: 1, constant: 0)
            secondViewTrailingConstraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: secondContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        }
        secondViewTopConstraint.isActive = false
        view.addConstraint(secondViewTopConstraint!)
        view.addConstraint(secondViewBottomConstraint!)
        secondViewLeadingConstraint.isActive = false
        view.addConstraint(secondViewLeadingConstraint!)
        view.addConstraint(secondViewTrailingConstraint!)
        
        secondViewFirstTopConstraint = NSLayoutConstraint(item: secondContainerView, attribute: .top, relatedBy: .equal, toItem: firstContainerView, attribute: .bottom, multiplier: 1, constant: 0)
        secondViewFirstTopConstraint.isActive = false
        secondViewFirstLeadingConstraint = NSLayoutConstraint(item: secondContainerView, attribute: .leading, relatedBy: .equal, toItem: firstContainerView, attribute: .trailing, multiplier: 1, constant: 0)
        secondViewFirstLeadingConstraint.isActive = false
        
        let separatorSize : CGFloat = 44.0
        horizontalSeparatorView.frame = CGRect(x: (view.bounds.size.width - separatorSize) / 2.0, y: 0.0, width: separatorSize, height: view.bounds.size.height)
        horizontalSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        horizontalSeparatorView.alpha = 1.0
        horizontalSeparatorView.backgroundColor = .clear
        view.addSubview(horizontalSeparatorView)
        view.addConstraint(NSLayoutConstraint(item: firstContainerView, attribute: .trailing, relatedBy: .equal, toItem: horizontalSeparatorView, attribute: .centerX, multiplier: 1, constant: 0))
        if #available(iOS 11.0, *) {
            view.addConstraint(NSLayoutConstraint(item: horizontalSeparatorView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: horizontalSeparatorView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        } else {
            view.addConstraint(NSLayoutConstraint(item: horizontalSeparatorView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: horizontalSeparatorView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        }
        view.addConstraint(NSLayoutConstraint(item: horizontalSeparatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: separatorSize))
        
        let horizontalPanGesture = InstantPanGestureRecognizer(target: self, action: #selector(horizontalPanGestureDidPan))

        horizontalPanGesture.delaysTouchesBegan = false
        horizontalSeparatorView.addGestureRecognizer(horizontalPanGesture)

        horizontalSeparatorHair.frame = horizontalSeparatorView.bounds
        horizontalSeparatorHair.backgroundColor = separatorColor
        horizontalSeparatorView.addSubview(horizontalSeparatorHair)
        horizontalSeparatorHair.translatesAutoresizingMaskIntoConstraints = false
        horizontalSeparatorView.addConstraint(NSLayoutConstraint(item: horizontalSeparatorHair, attribute: .top, relatedBy: .equal, toItem: horizontalSeparatorView, attribute: .top, multiplier: 1, constant: 0))
        horizontalSeparatorView.addConstraint(NSLayoutConstraint(item: horizontalSeparatorHair, attribute: .bottom, relatedBy: .equal, toItem: horizontalSeparatorView, attribute: .bottom, multiplier: 1, constant: 0))
        horizontalSeparatorView.addConstraint(NSLayoutConstraint(item: horizontalSeparatorHair, attribute: .centerX, relatedBy: .equal, toItem: horizontalSeparatorView, attribute: .centerX, multiplier: 1, constant: 0))
        horizontalSeparatorWidthConstraint = NSLayoutConstraint(item: horizontalSeparatorHair, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1.0 / UIScreen.main.scale)
        horizontalSeparatorView.addConstraint(horizontalSeparatorWidthConstraint!)
        horizontalSeparatorView.addSubview(horizontalSeparatorHair)
        
        horizontalSeparatorView.addSubview(horizontalHandle)
        horizontalHandle.translatesAutoresizingMaskIntoConstraints = false
        horizontalSeparatorView.addConstraint(NSLayoutConstraint(item: horizontalHandle, attribute: .centerX, relatedBy: .equal, toItem: horizontalSeparatorView, attribute: .centerX, multiplier: 1, constant: 0))
        horizontalSeparatorView.addConstraint(NSLayoutConstraint(item: horizontalHandle, attribute: .centerY, relatedBy: .equal, toItem: horizontalSeparatorView, attribute: .centerY, multiplier: 1, constant: 0))
        horizontalSeparatorView.addConstraint(NSLayoutConstraint(item: horizontalHandle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: handleSize.height))
        horizontalSeparatorView.addConstraint(NSLayoutConstraint(item: horizontalHandle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: handleSize.width))
        
        verticalSeparatorView.frame = CGRect(x: 0.0, y: (view.bounds.size.height - separatorSize) / 2.0, width: view.bounds.size.width, height: separatorSize)
        verticalSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        verticalSeparatorView.alpha = 1.0
        verticalSeparatorView.backgroundColor = .clear
        view.addSubview(verticalSeparatorView)
        view.addConstraint(NSLayoutConstraint(item: firstContainerView, attribute: .bottom, relatedBy: .equal, toItem: verticalSeparatorView, attribute: .centerY, multiplier: 1, constant: 0))
        if #available(iOS 11.0, *) {
            view.addConstraint(NSLayoutConstraint(item: verticalSeparatorView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: verticalSeparatorView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0))
        } else {
            view.addConstraint(NSLayoutConstraint(item: verticalSeparatorView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: verticalSeparatorView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        }
        view.addConstraint(NSLayoutConstraint(item: verticalSeparatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: separatorSize))
        
        let verticalPanGesture = InstantPanGestureRecognizer(target: self, action: #selector(verticalPanGestureDidPan))
        verticalPanGesture.delaysTouchesBegan = false
        verticalSeparatorView.addGestureRecognizer(verticalPanGesture)
        
        verticalSeparatorHair.frame = verticalSeparatorView.bounds
        verticalSeparatorHair.backgroundColor = separatorColor
        verticalSeparatorView.addSubview(verticalSeparatorHair)
        verticalSeparatorHair.translatesAutoresizingMaskIntoConstraints = false
        verticalSeparatorView.addConstraint(NSLayoutConstraint(item: verticalSeparatorHair, attribute: .leading, relatedBy: .equal, toItem: verticalSeparatorView, attribute: .leading, multiplier: 1, constant: 0))
        verticalSeparatorView.addConstraint(NSLayoutConstraint(item: verticalSeparatorHair, attribute: .trailing, relatedBy: .equal, toItem: verticalSeparatorView, attribute: .trailing, multiplier: 1, constant: 0))
        verticalSeparatorView.addConstraint(NSLayoutConstraint(item: verticalSeparatorHair, attribute: .centerY, relatedBy: .equal, toItem: verticalSeparatorView, attribute: .centerY, multiplier: 1, constant: 0))
        verticalSeparatorHeightConstraint = NSLayoutConstraint(item: verticalSeparatorHair, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1.0 / UIScreen.main.scale)
        verticalSeparatorView.addConstraint(verticalSeparatorHeightConstraint!)
        verticalSeparatorView.addSubview(verticalSeparatorHair)
        
        verticalSeparatorView.addSubview(verticalHandle)
        verticalHandle.translatesAutoresizingMaskIntoConstraints = false
        verticalSeparatorView.addConstraint(NSLayoutConstraint(item: verticalHandle, attribute: .centerX, relatedBy: .equal, toItem: verticalSeparatorView, attribute: .centerX, multiplier: 1, constant: 0))
        verticalSeparatorView.addConstraint(NSLayoutConstraint(item: verticalHandle, attribute: .centerY, relatedBy: .equal, toItem: verticalSeparatorView, attribute: .centerY, multiplier: 1, constant: 0))
        verticalSeparatorView.addConstraint(NSLayoutConstraint(item: verticalHandle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: handleSize.height))
        verticalSeparatorView.addConstraint(NSLayoutConstraint(item: verticalHandle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: handleSize.width))
        
        switch traitCollection.horizontalSizeClass {
        case .compact:
            splitDisposition = .vertical
            break
        case .regular:
            splitDisposition = .horizontal
            break
        case .unspecified:
            splitDisposition = .vertical
        }
        
        shouldAnimateSplitChange = true
        
        // We do some magic to detect bottom safe area to react the the keyboard size change (appearance, disappearance, ecc)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: OperationQueue.main) { [unowned self] (notification) -> Void in
            let initialRect = ((notification as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue
            let _ = self.view.frame.size.height - self.view.convert(initialRect!, from: nil).origin.y
            let keyboardRect = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let newHeight = self.view.frame.size.height - self.view.convert(keyboardRect!, from: nil).origin.y
            
            self.bottomKeyboardHeight = newHeight
        }
    }
    
    fileprivate var didAppearFirstRound = false
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if didAppearFirstRound == false {
            if #available(iOS 11.0, *) {
                firstViewHeightConstraint.constant = (view.bounds.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) / 2.0
            } else {
                firstViewHeightConstraint.constant = (view.bounds.size.height - topLayoutGuide.length - bottomLayoutGuide.length) / 2.0
            }
            didAppearFirstRound = true
        }
    }

    private var panInitialX : CGFloat = 0.0
    private var panInitialY : CGFloat = 0.0
    
    @IBAction private func horizontalPanGestureDidPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            guard let senderView = sender.view else { break }
            if #available(iOS 11.0, *) {
                panInitialX = senderView.frame.origin.x - view.safeAreaInsets.left - view.safeAreaInsets.right + senderView.frame.size.width / 2
            } else {
                panInitialX = senderView.frame.origin.x + senderView.frame.size.width / 2
            }
            horizontalSeparatorWidthConstraint.constant = 2.0
            UIView.animate(withDuration: draggingAnimationDuration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
                self.horizontalSeparatorHair.alpha = 1.0
                self.horizontalHandle.alpha = 1.0
                self.horizontalSeparatorHair.backgroundColor = self.separatorSelectedColor
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
            })
            horizontalHandle.snapped = .none
        case .changed:
            let translation = sender.translation(in: view)
            let finalX = panInitialX + translation.x
            var maximumAllowedWidth : CGFloat = 0.0
            if #available(iOS 11.0, *) {
                maximumAllowedWidth = view.frame.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right
            } else {
                maximumAllowedWidth = view.frame.size.width
            }
            if finalX >= maximumAllowedWidth {
                firstViewWidthConstraint.constant = maximumAllowedWidth
            } else if finalX > 0 {
                firstViewWidthConstraint.constant = finalX
            } else {
                firstViewWidthConstraint.constant = 0
            }
            break
        case .ended:
            var snapped = false
            // If we are near a border, just snap to it
            if #available(iOS 11.0, *) {
                if firstViewWidthConstraint.constant >= (view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right) * 0.95 {
                    firstViewWidthConstraint.constant = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
                    snapped = true
                    horizontalHandle.snapped = .trail
                } else if firstViewWidthConstraint.constant <= (view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right) * 0.05 {
                    firstViewWidthConstraint.constant = 0
                    snapped = true
                    horizontalHandle.snapped = .lead
                }
            } else {
                if firstViewWidthConstraint.constant >= view.bounds.width * 0.95 {
                    firstViewWidthConstraint.constant = view.bounds.width
                    snapped = true
                    horizontalHandle.snapped = .trail
                } else if firstViewWidthConstraint.constant <= view.bounds.width * 0.05 {
                    firstViewWidthConstraint.constant = 0
                    snapped = true
                    horizontalHandle.snapped = .lead
                }
            }
            horizontalSeparatorWidthConstraint.constant = 1.0 / UIScreen.main.scale
            UIView.animate(withDuration: draggingAnimationDuration, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
                if snapped == false {
                    self.horizontalHandle.alpha = 0.0
                } else {
                    self.horizontalSeparatorHair.alpha = 0.0
                }
                self.horizontalSeparatorHair.backgroundColor = self.separatorColor
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            
            break
        default:
            break
        }
    }
    
    @IBAction private func verticalPanGestureDidPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            guard let senderView = sender.view else { break }
            if #available(iOS 11.0, *) {
                panInitialY = senderView.frame.origin.y - view.safeAreaInsets.top - view.safeAreaInsets.bottom + senderView.frame.size.height / 2
            } else {
                panInitialY = senderView.frame.origin.y - topLayoutGuide.length - bottomLayoutGuide.length + senderView.frame.size.height / 2
            }
            verticalSeparatorHeightConstraint.constant = 2.0
            UIView.animate(withDuration: draggingAnimationDuration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
                self.verticalSeparatorHair.alpha = 1.0
                self.verticalHandle.alpha = 1.0
                self.verticalSeparatorHair.backgroundColor = self.separatorSelectedColor
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
            })
            verticalHandle.snapped = .none
        case .changed:
            let translation = sender.translation(in: view)
            let finalY = panInitialY + translation.y
            var maximumAllowedHeight : CGFloat = 0.0
            if #available(iOS 11.0, *) {
                maximumAllowedHeight = view.frame.size.height - view.safeAreaInsets.top - bottomKeyboardHeight
            } else {
                maximumAllowedHeight = view.frame.size.height - topLayoutGuide.length - bottomKeyboardHeight
            }
            if finalY >= maximumAllowedHeight {
                firstViewHeightConstraint.constant = maximumAllowedHeight
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            } else if finalY > 0 {
                firstViewHeightConstraint.constant = finalY
            } else {
                firstViewHeightConstraint.constant = 0
            }
            break
        case .ended:
            var snapped = false
            // If we are near a border, just snap to it
            if #available(iOS 11.0, *) {
                if firstViewHeightConstraint.constant >= (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) * 0.95 {
                    firstViewHeightConstraint.constant = view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
                    snapped = true
                    verticalHandle.snapped = .bottom
                } else if firstViewHeightConstraint.constant <= (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom) * 0.05 {
                    firstViewHeightConstraint.constant = 0
                    snapped = true
                    verticalHandle.snapped = .top
                }
            } else {
                if firstViewHeightConstraint.constant >= (view.bounds.height - topLayoutGuide.length - bottomLayoutGuide.length) * 0.95 {
                    firstViewHeightConstraint.constant = view.bounds.height - topLayoutGuide.length - bottomLayoutGuide.length
                    snapped = true
                    verticalHandle.snapped = .bottom
                } else if firstViewHeightConstraint.constant <= (view.bounds.height - topLayoutGuide.length - bottomLayoutGuide.length) * 0.05 {
                    firstViewHeightConstraint.constant = 0
                    snapped = true
                    verticalHandle.snapped = .top
                }
            }
            verticalSeparatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
            UIView.animate(withDuration: invertAnimationDuration, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
                if snapped == false {
                    self.verticalHandle.alpha = 0.0
                } else {
                    self.verticalSeparatorHair.alpha = 0.0
                }
                self.verticalSeparatorHair.backgroundColor = self.separatorColor
                self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
            })
            break
        default:
            break
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        var currentRatio : CGFloat = 0.0
        if #available(iOS 11.0, *) {
            currentRatio = self.firstViewWidthConstraint.constant / (self.view.bounds.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right)
        } else {
            currentRatio = self.firstViewWidthConstraint.constant / self.view.bounds.size.width
        }
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            var newWidth : CGFloat = 0.0
            if #available(iOS 11.0, *) {
                newWidth = (size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right) * currentRatio
            } else {
                newWidth = size.width * currentRatio
            }
            self.firstViewWidthConstraint.constant = newWidth
        }) { (context) in
            
        }
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            switch newCollection.horizontalSizeClass {
            case .compact:
                self.splitDisposition = .vertical
                break
            case .regular:
                self.splitDisposition = .horizontal
                break
            case .unspecified:
                self.splitDisposition = .vertical
            }
        }) { (context) in
            
        }
    }
}
