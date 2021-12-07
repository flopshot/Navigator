# Navigator

A navigation library that decouples Navigation logic in
SwiftUI from the View and allows you to dynamically 
navigate to other Views programatically in your app.

```swift
struct DetailScreen: Navigable {
    @EnvironmentObject var navigator: Navigator<Screen>    
    @State var showNextScreen: Bool = false
    var currentScreen: Screen
    
    var body: some View {
        Button("Next") {
            navigator.navigate(to: anotherScreen())
        }
        .navigationTitle("Detail Screen")
        .bindNavigation(self, binding: $showNextScreen)
    }
}
```

## Setup

### 1. Create a ViewFactory

Create an enum that that maps to the screens in your app
along with any needed values. Ensure that it conforms
to `Hashable`

```swift
enum Screens: Hashable {
    case rootScreen
    case detailScreen(detailID: String)
}
```

Then create a class that conforms to `ViewFactory` and 
implement `makeView(screen:)` so that the given `Screens`
enum returns the associated `View`. Ensure it conforms
to `ObservedObject` for `EnvironmentObject` dependency 
injection

```swift 
class MyViewFactory: ViewFactory, ObservableObject {
    
    @ViewBuilder
    func makeView(screen: ScreenWrapper<Screens>) -> some View {
        switch screen {
        case .screenWrapper(let myScreen):
            switch myScreen {
            case .rootScreen:
                RootScreen()
            case .detailScreen:
                DetailScreen(currentScreen: myScreen!)
            case .none:
            // EmptyView is fine in the exhaustive case
            // as this is just a placeholder until the 
            // Navigation state is instantiated. The
            // app will never need to navigate to this
                EmptyView()
            }
        }
    }
}
```

### 2. Initialize Library

In the `@main` app delcaration, where your root view
is the top level view in the navigation stack, inject
into the environment the necessary `Navigator` classes
and add the `NavigatorViewBinding` view modifier

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootScreen()
                .modifier(NavigatorViewBinding())
                .environmentObject(Navigator(rootScreen: Screens.rootScreen, viewFactory: MyViewFactory())
        }
    }
}
```

### 3. Conform app screens to Navigable

For each top level view, conform them to `Navigable`
and apply the `bindNavigation(_:binding:)` view modifier

```swift
struct RootScreen: Navigable {
    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>    
    @State var showNextScreen: Bool = false
    var currentScreen = .rootScreen
    
    var body: some View {
        List {
            Button("Navigate to Deatil Screen") {
                // TODO
            }
        }
        .navigationTitle("Root Screen")
        .bindNavigation(self, binding: $showNextScreen)
    }
}
``` 

```swift
struct DetailScreen: Navigable {
    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>  
    @State var showNextScreen: Bool = false
    var currentScreen: Screens
    
    var body: some View {
        VStack {
            Text("Here is some amazing detail.")
            
            Button("Go Back") {
                // TODO
            }
            .tint(.red)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.automatic)
            .controlSize(.large)
        }
        .navigationTitle("Detail Screen")
        .bindNavigation(self, binding: $showNextScreen)
    }
}
```

Note that except for the `RootScreen` all other screens 
should have an `id` in their `Screens` enum value in order
to differentiate same screens in the navigation stack. This
can be in the form of a business logic id `detailID` or some
deafult id that has no business logic but merely used to id
the screen

```swift
enum Screens: Hashable {
    // ...
    case anotherScreen(id: UUID = UUID())
}
```

### 4. Use the Navigator instance for navigation

Now that all the setup is done, we can use the `Navigator`
instance in the `Navigable` View to execute system level
View navigation

```swift
struct RootScreen: Navigable {
    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>
    @State var showNextScreen: Bool = false
    var currentScreen = .rootScreen
    
    var body: some View {
        List {
            Button("Navigate to Deatil Screen") {
                // Use navigate(to:) to navigate to another screen
                
                // This can be anywhere at the view level
                
                // This can also be called at an abstraction layer like a ViewModel
                
                navigator.navigate(to: Screens.detailScreen(detailID: "detail-123"))
            }
        }
        .navigationTitle("Root Screen")
        .bindNavigation(self, binding: $showNextScreen)
    }
}
``` 

```swift
struct DetailScreen: Navigable {
    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>    
    @State var showNextScreen: Bool = false
    var currentScreen: Screens
    
    var body: some View {
        VStack {
            Text("Here is some amazing detail.")
            
            Button("Go Back") {
                // Use dismissCurrent() to navigate back
                // to the previous view by popping the current
                navigator.dismissCurrent()
            }
            .tint(.red)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.automatic)
            .controlSize(.large)
        }
        .navigationTitle("Detail Screen")
        .bindNavigation(self, binding: $showNextScreen)
    }
}
```
