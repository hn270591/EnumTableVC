import UIKit

enum UserDefaultsKeys {
    static let displaySetting = "displaySetting"
}

extension UserDefaults {
    static func currentDisplaySetting() -> DisplaySetting {
        guard let rawValue = UserDefaults.standard.value(forKey: UserDefaultsKeys.displaySetting) as? Int else {
            return .automatic
        }
        return DisplaySetting(rawValue: rawValue) ?? .automatic
    }
    
    static func setCurrentDisplaySetting(_ displaySetting: DisplaySetting) {
        UserDefaults.standard.set(displaySetting.rawValue, forKey: UserDefaultsKeys.displaySetting)
    }
}

enum DisplaySetting: Int, CaseIterable {
    case light, dark, automatic
    
    var name: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .dark:
            return "Dark"
        case .light:
            return "Light"
        }
    }
    
    var description: String {
        switch self {
        case .automatic:
            return "User your device setting to determine appearance. The app will change modes when your device setting is changed"
        case .dark:
            return "Ignore your device setting and always render is dark mode"
        case .light:
            return "Ignore your device setting and always render is light mode"
        }
    }
    
    var userInterface: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .automatic: return .unspecified
        }
    }
}

class ViewController: UITableViewController {
    enum ReuseIdentifier {
        static let displaySettingCell = "DisplaySettingCell"
        static let textSizeCell = "TextSizeCell"
    }

    enum Section: Int, CaseIterable {
        case displaySettings
        case textSize
        
        var header: String? {
            switch self {
            case .displaySettings: return "Appearance"
            default: return " "
            }
        }
        
        var footer: String? {
            switch self {
            case .displaySettings: return nil
            case .textSize: return "Adjust text size"
            }
        }
    }
    
    enum TextSetting: String, CaseIterable {
        case textSize
        
        var name: String {
            switch self {
            case .textSize: return "Text Size"
            }
        }
    }
    
    private var sections: [Section] = [.displaySettings, .textSize] // Section.allCases
    private var displaySettings: [DisplaySetting] = [.dark, .light, .automatic] // DisplaySetting.allCases
    private var textSettings: [TextSetting] = [.textSize]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.window?.overrideUserInterfaceStyle = UserDefaults.currentDisplaySetting().userInterface
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .displaySettings:
            return displaySettings.count
        case .textSize:
            return textSettings.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .displaySettings:
            let setting = displaySettings[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.displaySettingCell, for: indexPath)
            let selected = UserDefaults.currentDisplaySetting() == setting
            let cfg = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22))
            cell.imageView?.image = UIImage(systemName: selected ? "checkmark.circle.fill" : "circle", withConfiguration: cfg)
            cell.imageView?.tintColor = selected ? view.tintColor : .gray
            cell.textLabel?.text = setting.name
            cell.detailTextLabel?.text = setting.description
            return cell
        case .textSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.textSizeCell, for: indexPath)
            let item = textSettings[indexPath.row]
            cell.textLabel?.text = item.name
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .displaySettings:
            let setting = displaySettings[indexPath.row]
            UserDefaults.setCurrentDisplaySetting(setting)
            tableView.performBatchUpdates {
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
            UIView.animate(withDuration: 0.25) {
                self.view.window?.overrideUserInterfaceStyle = setting.userInterface
            }
        case .textSize:
            print("")
        }
    }
}
