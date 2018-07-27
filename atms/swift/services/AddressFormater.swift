import Foundation


class AddressFormatter {
    
    func format(atmNode: AtmNode) -> String {
        
        let components = [
            atmNode.tags.street + " " + atmNode.tags.houseNumber,
            atmNode.tags.postCode,
            atmNode.tags.city
            ]
            .map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            .filter {
                $0.isNotEmpty
        }
    
        return components.joined(separator: ", ").trimmingCharacters(in: [",", " "])
    }
}
