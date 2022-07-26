# Event-Driven Swift

<p>
    <img src="https://img.shields.io/badge/Swift-5.1%2B-yellowgreen.svg?style=flat" />
    <img src="https://img.shields.io/badge/iOS-13.0+-865EFC.svg" />
    <img src="https://img.shields.io/badge/iPadOS-13.0+-F65EFC.svg" />
    <img src="https://img.shields.io/badge/macOS-10.15+-179AC8.svg" />
    <img src="https://img.shields.io/badge/tvOS-13.0+-41465B.svg" />
    <img src="https://img.shields.io/badge/watchOS-6.0+-1FD67A.svg" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" />
    <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" />
    </a>
    <a href="https://discord.gg/WXCcw532ne">
      <img src="https://img.shields.io/discord/878568176856731688?logo=Discord" />
    </a>
</p>


Decoupling of discrete units of code contributes massively to the long-term maintainability of your project(s). While *Observer Pattern* is a great way of providing some degree of decoupling by only requiring that *Observers* conform to a mutually-agreed *Interface* (Protocol, in Swift), we can go significantly further using an Event-Driven Pattern.

With Event-Driven systems, there is absolutely *no* direct reference between discrete units of code. Instead, each discrete unit of code emits and listens for *Events* (as applicable). An *Event* is simply a structured object containing immutable information. Each unit of code can then operate based on the Event(s) it receives, and perform whatever operation(s) are necessary in the context of that particular unit of code.

*Event Driven Swift* is an extremely powerful library designed specifically to power your Event-Driven Applications in the Swift language.

## Decoupled Topology
Where traditional software design principles would require communicating objects to reference each-other directly, Event-Driven design patterns eliminate the need for this.

<img src="/Diagrams/Event-Driven%20SwiftUI%20View.png?raw=true" alt="Topological Diagram showing Event-Driven ViewModel being updated via Events from the Data Model Repository" title="Topological Diagram showing Event-Driven ViewModel being updated via Events from the Data Model Repository">

## Terminology
Understanding the Terminology used in this Library and its supporting examples/documentation will aid you considerably in immediately leveraging these tools to produce extremely powerful, high-performance, entirely-decoupled and easily maintained Event-Driven solutions.

### Event
An *Event* is simply an immutable payload of information that can be used to drive logic and behaviour.

Think of an *Event* as being akin to an *Operation Trigger*. In response to receiving an *Event* of a known Type, a distinct unit of code would perform an appropriate operation based on the information received in that *Event*'s *payload*.

In `EventDrivenSwift`, we would typically define an *Event* as a `struct` conforming to the `Eventable` protocol.

Here is a simple example:
```swift
struct TemperatureEvent: Eventable {
    var temperatureInCelsius: Float
}
```
Note that the above example, `TemperatureEvent`, is the most basic example of an *Event* possible, in that it only contains one piece of information.
In reality, your *Events* can encapsulate as much information as is logical for a single cohesive operation trigger.

**Important Note:** An *Event* should **never** include any Reference-Type values (such as `class` instances). *Events* need to be **immutable**, meaning that none of their values can possibly change after they have been *Dispatched*.

### Event Queue
An *Event Queue* is a sequencial collection (`Array`) of `Eventable` objects that will automatically be processed whenever the *Queue* is not empty.
*Queues* are always processed in the order First-in-First-out (or *FiFo*).

Note that *Events* dispatched to a *Queue* will always be processed after *Events* dispatched to a *Stack*.

### Event Stack
An *Event Stack* is virtually the same as an *Event Queue*, except that it is processed in the opposite order: Last-in-First-out (or *LiFo*)

Note that *Events* dispatched to a *Stack* will always be processed before *Events* dispatched to a *Queue*.

### Event Priority
*Events* can be dispatched to a *Queue* or *Stack* with one of the following *Priorities*:
`.highest` will be processed first
`.high` will be processed second
`.normal` will be processed third
`.low` will be processed fourth
`.lowest` will be processed last

This means that we can enforce some degree of *execution order* over *Events* at the point of dispatch.

### Dispatch
*Dispatch* is a term comparable to *Broadcast*.
When we *Dispatch* an *Event*, it means that we are sending that information to every `EventThread` (see next section) that is listening for that *Event type*.

Once an *Event* has been *Dispatched*, it cannot be cancelled or modified. This is by design. Think of it as saying that "you cannot unsay something once you have said it."

*Events* can be *Dispatched* from anywhere in your code, regardless of what *Thread* is invoking it. In this sense, *Events* are very much a **fire and forget** process.

### `EventThread`
An `EventThread` is a `class` inheriting the base type provided by this library called `EventThread`.

Beneath the surface, `EventThread` descends from `Thread`, and is literally what is known as a `Persistent Thread`.
This means that the `Thread` would typically exist either for a long as your particular application would require it, or even for the entire lifetime of your application.

Unlike most Threads, `EventThread` has been built specifically to operate with the lowest possible system resource footprint. When there are no *Events* waiting to be processed by your `EventThread`, the Thread will consume absolutely no CPU time, and effectively no power at all.

Once your `EventThread` receives an *Event* of an `Eventable` type to which it has *subscribed*, it will *wake up* automatically and process any waiting *Events* in its respective *Queue* and *Stack*.

**Note:** any number of `EventThread`s can receive the same *Event*s. This means that you can process the same *Event* for any number of purposes, in any number of ways, with any number of outcomes.

### Event Handler (or Callback)
When you define your `EventThread` descendant, you will implement a function called `registerEventListeners`. Within this function (which is invoked automatically every time an Instance of your `EventThread` descendant type is initialised) you will register the `Eventable` Types to which your `EventThread` is interested; and for each of those, define a suitable *Handler* (or *Callback*) method to process those *Events* whenever they occur.

You will see detailed examples of this in the **Usage** section of this document later, but the key to understand here is that, for each `Eventable` type that your `EventThread` is interested in processing, you will be able to register your *Event Handler* for that *Event* type in a single line of code.

This makes it extremely easy to manage and maintain the *Event Subscriptions* that each `EventThread` has been implemented to process.

## Performance-Centric
`EventDrivenSwift` is designed specifically to provide the best possible performance balance both at the point of *Dispatching* an *Event*, as well as at the point of *Processing* an *Event*.

With this in mind, `EventDrivenSwift` provides a *Central Event Dispatch Handler* by default. Whenever you *Dispatch* an *Event* through either a *Queue* or *Stack*, it will be immediately enqueued within the *Central Event Dispatch Handler*, where it will subsequently be *Dispatched* to all registered `EventThread`s through its own *Thread*.

This means that there is a near-zero wait time between instructing an *Event* to *Dispatch*, and continuing on in the invoking Thread's execution.

Despite using an intermediary Handler in this manner, the time between *Dispatch* of an *Event* and the *Processing* of that *Event* by each `EventThread` is **impressively short!** This makes `EventDrivenSwift` more than useful for performance-critical applications, including videogames!

## Built on `Observable`
`EventDrivenSwift` is built on top of our [`Observable` library](https://github.com/flowduino/observable), and `EventThread` descends from `ObservableThread`, meaning that it supports full *Observer Pattern* behaviour as well as *Event-Driven* behaviour.

Put simply: you can Observe `EventThread`s anywhere in your code that it is necessary, including from SwiftUI Views.

This means that your application can dynamically update your Views in response to *Events* being received and processed, making your application truly and fully multi-threaded, without you having to produce code to handle the intra-Thread communication yourself.

## Built on `ThreadSafeSwift`
`EventDrivenSwift` is also built on top of our [`ThreadSafeSwift` library](https://github.com/flowduino/threadsafeswift), and every public method and member of every type in `EventDrivenSwift` is designed specifically to be *Thread-Safe*.

It is strongly recommended that your own implementations using `EventDrivenSwift` adhere strictly to the best Thread-Safe standards. With that said, unless you are defining a `var` or `func` that is accessible publicly specifically for the purpose of displaying information on the UI, most back-end implemenations built with a pure Event-Driven methodology will not need to concern themselves too much with Thread-Safety.

## Installation
### Xcode Projects
Select `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/Flowduino/EventDrivenSwift.git`

### Swift Package Manager Projects
You can use `EventDrivenSwift` as a Package Dependency in your own Packages' `Package.swift` file:
```swift
let package = Package(
    //...
    dependencies: [
        .package(
            url: "https://github.com/Flowduino/EventDrivenSwift.git",
            .upToNextMajor(from: "5.0.0")
        ),
    ],
    //...
)
```

From there, refer to `EventDrivenSwift` as a "target dependency" in any of _your_ package's targets that need it.

```swift
targets: [
    .target(
        name: "YourLibrary",
        dependencies: [
          "EventDrivenSwift",
        ],
        //...
    ),
    //...
]
```
You can then do `import EventDrivenSwift` in any code that requires it.

## Usage
So, now that we've taken a look at what `EventDrivenSwift` is, what it does, and we've covered a lot of the important *Terminology*, let's take a look at how we can actually use it.

### Defining an *Event* type
You can make virtually *any* `struct` type into an *Event* type simply by inheriting from `Eventable`:
```swift
struct TemperatureEvent: Eventable {
    var temperatureInCelsius: Float
} 
```
It really is as simple as that!

### *Dispatching* an *Event*
Now that we have a defined *Event* type, let's look at how we would *Dispatch* an *Event* of this type:
```swift
let temperatureEvent = TemperatureEvent(temperatureInCelsius: 23.25)
```
The above creates an instance of our `TemperatureEvent` *Event* type.
If we want to dispatch it via a *Queue* with the `.normal` *Priority*, we can do so as easily as this:
```swift
temperatureEvent.queue()
```
We can also customise the *Priority*:
```swift
temperatureEvent.queue(priority: .highest)
```
The above would dispatch the Event via a *Stack* with the `.highest` *Priority*.

The same works when dispatching via a *Stack*:
```swift
temperatureEvent.stack()
```
Above would again be with `.normal` *Priority*...
```swift
temperatureEvent.stack(priority: .highest)
```
Above would be with `.highest` *Priority*.

### Scheduled *Dispatching* of an *Event*
Version 4.2.0 introduced *Scheduled Dispatch* into the library:
```swift
temperatureEvent.scheduleQueue(at: DispatchTime.now() + TimeInterval().advanced(by: 4), priority: .highest)
```
The above would *Dispatch* the `temperatureEvent` after 4 seconds, via the *Queue*, with the *highest Priority*
```swift
temperatureEvent.scheduleStack(at: DispatchTime.now() + TimeInterval().advanced(by: 4), priority: .highest)
```
The above would *Dispatch* the `temperatureEvent` after 4 seconds, via the *Stack*, with the *highest Priority*

*Scheduled Event Dispatch* is a massive advantage when your use-case requires a fixed or calculated time delay between the composition of an *Event*, and its *Dispatch* for processing. 

### (Receiving & Processing Events - Method 1) Defining an `EventThread`
So, we have an *Event* type, and we are able to *Dispatch* it through a *Queue* or a *Stack*, with whatever *Priority* we desire. Now we need a way to Receive our `*`TemperatureEvent`s so that we can do something with them. One way of doing this is to define an `EventThread` to listen for and process our `TemperatureEvent`s.

```swift
class TemperatureProcessor: EventThread {
    /// Register our Event Listeners for this EventThread
    override func registerEventListeners() {
        addEventCallback(onTemperatureEvent, forEventType: TemperatureEvent.self)
    }
    
    /// Define our Callback Function to process received TemperatureEvent Events
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {

    }
}
```
Before we dig into the implementation of `onTemperatureEvent`, which can basically do whatever we would want to do with the data provided in the `TemperatureEvent`, let's take a moment to understand what is happening in the above code.

Firstly, `TemperatureProcessor` inherits from `EventThread`, which is where all of the magic happens to receive *Events* and register our *Listeners* (or *Callbacks* or *Handlers*).

The function `registerEventListeners` will be called automatically when an instance of `TemperatureProcessor` is created. Within this method, we call `addEventCallback` to register `onTemperatureEvent` so that it will be invoked every time an *Event* of type `TemperatureEvent` is *Dispatched*.

Our *Callback* (or *Handler* or *Listener Event*) is called `onTemperatureEvent`, which is where we will implement whatever *Operation* is to be performed against a `TemperatureEvent`.

Version 5.0.0 introduces the new parameter, `dispatchTime`, which will always provide the `DispatchTime` reference at which the *Event* was *Dispatched*. You can use this to determine *Delta* (how much time has passed since the *Event* was *Dispatched*), which is particularly useful if you are performing interpolation and/or extrapolation.

Now, let's actually do something with our `TemperatureEvent` in the `onTemperatureEvent` method.
```swift
    /// An Enum to map a Temperature value onto a Rating
    enum TemperatureRating: String {
        case belowFreezing = "Below Freezing"
        case freezing = "Freezing"
        case reallyCold = "Really Cold"
        case cold = "Cold"
        case chilly = "Chilly"
        case warm = "Warm"
        case hot = "Hot"
        case reallyHot = "Really Hot"
        case boiling = "Boiling"
        case aboveBoiling = "Steam"
        
        static func fromTemperature(temperatureInCelsius: Float) -> TemperatureRating {
            if temperatureInCelsius < 0 { return .belowFreezing }
            else if temperatureInCelsius == 0 { return .freezing }
            else if temperatureInCelsius < 5 { return .reallyCold }
            else if temperatureInCelsius < 10 { return .cold }
            else if temperatureInCelsius < 16 { return .chilly }
            else if temperatureInCelsius < 22 { return .warm }
            else if temperatureInCelsius < 25 { return .hot }
            else if temperatureInCelsius < 100 { return .reallyHot }
            else if temperatureInCelsius == 100 { return .boiling }
            else { return .aboveBoiling }
        }
    }
    
    @ThreadSafeSemaphore public var temperatureInCelsius: Float = Float.zero
    @ThreadSafeSemaphore public var temperatureRating: TemperatureRating = .freezing
    
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = TemperatureRating.fromTemperature(event.temperatureInCelsius)
    }
}
```
The above code is intended to be illustrative, rather than *useful*. Our `onTemperatureEvent` passes *Event*'s encapsulated `temperatureInCelsius` to a public variable (which could then be read by other code as necessary) as part of our `EventThread`, and also pre-calculates a `TemperatureRating` based on the Temperature value received in the *Event*.

Ultimately, your code can do whatever you wish with the *Event*'s *Payload* data!

### Playground Code to test everything so far
The only thing you're missing so far is how to create an instance of your `EventListner` type.
This is in fact remarkably simple. The following can be run in a Playground:
```swift
let temperatureProcessor = TemperatureProcessor()
```
That's all you need to do to create an instance of your `TemperatureProcessor`.

Let's add a line to print the inital values of `temperatureProcessor`:
```swift
print("Temp in C: \(temperatureProcessor.temperatureInCelsius)")
print("Temp Rating: \(temperatureProcessor.temperatureRating)")
```

We can now dispatch a `TemperatureEvent` to be processed by `temperatureProcessor`:
```swift
TemperatureEvent(temperatureInCelsius: 25.5).queue()
```

Because *Events* are processed *Asynchronously*, and because this is just a Playground test, let's add a 1-second sleep to give `TemperatureProcessor` time to receive and process the *Event*. **Note:** In reality, this would need less than 1ms to process!
```swift
sleep(1)
```

Now let's print the same values again to see that they have changed:
```swift
print("Temp in C: \(temperatureProcessor.temperatureInCelsius)")
print("Temp Rating: \(temperatureProcessor.temperatureRating)")
```

Now you have a little Playground code to visually confirm that your *Events* are being processed. You can modify this to see what happens.
### Observing an `EventThread`
Remember, `EventThread`s are also *Observable*, so we can not only receive and operate on *Events*, we can also notify *Observers* in response to *Events*.

Let's take a look at a simple example based on the examples above.
We shall begin by defining an *Observer Protocol*:
```swift
protocol TemperatureProcessorObserver: AnyObject {
    func onTemperatureEvent(temperatureInCelsius: Float)
}
```
Now let's modify the `onTemperatureEvent` method we implemented in the previous example:
```swift
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = TemperatureRating.fromTemperature(event.temperatureInCelsius)
        
        /// Notify any Observers...
        withObservers { (observer: TemperatureProcessorObserver) in
            observer.onTemperatureEvent(temperatureInCelsius: event.temperatureInCelsius)
        }
    }
```
Now, every time a `TemperatureEvent` is processed by the `EventThread`, it will also notify any direct *Observers* as well.

It should be noted that this functionality serves as a *complement* to *Event-Driven* behaviour, as there is no "one size fits all" solution to every requirement in software. It is often neccessary to combine methodologies to achieve the best results.

### Reciprocal Events
Typically, systems not only *consume* information, but also *return* information (results). This is not only true when it comes to Event-Driven systems, but also trivial to achieve.

Let's expand upon the previous example once more, this time emitting a reciprocal *Event* to encapsulate the Temperature, as well as the `TemperatureRating` we calculated in response to the `TemperatureEvent`.

We'll begin by defining the Reciprocal *Event* type:
```swift
enum TemperatureRatingEvent: Eventable {
    var temperatureInCelsius: Float
    var temperatureRating: TemperatureRating
}
```
With the *Event* type defined, we can now once more expand our `onTemperatureEvent` to *Dispatch* our reciprocal `TemperatureRatingEvent`:
```swift
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = TemperatureRating.fromTemperature(event.temperatureInCelsius)
        
        /// Notify any Observers...
        withObservers { (observer: TemperatureProcessorObserver) in
            observer.onTemperatureEvent(temperatureInCelsius: event.temperatureInCelsius)
        }
        
        /// Dispatch our Reciprocal Event...
        TemperatureRatingEvent(
            temperatureInCelsius = temperatureInCelsius,
            temperatureRating = temperatureRating
        ).queue()
    }
``` 
As you can see, we can create and *Dispatch* an *Event* in a single operation. This is because *Events* should be considered to be "fire and forget". You need only retain a copy of the *Event* within the *Dispatching Method* if you wish to use its values later in the same operation. Otherwise, just create it and *Dispatch* it together, as shown above.

Now that we've walked through these basic Usage Examples, see if you can produce your own `EventThread` to process `TemperatureRatingEvent`s. Everything you need to achieve this has already been demonstrated in this document.

## `UIEventThread`
Version 2.0.0 introduced the `UIEventThread` base class, which operates exactly the same way as `EventThread`, with the notable difference being that your registered *Event* Callbacks will **always** be invoked on the `MainActor` (or "UI Thread"). You can simply inherit from `UIEventThread` instead of `EventThread` whenever it is imperative for one or more *Event* Callbacks to execute on the `MainActor`.

## (Receiving & Processing Events - Method 2) `EventListener`
Version 3.0.0 introduced the `EventListener` concept to the Library. These are a universally-available means (available in any `class` you define) of *Receiving Events* dispatched from anywhere in your code, and require *considerably less code* to use.

An `EventListener` is a universal way of subscribing to *Events*, anywhere in your code, without having to define and operate within the constraints of an `EventThread`.

By design, `EventDrivenSwift` provides a *Central Event Listener*, which is automatically initialized should any of your code register a *Listener* for an *Event* by reference to the `Eventable` type.

**Important Note:** `EventListener` will (by default) invoke the associated `Callbacks` on the same Thread (or `DispatchQueue`) from whence the *Listener* registered! This is an extremely useful behaviour, because it means that *Listeners* registered from the `MainActor` (or "UI Thread") will always execute on that Thread, with no additional overhead or code required by you.

Let's register a simple *Listener* in some arbitrary `class`. For this example, let's produce a hypothetical *View Model* that will *Listen* for `TemperatureRatingEvent`, and would invalidate an owning `View` to show the newly-received values.

For the sake of this example, let's define this the pure SwiftUI way, *without* taking advantage of our `Observable` library: 
```swift
class TemperatureRatingViewModel: ObservableObject {
    @Published var temperatureInCelsius: Float
    @Published var temperatureRating: TemperatureRating
    
    var listenerHandle: EventListenerHandling?
    
    internal func onTemperatureRatingEvent(_ event: TemperatureRatingEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = event.temperatureRating
    }
    
    init() {
        // Let's register our Event Listener Callback!
        listenerHandle = TemperatureRatingEvent.addListener(self, onTemperatureRatingEvent)
    }
}
```
It really is **that** simple!

We can use a direct reference to an `Eventable` type, and invoke the `addListener` method, automatically bound to all `Eventable` types, to register our *Listener*.

In the above example, whenever the *Reciprocal Event* named `TemperatureRatingEvent` is dispatched, the `onTemperatureRatingEvent` method of any `TemperatureRatingViewModel` instance(s) will be invoked, in the context of that *Event*!

Don't worry about managing the lifetime of your *Listener*! If the object which owns the *Listener* is destroyed, the *Listener* will be automatically unregistered for you!

If you need your *Event Callback* to execute on the *Listener's* Thread, as of Version 3.1.0... you can!
```swift
listenerHandle = TemperatureRatingEvent.addListener(self, onTemperatureRatingEvent, executeOn: .listenerThread)
```
**Remember:** When executing an *Event Callback* on `.listenerThread`, you will need to ensure that your *Callback* and all resources that it uses are 100% Thread-Safe!
**Important:** Executing the *Event Callback* on `.listnerThread` can potentially delay the invocation of other *Event Callbacks*. Only use this option when it is necessary.

You can also execute your *Event Callback* on an ad-hoc `Task`:
```swift
listenerHandle = TemperatureRatingEvent.addListener(self, onTemperatureRatingEvent, executeOn: .taskThread)
```
**Remember:** When executing an *Event Callback* on `.taskThread`, you will need to ensure that your *Callback* and all resources that it uses are 100% Thread-Safe!

Another thing to note about the above example is the `listenerHandle`. Whenever you register a *Listener*, it will return an `EventListenerHandling` object. You can use this value to *Unregister* your *Listener* at any time:
```swift
    listenerHandle.remove()
```
This will remove your *Listener Callback*, meaning it will no longer be invoked any time a `TemperatureRatingEvent` is *Dispatched*.

**Note:** This is an improvement for Version 4.1.0, as opposed to the use of an untyped `UUID` from previous versions.

`EventListener`s are an extremely versatile and very powerful addition to `EventDrivenSwift`.

## `EventListener` with *Latest-Only* Interest
Version 4.3.0 of this library introduces the concept of *Latest-Only Listeners*. A *Latest-Only Listener* is a *Listener* that will only be invoked for the very latest *Event* of its requested *Event Type*. If there are a number of older *Events* of this type pending in a Queue/Stack, they will simply be skipped over... and only the very *Latest* will invoke your *Listener*.

We have made it incredibly simple for you to configure your *Listener* to be a *Latest-Only Listener*. Taking the previous code example, we can simply modify it as follows:
```swift
class TemperatureRatingViewModel: ObservableObject {
    @Published var temperatureInCelsius: Float
    @Published var temperatureRating: TemperatureRating
    
    var listenerHandle: EventListenerHandling?
    
    internal func onTemperatureRatingEvent(_ event: TemperatureRatingEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = event.temperatureRating
    }
    
    init() {
        // Let's register our Event Listener Callback!
        listenerHandle = TemperatureRatingEvent.addListener(self, onTemperatureRatingEvent, interestedIn: .latestOnly)
    }
}
```
By including the `interestedIn` optional parameter when invoking `addListener` against any `Eventable` type, and passing for this parameter a value of `.latestOnly`, we define that this *Listener* is only interested in the *Latest* `TemperatureRatingEvent` to be *Dispatched*. Should a number of `TemperatureRatingEvent`s build up in the Queue/Stack, the above-defined *Listener* will simply discard any older Events, and only invoke for the newest.

## `EventListener` with *Maximum Age* Interest
Version 5.1.0 of this library introduces the concent of *Maximum Age Listeners*. A *Maximum Age Listener* is a *Listener* that will only be invoked for *Events* of its registered *Event Type* that are younger than a defined *Maximum Age*. Any *Event* older than the defined *Maximum Age* will be skipped over, while any *Event* younger will invoke your *Listener*.

We have made it simple for you to configure your *Listener* to define a *Maximum Age* interest. Taking the previous code example, we can simply modify it as follows:
```swift
class TemperatureRatingViewModel: ObservableObject {
    @Published var temperatureInCelsius: Float
    @Published var temperatureRating: TemperatureRating
    
    var listenerHandle: EventListenerHandling?
    
    internal func onTemperatureRatingEvent(_ event: TemperatureRatingEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = event.temperatureRating
    }
    
    init() {
        // Let's register our Event Listener Callback!
        listenerHandle = TemperatureRatingEvent.addListener(self, onTemperatureRatingEvent, interestedIn: .youngerThan, maximumAge: 1 * 1_000_000_000)
    }
}
```
In the above code example, `maximumAge` is a value defined in *nanoseconds*. With that in mind, `1 * 1_000_000_000` would be 1 second. This means that, any `TemperatureRatingEvent` older than 1 second would be ignored by the *Listener*, while any `TemperatureRatingEvent` *younger* than 1 second would invoke the `onTemperatureRatingEvent` method.

This functionality is very useful when the context of an *Event*'s usage would have a known, fixed expiry.

## `EventListener` with *Custom Event Filtering* Interest
Version 5.2.0 of this library introduces the concept of *Custom Event Filtering* for *Listeners*.

Now, when registering a *Listener* for an `Eventable` type, you can specify a `customFilter` *Callback* which, ultimately, returns a `Bool` where `true` means that the *Listener* is interested in the *Event*, and `false` means that the *Listener* is **not** interested in the *Event*.

We have made it simple for you to configure a *Custom Filter* for your *Listener*. Taking the previous code example, we can simply modify it as follows:
```swift
class TemperatureRatingViewModel: ObservableObject {
    @Published var temperatureInCelsius: Float
    @Published var temperatureRating: TemperatureRating
    
    var listenerHandle: EventListenerHandling?
    
    internal func onTemperatureRatingEvent(_ event: TemperatureRatingEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = event.temperatureRating
    }
    
    internal func onTemperatureRatingEventFilter(_ event: TemperatureRatingEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) -> Bool {
        if event.temperatureInCelsius > 50 { return false } // If the Temperature is above 50 Degrees, this Listener is not interested in it!
        return true // If the Temperature is NOT above 50 Degrees, the Listener IS interested in it!
    }
    
    init() {
        // Let's register our Event Listener Callback!
        listenerHandle = TemperatureRatingEvent.addListener(self, onTemperatureRatingEvent, interestedIn: .custom, customFilter: onTemperatureRatingEventFilter)
    }
}
```
The above code will ensure that the `onTemperatureRatingEvent` method is only invoked for a `TemperatureRatingEvent` where its `temperatureInCelsius` is less than or equal to 50 Degrees Celsius. Any `TemperatureRatingEvent` with a `temperatureInCelsius` greater than 50 will simply be ignored by this *Listener*. 

## `EventPool`
Version 4.0.0 introduces the extremely powerful `EventPool` solution, making it possible to create managed groups of `EventThread`s, where inbound *Events* will be directed to the best `EventThread` in the `EventPool` at any given moment.

`EventDrivenSwift` makes it trivial to produce an `EventPool` for any given `EventThread` type.

To create an `EventPool` of our `TemperatureProcessor` example from earlier, we can use a single line of code:
```swift
var temperatureProcessorPool = EventPool<TemperatureProcessor>(capacity: 5)
```
The above example will create an `EventPool` of `TemperatureProcessor`s, with an initial *Capacity* of **5** instances. This means that your program can concurrently process **5** `TemperatureEvent`s.
Obviously, for a process so simple and quick to complete as our earlier example, it would not be neccessary to produce an `EventPool`, but you can adapt this example for your own, more complex and time-consuming, `EventThread` implementations to immediately parallelise them.

`EventPool`s enable you to specify the most context-appropriate *Balancer* on initialization:
```swift
var temperatureProcessorPool = EventPool<TemperatureProcessor>(capacity: 5, balancer: EventPoolRoundRobinBalancer())
```
The above example would use the `EventPoolRoundRobinBalancer` implementation, which simply directs each inbound `Eventable` to the next `EventThread` in the pool, rolling back around to the first after using the final `EventThread` in the pool.

There is also another *Balancer* available in version 4.0.0: 
```swift
var temperatureProcessorPool = EventPool<TemperatureProcessor>(capacity: 5, balancer: EventPoolLowestLoadBalancer())
```
The above example would use the `EventPoolLowestLoadBalancer` implementation, which simply directs each inbound `Eventable` to the `EventThread` in the pool with the lowest number of pending `Eventable`s in its own *Queue* and *Stack*.

**NOTE:** When no `balancer` is declared, `EventPool` will use `EventPoolRoundRobinBalancer` by default.

## Features Coming Soon
`EventDrivenSwift` is an evolving and ever-improving Library, so here are lists of the features you can expect in future releases.

Version 5.1.0 (or 6.0.0 if interface-breaking changes are required):
- **Event Pool Scalers** - Dynamic Scaling for `EventPool` instances will be fully-implemented (for the moment, no automatic Scaling will occur, and you cannot change the scale of an *Event Pool* once it has been initialised)

## License

`EventDrivenSwift` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.

## Join us on Discord

If you require additional support, or would like to discuss `EventDrivenSwift`, Swift, or any other topics related to Flowduino, you can [join us on Discord](https://discord.gg/WXCcw532ne).

