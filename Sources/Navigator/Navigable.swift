//
//  Created by Sean Najera on 9/3/21.
//
import Combine
import Foundation
import SwiftUI

protocol Navigable: View {
    associatedtype VF: ViewFactory
    var navigator: Navigator { get }
    var viewFactory: VF { get }
    var showNextScreen: Bool { get set }
    var currentScreen: Screen { get }
}
