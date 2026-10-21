# Security policy

## Supported versions

Security fixes are made for the latest release. Version 1.0.0 is a different, unmaintained code
base that did not build, and does not receive fixes.

## What counts as a vulnerability

The package runs inside apps, often in internal and beta builds that real people use, reads
the app's own memory and threads, and decodes MetricKit data that may come from a server.
Please report privately anything that makes it:

- crash (a trap, an integer overflow, an out-of-range index) on a value from the kernel, a
  display link, MetricKit, or JSON decoded into `FieldMetrics`, `FieldHistogram`,
  `FrameStatistics` or `CPUSnapshot`, instead of clamping or leaving the value out;
- use memory or time without bound: beyond the documented limits of `RingBuffer`,
  `PerformanceTracer`, `LeakTracker`, `NetworkMetricsCollector`, `FieldHistogram` and the
  event streams;
- deadlock or crash the app while reading a thread's call stack;
- keep an object alive that it was only meant to watch (`LeakTracker` holds objects weakly);
- store or emit a part of a URL that `URLRedaction` documents that it hides (credentials,
  fragment, query parameters that are not allowed, identifiers, the segment after a secret
  name or an unreadable name, paths that servers read differently), let a URL put a line break
  into its output, or record a request header or body;
- take more than a second, or crash on a 512 KiB stack, while redacting a URL of 1 MB.

`URLRedaction` is a safety net: a secret that looks like an ordinary word in an ordinary place
of a path is a documented limit, not a vulnerability (see "What it does not find" in the
[network timings article](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)).

## Reporting a vulnerability

Please report vulnerabilities privately, not in a public issue, pull request or discussion.

1. **Preferred:** open the repository's **Security** tab and choose
   **Report a vulnerability** ([how private reporting works](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately)).
2. **Or** email [muhittincamdali@gmail.com](mailto:muhittincamdali@gmail.com) with
   "Security" in the subject.

Include the version (tag or commit), the platform and Xcode version, the input or a small
project that triggers the problem, and what happens.

## What happens next

You get an answer within a week. Confirmed problems are fixed in a release, with a test that
reproduces them and a note in the changelog; you are credited unless you ask not to be.
