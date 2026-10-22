# Finding Hangs and Hitches

Tell a blocked main thread from late frames, and find the code behind each.

## Overview

People notice two kinds of slowness. A _hang_ is a period in which the app does not respond
to touches because its main thread is busy. A _hitch_ is a frame that reaches the screen late,
which makes scrolling and animations stutter even though the app still responds. Both usually
come from work on the main thread, but they are measured differently.

### Detect hangs

``HangDetector`` sends a small block to the main queue from a background thread and measures
how long the queue takes to run it. When that is at least the threshold, it reports a
``HangEvent``:

```swift
let detector = HangDetector(threshold: .milliseconds(250), capturesBacktraces: true)
detector.start()

Task {
    for await hang in detector.events() {
        logger.warning("Hang of \(hang.duration), \(hang.severity.rawValue)")
        for frame in hang.backtrace?.prefix(8) ?? [] {
            logger.warning("  \(frame.image ?? "?") \(frame.symbol ?? "?")")
        }
    }
}
```

Apple's "Understanding hangs in your app" says a delay under 100 ms is rarely noticeable and
that its tools report unresponsiveness from 250 ms. ``HangSeverity`` follows those limits:
``HangSeverity/delay`` from 100 ms and ``HangSeverity/hang`` from 250 ms.

With `capturesBacktraces`, the detector reads the main thread's call stack once the hang
reaches the threshold, while the thread is still blocked. The innermost frames are what the
thread was doing; look for the first frame in your own binary. In a release build without
symbols the frames have addresses and binary names only; symbolicate them with the dSYM.

### Measure hitches

A display refreshes at a fixed rate, such as every 1/120 s on a ProMotion iPhone. Each refresh,
`CADisplayLink` tells the app when the current frame was shown and when the next one is due.
A frame shown after its due time is late by its _hitch duration_. ``FrameTimeline`` computes
that from the display link's times, and ``FrameRateMonitor`` runs the display link for you:

```swift
let frames = FrameRateMonitor(reportInterval: .seconds(1))
frames.start()

for await window in frames.updates() {
    print(window.framesPerSecond, window.hitchTimeRatio, window.rating)
}
```

The hitch time ratio is the hitch duration per second, in milliseconds per second; it does
not depend on the refresh rate, unlike frames per second. ``HitchRating`` grades it with the
limits in Apple's "Understanding hitches in your app": at most 10 ms/s is good, at most 25 a
warning, at most 50 critical, and above that it needs immediate attention.

A display link only runs while the app is in the foreground. When it pauses, for example while
the app is in the background, the next callback comes much later; ``FrameTimeline`` treats gaps
longer than half a second as a pause rather than as one long hitch.

### Find the code

- For a hang, the backtrace in the ``HangEvent`` points at the code; the Hangs instrument in
  Instruments shows the same with a timeline.
- For hitches, record with the Animation Hitches instrument: it tells hitches caused by the app
  (commit hitches) from those caused by rendering (render hitches).
- Wrap suspicious work in ``PerformanceTracer/measure(_:_:)``; its signposts appear next to the
  hangs and hitches in Instruments.
