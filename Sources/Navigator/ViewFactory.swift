//
//  Created by Sean Najera on 9/6/21.
//

import SwiftUI

/// Defines the contract that a client app will conform to in order
/// to dynamically create SwiftUI views via screen lookup
public protocol ViewFactory {
    associatedtype CreatedView: View
    associatedtype ScreenIdentifer: Hashable
    
    /// Client app's concrete conformance of this method will map the ScreenType
    /// enum defined by the client app to it's associated SwiftUI View
    @ViewBuilder func makeView(screen: ScreenWrapper<ScreenIdentifer>) -> Self.CreatedView
}

/// Used to wrap the client app's own defined enum
public enum ScreenWrapper<T: Hashable>: Hashable {
    case screenWrapper(T?)
}
