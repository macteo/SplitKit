//
//  Arrangement.swift
//  SplitKit
//
//  Created by Matteo Gavagnin on 07/09/2017.
//  Copyright © 2017 Dolomate.
//  See LICENSE file for more details.
//

import Foundation

/// Split controller arrangement
///
/// - horizontal: two controllers will be arranged side by side, first one on the leading side
/// - vertical: two controllers will be arranged one on top of the other, first on top
@objc(SPKArrangement)
public enum Arrangement: Int {
    case horizontal = 0
    case vertical = 1
}
