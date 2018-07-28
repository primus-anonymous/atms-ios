// MARK: - Mocks generated from file: atms/swift/services/AtmsProtocol.swift at 2018-07-27 19:37:13 +0000


import Cuckoo
@testable import atms

import Foundation
import RxSwift

class MockAtmsProtocol: AtmsProtocol, Cuckoo.ProtocolMock {
    typealias MocksType = AtmsProtocol
    typealias Stubbing = __StubbingProxy_AtmsProtocol
    typealias Verification = __VerificationProxy_AtmsProtocol
    let cuckoo_manager = Cuckoo.MockManager(hasParent: false)

    

    

    
    // ["name": "atms", "returnSignature": " -> Single<[AtmNode]>", "fullyQualifiedName": "atms(viewPort: ViewPort) -> Single<[AtmNode]>", "parameterSignature": "viewPort: ViewPort", "parameterSignatureWithoutNames": "viewPort: ViewPort", "inputTypes": "ViewPort", "isThrowing": false, "isInit": false, "isOverriding": false, "hasClosureParams": false, "@type": "ProtocolMethod", "accessibility": "", "parameterNames": "viewPort", "call": "viewPort: viewPort", "parameters": [CuckooGeneratorFramework.MethodParameter(label: Optional("viewPort"), name: "viewPort", type: "ViewPort", range: CountableRange(77..<95), nameRange: CountableRange(77..<85))], "returnType": "Single<[AtmNode]>", "isOptional": false, "stubFunction": "Cuckoo.ProtocolStubFunction"]
     func atms(viewPort: ViewPort)  -> Single<[AtmNode]> {
        
            return cuckoo_manager.call("atms(viewPort: ViewPort) -> Single<[AtmNode]>",
                parameters: (viewPort),
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    )
        
    }
    

	struct __StubbingProxy_AtmsProtocol: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func atms<M1: Cuckoo.Matchable>(viewPort: M1) -> Cuckoo.ProtocolStubFunction<(ViewPort), Single<[AtmNode]>> where M1.MatchedType == ViewPort {
	        let matchers: [Cuckoo.ParameterMatcher<(ViewPort)>] = [wrap(matchable: viewPort) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockAtmsProtocol.self, method: "atms(viewPort: ViewPort) -> Single<[AtmNode]>", parameterMatchers: matchers))
	    }
	    
	}

	struct __VerificationProxy_AtmsProtocol: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func atms<M1: Cuckoo.Matchable>(viewPort: M1) -> Cuckoo.__DoNotUse<Single<[AtmNode]>> where M1.MatchedType == ViewPort {
	        let matchers: [Cuckoo.ParameterMatcher<(ViewPort)>] = [wrap(matchable: viewPort) { $0 }]
	        return cuckoo_manager.verify("atms(viewPort: ViewPort) -> Single<[AtmNode]>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}

}

 class AtmsProtocolStub: AtmsProtocol {
    

    

    
     func atms(viewPort: ViewPort)  -> Single<[AtmNode]> {
        return DefaultValueRegistry.defaultValue(for: Single<[AtmNode]>.self)
    }
    
}

