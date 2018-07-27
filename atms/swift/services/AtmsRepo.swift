import Foundation
import RxSwift
import Alamofire

class AtmsRepo: AtmsProtocol {
    
    func atms(viewPort: ViewPort) -> PrimitiveSequence<SingleTrait, [AtmNode]> {
        return Single<[[String: Any]]>.create(subscribe: { single -> Disposable in
            
            let coordinates = "[out:json];node(\(viewPort.latStart),\(viewPort.lngStart),\(viewPort.latEnd),\(viewPort.lngEnd))[atm];out;"
            
            let parameters: Parameters = ["data": coordinates]
            
            let request = Alamofire.request("https://lz4.overpass-api.de/api/interpreter", parameters: parameters)
                .validate()
                .responseJSON(completionHandler: { response in
                    
                    print(response)
                    
                    if let json = response.result.value {
                        
                        if let dict = (json as? [String: Any])?["elements"] as? [[String: Any]] {
                            single(.success(dict))
                        } else {
                            single(.error(NSError()))
                        }
                    } else {
                        single(.error(NSError()))
                    }
                    
                })
            return Disposables.create {
                request.cancel()
            }
        }).map({ dict -> [AtmNode] in
            
            return dict.map({ rawItem -> AtmNode in
                
                let id = rawItem["id"] as? Int ?? 0
                let lat = rawItem["lat"] as? Double ?? 0.0
                let lng = rawItem["lon"] as? Double ?? 0.0
                
                var postCode =  ""
                var name =  ""
                var houseNumber =  ""
                var street =  ""
                var city =  ""
                
                if let rawTags = rawItem["tags"] as? [String: Any] {
                    
                    postCode = rawTags["addr:postcode"] as? String ?? ""
                    name = rawTags["name"] as? String ?? ""
                    houseNumber = rawTags["addr:housenumber"] as? String ?? ""
                    street = rawTags["addr:street"] as? String ?? ""
                    city = rawTags["addr:city"] as? String ?? ""
                }
                
                let tags = Tag(name: name, city: city, houseNumber: houseNumber, postCode: postCode, street: street)
                
                return AtmNode(id: id, lat: lat, lon: lng, tags: tags)
            })
        })
    }
    
}
