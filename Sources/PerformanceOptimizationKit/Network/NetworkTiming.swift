import Foundation

/// Where the time of one HTTP request went, from `URLSessionTaskMetrics`.
///
/// The URL is stored in its redacted form (see ``URLRedaction``), so a timing can be logged or
/// sent with a report without the query string, credentials or identifiers in the path.
public struct NetworkTiming: Sendable, Equatable, Codable {
    /// The redacted URL of the final request, after redirects.
    public let url: String
    /// The HTTP method, such as `GET`.
    public let method: String?
    /// The HTTP status code, or `nil` when there was no HTTP response.
    public let statusCode: Int?
    /// The protocol, such as `h2`, `h3` or `http/1.1`, when the system reports it.
    public let networkProtocol: String?
    /// A Boolean value that indicates whether the request reused an open connection.
    public let reusedConnection: Bool
    /// A Boolean value that indicates whether the response came from the local cache.
    public let fromCache: Bool
    /// The time from the start of the task to its end, including redirects.
    public let total: Duration?
    /// The phases of the final request.
    public let phases: Phases
    /// The bytes of the response body as received, before decompression.
    public let responseBodyBytes: Int64

    /// Creates a timing from known values, for tests and previews.
    public init(url: String, method: String? = nil, statusCode: Int? = nil, networkProtocol: String? = nil, reusedConnection: Bool = false, fromCache: Bool = false, total: Duration? = nil, phases: Phases = Phases(), responseBodyBytes: Int64 = 0) {
        self.url = url
        self.method = method
        self.statusCode = statusCode
        self.networkProtocol = networkProtocol
        self.reusedConnection = reusedConnection
        self.fromCache = fromCache
        self.total = total
        self.phases = phases
        self.responseBodyBytes = max(responseBodyBytes, 0)
    }

    /// Creates a timing from the metrics `URLSession` delivers when a task finishes.
    ///
    /// Returns `nil` when the metrics hold no transaction, which happens when a task fails
    /// before it sends a request.
    public init?(metrics: URLSessionTaskMetrics) {
        guard let transaction = metrics.transactionMetrics.last else { return nil }
        let request = transaction.request
        self.init(
            url: request.url.map(URLRedaction.redact) ?? "<none>",
            method: request.httpMethod,
            statusCode: (transaction.response as? HTTPURLResponse)?.statusCode,
            networkProtocol: transaction.networkProtocolName,
            reusedConnection: transaction.isReusedConnection,
            fromCache: transaction.resourceFetchType == .localCache,
            total: Duration.validSeconds(metrics.taskInterval.duration),
            phases: Phases(transaction),
            responseBodyBytes: transaction.countOfResponseBodyBytesReceived
        )
    }
}

extension NetworkTiming {
    /// The phases of one request. A phase is `nil` when it did not happen (no DNS lookup on a
    /// reused connection, no TLS on `http`) or when its times are missing or out of order.
    public struct Phases: Sendable, Equatable, Codable {
        /// Resolving the host name.
        public let domainLookup: Duration?
        /// Opening the connection, including the TLS handshake.
        public let connect: Duration?
        /// The TLS handshake.
        public let secureConnection: Duration?
        /// Sending the request headers and body.
        public let request: Duration?
        /// From the end of the request to the first byte of the response: mostly the server's
        /// own processing time plus one round trip.
        public let waiting: Duration?
        /// Receiving the response.
        public let response: Duration?

        /// Creates phases from known values, for tests and previews.
        public init(domainLookup: Duration? = nil, connect: Duration? = nil, secureConnection: Duration? = nil, request: Duration? = nil, waiting: Duration? = nil, response: Duration? = nil) {
            self.domainLookup = domainLookup
            self.connect = connect
            self.secureConnection = secureConnection
            self.request = request
            self.waiting = waiting
            self.response = response
        }

        /// Computes the phases from the timestamps of a transaction.
        public init(_ transaction: URLSessionTaskTransactionMetrics) {
            self.init(
                domainLookup: Self.span(transaction.domainLookupStartDate, transaction.domainLookupEndDate),
                connect: Self.span(transaction.connectStartDate, transaction.connectEndDate),
                secureConnection: Self.span(transaction.secureConnectionStartDate, transaction.secureConnectionEndDate),
                request: Self.span(transaction.requestStartDate, transaction.requestEndDate),
                waiting: Self.span(transaction.requestEndDate, transaction.responseStartDate),
                response: Self.span(transaction.responseStartDate, transaction.responseEndDate)
            )
        }

        /// The time from `start` to `end`, or `nil` when either is missing or `end` is earlier.
        public static func span(_ start: Date?, _ end: Date?) -> Duration? {
            guard let start, let end else { return nil }
            return Duration.validSeconds(end.timeIntervalSince(start))
        }
    }
}
