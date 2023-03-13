import UIKit

// MARK: - Traditional Singleton Pattern

// Model
struct User: Identifiable {
    let id = UUID().uuidString
    let name: String
}

final class UserCacheManager {

    static let shared = UserCacheManager()
    private(set) var cachedUsers = [String : User]()

    private init() { }

    func add(_ user: User) {
        cachedUsers[user.id] = user
    }

    func getCachedUsers() -> [User] {
        Array(cachedUsers.values)
    }
}

protocol ViewModelInterface {
    func cache(_ user: User)
    func getCachedUsers() -> [User]
}

final class ViewModel: ViewModelInterface {

    func cache(_ user: User) {
        UserCacheManager.shared.add(user)
    }

    func getCachedUsers() -> [User] {
        UserCacheManager.shared.getCachedUsers()
    }
}

let viewModel = ViewModel()
viewModel.cache(User(name: "User1"))
viewModel.cache(User(name: "User2"))
viewModel.cache(User(name: "User3"))

print("Users from traditional version ->", viewModel.getCachedUsers().map({ $0.name }))


// MARK: - Testable version

// Create Interface to wrap singleton class

protocol UserCacheProtocol {
    func add(_ user: User)
    func getCachedUsers() -> [User]
}

// Create a singleton class that inherits from a wrapped interface

final class UserCacheManager2: UserCacheProtocol {
    
    static let shared: UserCacheProtocol = UserCacheManager2()
    private(set) var cachedUsers = [String : User]()
        
    func add(_ user: User) {
        cachedUsers[user.id] = user
    }
    
    func getCachedUsers() -> [User] {
        Array(cachedUsers.values)
    }
}

// Create a mock singleton class that inherits from wrapped singleton interface

class MockUserCacheManager: UserCacheProtocol {
    
    var userCounter = 0
    var mockUsers = [String : User]()

    func add(_ user: User) {
        userCounter += 1
        mockUsers[String(userCounter)] = user
    }
    
    func getCachedUsers() -> [User] {
        Array(mockUsers.values)
    }
}

// Add a init to your interface that want to make test
// Add that wrapped singleton interface as input to init

protocol TestViewModelInterface {
    func cache(_ user: User)
    func getCachedUsers() -> [User]
    
    init(cacheManager: UserCacheProtocol)
}

final class TestViewModel: TestViewModelInterface {

    var cacheManager: UserCacheProtocol

    init(cacheManager: UserCacheProtocol) {
        self.cacheManager = cacheManager
    }

    func cache(_ user: User) {
        cacheManager.add(user)
    }

    func getCachedUsers() -> [User] {
        cacheManager.getCachedUsers()
    }
}

// Prod version

let testableViewModel = TestViewModel(cacheManager: UserCacheManager2.shared)

testableViewModel.cache(User(name: "User1"))
testableViewModel.cache(User(name: "User2"))
testableViewModel.cache(User(name: "User3"))

print("Users from prod version ->", testableViewModel.getCachedUsers().map({ $0.name }))

// Test version

let mockViewModel = TestViewModel(cacheManager: MockUserCacheManager())
mockViewModel.cache(User(name: "MockUser1"))
mockViewModel.cache(User(name: "MockUser2"))
mockViewModel.cache(User(name: "MockUser3"))

print("Users from testable version ->", mockViewModel.getCachedUsers().map({ $0.name }))
