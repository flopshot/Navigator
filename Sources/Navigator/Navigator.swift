//
//  Created by Sean Najera on 9/2/21.
//

import Combine
import OrderedCollections
import SwiftUI

@MainActor
public protocol Navigation {
    associatedtype ScreenIdentifer: Hashable
    associatedtype ViewFactoryImpl: ViewFactory

    init(rootScreen: ScreenIdentifer, viewFactory: ViewFactoryImpl)
    
    /// Holds the ordered uniqe set of screens that makes up the Navigation State of the client app,
    /// along with its associated Boolean subject, which toggles the NavigationLink.isActive
    var navStack: OrderedDictionary<ScreenIdentifer, CurrentValueSubject<Bool, Never>> { get }
    
    /// Pushes to the next ScreenView, on the NavigationView
    func navigate(to screen: ScreenIdentifer)

    /// Adds ScreenViews to the the NavigationView stack, with the final
    /// ScreenIdentifier denoting the top most visible ScreenView
    func navigateWith(stack: ScreenIdentifer...) async
    
    /// Called when the current ScreenView is about to be dismissed
    /// used to update nav state.
    func onDismiss(_ screen: ScreenIdentifer)
    
    /// Triggers dismissal of the current ScreenView. Client app
    /// will call this to immediately pop the ScreenView
    func pop()

    /// pops all views off the navigation statck to the root view with animation
    func popToRoot()
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
        viewFactory.makeView(screenType: .screenWrapper(nextScreen))
    }
    
    public func navigate(to destinationScreen: ScreenIdentifer) {
        addScreenBindingAndToggleTrue(destinationScreen)
    }
    
    public func onDismiss(_ screen: ScreenIdentifer) {
        updateNavStateOnDismiss(screen)
    }
    
    public func pop() {
        toggleNavigationLinkBindingFalse()
    }

    public func popToRoot() {
        toggleRootScreenViewNavigationLinkBindingFalse()
    }

    public func navigateWith(stack: ScreenIdentifer...) async {
        for (idx, screen) in stack.enumerated() {
            navigate(to: screen)

            if idx < stack.count - 1 {
                try! await Task.sleep(nanoseconds: 700_000_000)
            }
        }
    }
}

private extension Navigator {
    
    /// Once the bound NavigationLink.isActive is set to true, this method dynamically calculates
    /// the next ScreenView using the ViewFactory to map the next ScreenView in the nav state to its View
    func calculateNextScreen(from screen: ScreenIdentifer) -> ScreenIdentifer? {
        guard let currentScreenIdx = navStack.keys.firstIndex(where: { $0 == screen })
        else { return .none }
        let nextScreenIdx = navStack.keys.index(after: currentScreenIdx)
        return navStack.keys.elements.item(at: nextScreenIdx)
    }
    
    /// Whether the ScreenView is dismissed by the library bindings or via external logic (swipe to go back/back button)
    /// we remove the ScreenView from the ordered disctionary in order to mainain the current nav state
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

    /// Send the false flag to the root ScreenView's NavigationLink.isActive navigation binding
    /// in order to dismiss all views in the navigation stack back to the root ScreenView
    func toggleRootScreenViewNavigationLinkBindingFalse() {
        navStack.elements[0].value.send(false)
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
