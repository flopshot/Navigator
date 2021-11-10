//
//  Created by Sean Najera on 9/3/21.
//
import Combine
import Foundation
import SwiftUI

/// For a View to opt into the Navigation library's system of
/// dynamic navigation, a view mustconform to this protocol
protocol Navigable: View {
    /// Client app's implementation of ViewFactory
    associatedtype VF: ViewFactory

    /// Client app's implementation of a Hashable Screen type
    associatedtype ScreenIdentifer: Hashable

    /// Navigator instance to be initialized in the Navigable View
    var navigator: Navigator<ScreenIdentifer> { get }
    
    /// ViewFactory implementation instance to be initialized in the Navigable View
    var viewFactory: VF { get }
    
    /// boolean used for the underlying NavigationLink.isActive binding
    var showNextScreen: Bool { get set }
    
    /// The identifier of the current Navigable View screen
    var currentScreen: ScreenIdentifer { get }
}
