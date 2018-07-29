import UIKit

extension String {
    
    var isNotEmpty: Bool {
        get {
            return !self.isEmpty
        }
    }
    
    var localized: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
    
    var trimmed: String {
        get {
            return self.trimmingCharacters(in: .whitespaces)
        }
    }
}


extension UIColor {
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: 1
        )
    }
    
    static var purple: UIColor {
        get {
            return UIColor(hex: "9C27B0")
        }
    }
    
    static var accent: UIColor {
        get {
            return UIColor(hex: "7C4DFF")
        }
    }
    
}
