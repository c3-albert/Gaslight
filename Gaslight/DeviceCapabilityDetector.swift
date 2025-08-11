//
//  DeviceCapabilityDetector.swift
//  Gaslight
//
//  Created by Albert Xu on 8/6/25.
//

import Foundation
import UIKit

enum AICapabilityTier {
    case premium      // iPhone 15 Pro+, M1+ iPads - Full on-device AI
    case standard     // iPhone 12-14, A14-A16 - Lightweight models
    case basic        // Older devices - Enhanced templates
}

enum DeviceType {
    case iPhone
    case iPad
    case mac
    case unknown
}

class DeviceCapabilityDetector {
    static let shared = DeviceCapabilityDetector()
    
    private init() {}
    
    // MARK: - Public Interface
    
    var aiCapabilityTier: AICapabilityTier {
        return determineAICapability()
    }
    
    var deviceType: DeviceType {
        return getCurrentDeviceType()
    }
    
    var modelIdentifier: String {
        return getModelIdentifier()
    }
    
    var totalRAM: UInt64 {
        return getTotalRAM()
    }
    
    var hasNeuralEngine: Bool {
        return checkNeuralEngineAvailability()
    }
    
    // MARK: - Capability Detection
    
    private func determineAICapability() -> AICapabilityTier {
        let identifier = getModelIdentifier()
        
        // Premium Tier - Latest devices with excellent AI performance
        let premiumDevices = [
            // iPhone 15 Pro series (A17 Pro)
            "iPhone16,1",  // iPhone 15 Pro
            "iPhone16,2",  // iPhone 15 Pro Max
            
            // Future iPhone 16 series (A18)
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4",
            
            // M1+ iPads
            "iPad13,1", "iPad13,2",           // iPad Pro 11" M1
            "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7", // iPad Pro 12.9" M1
            "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11", // iPad Pro 11" M2
            "iPad13,16", "iPad13,17", "iPad13,18", "iPad13,19", // iPad Pro 12.9" M2
            
            // M1+ iPad Air
            "iPad13,1", "iPad13,2",           // iPad Air M1
            "iPad14,8", "iPad14,9",           // iPad Air M2
            
            // M-series Macs (if running as Catalyst)
            "MacBookAir10,1", "MacBookPro17,1", "MacBookPro18,1", // M1 devices
            "Mac13,1", "Mac13,2", "Mac14,2"   // M2+ devices
        ]
        
        // Standard Tier - Good performance devices
        let standardDevices = [
            // iPhone 12-14 series (A14-A16)
            "iPhone13,1", "iPhone13,2", "iPhone13,3", "iPhone13,4", // iPhone 12 series
            "iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5", // iPhone 13 series
            "iPhone14,6",                                             // iPhone SE 3
            "iPhone14,7", "iPhone14,8",                               // iPhone 14/Plus
            "iPhone15,2", "iPhone15,3",                               // iPhone 14 Pro series
            "iPhone15,4", "iPhone15,5",                               // iPhone 15/Plus
            
            // A14+ iPads
            "iPad11,1", "iPad11,2", "iPad11,3", "iPad11,4", "iPad11,6", "iPad11,7", // iPad Pro A12Z/A12X
            "iPad12,1", "iPad12,2",           // iPad Air 4 (A14)
            "iPad14,1", "iPad14,2",           // iPad mini 6 (A15)
            "iPad13,18", "iPad13,19"          // iPad 10 (A14)
        ]
        
        if premiumDevices.contains(identifier) {
            return .premium
        } else if standardDevices.contains(identifier) {
            return .standard
        } else {
            return .basic
        }
    }
    
    // MARK: - Device Information
    
    private func getCurrentDeviceType() -> DeviceType {
        let identifier = getModelIdentifier()
        
        if identifier.hasPrefix("iPhone") {
            return .iPhone
        } else if identifier.hasPrefix("iPad") {
            return .iPad
        } else if identifier.hasPrefix("Mac") {
            return .mac
        } else {
            return .unknown
        }
    }
    
    private func getModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            let unicodeScalar = UnicodeScalar(UInt8(value))
            return identifier + String(unicodeScalar)
        }
        return identifier
    }
    
    private func getTotalRAM() -> UInt64 {
        return ProcessInfo.processInfo.physicalMemory
    }
    
    private func checkNeuralEngineAvailability() -> Bool {
        // Neural Engine available on A11+ chips
        let identifier = getModelIdentifier()
        
        // Extract device generation from identifier
        if identifier.hasPrefix("iPhone") {
            // iPhone X and later have Neural Engine
            let phoneModels = ["iPhone10,", "iPhone11,", "iPhone12,", "iPhone13,", "iPhone14,", "iPhone15,", "iPhone16,", "iPhone17,"]
            return phoneModels.contains { identifier.hasPrefix($0) }
        } else if identifier.hasPrefix("iPad") {
            // iPad Pro 2018+ and iPad Air 2019+ have Neural Engine
            let ipadModels = ["iPad8,", "iPad11,", "iPad12,", "iPad13,", "iPad14,"]
            return ipadModels.contains { identifier.hasPrefix($0) }
        }
        
        return false
    }
    
    // MARK: - Performance Metrics
    
    var recommendedModelSize: String {
        switch aiCapabilityTier {
        case .premium:
            return "7B" // 7 billion parameter models
        case .standard:
            return "3B" // 3 billion parameter models  
        case .basic:
            return "Enhanced Templates"
        }
    }
    
    var estimatedInferenceTime: String {
        switch aiCapabilityTier {
        case .premium:
            return "1-2 seconds"
        case .standard:
            return "3-5 seconds"
        case .basic:
            return "Instant"
        }
    }
    
    // MARK: - Debug Information
    
    func getDetailedCapabilityReport() -> String {
        return """
        Device Capability Report
        ========================
        Model: \(modelIdentifier)
        Device Type: \(deviceType)
        AI Tier: \(aiCapabilityTier)
        Total RAM: \(ByteCountFormatter.string(fromByteCount: Int64(totalRAM), countStyle: .memory))
        Neural Engine: \(hasNeuralEngine ? "Available" : "Not Available")
        Recommended Model: \(recommendedModelSize)
        Estimated Speed: \(estimatedInferenceTime)
        """
    }
}

// MARK: - Extensions for String Representation

extension AICapabilityTier: CustomStringConvertible {
    var description: String {
        switch self {
        case .premium: return "Premium"
        case .standard: return "Standard"  
        case .basic: return "Basic"
        }
    }
}

extension DeviceType: CustomStringConvertible {
    var description: String {
        switch self {
        case .iPhone: return "iPhone"
        case .iPad: return "iPad"
        case .mac: return "Mac"
        case .unknown: return "Unknown"
        }
    }
}