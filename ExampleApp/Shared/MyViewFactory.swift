//
//  MyViewFactory.swift
//  ExampleApp
//
//  Created by Sean Najera on 1/2/22.
//

import Foundation
import Navigator
import SwiftUI

class AppViewFactory: ViewFactory {

    @ViewBuilder
    func makeView(screenType: ScreenWrapper<ScreenID>) -> some View {
        switch screenType {
        case .screenWrapper(let screenId):
            switch screenId {
            case .greenScreen:
                GreenScreen(screenId: screenId!)
            case .rootScreen:
                RootScreen(screenId: screenId!)
            case .blueScreen:
                BlueScreen(screenId: screenId!)
            case .none:
                EmptyView()
            }
        }
    }
}

enum ScreenID: Hashable {
    case rootScreen
    case blueScreen(id: UUID = UUID())
    case greenScreen(id: UUID = UUID())
}
