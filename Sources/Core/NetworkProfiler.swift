//
//  NetworkProfiler.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import Foundation

/// Comprehensive network request profiling and optimization
public final class NetworkProfiler: NSObject {
    
    // MARK: - Singleton
    public static let shared = NetworkProfiler()
    
    // MARK: - Properties
    private var requests: [String: NetworkRequest] = [:]
    private var completedRequests: [NetworkRequest] = []
    private let profileQueue = DispatchQueue(label: "com.performancekit.network", qos: .utility)
    private var isEnabled = false
    private var config = Configuration()
    
    // URL Protocol for interception
    private var interceptorSession: URLSession?
    
    // Statistics
    private var totalBytesReceived: Int64 = 0
    private var totalBytesSent: Int64 = 0
    private var totalRequestCount: Int = 0
    private var failedRequestCount: Int = 0
    
    // Callbacks
    public var onRequestStarted: ((NetworkRequest) -> Void)?
    public var onRequestCompleted: ((NetworkRequest) -> Void)?
    public var onSlowRequestDetected: ((NetworkRequest) -> Void)?
    
    // MARK: - Configuration
    public struct Configuration {
        public var slowRequestThreshold: TimeInterval = 3.0
        public var maxStoredRequests: Int = 1000
        public var enableDetailedMetrics: Bool = true
        public var trackDNSLookup: Bool = true
        public var trackTLSHandshake: Bool = true
        public var groupByEndpoint: Bool = true
        
        public init() {}
    }
    
    // MARK: - Initialization
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Configure the network profiler
    public func configure(_ configuration: Configuration) {
        self.config = configuration
    }
    
    /// Enable network profiling
    public func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        
        // Register URL Protocol for interception
        URLProtocol.registerClass(NetworkInterceptorProtocol.self)
        NetworkInterceptorProtocol.profiler = self
    }
    
    /// Disable network profiling
    public func disable() {
        isEnabled = false
        URLProtocol.unregisterClass(NetworkInterceptorProtocol.self)
    }
    
    /// Create a profiling URLSession
    public func createProfiledSession(configuration: URLSessionConfiguration = .default) -> URLSession {
        let config = configuration
        var protocols = config.protocolClasses ?? []
        protocols.insert(NetworkInterceptorProtocol.self, at: 0)
        config.protocolClasses = protocols
        
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
    
    /// Start tracking a request manually
    public func startRequest(identifier: String, url: URL, method: String) {
        profileQueue.async {
            let request = NetworkRequest(
                identifier: identifier,
                url: url,
                method: method,
                startTime: Date()
            )
            self.requests[identifier] = request
            self.totalRequestCount += 1
            
            DispatchQueue.main.async {
                self.onRequestStarted?(request)
            }
        }
    }
    
    /// Complete a tracked request
    public func completeRequest(
        identifier: String,
        statusCode: Int?,
        bytesReceived: Int64,
        bytesSent: Int64,
        error: Error?
    ) {
        profileQueue.async {
            guard var request = self.requests.removeValue(forKey: identifier) else { return }
            
            request.endTime = Date()
            request.duration = request.endTime!.timeIntervalSince(request.startTime)
            request.statusCode = statusCode
            request.bytesReceived = bytesReceived
            request.bytesSent = bytesSent
            request.error = error?.localizedDescription
            request.isSuccessful = error == nil && (statusCode ?? 0) < 400
            
            // Update statistics
            self.totalBytesReceived += bytesReceived
            self.totalBytesSent += bytesSent
            if !request.isSuccessful {
                self.failedRequestCount += 1
            }
            
            // Store completed request
            self.completedRequests.append(request)
            if self.completedRequests.count > self.config.maxStoredRequests {
                self.completedRequests.removeFirst()
            }
            
            DispatchQueue.main.async {
                self.onRequestCompleted?(request)
                
                // Check for slow request
                if let duration = request.duration, duration > self.config.slowRequestThreshold {
                    self.onSlowRequestDetected?(request)
                }
            }
        }
    }
    
    /// Add timing metrics to a request
    public func addTimingMetrics(
        identifier: String,
        dnsLookup: TimeInterval?,
        tcpConnect: TimeInterval?,
        tlsHandshake: TimeInterval?,
        requestSent: TimeInterval?,
        responseReceived: TimeInterval?,
        contentDownload: TimeInterval?
    ) {
        profileQueue.async {
            guard var request = self.requests[identifier] else { return }
            
            request.timingMetrics = TimingMetrics(
                dnsLookup: dnsLookup,
                tcpConnect: tcpConnect,
                tlsHandshake: tlsHandshake,
                requestSent: requestSent,
                responseReceived: responseReceived,
                contentDownload: contentDownload
            )
            
            self.requests[identifier] = request
        }
    }
    
    /// Get all completed requests
    public func getCompletedRequests() -> [NetworkRequest] {
        var result: [NetworkRequest] = []
        profileQueue.sync {
            result = completedRequests
        }
        return result
    }
    
    /// Get requests grouped by endpoint
    public func getRequestsByEndpoint() -> [String: [NetworkRequest]] {
        var result: [String: [NetworkRequest]] = [:]
        profileQueue.sync {
            result = Dictionary(grouping: completedRequests) { request in
                guard let host = request.url.host else { return "Unknown" }
                return "\(host)\(request.url.path)"
            }
        }
        return result
    }
    
    /// Get network statistics
    public func getStatistics() -> NetworkStatistics {
        var stats: NetworkStatistics!
        profileQueue.sync {
            let durations = completedRequests.compactMap { $0.duration }
            let avgDuration = durations.isEmpty ? 0 : durations.reduce(0, +) / Double(durations.count)
            let sortedDurations = durations.sorted()
            
            stats = NetworkStatistics(
                totalRequests: totalRequestCount,
                successfulRequests: totalRequestCount - failedRequestCount,
                failedRequests: failedRequestCount,
                totalBytesReceived: totalBytesReceived,
                totalBytesSent: totalBytesSent,
                averageResponseTime: avgDuration,
                minResponseTime: sortedDurations.first ?? 0,
                maxResponseTime: sortedDurations.last ?? 0,
                percentile95: sortedDurations.isEmpty ? 0 : sortedDurations[Int(Double(sortedDurations.count) * 0.95)],
                pendingRequests: requests.count,
                successRate: totalRequestCount > 0 ? Double(totalRequestCount - failedRequestCount) / Double(totalRequestCount) * 100 : 0
            )
        }
        return stats
    }
    
    /// Get performance analysis
    public func getPerformanceAnalysis() -> NetworkPerformanceAnalysis {
        let stats = getStatistics()
        var issues: [NetworkIssue] = []
        var recommendations: [NetworkRecommendation] = []
        
        // Analyze success rate
        if stats.successRate < 95 {
            issues.append(NetworkIssue(
                type: .highFailureRate,
                description: "Request failure rate is \(String(format: "%.1f", 100 - stats.successRate))%",
                severity: stats.successRate < 90 ? .high : .medium
            ))
            recommendations.append(NetworkRecommendation(
                title: "Implement retry logic",
                description: "Add exponential backoff retry for failed requests",
                impact: .high
            ))
        }
        
        // Analyze response time
        if stats.averageResponseTime > 2.0 {
            issues.append(NetworkIssue(
                type: .slowResponse,
                description: "Average response time is \(String(format: "%.2f", stats.averageResponseTime))s",
                severity: stats.averageResponseTime > 5.0 ? .high : .medium
            ))
            recommendations.append(NetworkRecommendation(
                title: "Optimize API endpoints",
                description: "Consider implementing pagination, caching, or CDN",
                impact: .high
            ))
        }
        
        // Analyze bandwidth
        let totalBytes = stats.totalBytesReceived + stats.totalBytesSent
        if stats.totalRequests > 0 {
            let avgBytesPerRequest = Double(totalBytes) / Double(stats.totalRequests)
            if avgBytesPerRequest > 1_000_000 { // 1MB
                issues.append(NetworkIssue(
                    type: .largePayloa,
                    description: "Average payload size is \(ByteCountFormatter.string(fromByteCount: Int64(avgBytesPerRequest), countStyle: .file))",
                    severity: .medium
                ))
                recommendations.append(NetworkRecommendation(
                    title: "Compress responses",
                    description: "Enable gzip/brotli compression and optimize payload sizes",
                    impact: .medium
                ))
            }
        }
        
        // Calculate health score
        var healthScore = 100.0
        healthScore -= (100 - stats.successRate) * 0.5
        healthScore -= min(stats.averageResponseTime * 10, 30)
        healthScore = max(healthScore, 0)
        
        return NetworkPerformanceAnalysis(
            healthScore: healthScore,
            issues: issues,
            recommendations: recommendations,
            statistics: stats
        )
    }
    
    /// Clear all stored data
    public func clear() {
        profileQueue.async {
            self.requests.removeAll()
            self.completedRequests.removeAll()
            self.totalBytesReceived = 0
            self.totalBytesSent = 0
            self.totalRequestCount = 0
            self.failedRequestCount = 0
        }
    }
}

// MARK: - URL Protocol Interceptor

private class NetworkInterceptorProtocol: URLProtocol {
    
    static weak var profiler: NetworkProfiler?
    
    private var dataTask: URLSessionDataTask?
    private var receivedData = Data()
    private var response: URLResponse?
    private var requestIdentifier: String = ""
    private var startTime: Date?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Don't intercept if already handled
        if URLProtocol.property(forKey: "NetworkInterceptorHandled", in: request) != nil {
            return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }
        
        // Mark as handled
        URLProtocol.setProperty(true, forKey: "NetworkInterceptorHandled", in: mutableRequest)
        
        // Generate identifier
        requestIdentifier = UUID().uuidString
        startTime = Date()
        
        // Notify profiler
        if let url = request.url {
            NetworkInterceptorProtocol.profiler?.startRequest(
                identifier: requestIdentifier,
                url: url,
                method: request.httpMethod ?? "GET"
            )
        }
        
        // Create session and task
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        dataTask = session.dataTask(with: mutableRequest as URLRequest)
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
    }
}

extension NetworkInterceptorProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let httpResponse = response as? HTTPURLResponse
        
        NetworkInterceptorProtocol.profiler?.completeRequest(
            identifier: requestIdentifier,
            statusCode: httpResponse?.statusCode,
            bytesReceived: Int64(receivedData.count),
            bytesSent: Int64(request.httpBody?.count ?? 0),
            error: error
        )
        
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}

// MARK: - Data Types

public struct NetworkRequest: Codable, Sendable, Identifiable {
    public let id: String
    public let identifier: String
    public let url: URL
    public let method: String
    public let startTime: Date
    public var endTime: Date?
    public var duration: TimeInterval?
    public var statusCode: Int?
    public var bytesReceived: Int64 = 0
    public var bytesSent: Int64 = 0
    public var error: String?
    public var isSuccessful: Bool = false
    public var timingMetrics: TimingMetrics?
    
    public init(identifier: String, url: URL, method: String, startTime: Date) {
        self.id = identifier
        self.identifier = identifier
        self.url = url
        self.method = method
        self.startTime = startTime
    }
    
    public var formattedDuration: String {
        guard let duration = duration else { return "N/A" }
        return String(format: "%.0f ms", duration * 1000)
    }
    
    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: bytesReceived, countStyle: .memory)
    }
}

public struct TimingMetrics: Codable, Sendable {
    public let dnsLookup: TimeInterval?
    public let tcpConnect: TimeInterval?
    public let tlsHandshake: TimeInterval?
    public let requestSent: TimeInterval?
    public let responseReceived: TimeInterval?
    public let contentDownload: TimeInterval?
    
    public var formattedBreakdown: String {
        var parts: [String] = []
        if let dns = dnsLookup { parts.append("DNS: \(String(format: "%.0f", dns * 1000))ms") }
        if let tcp = tcpConnect { parts.append("TCP: \(String(format: "%.0f", tcp * 1000))ms") }
        if let tls = tlsHandshake { parts.append("TLS: \(String(format: "%.0f", tls * 1000))ms") }
        if let download = contentDownload { parts.append("Download: \(String(format: "%.0f", download * 1000))ms") }
        return parts.joined(separator: " | ")
    }
}

public struct NetworkStatistics: Codable, Sendable {
    public let totalRequests: Int
    public let successfulRequests: Int
    public let failedRequests: Int
    public let totalBytesReceived: Int64
    public let totalBytesSent: Int64
    public let averageResponseTime: TimeInterval
    public let minResponseTime: TimeInterval
    public let maxResponseTime: TimeInterval
    public let percentile95: TimeInterval
    public let pendingRequests: Int
    public let successRate: Double
    
    public var formattedBytesReceived: String {
        ByteCountFormatter.string(fromByteCount: totalBytesReceived, countStyle: .memory)
    }
    
    public var formattedBytesSent: String {
        ByteCountFormatter.string(fromByteCount: totalBytesSent, countStyle: .memory)
    }
}

public struct NetworkPerformanceAnalysis: Codable, Sendable {
    public let healthScore: Double
    public let issues: [NetworkIssue]
    public let recommendations: [NetworkRecommendation]
    public let statistics: NetworkStatistics
    
    public var grade: String {
        switch healthScore {
        case 90...: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

public struct NetworkIssue: Codable, Sendable {
    public let type: NetworkIssueType
    public let description: String
    public let severity: IssueSeverity
}

public enum NetworkIssueType: String, Codable, Sendable {
    case highFailureRate = "High Failure Rate"
    case slowResponse = "Slow Response"
    case largePayloa = "Large Payload"
    case tooManyRequests = "Too Many Requests"
    case connectionIssue = "Connection Issue"
}

public enum IssueSeverity: String, Codable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

public struct NetworkRecommendation: Codable, Sendable {
    public let title: String
    public let description: String
    public let impact: ImpactLevel
}
