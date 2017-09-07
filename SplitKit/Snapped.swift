//
//  Snapped.swift
//  SplitKit
//
//  Created by Matteo Gavagnin on 07/09/2017.
//  Copyright © 2017 Dolomate.
//  See LICENSE file for more details.
//

import Foundation

@objc(SPKSnapped)
public enum Snapped: Int {
    case none = 0
    case lead = 1
    case trail = 2
    case top = 3
    case bottom = 4
}
