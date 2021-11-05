//
//  NavigationBinding.swift
//  Navigator
//
//  Created by Sean Najera on 9/6/21.
//

import SwiftUI

struct NavigationBinding<ViewFactoryImpl: ViewFactory>: ViewModifier {
    let navigation: Navigation
    let viewFactory: ViewFactoryImpl
    let currentScreen: Screen
    @Binding var showNextScreenBinding: Bool
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitle("", displayMode: .large)
            .background(
                NavigationLink(destination: viewFactory.makeView(screen: navigation.nextScreen(from: currentScreen)),
                               isActive: $showNextScreenBinding) {
                    EmptyView()
                })
            .onReceive(
                navigation.tab1NavSubjects.first(where: { $0.key == currentScreen })!.value,
                perform: { shouldShowNextScreen in
                    showNextScreenBinding = shouldShowNextScreen
                }
            )
            .onChange(of: showNextScreenBinding, perform: { shouldShow in
                if !shouldShow { navigation.onDismiss(currentScreen) }
            })
    }
}

struct NavigatorViewBinding: ViewModifier {
    func body(content: Content) -> some View {
        NavigationView { content }
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
    }
}
