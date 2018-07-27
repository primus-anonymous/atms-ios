import Foundation
import XCTest
@testable import atms

class AddressFormatterTest: XCTestCase {
    
    let addressFormatter = AddressFormatter()
    
    func testTrimming() {
        
        let tag = Tag(name: "", city: ", ", houseNumber: " ", postCode: " ", street: "  ")
        let node = AtmNode(id: 0, lat: 0, lon: 0, tags: tag)

        XCTAssert(addressFormatter.format(atmNode: node) == "")
    }
    
    func testCity() {
        
        let tag = Tag(name: "", city: "City", houseNumber: " ", postCode: " ", street: "  ")
        let node = AtmNode(id: 0, lat: 0, lon: 0, tags: tag)
        
        XCTAssert(addressFormatter.format(atmNode: node) == "City")
    }
    
    func testCityStreet() {
        
        let tag = Tag(name: "", city: "City", houseNumber: " ", postCode: " ", street: "Street")
        let node = AtmNode(id: 0, lat: 0, lon: 0, tags: tag)
        
        XCTAssert(addressFormatter.format(atmNode: node) == "Street, City")
    }
    
    func testCityStreetHouse() {
        
        let tag = Tag(name: "", city: "City", houseNumber: "23", postCode: " ", street: "Street")
        let node = AtmNode(id: 0, lat: 0, lon: 0, tags: tag)
        
        XCTAssert(addressFormatter.format(atmNode: node) == "Street 23, City")
    }
    
    func testCityStreetHouseZip() {
        
        let tag = Tag(name: "", city: "City", houseNumber: "23", postCode: "324", street: "Street")
        let node = AtmNode(id: 0, lat: 0, lon: 0, tags: tag)
        
        XCTAssert(addressFormatter.format(atmNode: node) == "Street 23, 324, City")
    }
}
