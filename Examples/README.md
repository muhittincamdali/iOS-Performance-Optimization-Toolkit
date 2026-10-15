# Examples

## PerformanceLab

A small iOS and macOS app that causes the problems the package measures, on purpose, so you
can see each measurement react. A `PerformanceHUD` in the corner shows the live figures on
every screen.

- **Hangs**: blocks the main thread for 150 ms or 600 ms. Only the second is a hang; its row
  shows the function in the app that the captured call stack points at.
- **Frames and hitches**: a list of 400 rows whose rows can be made slow (8 ms of work each
  when they appear). Scrolling with slow rows shows the frame rate drop and the hitch time
  ratio climb.
- **Memory**: allocates and frees memory in 50 MB blocks and shows the footprint, its peak
  and, on a device, how much memory is left before the app's limit.
- **Leaks**: opens a sheet whose view model is released when it closes, and one whose view
  model keeps itself alive through a closure. `LeakTracker` reports the second one two
  seconds after the sheet closes.
- **Tracing**: decodes 2,000 JSON records 20 times inside `PerformanceTracer.measure` and
  shows the median, the 95th percentile and the slowest run.
- **Budget**: checks the app's current figures against a `PerformanceBudget` and lists what
  is over.

It uses the package from this checkout (a local package reference to `../..`), so it always
shows the current code.

Run it:

1. Open `Examples/PerformanceLab/PerformanceLab.xcodeproj` in Xcode 26 or later.
2. Choose the **PerformanceLab** scheme and an iPhone simulator or **My Mac** as the run
   destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/PerformanceLab
xcodebuild build -scheme PerformanceLab -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme PerformanceLab -destination 'platform=macOS'
```

To open one screen and run its demo directly, pass its name as a launch argument, for example
`-screen hangs` (the names are the cases of `LabView.Screen`).
[`scripts/capture-example-screens.sh`](../scripts/capture-example-screens.sh) takes the README
screenshots that way, so the figures on them are measured live on a simulator.

The README samples live in
[`PerformanceLab/ReadmeSamples.swift`](PerformanceLab/PerformanceLab/ReadmeSamples.swift); the
README copies its code from that file and the app compiles it.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](PerformanceLab/project.yml) and committed, so you only need XcodeGen after
editing `project.yml`.
