import Foundation

/// Formats measurements the way ``PerformanceHUD`` shows them.
public enum PerformanceFormat {
    /// Bytes in mebibytes with one decimal, such as `"142.3 MB"`.
    public static func megabytes(_ bytes: UInt64, locale: Locale = .current) -> String {
        "\(number(Double(bytes) / 1_048_576, digits: 1, locale: locale)) MB"
    }

    /// CPU usage in percent of one core without decimals, such as `"37%"`.
    public static func cpu(_ usage: Double, locale: Locale = .current) -> String {
        "\(number(usage, digits: 0, locale: locale))%"
    }

    /// A frame rate without decimals, such as `"119 fps"`.
    public static func framesPerSecond(_ value: Double, locale: Locale = .current) -> String {
        "\(number(value, digits: 0, locale: locale)) fps"
    }

    /// A hitch time ratio with one decimal, such as `"3.2 ms/s"`.
    public static func hitchTimeRatio(_ value: Double, locale: Locale = .current) -> String {
        "\(number(value, digits: 1, locale: locale)) ms/s"
    }

    /// A duration in milliseconds without decimals, such as `"412 ms"`.
    public static func milliseconds(_ duration: Duration, locale: Locale = .current) -> String {
        "\(number(duration.seconds * 1000, digits: 0, locale: locale)) ms"
    }

    /// A number with a fixed count of decimals; `–` for NaN and infinity.
    static func number(_ value: Double, digits: Int, locale: Locale) -> String {
        guard value.isFinite else { return "–" }
        return value.formatted(.number.precision(.fractionLength(digits)).locale(locale))
    }
}
