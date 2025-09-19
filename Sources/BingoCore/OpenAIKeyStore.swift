import Foundation
import Observation
#if canImport(Security)
import Security
#endif

/// Persists the OpenAI API key in the user's keychain.
@Observable
public final class OpenAIKeyStore {
    private enum KeychainError: Error {
        #if canImport(Security)
        case unexpectedStatus(OSStatus)
        #else
        case notSupported
        #endif
    }
    
    private let service = "com.bingoapp.openai"
    private let account = "apiKey"
    
    public private(set) var hasSavedKey: Bool = false
    
    public init() {
        #if canImport(Security)
        hasSavedKey = (try? readKey())?.isEmpty == false
        #else
        hasSavedKey = false
        #endif
    }
    
    public func save(key: String) throws {
        #if canImport(Security)
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }
        let encodedKey = Data(trimmedKey.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: encodedKey
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            hasSavedKey = true
        case errSecDuplicateItem:
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if updateStatus == errSecSuccess {
                hasSavedKey = true
            } else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
        #else
        // On non-iOS platforms, we can't use keychain, so just track that we have a key
        // but don't actually store it
        hasSavedKey = !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        #endif
    }
    
    private func readKey() throws -> String? {
        #if canImport(Security)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecSuccess:
            if let data = item as? Data, let key = String(data: data, encoding: .utf8) {
                return key
            }
            return nil
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unexpectedStatus(status)
        }
        #else
        // On non-iOS platforms, we can't read from keychain
        return nil
        #endif
    }

    public func currentKey() -> String? {
        try? readKey()
    }
}