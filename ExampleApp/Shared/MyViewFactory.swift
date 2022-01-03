//
//  MyViewFactory.swift
//  ExampleApp
//
//  Created by Sean Najera on 1/2/22.
//

import Foundation
import Navigator
import SwiftUI

class MyViewFactory: ViewFactory {

    @ViewBuilder
    func makeView(screenType: ScreenWrapper<Screens>) -> some View {
        switch screenType {
        case .screenWrapper(let myScreen):
            switch myScreen {
            case .greenScreen:
                GreenScreen(currentScreen: myScreen!)
            case .rootScreen:
                RootScreen(currentScreen: myScreen!)
            case .blueScreen:
                BlueScreen(currentScreen: myScreen!)
            case .none:
                EmptyView()
            }
        }
    }
}

enum Screens: Hashable {
    case rootScreen
    case blueScreen(id: UUID = UUID())
    case greenScreen(id: UUID = UUID())
}
