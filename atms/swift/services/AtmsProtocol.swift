import Foundation
import RxSwift

protocol AtmsProtocol {
    
    func atms(viewPort: ViewPort) -> Single<[AtmNode]>

}
