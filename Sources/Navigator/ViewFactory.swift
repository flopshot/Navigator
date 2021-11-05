//
//  Created by Sean Najera on 9/6/21.
//

import SwiftUI

protocol ViewFactory {
    associatedtype CreatedView : View
    
    @ViewBuilder
    func makeView(screen: Screen?) -> Self.CreatedView
}
