//
//  Created by Sean Najera on 9/6/21.
//

import SwiftUI

/// Connects all Navigation components of a Navigable screen View.
/// Client app Views that conform to Navigable and add this Modifier
/// will then be able to call Navigation methods and programatically
/// navigate between screens of their app, dynamically.
struct NavigationBinding<ViewFactoryImpl: ViewFactory, ScreenIdentifer: Hashable>: ViewModifier {
    let navigation: Navigator<ScreenIdentifer>
    let viewFactory: ViewFactoryImpl
    let currentScreen: ScreenIdentifer
    @Binding var showNextScreenBinding: Bool
    
    func body(content: Content) -> some View {
        // Calculate the next screen of the underlying bound View (if any)
        let nextScreen = navigation.nextScreen(from: currentScreen) as? ViewFactoryImpl.ScreenIdentifer
        content
            #if os(iOS)
            .navigationBarTitle("", displayMode: .large)
            #endif
            .background(
                // This is the hidden NavigationLink of every Navigable bound View
                // which executes the native system View navigation
                NavigationLink(
                    destination: viewFactory.makeView(screen: .screenWrapper(nextScreen)),
                    isActive: $showNextScreenBinding
                ) {
                    EmptyView()
                })
            .onReceive(
                // This relays the Navigation publisher associated with the underlying
                // Navigable screen and updates the View's showNextScreenBinding to
                // either push or pop Views
                navigation.tab1NavSubjects.first(where: { $0.key == currentScreen })!.value,
                perform: { shouldShowNextScreen in
                    showNextScreenBinding = shouldShowNextScreen
                }
            )
            .onChange(of: showNextScreenBinding, perform: { shouldShow in
                // If the user swipes to dismiss or clicks the NavigationBar back
                // button, we will use this callback to update the Nav State in Navigation
                if !shouldShow { navigation.onDismiss(currentScreen) }
            })
    }
}

/// Apply this ViewModifier to the root screen View
/// of your app to be able to cal Navigation methods
struct NavigatorViewBinding: ViewModifier {
    func body(content: Content) -> some View {
        NavigationView { content }
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
    }
}
