//
//  ExampleAppApp.swift
//  Shared
//
//  Created by Sean Najera on 1/2/22.
//

// NOTE: THE macOS TARGET IS IN THE EARLY EXPERIMENTAL STAGE AND IS NOT YET READY FOR USE

import SwiftUI
import Navigator

@main
struct NavigatorDemoApp: App {

    var body: some Scene {
        WindowGroup {

            let navigator = Navigator(rootScreen: Screens.rootScreen, viewFactory: MyViewFactory())

            let rootView = RootScreen(currentScreen: .rootScreen)
                .modifier(NavigatorViewBinding())
                .environmentObject(navigator)

            if #available(macOS 12.0, iOS 15.0, *) {
                rootView
                    .task {
                        await delay(8)
                        navigator.popToFirstGreenScreenOrRoot(id: UUID(uuidString: "d59bb9c3-f026-4890-b612-2dfa78bf6402")!)
                    }
            } else {
                rootView
                    .onLoad {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                            navigator.popToFirstGreenScreenOrRoot(id: UUID(uuidString: "d59bb9c3-f026-4890-b612-2dfa78bf6402")!)
                        }
                    }
            }
        }
    }
}
