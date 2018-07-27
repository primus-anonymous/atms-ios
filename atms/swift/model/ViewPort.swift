import Foundation
import CoreLocation


struct ViewPort {
    var lngStart: Double = 0.0
    
    var latStart: Double = 0.0
    
    var lngEnd: Double = 0.0
    
    var latEnd: Double = 0.0
    
    func isInside(another: ViewPort) -> Bool  {
        return another.lngStart >= lngStart &&
            another.lngStart <= lngEnd &&
            another.latStart >= latStart &&
            another.latStart <= latEnd &&
            
            another.lngEnd >= lngStart &&
            another.lngEnd <= lngEnd &&
            another.latEnd >= latStart &&
            another.latEnd <= latEnd
    }
    
    
    func extended() -> ViewPort {
        
        let southWest = locationWithBearing(origin: CLLocationCoordinate2D(latitude: latStart, longitude: lngStart), distanceMeters: 3000.0, bearing: 245.0 * Double.pi/180)
        
        let startLng = southWest.longitude
        let startLat = southWest.latitude
        
        let northeast = locationWithBearing(origin: CLLocationCoordinate2D(latitude: latEnd, longitude: lngEnd), distanceMeters: 3000.0, bearing: 45.0 * Double.pi/180)
        
        let endLng = northeast.longitude
        let endLat = northeast.latitude
        
        return ViewPort(lngStart: startLng, latStart: startLat, lngEnd: endLng, latEnd: endLat)
    }
    
    private func locationWithBearing(origin:CLLocationCoordinate2D, distanceMeters:Double, bearing:Double) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        
        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}
