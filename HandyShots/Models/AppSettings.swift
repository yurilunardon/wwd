import Foundation

class AppSettings: ObservableObject {
    @Published var screenshotFolder: String {
        didSet {
            UserDefaults.standard.set(screenshotFolder, forKey: "screenshotFolder")
        }
    }
    
    @Published var timeFilterMinutes: Int {
        didSet {
            UserDefaults.standard.set(timeFilterMinutes, forKey: "timeFilterMinutes")
        }
    }
    
    @Published var isFirstLaunch: Bool {
        didSet {
            UserDefaults.standard.set(isFirstLaunch, forKey: "isFirstLaunch")
        }
    }
    
    init() {
        self.screenshotFolder = UserDefaults.standard.string(forKey: "screenshotFolder") ?? ""
        self.timeFilterMinutes = UserDefaults.standard.integer(forKey: "timeFilterMinutes") == 0 ? 5 : UserDefaults.standard.integer(forKey: "timeFilterMinutes")
        self.isFirstLaunch = UserDefaults.standard.object(forKey: "isFirstLaunch") == nil ? true : UserDefaults.standard.bool(forKey: "isFirstLaunch")
    }
}
