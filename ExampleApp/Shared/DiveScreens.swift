//
//  DiveScreens.swift
//  ExampleApp
//
//  Created by Sean Najera on 1/2/22.
//

import SwiftUI
import Navigator

struct GreenScreen: ScreenView {

    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>
    @State var showNextScreen: Bool = false
    var currentScreen: Screens

    var body: some View {

        let nextButton = Button("Next") {
            navigator.navigate(to: randomScreen())
        }

        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, *) {
            nextButton
                .tint(.green)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.automatic)
                #if os(macOS) || os(iOS)
                .controlSize(.large)
                #endif
                .navigationTitle("Green Screen")
                .bindNavigation(self, binding: $showNextScreen)
        } else {
            nextButton
                .navigationTitle("Green Screen")
                .bindNavigation(self, binding: $showNextScreen)
        }
    }
}

struct BlueScreen: ScreenView {

    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>
    @State var showNextScreen: Bool = false
    var currentScreen: Screens

    var body: some View {

        let nextButton = Button("Next") {
            navigator.navigate(to: randomScreen())
        }

        let dismissButton = Button("Dismiss") {
            navigator.pop()
        }

        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, *) {
            VStack(spacing: 32) {
                nextButton
                    .tint(.blue)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.automatic)
                    #if os(macOS) || os(iOS)
                    .controlSize(.large)
                    #endif


                dismissButton
                    .tint(.blue)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.automatic)
                    #if os(macOS) || os(iOS)
                    .controlSize(.large)
                    #endif
            }
            .navigationTitle("Blue Screen")
            .bindNavigation(self, binding: $showNextScreen)
        } else {
            VStack(spacing: 32) {
                nextButton

                dismissButton
            }
            .navigationTitle("Blue Screen")
            .bindNavigation(self, binding: $showNextScreen)
        }
    }
}

#if DEBUG
struct BlueScreen_Preview: PreviewProvider {
    static var previews: some View {

        let blueScreen = Screens.blueScreen()

        BlueScreen(
            currentScreen: blueScreen)
            .environmentObject(
                Navigator(
                    rootScreen: blueScreen,
                    viewFactory: MyViewFactory()
                )
            )
    }
}
#endif

#if DEBUG
struct GreenScreen_Preview: PreviewProvider {
    static var previews: some View {

        let greenScreen = Screens.greenScreen()

        GreenScreen(currentScreen: greenScreen)
            .environmentObject(
                Navigator(
                    rootScreen: greenScreen,
                    viewFactory: MyViewFactory()
                )
            )
    }
}
#endif
