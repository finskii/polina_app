import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var password: String
}

final class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var currentUser: User?
    @Published var isAuthorized: Bool = false

    private let userKey = "current_user_key"
    private let authKey = "is_user_logged_in"

    private init() {
        loadState()
    }

    private func loadState() {
        // Загрузка пользователя
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
        }

        // Загрузка статуса авторизации
        self.isAuthorized = UserDefaults.standard.bool(forKey: authKey)
    }

    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    private func saveAuthStatus(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: authKey)
    }

    func register(name: String, email: String, password: String) -> Bool {
        guard currentUser == nil else {
            return false // уже есть пользователь
        }

        let user = User(id: UUID(), name: name, email: email, password: password)
        currentUser = user
        isAuthorized = true
        saveUser(user)
        saveAuthStatus(true)
        return true
    }

    func login(email: String, password: String) -> Bool {
        guard let user = currentUser else { return false }

        if user.email == email && user.password == password {
            isAuthorized = true
            saveAuthStatus(true)
            return true
        }

        return false
    }

    func logout() {
        isAuthorized = false
        saveAuthStatus(false)
    }
}


//Эта вью модель для тебя только для примера, она тебе не понадобится, как разберешься с подключением менеджера пользователей к своим вью моделям - удали ее из файла
class TestViewModel: ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var currentUser: User?

    private let manager = UserManager.shared

    init() {
        // Загружаем состояние при инициализации
        self.isAuthorized = manager.isAuthorized
        self.currentUser = manager.currentUser
    }

    // Регистрация пользователя во вью модели авторизации
    func register() {
        let success = manager.register(name: "сюда нужно передать имя из твоей вью модели регистрации",
                                       email: "сюда нужно передать емейл из твоей вью модели регистрации",
                                       password: "а сюда нужно передать пароль из твоей вью модели регистрации")
        if success {
            self.isAuthorized = true
            self.currentUser = manager.currentUser
        } else {
            print("Пользователь уже зарегистрирован")
        }
    }

    // Авторизация пользователя во вью модели атворизации
    func login() {
        let success = manager.login(email: "сюда нужно передать емейл из твоей вью модели авторизации",
                                    password: "а сюда нужно передать пароль из твоей вью модели авторизации")
        if success {
            self.isAuthorized = true
            self.currentUser = manager.currentUser
        } else {
            print("Неверный логин или пароль")
        }
    }

    // Выход из аккаунта
    func logout() {
        manager.logout()
        self.isAuthorized = false
        self.currentUser = nil
    }

    // Удаление аккаунта
    func deleteAccount() {
        manager.logout()
        UserDefaults.standard.removeObject(forKey: "current_user_key")
        self.currentUser = nil
        self.isAuthorized = false
    }
}

////чтобы при старте приложения понять, какой экран открывать - можешь сделать следующее:
//private let manager = UserManager.shared
// if manager.currentUser != nil && manager.isAuthorized {
//     //переходим на главный экран (список задач вроде, да?)
// } else if manager.currentUser != nil && !manager.isAuthorized {
//     //переходим на экран авторизации
// } else {
//     //переходим на экран регистрации
// }
