//
//  Created by Sean Najera on 9/3/21.
//
import Combine
import Foundation
import SwiftUI

/// For a View to opt into the Navigation library's
/// dynamic navigation, a view mustconform to this protocol
public protocol ScreenView: View {

    /// Client app's implementation of a Hashable Screen type
    associatedtype ScreenIdentifier: Hashable

    /// Client app's implementation of a a ViewFactory
    associatedtype ViewFactoryImpl: ViewFactory

    /// Navigator instance to be initialized in the Screen. Typicallly via a EnvironmentObject
    var navigator: Navigator<ScreenIdentifier, ViewFactoryImpl> { get }
    
    /// boolean used for the underlying NavigationLink.isActive binding
    var showNextScreen: Bool { get set }
    
    /// The identifier of the current Screen View. To be used to identify the View in
    /// the library's navigation statck
    var currentScreen: ScreenIdentifier { get }
}

public extension View {

    /// Helper method to bind NavigationBindings modifier to current Screen View.
    /// Call this method to allow Screen View to use Navigator property
    @inlinable
    func bindNavigation<NV: ScreenView>(
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
