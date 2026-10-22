#if canImport(MetricKit) && !os(tvOS) && !os(watchOS)
import Foundation
import MetricKit

extension FieldMetrics {
    /// Creates field metrics from a MetricKit payload (iOS 17 to 26, macOS 14 to 26, visionOS).
    public init(_ payload: MXMetricPayload) {
        let launch = payload.applicationLaunchMetrics
        let exits = payload.applicationExitMetrics?.foregroundExitData
        self.init(
            periodStart: payload.timeStampBegin,
            periodEnd: payload.timeStampEnd,
            appBuild: payload.metaData?.applicationBuildVersion ?? payload.latestApplicationVersion,
            timeToFirstDraw: launch.map { FieldHistogram($0.histogrammedTimeToFirstDraw) },
            resumeTime: launch.map { FieldHistogram($0.histogrammedApplicationResumeTime) },
            hangTime: payload.applicationResponsivenessMetrics.map { FieldHistogram($0.histogrammedApplicationHangTime) },
            hitchTimeRatio: payload.animationMetrics.map(Self.hitchTimeRatio),
            peakMemoryBytes: payload.memoryMetrics?.peakMemoryUsage.converted(to: .bytes).value.clampedUInt64,
            cpuTime: payload.cpuMetrics?.cumulativeCPUTime.converted(to: .seconds).value,
            foregroundTerminations: exits.map {
                Terminations(
                    normal: $0.cumulativeNormalAppExitCount,
                    memoryLimit: $0.cumulativeMemoryResourceLimitExitCount,
                    watchdog: $0.cumulativeAppWatchdogExitCount,
                    badAccess: $0.cumulativeBadAccessExitCount,
                    illegalInstruction: $0.cumulativeIllegalInstructionExitCount,
                    abnormal: $0.cumulativeAbnormalExitCount
                )
            }
        )
    }

    // MetricKit reports both ratios in "ms per s"; iOS 26 added the ratio of all animations,
    // which is what Instruments and the iOS 27 API report as well.
    private static func hitchTimeRatio(_ metric: MXAnimationMetric) -> Double {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return metric.hitchTimeRatio.value
        }
        return metric.scrollHitchTimeRatio.value
    }
}

extension FieldHistogram {
    /// Creates a histogram of durations, in seconds, from a MetricKit histogram.
    public init(_ histogram: MXHistogram<UnitDuration>) {
        var buckets: [Bucket] = []
        let enumerator = histogram.bucketEnumerator
        while buckets.count < Self.maximumBucketCount, let bucket = enumerator.nextObject() as? MXHistogramBucket<UnitDuration> {
            buckets.append(Bucket(
                lowerBound: bucket.bucketStart.converted(to: .seconds).value,
                upperBound: bucket.bucketEnd.converted(to: .seconds).value,
                count: bucket.bucketCount
            ))
        }
        self.init(buckets: buckets)
    }
}

#if compiler(>=6.4) && !os(visionOS)
@available(iOS 27.0, macOS 27.0, *)
extension FieldMetrics {
    /// Creates field metrics from a MetricKit report (iOS 27 and macOS 27 and later).
    ///
    /// The figures come from the report's longest interval entry, which covers the whole period.
    public init(_ report: MetricReport) {
        var builder = Builder()
        let entry = report.intervalEntries.max { $0.duration.converted(to: .seconds).value < $1.duration.converted(to: .seconds).value }
        for value in entry?.values ?? [] {
            builder.add(value)
        }
        self.init(
            periodStart: report.timeRange.start,
            periodEnd: report.timeRange.end,
            appBuild: report.environment?.applicationBuildVersion,
            timeToFirstDraw: builder.timeToFirstDraw,
            resumeTime: builder.resumeTime,
            hangTime: builder.hangTime,
            hitchTimeRatio: builder.hitchTimeRatio,
            peakMemoryBytes: builder.peakMemoryBytes,
            cpuTime: builder.cpuTime,
            foregroundTerminations: builder.terminations
        )
    }

    private struct Builder {
        var timeToFirstDraw: FieldHistogram?
        var resumeTime: FieldHistogram?
        var hangTime: FieldHistogram?
        var hitchTimeRatio: Double?
        var peakMemoryBytes: UInt64?
        var cpuTime: Double?
        var terminations: Terminations?

        mutating func add(_ value: MetricResult) {
            switch value {
            case .timeToFirstDraw(let metric): timeToFirstDraw = FieldHistogram(metric.histogram)
            case .applicationResumeTime(let metric): resumeTime = FieldHistogram(metric.histogram)
            case .hangTime(let metric): hangTime = FieldHistogram(metric.histogram)
            case .hitchTime(let metric): hitchTimeRatio = Self.ratio(metric)
            case .peakMemory(let metric): peakMemoryBytes = metric.value.converted(to: .bytes).value.clampedUInt64
            case .cpuTime(let metric): cpuTime = metric.value.converted(to: .seconds).value
            case .foregroundTermination(let metric): terminations = Terminations(metric)
            default: break
            }
        }

        // Computed from the two durations so the result does not depend on how the
        // HitchTimeRatio unit is scaled.
        private static func ratio(_ metric: HitchTimeMetric) -> Double? {
            let animation = metric.totalAnimationTime.converted(to: .seconds).value
            guard animation > 0 else { return nil }
            return metric.totalHitchTime.converted(to: .milliseconds).value / animation
        }
    }
}

@available(iOS 27.0, macOS 27.0, *)
extension FieldMetrics.Terminations {
    init(_ metric: ForegroundTerminationMetric) {
        self.init(
            normal: metric.normalTerminationCount,
            memoryLimit: metric.memoryLimitTerminationCount,
            watchdog: metric.watchdogTerminationCount,
            badAccess: metric.badAccessTerminationCount,
            illegalInstruction: metric.illegalInstructionTerminationCount,
            abnormal: metric.abnormalTerminationCount
        )
    }
}

@available(iOS 27.0, macOS 27.0, *)
extension FieldHistogram {
    /// Creates a histogram of durations, in seconds, from a MetricKit histogram.
    public init(_ histogram: Histogram<UnitDuration>) {
        self.init(buckets: histogram.buckets.prefix(Self.maximumBucketCount).map {
            Bucket(
                lowerBound: $0.lowerBound.converted(to: .seconds).value,
                upperBound: $0.upperBound.converted(to: .seconds).value,
                count: $0.count
            )
        })
    }
}
#endif
#endif
