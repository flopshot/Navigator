//
//  NavigationView+Ext.swift
//  
//
//  Created by Sean Najera on 2/20/22.
//

import SwiftUI

public extension NavigationView {

    /// Initializes the NavigationView with the instance of Navigator added into the
    /// environment as an object. The root content should return a ScreenView.
    /// All views pushed onto the NavigationView will receive the same Navigator
    /// insatnce used to dynamically navigate between screens.
    @ViewBuilder
    static func with<ScreenID: Hashable, VF: ViewFactory>(
        _ navigator: Navigator<ScreenID, VF>,
        @ViewBuilder _ root: () -> Content
    ) -> some View {
        NavigationView {
            root()
        }
        .environmentObject(navigator)
    }
}
