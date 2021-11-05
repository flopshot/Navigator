//
//  Navigator.swift
//  Navigator
//
//  Created by Sean Najera on 9/2/21.
//

import Combine
import OrderedCollections
import SwiftUI

protocol Navigation {
    var tab1NavSubjects: OrderedDictionary<Screen, CurrentValueSubject<Bool, Never>> { get }
    
    func nextScreen(from screen: Screen) -> Screen?
    func navigate(to screen: Screen, from screen: Screen)
    func onDismiss(_ screen: Screen)
    func dismissCurrent(_ screen: Screen)
}

class Navigator: ObservableObject, Navigation {
    
    init(rootScreen: Screen) {
        tab1NavSubjects = [rootScreen: Self.makeSubject()]
    }

    var tab1NavSubjects: OrderedDictionary<Screen, CurrentValueSubject<Bool, Never>>
    
    func nextScreen(from screen: Screen) -> Screen? {
        guard let currentScreenIdx = tab1NavSubjects.keys.firstIndex(where: { $0 == screen })
        else { return .none }
        let nextScreenIdx = tab1NavSubjects.keys.index(after: currentScreenIdx)
        return tab1NavSubjects.keys.elements.item(at: nextScreenIdx)
    }
    
    func navigate(to destinationScreen: Screen, from screen: Screen) {
        if tab1NavSubjects.keys.last! == screen {
            tab1NavSubjects[destinationScreen] = Self.makeSubject()
            tab1NavSubjects.first(where: { $0.key == screen})!.value.send(true)
        }
    }
    
    func onDismiss(_ screen: Screen) {
        if screen != tab1NavSubjects.keys.last {
            let parentIdx = tab1NavSubjects.keys.firstIndex(where: { $0 == screen})!
            let childIdx = parentIdx + 1
            tab1NavSubjects.removeSubrange(childIdx..<tab1NavSubjects.keys.endIndex)
        }
    }
    
    func dismissCurrent(_ screen: Screen) {
        let currentIdx = tab1NavSubjects.keys.lastIndex(where: { $0 == screen })!
        if //*let validScreenId = tab1NavSubjects.keys.elements.item(at: currentIdx),*/ // used to remove the screen after dismiss
           let parentScreenId = tab1NavSubjects.keys.elements.item(at: currentIdx - 1) {
            tab1NavSubjects.first(where: { $0.key == parentScreenId })!.value.send(false)
               // will be removed in onDismiss()
               // tab1NavSubjects.removeSubrange(validScreenId..<tab1NavSubjects.keys.endIndex)
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
