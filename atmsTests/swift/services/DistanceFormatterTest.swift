import Foundation
import XCTest
@testable import atms


class DistanceFormatterTest: XCTestCase {
    
    let distanceFormatter = DistanceFormatter()
    
    func testLessKm() {
        
        let locationOne = Location(lat: 1, lng: 1)
        let locationTwo = Location(lat: 1.001, lng: 1.001)

        let formattedDistance = distanceFormatter.formatDistance(locationOne: locationOne, locationTwo: locationTwo)
        
        XCTAssert(formattedDistance == "156 \("m".localized)")
    }
    
    func testKm() {
        
        let locationOne = Location(lat: 1, lng: 1)
        let locationTwo = Location(lat: 1.01, lng: 1.01)
        
        let formattedDistance = distanceFormatter.formatDistance(locationOne: locationOne, locationTwo: locationTwo)
        
        XCTAssert(formattedDistance == "1.57 \("km".localized)")
    }
}

