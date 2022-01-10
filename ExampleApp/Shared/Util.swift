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

public struct ButtonColoring: ViewModifier {

    let color: Color

    public init(color: Color) {
        self.color = color
    }

    public func body(content: Content) -> some View {
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, *) {
            content
                .tint(color)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.automatic)
                #if os(macOS) || os(iOS)
                .controlSize(.large)
                #endif
        } else {
            content
                .foregroundColor(color)
        }
    }
}

public extension View {

    @inlinable
    func buttonStyling(color: Color) -> some View {
        modifier(ButtonColoring(color: color))
    }
}
