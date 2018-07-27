import Foundation
import CoreLocation

class DistanceFormatter {
    
    func formatDistance(locationOne: Location, locationTwo: Location) -> String {
        
        let atmLoc = CLLocation(latitude: locationOne.lat, longitude: locationOne.lng)
        let myLoc = CLLocation(latitude: locationTwo.lat, longitude: locationTwo.lng)
        
        let distance = atmLoc.distance(from: myLoc)
        
        if distance < 1000.0 {
            return "\(Int(distance)) \("m".localized)"
        }
        
        return "\(NSString(format: "%.2f", distance/1000.0)) \("km".localized)"
    }
}
