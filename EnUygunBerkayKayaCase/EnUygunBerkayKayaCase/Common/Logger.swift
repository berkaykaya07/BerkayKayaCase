//
//  Logger.swift
//  EnUygunBerkayKayaCase
//
//  Created by Berkay Kaya
//

import Foundation

enum LogLevel: String {
    case debug = "🔍 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case network = "🌐 NETWORK"
    case success = "✅ SUCCESS"
}

final class Logger {
    
    static let shared = Logger()
    
    private init() {}
    
    // MARK: - Configuration
    
    #if DEBUG
    var isEnabled = true
    #else
    var isEnabled = false
    #endif
    
    // MARK: - Logging Methods
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += "\nError: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, file: file, function: function, line: line)
    }
    
    func success(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .success, file: file, function: function, line: line)
    }
    
    // MARK: - Network Logging
    
    func logRequest(url: URL?, method: String = "GET", headers: [String: String]? = nil, body: Data? = nil) {
        guard isEnabled else { return }
        
        var message = """
        
        ╔═══════════════════════════════════════════════════════════════
        ║ 🚀 REQUEST
        ╠═══════════════════════════════════════════════════════════════
        """
        
        message += "\n║ URL: \(url?.absoluteString ?? "N/A")"
        message += "\n║ Method: \(method)"
        
        if let headers = headers, !headers.isEmpty {
            message += "\n║ Headers:"
            headers.forEach { key, value in
                message += "\n║   \(key): \(value)"
            }
        }
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            message += "\n║ Body:"
            message += "\n║   \(bodyString)"
        }
        
        message += "\n╚═══════════════════════════════════════════════════════════════\n"
        
        print("\(LogLevel.network.rawValue) \(message)")
    }
    
    func logResponse(url: URL?, statusCode: Int, data: Data?, error: Error? = nil) {
        guard isEnabled else { return }
        
        let statusEmoji = statusCode >= 200 && statusCode < 300 ? "✅" : "❌"
        
        var message = """
        
        ╔═══════════════════════════════════════════════════════════════
        ║ \(statusEmoji) RESPONSE
        ╠═══════════════════════════════════════════════════════════════
        """
        
        message += "\n║ URL: \(url?.absoluteString ?? "N/A")"
        message += "\n║ Status Code: \(statusCode)"
        
        if let error = error {
            message += "\n║ Error: \(error.localizedDescription)"
        }
        
        if let data = data {
            message += "\n║ Response Size: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))"
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                
                // Limit response logging to first 1000 characters
                let truncated = prettyString.count > 1000 ? String(prettyString.prefix(1000)) + "\n... (truncated)" : prettyString
                message += "\n║ Response:"
                truncated.split(separator: "\n").forEach { line in
                    message += "\n║   \(line)"
                }
            }
        }
        
        message += "\n╚═══════════════════════════════════════════════════════════════\n"
        
        print("\(LogLevel.network.rawValue) \(message)")
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard isEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        print("""
        \(level.rawValue) [\(timestamp)] [\(fileName):\(line)] \(function)
        \(message)
        """)
    }
    
    // MARK: - Date Formatter
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - Convenience Extensions

extension Logger {
    
    /// Log app lifecycle events
    func logLifecycle(_ event: String) {
        info("🔄 LIFECYCLE: \(event)")
    }
    
    /// Log user interactions
    func logUserAction(_ action: String) {
        info("👆 USER ACTION: \(action)")
    }
    
    /// Log database operations
    func logStorage(_ operation: String) {
        debug("💾 STORAGE: \(operation)")
    }
    
    /// Log navigation
    func logNavigation(from: String, to: String) {
        info("🧭 NAVIGATION: \(from) → \(to)")
    }
}
