//
//  Created by Sean Najera on 9/3/21.
//
import Combine
import Foundation
import SwiftUI

/// For a View to opt into the Navigation library's system of
/// dynamic navigation, a view mustconform to this protocol
public protocol Navigable: View {
    /// Client app's implementation of ViewFactory
    associatedtype VF: ViewFactory

    /// Client app's implementation of a Hashable Screen type
    associatedtype ScreenIdentifer: Hashable

    /// Navigator instance to be initialized in the Navigable View
    var navigator: Navigator<ScreenIdentifer> { get }
    
    /// ViewFactory implementation instance to be initialized in the Navigable View
    var viewFactory: VF { get }
    
    /// boolean used for the underlying NavigationLink.isActive binding
    var showNextScreen: Binding<Bool> { get }
    
    /// The identifier of the current Navigable View screen
    var currentScreen: ScreenIdentifer { get }
    
    var showNextScreenSubject: CurrentValueSubject<Bool, Never> { get }
}

public extension View {
    @inlinable
    func bindNavigation<NV: Navigable>(_ navigable: NV) -> ModifiedContent<Self, NavigationBinding<NV.VF, NV.ScreenIdentifer>> {
        self
        .modifier(
            NavigationBinding(
                navigation: navigable.navigator,
                viewFactory: navigable.viewFactory,
                currentScreen: navigable.currentScreen,
                showNextScreenBinding: navigable.showNextScreen
            )
        )
    }
}

public extension Navigable {
    var showNextScreenSubject: CurrentValueSubject<Bool, Never> {
        CurrentValueSubject(false)
    }
    
    var showNextScreen: Binding<Bool> {
        Binding<Bool>(get: {showNextScreenSubject.value}, set: {showNextScreenSubject.send($0)})
    }
}
//
//struct RootScreen: Navigable {
//    @EnvironmentObject var navigator: Navigator<MyScreen>
//    @EnvironmentObject var viewFactory: MyViewFactory
//    var currentScreen: MyScreen
//
//    @State var showingAlert: Bool = false
//
//    var body: some View {
//        List {
//            Button("Next") {
////                navigator.navigate(to: randomScreen(), from: currentScreen)
//
//            }
//        }
//        .navigationTitle("Root Screen")
//        .bindNavigation(self)
//    }
//}
//
//
//class MyViewFactory: ViewFactory, ObservableObject {
//
//    @ViewBuilder
//    func makeView(screen: ScreenWrapper<MyScreen>) -> some View {
//        switch screen {
//        case .screenWrapper(let myScreen):
//            switch myScreen {
//            case .rootScreen:
//                RootScreen(currentScreen: myScreen!)
//            case .none:
//                EmptyView()
//            }
//        }
//    }
//}
//
//enum MyScreen: Hashable {
//    case rootScreen(id: UUID = UUID())
//}
