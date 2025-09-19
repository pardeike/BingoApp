import Foundation
import Security

/// Persists the OpenAI API key in the user's keychain.
@Observable
final class OpenAIKeyStore: ObservableObject {
    private enum KeychainError: Error {
        case unexpectedStatus(OSStatus)
    }
    
    private let service = "com.bingoapp.openai"
    private let account = "apiKey"
    
    private(set) var hasSavedKey: Bool = false
    
    init() {
        hasSavedKey = (try? readKey())?.isEmpty == false
    }
    
    func save(key: String) throws {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else { return }
        let encodedKey = Data(trimmedKey.utf8)
        
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        var addQuery = baseQuery
        addQuery[kSecValueData as String] = encodedKey
        
        let attributes: [String: Any] = [
            kSecValueData as String: encodedKey
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            hasSavedKey = true
        case errSecDuplicateItem:
            let updateStatus = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)
            if updateStatus == errSecSuccess {
                hasSavedKey = true
            } else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    private func readKey() throws -> String? {
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
    }

    func currentKey() -> String? {
        try? readKey()
    }
}
