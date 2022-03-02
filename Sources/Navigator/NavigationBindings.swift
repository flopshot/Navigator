//
//  Created by Sean Najera on 9/6/21.
//

import SwiftUI

/// Connects all Navigation components of a ScreenView.
/// Client app Views that conform to ScreenView and add this Modifier
/// will then be able to call Navigation methods and programatically
/// navigate between ScreenViews of their app, dynamically.
public struct NavigationBinding<ViewFactoryImpl: ViewFactory, ScreenIdentifer: Hashable>: ViewModifier {
    let navigation: Navigator<ScreenIdentifer, ViewFactoryImpl>
    let screenId: ScreenIdentifer
    var showNextScreenBinding: Binding<Bool>
    
    public init(
        navigation: Navigator<ScreenIdentifer, ViewFactoryImpl>,
        screenId: ScreenIdentifer,
        showNextScreenBinding: Binding<Bool>
    ) {
        self.navigation = navigation
        self.screenId = screenId
        self.showNextScreenBinding = showNextScreenBinding
    }
    
    public func body(content: Content) -> some View {
        content
            #if os(iOS)
            .navigationBarTitle("", displayMode: .large)
            #endif
            .background(
                // This is the hidden NavigationLink of every bound ScreenView
                // which delegates navigation to the native SwiftUI View navigation
                NavigationLink(
                    destination: navigation.nextView(from: screenId),
                    isActive: showNextScreenBinding
                ) {
                    EmptyView()
                }.hidden())
            .onReceive(
                // This relays the Navigation publisher associated with the underlying
                // ScreenView and updates the View's showNextScreenBinding to
                // either push or pop Views
                navigation.navStack.first(where: { $0.key == screenId })!.value,
                perform: { shouldShowNextScreen in
                    showNextScreenBinding.wrappedValue = shouldShowNextScreen
                }
            )
            .onChange(of: showNextScreenBinding.wrappedValue, perform: { shouldShow in
                // If the user swipes to dismiss or clicks the NavigationBar back
                // button, this callback will update the Nav State in Navigation
                if !shouldShow { navigation.onDismiss(screenId) }
            })
    }
}
