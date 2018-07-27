import UIKit


class SettingsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let items = [
        [
            "header": "Data",
            "items": [
                SettingItem(type: .osm, title: "About OSM", subTitle: "Click to know more")
            ]
        ],
        [
            "header": "Common",
            "items": [
                SettingItem(type: .rate, title: "Rate us", subTitle: "Click to rate"),
                SettingItem(type: .about, title: "About app", subTitle: "Version 1.0 (1)")
            ]
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ATMs"
        
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
    }
}


extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
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
