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
When we *Dispatch* an *Event*, it means that we are sending that information to every `EventReceiver` (see next section) that is listening for that *Event type*.

Once an *Event* has been *Dispatched*, it cannot be cancelled or modified. This is by design. Think of it as saying that "you cannot unsay something once you have said it."

*Events* can be *Dispatched* from anywhere in your code, regardless of what *Thread* is invoking it. In this sense, *Events* are very much a **fire and forget** process.

### `EventReceiver`
An `EventReceiver` is a `class` inheriting the base type provided by this library called `EventReceiver`.

Beneath the surface, `EventReceiver` descends from `Thread`, and is literally what is known as a `Persistent Thread`.
This means that the `Thread` would typically exist either for a long as your particular application would require it, or even for the entire lifetime of your application.

Unlike most Threads, `EventReceiver` has been built specifically to operate with the lowest possible system resource footprint. When there are no *Events* waiting to be processed by your `EventReceiver`, the Thread will consume absolutely no CPU time, and effectively no power at all.

Once your `EventReceiver` receives an *Event* of an `Eventable` type to which it has *subscribed*, it will *wake up* automatically and process any waiting *Events* in its respective *Queue* and *Stack*.

**Note:** any number of `EventReceiver`s can receive the same *Event*s. This means that you can process the same *Event* for any number of purposes, in any number of ways, with any number of outcomes.

### Event Handler (or Callback)
When you define your `EventReceiver` descendant, you will implement a function called `registerEventListeners`. Within this function (which is invoked automatically every time an Instance of your `EventReceiver` descendant type is initialised) you will register the `Eventable` Types to which your `EventReceiver` is interested; and for each of those, define a suitable *Handler* (or *Callback*) method to process those *Events* whenever they occur.

You will see detailed examples of this in the **Usage** section of this document later, but the key to understand here is that, for each `Eventable` type that your `EventReceiver` is interested in processing, you will be able to register your *Event Handler* for that *Event* type in a single line of code.

This makes it extremely easy to manage and maintain the *Event Subscriptions* that each `EventReceiver` has been implemented to process.

## Performance-Centric
`EventDrivenSwift` is designed specifically to provide the best possible performance balance both at the point of *Dispatching* an *Event*, as well as at the point of *Processing* an *Event*.

With this in mind, `EventDrivenSwift` provides a *Central Event Dispatch Handler* by default. Whenever you *Dispatch* an *Event* through either a *Queue* or *Stack*, it will be immediately enqueued within the *Central Event Dispatch Handler*, where it will subsequently be *Dispatched* to all registered `EventReceiver`s through its own *Thread*.

This means that there is a near-zero wait time between instructing an *Event* to *Dispatch*, and continuing on in the invoking Thread's execution.

Despite using an intermediary Handler in this manner, the time between *Dispatch* of an *Event* and the *Processing* of that *Event* by each `EventReceiver` is **impressively short!** This makes `EventDrivenSwift` more than useful for performance-critical applications, including videogames!

## Built on `Observable`
`EventDrivenSwift` is built on top of our [`Observable` library](https://github.com/flowduino/observable), and `EventReceiver` descends from `ObservableThread`, meaning that it supports full *Observer Pattern* behaviour as well as *Event-Driven* behaviour.

Put simply: you can Observe `EventReceiver`s anywhere in your code that it is necessary, including from SwiftUI Views.

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
            .upToNextMajor(from: "1.0.0")
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

### Defining an `EventReceiver`
So, we have an *Event* type, and we are able to *Dispatch* it through a *Queue* or a *Stack*, with whatever *Priority* we desire. Now we need to define an `EventReceiver` to listen for and process our `TemperatureEvent`s.

```swift
class TemperatureProcessor: EventReceiver {
    /// Register our Event Listeners for this EventReceiver
    override func registerEventListeners() {
        addEventCallback({ event, priority in
            self.callTypedEventCallback(self.onTemperatureEvent, forEvent: event, priority: priority)
        }, forEventType: TemperatureEvent.self)
    }
    
    /// Define our Callback Function to process received TemperatureEvent Events
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority) {

    }
}
```
Before we dig into the implementation of `onTemperatureEvent`, which can basically do whatever we would want to do with the data provided in the `TemperatureEvent`, let's take a moment to understand what is happening in the above code.

Firstly, `TemperatureProcessor` inherits from `EventReceiver`, which is where all of the magic happens to receive *Events* and register our *Listeners* (or *Callbacks* or *Handlers*).

The function `registerEventListeners` will be called automatically when an instance of `TemperatureProcessor` is created. Within this method, we call `addEventCallback` to register `onTemperatureEvent` so that it will be invoked every time an *Event* of type `TemperatureEvent` is *Dispatched*.

Notice that we use a *Closure* which invokes `self.callTypedEventCallback`. This is to address a fundamental limitation of Generics in the Swift language, and acts as a decorator to perform the Type Checking and Casting of the received `event` to the explicit *Event* type we expect. In this case, that is `TemperatureEvent`

Our *Callback* (or *Handler* or *Listener Event*) is called `onTemperatureEvent`, which is where we will implement whatever *Operation* is to be performed against a `TemperatureEvent`.

**Note**: The need to provide type checking and casting (in `onTemperatureEvent`) is intended to be a temporary requirement. We are looking at ways to decorate this internally within the library, so that we can reduce the amount of boilerplate code you have to produce in your implementations.
For the moment, this solution works well, and enables you to begin using `EventDrivenSwift` in your applications immediately.

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
    
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = TemperatureRating.fromTemperature(event.temperatureInCelsius)
    }
}
```
The above code is intended to be illustrative, rather than *useful*. Our `onTemperatureEvent` passes *Event*'s encapsulated `temperatureInCelsius` to a public variable (which could then be read by other code as necessary) as part of our `EventReceiver`, and also pre-calculates a `TemperatureRating` based on the Temperature value received in the *Event*.

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
### Observing an `EventReceiver`
Remember, `EventRecevier`s are also *Observable*, so we can not only receive and operate on *Events*, we can also notify *Observers* in response to *Events*.

Let's take a look at a simple example based on the examples above.
We shall begin by defining an *Observer Protocol*:
```swift
protocol TemperatureProcessorObserver: AnyObject {
    func onTemperatureEvent(temperatureInCelsius: Float)
}
```
Now let's modify the `onTemperatureEvent` method we implemented in the previous example:
```swift
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority) {
        temperatureInCelsius = event.temperatureInCelsius
        temperatureRating = TemperatureRating.fromTemperature(event.temperatureInCelsius)
        
        /// Notify any Observers...
        withObservers { (observer: TemperatureProcessorObserver) in
            observer.onTemperatureEvent(temperatureInCelsius: event.temperatureInCelsius)
        }
    }
```
Now, every time a `TemperatureEvent` is processed by the `EventReceiver`, it will also notify any direct *Observers* as well.

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
    func onTemperatureEvent(_ event: TemperatureEvent, _ priority: EventPriority) {
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

Now that we've walked through these basic Usage Examples, see if you can produce your own `EventReceiver` to process `TemperatureRatingEvent`s. Everything you need to achieve this has already been demonstrated in this document.

## Features Coming Soon
`EventDrivenSwift` is an evolving and ever-improving Library, so here is a list of the features you can expect in future releases:
- **Event Pools** - A superset expanding upon a given `EventReceiver` descendant type to provide pooled processing based on given scaling rules and conditions.
- **`UIEventReceiver`** - Will enable you to register Event Listener Callbacks to be executed on the UI Thread. This is required if you wish to use Event-Driven behaviour to directly update SwiftUI Views, for example.

These are the features intended for the next Release, which will either be *1.1.0* or *2.0.0* depending on whether these additions require interface-breaking changes to the interfaces in version *1.0.0*.

## License

`EventDrivenSwift` is available under the MIT license. See the [LICENSE file](./LICENSE) for more info.

## Join us on Discord

If you require additional support, or would like to discuss `EventDrivenSwift`, Swift, or any other topics related to Flowduino, you can [join us on Discord](https://discord.gg/WXCcw532ne).

