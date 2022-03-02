//
//  ContentView.swift
//  Shared
//
//  Created by Sean Najera on 1/2/22.
//

import SwiftUI
import Navigator

struct RootScreen: ScreenView {

    @EnvironmentObject var navigator: Navigator<ScreenID, AppViewFactory>
    @State var showNextScreen: Bool = false
    var screenId: ScreenID

    var body: some View {
        List {
            Button("Blue Screen") {
                navigator.navigate(to: .blueScreen())
            }
            .foregroundColor(.blue)

            Button("Green Screen") {
                navigator.navigate(to: .greenScreen())
            }
            .foregroundColor(.green)
        }
        .navigationTitle("Root Screen")
        .bindNavigation(self, binding: $showNextScreen)
    }
}

struct RootView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RootScreen(screenId: .rootScreen)
                .environmentObject(
                    Navigator(
                        rootScreen: ScreenID.rootScreen,
                        viewFactory: AppViewFactory()
                    )
                )
        }
    }
}
