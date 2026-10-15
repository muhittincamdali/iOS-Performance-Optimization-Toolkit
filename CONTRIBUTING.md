# Contributing

Thanks for taking the time to improve Performance Toolkit.

## Reporting bugs

Open an issue with:

- what you measured (hangs, frames, memory, launch, leaks, network or MetricKit) and how the
  monitor or detector was configured,
- what you expected and what you got, with the figures (a `HangEvent`, `FrameStatistics` or
  `MemorySnapshot` printed as JSON helps),
- for MetricKit, the payload as JSON with identifying fields removed,
- platform and OS version (simulator or device) and Xcode version.

## Pull requests

1. Fork the repository and branch from `master`.
2. Keep each pull request focused on one change.
3. Run the tests on macOS and on an iOS simulator:

    ```sh
    swift test
    xcodebuild test -scheme PerformanceOptimizationKit \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
    ```

   Some tests block a queue or the main thread for a few hundred milliseconds, allocate 64 MB
   or send requests to an HTTP server on 127.0.0.1; nothing goes to the internet.
4. Add or update a test for every behaviour you change in `Tests/PerformanceOptimizationKitTests`.
   Measure real effects where you can (a blocked queue, written memory, a real request) and
   avoid assertions on wall-clock time that a busy CI runner can miss.
5. Anything that comes from the kernel, a display link, MetricKit or a decoded file may be
   missing, NaN, negative or huge. Check it before it reaches an integer conversion, a
   `Duration` or arithmetic, and add a test with the extreme value. New buffers need a limit.
6. Code that runs while another thread is suspended (`ThreadBacktrace`) must not allocate or
   take locks.
7. If you change a README code sample, change the copy in
   `Examples/PerformanceLab/PerformanceLab/ReadmeSamples.swift` as well; the example app
   compiles that file. Build the app with:

    ```sh
    cd Examples/PerformanceLab
    xcodebuild build -scheme PerformanceLab -destination 'generic/platform=iOS Simulator'
    ```

8. If a change affects what the example app shows, regenerate the screenshots with
   `scripts/capture-example-screens.sh`.
9. If you change `README.md` and cannot update its translations, say so in the pull request.

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- The package builds in the Swift 6 language mode and has no dependencies; new code should
  not add warnings or dependencies.
- Document public API with DocC comments (`///`); the documentation builds with
  `--warnings-as-errors`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).
