//
//  ExampleAppApp.swift
//  Shared
//
//  Created by Sean Najera on 1/2/22.
//

// NOTE: THE macOS TARGET IS IN THE EARLY EXPERIMENTAL STAGE AND IS NOT YET READY FOR USE

import SwiftUI
import Navigator
#if os(iOS)
import AsyncCompatibilityKit
#endif

@main
struct NavigatorDemoApp: App {

    var body: some Scene {
        WindowGroup {

            let navigator = Navigator(rootScreen: Screens.rootScreen, viewFactory: MyViewFactory())

            RootScreen(currentScreen: .rootScreen)
                .modifier(NavigatorViewBinding())
                .accentColor(.black)
                .navigationViewStyle(.stack)
                .environmentObject(navigator)
                #if os(iOS)
                .task {

                    // Uncomment to test programatic view dismissal
                    // await delay(5)
                    // navigator.popToFirstGreenScreenOrRoot(id: UUID(uuidString: "d59bb9c3-f026-4890-b612-2dfa78bf6402")!)

                    // Uncomment to test programatic stack building
                     await navigator.navigateWith(stack: .blueScreen(), .greenScreen(), .blueScreen())
                }
                #endif
        }
    }
}


