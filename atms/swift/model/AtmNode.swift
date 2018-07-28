
import Foundation

struct AtmNode  {
    var id: Int
    
    var lat: Double
    
    var lon: Double
    
    var tags: Tag
}

extension AtmNode: Equatable {
    static func == (lhs: AtmNode, rhs: AtmNode) -> Bool {
        return lhs.id == rhs.id
    }

}

extension AtmNode: Hashable {
    var hashValue: Int {
        return id
    }
}
