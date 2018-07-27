import Foundation

struct SettingItem {
    let type: SettingItemType
    
    let title: String
    
    let subTitle: String
}

enum SettingItemType {
    case osm
    case rate
    case about
}
