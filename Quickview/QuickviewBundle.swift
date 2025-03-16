//
//  QuickviewBundle.swift
//  Quickview
//
//  Created by Jack Kroll on 3/10/25.
//

import WidgetKit
import SwiftUI

@main
struct QuickviewBundle: WidgetBundle {
    var body: some Widget {
        Quickview()
        QuickviewControl()
        QuickviewLiveActivity()
    }
}
