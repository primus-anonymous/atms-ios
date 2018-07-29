import UIKit


class SettingsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    
    var items : [[String: Any]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "settings".localized
        
        tableView.tableFooterView = UIView()
        
        items = [
            [
                "header": "settings_header_data".localized,
                "items": [
                    SettingItem(type: .osm, title: "settings_header_about_osm".localized, subTitle: "settings_value_about_osm".localized)
                ]
            ],
            [
                "header": "settings_header_common".localized,
                "items": [
                    SettingItem(type: .rate, title: "settings_header_rate_us".localized, subTitle: "settings_value_rate_us".localized),
                    SettingItem(type: .about, title: "settings_header_about_app".localized, subTitle: "\("version".localized) \(version) (\(build))")
                ]
            ]
        ]
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
    }
}


extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = (items[indexPath.section]["items"] as! [SettingItem])[indexPath.row]
        
        switch item.type {
        case .osm:
            let urlStr = "https://www.openstreetmap.org/about"
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(URL(string: urlStr)!)
            }
        case .rate:
            let urlStr = "itms://itunes.apple.com/us/app/apple-store/1419199757?mt=8"
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(URL(string: urlStr)!)
            }
            
        default:
            break
        }
        
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (items[section]["items"] as! [Any]).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsCell
        
        if let sectionItems = (items[indexPath.section]["items"] as? [SettingItem]) {
            let item = sectionItems[indexPath.row]
            
            cell.itemTitle.text = item.title
            cell.itemDescription.text = item.subTitle
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section]["header"] as? String
    }
}
