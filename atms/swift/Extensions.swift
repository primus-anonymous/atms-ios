import Foundation

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
    
}
