import Foundation

enum UserDefaultKey: String {
    case urlLastVisited
    case urlHistory
}

protocol LocalStorageProviderProtocol {
    func get(_ key: UserDefaultKey) -> AnyObject?
    func set<T>(_ data: T?, key: UserDefaultKey)
    func removeValue(at key: UserDefaultKey)
}

class LocalStorageProvider: LocalStorageProviderProtocol {
    
    private let localStorage: UserDefaults
    
    init(localStorage: UserDefaults) {
        self.localStorage = localStorage
    }
    
    func get(_ key: UserDefaultKey) -> AnyObject? {
        if let value = localStorage.object(forKey: key.rawValue) {
            return value as AnyObject?
        } else {
            return nil
        }
    }
    
    func set<T>(_ data: T?, key: UserDefaultKey) {
        guard data != nil else { return }
        localStorage.set(data, forKey: key.rawValue)
    }
    
    func removeValue(at key: UserDefaultKey) {
        localStorage.removeObject(forKey: key.rawValue)
    }
}
