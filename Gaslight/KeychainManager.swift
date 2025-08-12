//
//  KeychainManager.swift
//  Gaslight
//
//  Created by Claude on 8/12/25.
//

import Foundation
import Security

class KeychainManager {
    
    // MARK: - API Key Storage
    
    static func saveAPIKey(_ key: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        return save(key: "groq_api_key", data: data)
    }
    
    static func loadAPIKey() -> String? {
        guard let data = load(key: "groq_api_key") else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func deleteAPIKey() -> Bool {
        return delete(key: "groq_api_key")
    }
    
    // MARK: - Generic Keychain Operations
    
    private static func save(key: String, data: Data) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]
        
        // Delete any existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private static func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    private static func delete(key: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Migration Helper
    
    static func migrateFromUserDefaults() {
        // Check if there's an old API key in UserDefaults
        if let oldKey = UserDefaults.standard.string(forKey: "groq_api_key"),
           !oldKey.isEmpty {
            
            // Save to Keychain
            if saveAPIKey(oldKey) {
                print("✅ Migrated API key from UserDefaults to Keychain")
                // Remove from UserDefaults
                UserDefaults.standard.removeObject(forKey: "groq_api_key")
            } else {
                print("❌ Failed to migrate API key to Keychain")
            }
        }
    }
}