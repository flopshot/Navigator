# Navigator

![swift v5.5](https://img.shields.io/badge/swift-v5.5-orange.svg)
[![Platforms: iOS, watchOS](https://img.shields.io/badge/Platforms-iOS,%20watchOS-blue.svg?style=flat)](https://developer.apple.com/osx/)
![deployment target iOS 14, watchOS 2](https://img.shields.io/badge/deployment%20target-iOS%2014,%20watchOS%202-blueviolet)

A navigation library that decouples Navigation logic in
SwiftUI from the View and allows you to dynamically 
navigate to other Views programatically in your app.

* Uses native SwiftUI navigation
* No custom 3rd party navigation
* Retains Navigation back button 
* Retains swipe-to-dismiss
* Light weight, no wrapper views


## Features
1. **Navigation Stack**: Stores the state of SwiftUI navigation for your app
2. **Dynamic Navigation**: Full programatic navigation at runtime. No static hardcoded view destinations necessary
3. **Simple navigation APIs out of the box**: `navigate(to:)` `pop()` `popToRoot()`

```swift
struct DetailScreen: ScreenView {
    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>    
    @State var showNextScreen: Bool = false
    var currentScreen: Screens
    
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
implement `makeView(screenType:)` so that the given `Screens`
enum returns the associated `View`.

```swift 
class MyViewFactory: ViewFactory {
    
    @ViewBuilder
    func makeView(screenType: ScreenWrapper<Screens>) -> some View {
        switch screenType {
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

### 3. Conform app top level views to ScreenView

For each top level view, conform them to `ScreenView`
and apply the `bindNavigation(_:binding:)` view modifier

```swift
struct RootScreen: ScreenView {
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
struct DetailScreen: ScreenView {
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
instance in the `ScreenView` View to execute system level
View navigation

```swift
struct RootScreen: ScreenView {
    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>
    @State var showNextScreen: Bool = false
    var currentScreen = .rootScreen
    
    var body: some View {
        List {
            Button("Navigate to Deatil Screen") {
                // Use navigate(to:) to navigate to another ScreenView
                
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
struct DetailScreen: ScreenView {
    @EnvironmentObject var navigator: Navigator<Screens, MyViewFactory>    
    @State var showNextScreen: Bool = false
    var currentScreen: Screens
    
    var body: some View {
        VStack {
            Text("Here is some amazing detail.")
            
            Button("Go Back") {
                // Use pop() to navigate back to the
                // previous view by popping the current
                navigator.pop()
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

## Advanced
As stated previously, the `Navigator` class has the property `navStack` which keeps
a stack (OrderedDictionary) of the `ScreenView` associated `Screens` enums that are 
currently active in the NavigationView. Clients can use it to execte custom navigation logic.
```swift

    /// Holds the ordered uniqe set of screens that makes up the Navigation State of the client app,
    /// along with its associated Boolean subject, which toggles the NavigationLink.isActive
    var navStack: OrderedDictionary<ScreenIdentifer, CurrentValueSubject<Bool, Never>> { get }
    
```

As an example, we can use it create an extention funtion on `Navigator` called `popToDetailWithSpecificIdOrRoot(id: String)`

```swift
extension Navigator where ScreenIdentifer == Screens {
    func popToDetailWithSpecificIdOrRoot(id: String) {
    
        // Since all screens that have been pushed onto the NavigationView
        // are stored in the navStack as keys, we can simply search through
        // them for the specific detail screen with the called id
        
        if let detailScreen: Screens = navStack.keys.elements.first(where: {
            if case Screens.detailScreen(let detailID) = $0 { 
                return detailID == id 
            }
            return false
        }) {
        
            // Using the first(where:) collections function
            // if we find the detail screen with the called id
            // then the navStack Dictionary can be keyed
            // on the found detailScreen to return the Combine subject
            // that controls the NavigationLink.isActive binding
            // for that detailScreen
            let navigationIsActiveBinding = navStack[greenScreen]!
            
            // When then send the false flag to the NavigationLink.isActive binding
            // it will dismiss all views off the NavigationView stack to reveal
            // the detailScreen
            navigationIsActiveBinding.send(false)
        } else {
        
            // if the detail screen is not found in the current stack
            // then we default to pop all views off the stack to reveal the
            // rootScreen view
            let rootScreenNavigationIsActiveBinding = navStack.elements[0]
            rootScreenNavigationIsActiveBinding.value.send(false)
            
            // could also call self.popToRoot()
        }
    }
}
```

Because the `Navigator` class can be a singleton not copuled to any specific view, we can call
`popToDetailWithSpecificIdOrRoot(id:)` anywhere in the app.

```swift
@main
struct MyApp: App {

    // Keep reference to the navigator, either as a local property or in an abstraction
    // layer, such as an AppCoordinator
    let navigator = Navigator(rootScreen: Screens.rootScreen, viewFactory: MyViewFactory())

    var body: some Scene {
        WindowGroup {
            RootScreen(currentScreen: .rootScreen)
                .modifier(NavigatorViewBinding())
                .environmentObject(navigator)
                .task {
                    // mimic a system event, such as a notification 
                    
                    // create an artificial delay of 10 seconds after the app starts up
                    try! await Task.sleep(nanoseconds: 10_000_000_000)
                    
                    // User navigates to different views, adding to the navStack
                    
                    // However far along the user is, this will pop to the first 
                    // detailScreen with called id, or pop to the root screen
                    navigator.popToDetailWithSpecificIdOrRoot(id: "detail-123")
                }
        }
    }
}
```

## Acknowledgements
Big thanks to [Obsured Pixels'](https://github.com/obscured-pixels/abstracting-navigation-swiftui) excellent article, which inspired this library.
