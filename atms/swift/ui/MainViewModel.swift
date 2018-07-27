import Foundation
import RxSwift
import RxCocoa

class MainViewModel {
    
    let atmsRepo: AtmsProtocol
    
    let subscribe: SchedulerType
    
    let observe: SchedulerType
    
    private let zoomSubject = BehaviorRelay(value: 16)
    
    private let viewPortSubject = BehaviorRelay(value: ViewPort())
    
    private let progressSubject = BehaviorRelay(value: false)
    
    private let emptySubject = BehaviorRelay(value: false)
    
    private let searchQuerySubject = BehaviorRelay(value: "")
    
    private let atmsSubject = BehaviorRelay<[AtmNode]>(value: [])
    
    private let selectedAtmSubject = BehaviorRelay<AtmNode?>(value: nil)
    
    private let tabSubject = BehaviorRelay(value: Tab.map)
    
    private let locationSubject = BehaviorRelay<Location?>(value: nil)
    
    private let locationPermissionSubject = BehaviorRelay(value: false)
    
    private let errorSubject = PublishRelay<String>()

    private var cachedViewPort: ViewPort?
    
    private var repoCall: Observable<[AtmNode]> = Observable.just([])
    
    
    init(atmsRepo: AtmsProtocol, subscribe: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background), observe: SchedulerType = MainScheduler.instance) {
        
        self.atmsRepo = atmsRepo
        self.subscribe = subscribe
        self.observe = observe
    }
    
    
    var zoom: Int {
        get {
            return zoomSubject.value
        }
        set {
            zoomSubject.accept(newValue)
        }
    }
    
    var viewPort: ViewPort {
        get {
            return viewPortSubject.value
        }
        set {
            viewPortSubject.accept(newValue)
        }
    }
    
    var searchQuery: String {
        get {
            return searchQuerySubject.value
        }
        set {
            searchQuerySubject.accept(newValue)
        }
    }
    
    var tab: Tab {
        get {
            return tabSubject.value
        }
        set {
            tabSubject.accept(newValue)
        }
    }
    
    var locationPermission: Bool {
        get {
            return locationPermissionSubject.value
        }
        set {
            locationPermissionSubject.accept(newValue)
        }
    }
    
    func error() -> Observable<String> {
        return errorSubject.asObservable()
    }
    
    func locationPermissionObservable() -> Observable<Bool> {
        return locationPermissionSubject.asObservable()
    }
    
    func searchVisible() -> Observable<Bool> {
        return Observable.combineLatest(tabSubject, selectedAtmSubject) { tab, selectedAtm in
            return tab != .settings && (tab == .map && selectedAtm == nil || tab == .list) 
        }
    }
    
    func selectedTab() -> Observable<Tab> {
        return tabSubject.asObservable()
    }
    
    func select(atmNode: AtmNode) {
        selectedAtmSubject.accept(atmNode)
    }
    
    func setLocation(location: Location) {
        locationSubject.accept(location)
    }
    
    func clearLocation() {
        locationSubject.accept(nil)
    }
    
    func location() -> Observable<Location?> {
        return locationSubject.asObservable()
    }
    
    func selectedAtm() -> Observable<AtmNode?> {
        return selectedAtmSubject.asObservable()
    }
    
    func clearSelectedAtm() {
        selectedAtmSubject.accept(nil)
    }
    
    func progress() -> Observable<Bool> {
        return progressSubject.asObservable()
    }
    
    func zoomfurther() -> Observable<Bool> {
        return zoomSubject.map({ zoom -> Bool in
            return zoom < 16
        }).asObservable()
    }
    
    func empty() -> Observable<Bool> {
        return emptySubject.asObservable()
    }
    
    func atms() -> Observable<[AtmNode]> {
        
        let src = Observable.combineLatest(zoomSubject, viewPortSubject) { [unowned self] (zoom, viewport) -> Observable<[AtmNode]> in

            guard zoom >= 16 else {
                self.cachedViewPort = nil
                return Observable.just([])
            }
            
            if self.cachedViewPort == nil || !self.cachedViewPort!.isInside(another: viewport) {
                
                self.cachedViewPort = viewport.extended()
                
                self.repoCall = self.atmsRepo.atms(viewPort: self.cachedViewPort!)
                    .asObservable()
                    .subscribeOn(self.subscribe)
                    .observeOn(self.observe)
                    .do(onError: { [unowned self] error in
                        self.cachedViewPort = nil
                        
                        if let err = error as? URLError, err.code == .notConnectedToInternet {
                            self.errorSubject.accept("network_error".localized)
                        } else {
                            self.errorSubject.accept("general_error".localized)
                        }
                    })
                    .catchErrorJustReturn([])
                    .share(replay: 1, scope: SubjectLifetimeScope.forever)
                
            }
            
            return self.repoCall
            
            }.flatMapLatest {
                $0.do(onNext: { res in
                    self.progressSubject.accept(false)
                }, onSubscribe: {
                    self.progressSubject.accept(true)
                })
        }
        
        return Observable.combineLatest(src, searchQuerySubject) { (atms, search) -> [AtmNode] in
            
            if search.isEmpty {
                return atms
            }
            
            return atms.filter {
                $0.tags.name.lowercased().contains(search.lowercased())
            }
            }
            .do(onNext: { [unowned self] res in
                self.emptySubject.accept(res.isEmpty)
            })
        
    }
}
