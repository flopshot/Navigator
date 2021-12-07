//
//  Created by Sean Najera on 9/3/21.
//
import Combine
import Foundation
import SwiftUI

/// For a View to opt into the Navigation library's system of
/// dynamic navigation, a view mustconform to this protocol
public protocol Navigable: View {

    /// Client app's implementation of a Hashable Screen type
    associatedtype ScreenIdentifier: Hashable

    associatedtype ViewFactoryImpl: ViewFactory

    /// Navigator instance to be initialized in the Navigable View
    var navigator: Navigator<ScreenIdentifier, ViewFactoryImpl> { get }
    
    /// boolean used for the underlying NavigationLink.isActive binding
    var showNextScreen: Bool { get set }
    
    /// The identifier of the current Navigable View screen
    var currentScreen: ScreenIdentifier { get }
}

public extension View {
    
    /// Helper method to bind NavigationBindings modifier to current Navigable View.
    /// Call this method to allow Navigable View to use Navigator property
    @inlinable
    func bindNavigation<NV: Navigable>(
        _ navigable: NV,
        binding showNextScreen: Binding<Bool>
    ) -> ModifiedContent<Self, NavigationBinding<NV.ViewFactoryImpl, NV.ScreenIdentifier>> {
        self
        .modifier(
            NavigationBinding(
                navigation: navigable.navigator,
                currentScreen: navigable.currentScreen,
                showNextScreenBinding: showNextScreen
            )
        )
    }
}
