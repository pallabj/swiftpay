# Topics to Implement for Practice

Track concepts learned theoretically but not yet implemented practically.

1. **Combine concepts**
   1. `ObservableObject` and `@Published` model state.
   2. Build a live search flow from a changing `$query` publisher using operators such as `.map` and `.removeDuplicates()`.
   3. Subscribe with `.sink`, retain `AnyCancellable`, and verify cancellation when the owning view model is released.
   4. Build a production-style `URLSession.DataTaskPublisher` pipeline: create a request, validate the HTTP response, decode `Codable` data, and update loading, success, and user-facing error states.
   5. Handle publisher values separately from terminal completion (`.finished` or `.failure`), including network, HTTP, and decoding errors.
   6. **Combine scheduling and deferred work:** Compare `.subscribe(on:)` (upstream subscription work) with `.receive(on:)` (downstream event delivery); use `Deferred` to delay publisher creation and `Future` to publish one asynchronous result; verify where the work and subscriber callbacks execute.
   7. Use Subjects in a complete event flow: choose `PassthroughSubject` for events or `CurrentValueSubject` for current state, expose a read-only `AnyPublisher`, publish from a real source, subscribe, and handle the event.

2. **URLSession**
   1. Configure and reuse a `URLSession` with `URLSessionConfiguration`, including request timeouts and connectivity behavior.
   2. Cancel in-flight requests using Swift `Task` cancellation with async URLSession APIs or `URLSessionTask.cancel()` with callback-based APIs; prevent cancelled requests from updating UI state.
   3. Upload data with `URLSession.upload(for:from:)` or a file with `upload(for:fromFile:)`; check the HTTP response and handle server and network errors.
   4. Download files with `URLSession.download(from:)`; validate the response and move the temporary download to a persistent location with `FileManager`.

3. **Needle dependency injection**
   1. Add the `NeedleFoundation` package and install its separate code generator.
   2. Define the root `BootstrapComponent`, feature `Component`s, and their `Dependency` protocols.
   3. Provide shared dependencies at the right component scope and connect parent and child components.
   4. Generate and include Needle’s dependency-wiring source, then register provider factories at app startup.
   5. Inject dependencies through initializers and verify that missing providers fail during generation or build.
