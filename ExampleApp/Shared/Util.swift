//
//  Util.swift
//  ExampleApp
//
//  Created by Sean Najera on 1/2/22.
//

import Foundation
import SwiftUI
import Navigator

public func delay(_ seconds: Double) async {
    try! await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
}

func randomScreen() -> Screens {
    let randomFlag = Int.random(in: 0...1)
    switch randomFlag {
    case 0: return Screens.greenScreen()
    case 1: return Screens.blueScreen()
    default: fatalError()
    }
}

extension Navigator where ScreenIdentifer == Screens {
    func popToFirstGreenScreenOrRoot(id: UUID) {
        if let greenScreen: Screens = navStack.keys.elements.first(where: {
            if case Screens.greenScreen(let detailID) = $0 { return detailID == id }
            return false
        }) {
            navStack[greenScreen]!.send(false)
        } else {
            navStack.elements[0].value.send(false)
            // or self.popToRoot()
        }
    }
}

/// https://stackoverflow.com/a/64495887/7238475
struct ViewDidLoadModifier: ViewModifier {

    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }

}

extension View {

    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }

}
