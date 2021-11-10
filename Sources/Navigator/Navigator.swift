//
//  Created by Sean Najera on 9/2/21.
//

import Combine
import OrderedCollections
import SwiftUI

protocol Navigation {
    associatedtype ScreenIdentifer: Hashable
    
    /// Holds the ordered uniqe set of screens that makes up the Navigation State of the client app,
    /// along with its associated Boolean subject, which toggles the NavigationLink.isActive
    var tab1NavSubjects: OrderedDictionary<ScreenIdentifer, CurrentValueSubject<Bool, Never>> { get }
    
    /// Internally calculates the next screen given the current nav state
    /// when the next screen is to be presented
    func nextScreen(from screen: ScreenIdentifer) -> ScreenIdentifer?
    
    /// Triggers navigation to the next screen. Client app will call this to
    /// immediately navigate to the next screen from the current one
    func navigate(to screen: ScreenIdentifer, from screen: ScreenIdentifer)
    
    /// Called when the current screen is about to be dismissed
    /// used to update nav state
    func onDismiss(_ screen: ScreenIdentifer)
    
    /// Triggers dismissal of the current screen. Client app
    ///  will call this to immediately pop the screen
    func dismissCurrent(_ screen: ScreenIdentifer)
}

class Navigator<ScreenIdentifer: Hashable>: ObservableObject, Navigation {
    
    init(rootScreen: ScreenIdentifer) {
        tab1NavSubjects = [rootScreen: Self.makeSubject()]
    }

    var tab1NavSubjects: OrderedDictionary<ScreenIdentifer, CurrentValueSubject<Bool, Never>>
    
    func nextScreen(from screen: ScreenIdentifer) -> ScreenIdentifer? {
        calculateNextScreen(from: screen)
    }
    
    func navigate(to destinationScreen: ScreenIdentifer, from screen: ScreenIdentifer) {
        addScreenBindingAndToggleTrue(destinationScreen, from: screen)
    }
    
    func onDismiss(_ screen: ScreenIdentifer) {
        updateNavStateOnDismiss(screen)
    }
    
    func dismissCurrent(_ screen: ScreenIdentifer) {
        toggleNavigationLinkBindingFalse(screen)
    }
}

private extension Navigator {
    
    /// Once the bound NavigationLink.isActive is set to true, this method dynamically calculates
    /// the next screen using the ViewFactory to map the next screen in the nav state to its View
    func calculateNextScreen(from screen: ScreenIdentifer) -> ScreenIdentifer? {
        guard let currentScreenIdx = tab1NavSubjects.keys.firstIndex(where: { $0 == screen })
        else { return .none }
        let nextScreenIdx = tab1NavSubjects.keys.index(after: currentScreenIdx)
        return tab1NavSubjects.keys.elements.item(at: nextScreenIdx)
    }
    
    /// Whether the screen is dismissed by the library bindings or via external logic (swipe to go back/back button)
    /// we remove the screen from the ordered disctionary in order to mainain the current nav state
    func updateNavStateOnDismiss(_ screen: ScreenIdentifer) {
        if screen != tab1NavSubjects.keys.last {
            let parentIdx = tab1NavSubjects.keys.firstIndex(where: { $0 == screen})!
            let childIdx = parentIdx + 1
            tab1NavSubjects.removeSubrange(childIdx..<tab1NavSubjects.keys.endIndex)
        }
    }
    
    /// Adds a new screen to the nav state OrderedDictionary and pairs it with a Boolean combine subject
    /// then immediately sends true in order to toggle the NavigationLink.isActive to true and show the view
    func addScreenBindingAndToggleTrue(_ destinationScreen: ScreenIdentifer, from screen: ScreenIdentifer) {
        if tab1NavSubjects.keys.last! == screen {
            tab1NavSubjects[destinationScreen] = Self.makeSubject()
            tab1NavSubjects.first(where: { $0.key == screen})!.value.send(true)
        }
    }
    
    /// Find the current screen and associated Boolean combine subject in the nav state OrderedDictionary
    /// and send false in order to toggle the NavigationLink.isActive to false and dismiss the view
    func toggleNavigationLinkBindingFalse(_ screen: ScreenIdentifer) {
        let currentIdx = tab1NavSubjects.keys.lastIndex(where: { $0 == screen })!
        if let parentScreenId = tab1NavSubjects.keys.elements.item(at: currentIdx - 1) {
            tab1NavSubjects.first(where: { $0.key == parentScreenId })!.value.send(false)
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
