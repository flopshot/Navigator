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
        Color.green
        .ignoresSafeArea()
        .overlay(
            ScrollView {
                VStack(spacing: 32) {
                    Button("To Blue Screen") {
                        navigator.navigate(to: .blueScreen())
                    }
                    .buttonStyling(color: .blue)

                    Button("To Green Screen") {
                        navigator.navigate(to: .greenScreen())
                    }
                    .buttonStyling(color: .green)

                    Button("To a Random Screen") {
                        navigator.navigate(to: randomScreen())
                    }
                    .buttonStyling(color: .purple)

                    Button("Pop To Root") {
                        navigator.popToRoot()
                    }
                    .buttonStyling(color: .red)
                }
                .padding()
                .background(Color.white)
            }
        )
        .navigationTitle("Green Screen")
        .bindNavigation(self, binding: $showNextScreen)
    }
}

struct BlueScreen: ScreenView {

    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>
    @State var showNextScreen: Bool = false
    var currentScreen: Screens

    var body: some View {

        Color.blue
        .ignoresSafeArea()
        .overlay(
            ScrollView {
                VStack(spacing: 32) {
                    Button("To Blue Screen") {
                        navigator.navigate(to: .blueScreen())
                    }
                    .buttonStyling(color: .blue)

                    Button("To Green Screen") {
                        navigator.navigate(to: .greenScreen())
                    }
                    .buttonStyling(color: .green)

                    Button("To a Random Screen") {
                        navigator.navigate(to: randomScreen())
                    }
                    .buttonStyling(color: .purple)

                    Button("Pop") {
                        navigator.pop()
                    }
                    .buttonStyling(color: .red)
                }
                .padding()
                .background(Color.white)
            }
        )
        .navigationTitle("Blue Screen")
        .bindNavigation(self, binding: $showNextScreen)
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
