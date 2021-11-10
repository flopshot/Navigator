# Navigator

A navigation library that decouples Navigation logic in
SwiftUI from the View and allows you to dynamically 
navigate to other Views programatically in your app.

```swift
struct DetailScreen: Navigable {
    @EnvironmentObject var navigator: Navigator<Screen>
    @EnvironmentObject var viewFactory: MyViewFactory
    
    @State var showNextScreen: Bool = false
    
    var currentScreen: Screen
    
    var body: some View {
        Button("Next") {
            navigator.navigate(to: anotherScreen(), from: currentScreen)
        }
        .navigationTitle("Detail Screen")
        .modifier(
            NavigationBinding(
                navigation: navigator,
                viewFactory: viewFactory,
                currentScreen: currentScreen,
                showNextScreenBinding: $showNextScreen
            )
        )
    }
}
```
