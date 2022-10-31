//
//  VJLiveActivityWidgetBundle.swift
//  VJLiveActivityWidget
//
//  Created by Ethan on 2022/10/26.
//

import WidgetKit
import SwiftUI
import ActivityKit

@main
struct VJLiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            VJLiveActivityWidget()
        }
    }
}
