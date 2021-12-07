//
//  Created by Sean Najera on 9/2/21.
//

import Combine
import OrderedCollections
import SwiftUI

public protocol Navigation {
    associatedtype ScreenIdentifer: Hashable
    associatedtype ViewFactoryImpl: ViewFactory

    init(rootScreen: ScreenIdentifer, viewFactory: ViewFactoryImpl)
    
    /// Holds the ordered uniqe set of screens that makes up the Navigation State of the client app,
    /// along with its associated Boolean subject, which toggles the NavigationLink.isActive
    var navStack: OrderedDictionary<ScreenIdentifer, CurrentValueSubject<Bool, Never>> { get }
    
    /// Triggers navigation to the next screen. Client app will call this to
    /// immediately navigate to the next screen from the current screen
    func navigate(to screen: ScreenIdentifer)
    
    /// Called when the current screen is about to be dismissed
    /// used to update nav state
    func onDismiss(_ screen: ScreenIdentifer)
    
    /// Triggers dismissal of the current screen. Client app
    /// will call this to immediately pop the screen
    func dismissCurrent()
}

public class Navigator<ScreenIdentifer: Hashable, ViewFactoryImpl: ViewFactory>: ObservableObject, Navigation {

    public var navStack: OrderedDictionary<ScreenIdentifer, CurrentValueSubject<Bool, Never>>

    required public init(rootScreen: ScreenIdentifer, viewFactory: ViewFactoryImpl) {
        navStack = [rootScreen: Self.makeSubject()]
        self.viewFactory = viewFactory
    }

    let viewFactory: ViewFactoryImpl

    @ViewBuilder
    func nextView(from screen: ScreenIdentifer) -> some View {
        let nextScreen = calculateNextScreen(from: screen) as? ViewFactoryImpl.ScreenIdentifer
        viewFactory.makeView(screen: .screenWrapper(nextScreen))
    }
    
    public func navigate(to destinationScreen: ScreenIdentifer) {
        addScreenBindingAndToggleTrue(destinationScreen)
    }
    
    public func onDismiss(_ screen: ScreenIdentifer) {
        updateNavStateOnDismiss(screen)
    }
    
    public func dismissCurrent() {
        toggleNavigationLinkBindingFalse()
    }
}

private extension Navigator {
    
    /// Once the bound NavigationLink.isActive is set to true, this method dynamically calculates
    /// the next screen using the ViewFactory to map the next screen in the nav state to its View
    func calculateNextScreen(from screen: ScreenIdentifer) -> ScreenIdentifer? {
        guard let currentScreenIdx = navStack.keys.firstIndex(where: { $0 == screen })
        else { return .none }
        let nextScreenIdx = navStack.keys.index(after: currentScreenIdx)
        return navStack.keys.elements.item(at: nextScreenIdx)
    }
    
    /// Whether the screen is dismissed by the library bindings or via external logic (swipe to go back/back button)
    /// we remove the screen from the ordered disctionary in order to mainain the current nav state
    func updateNavStateOnDismiss(_ screen: ScreenIdentifer) {
        if screen != navStack.keys.last {
            let parentIdx = navStack.keys.firstIndex(where: { $0 == screen})!
            let childIdx = parentIdx + 1
            navStack.removeSubrange(childIdx..<navStack.keys.endIndex)
        }
    }
    
    /// Adds a new screen to the nav state OrderedDictionary and pairs it with a Boolean combine subject
    /// then immediately sends true in order to toggle the NavigationLink.isActive to true and show the view
    func addScreenBindingAndToggleTrue(_ destinationScreen: ScreenIdentifer) {
        let currentScreen = navStack.keys.last
        navStack[destinationScreen] = Self.makeSubject()
        navStack.first(where: { $0.key == currentScreen })!.value.send(true)
    }
    
    /// Find the current screen and associated Boolean combine subject in the nav state OrderedDictionary
    /// and send false in order to toggle the NavigationLink.isActive to false and dismiss the view
    func toggleNavigationLinkBindingFalse() {
        if let parentScreenId = navStack.keys.elements.item(at: navStack.keys.count - 2) {
            navStack.first(where: { $0.key == parentScreenId })!.value.send(false)
        }
    }
}

private extension Navigator {
    static func makeSubject() -> CurrentValueSubject<Bool, Never> {
        CurrentValueSubject<Bool, Never>(false)
    }
}

fileprivate extension Array {
    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
