//
//  InstantPanGestureRecognizer.swift
//  SplitKit
//
//  Created by Matteo Gavagnin on 07/09/2017.
//  Copyright © 2017 Dolomate.
//  See LICENSE file for more details.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

internal class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizerState.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began
    }
}
