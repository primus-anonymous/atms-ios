import Foundation
import XCTest
import Cuckoo
import RxTest
import RxSwift
@testable import atms


class MainViewModelTest: XCTestCase {
    
    let mockAtmsRepo = MockAtmsProtocol()
    
    var viewModel: MainViewModel!
    
    var emptyObserver: TestableObserver<Bool>!
    
    var searchVisibleObserver: TestableObserver<Bool>!

    var zoomFurtherObserver: TestableObserver<Bool>!

    var progressObserver: TestableObserver<Bool>!

    var errorObserver: TestableObserver<String>!

    var atmsObserver: TestableObserver<[AtmNode]>!

    override func setUp() {
        super.setUp()
        
        let scheduler = TestScheduler(initialClock: 0)

        emptyObserver = scheduler.createObserver(Bool.self)
        atmsObserver = scheduler.createObserver([AtmNode].self)
        searchVisibleObserver = scheduler.createObserver(Bool.self)
        zoomFurtherObserver = scheduler.createObserver(Bool.self)
        progressObserver = scheduler.createObserver(Bool.self)
        errorObserver = scheduler.createObserver(String.self)

        viewModel = MainViewModel(atmsRepo: mockAtmsRepo, subscribe: ConcurrentMainScheduler.instance, observe: MainScheduler.instance)
        
        scheduler.start()
    }
    
    func testEmpty() {
        stub(mockAtmsRepo) { mock in
            when(mock.atms(viewPort: any())).thenReturn(Single.just([]))
        }
        
        _ = viewModel.empty().subscribe(emptyObserver)

        _ = viewModel.atms().subscribe(atmsObserver)
        
        let emptyValues = [
            next(0, false),
            next(0, true)
        ]
        
        let atmValues = [
            next(0, [AtmNode]())
        ]
        
        XCTAssertEqual(emptyValues, emptyObserver.events)
        XCTAssertEqual(atmValues, atmsObserver.events)
    }
    
    func testNotEmpty() {
        
        let tag = Tag(name: "", city: "", houseNumber: "", postCode: "", street: "")
        
        let node1 = AtmNode(id: 0, lat: 0, lon: 0, tags: tag)
        let node2 = AtmNode(id: 1, lat: 0, lon: 0, tags: tag)

        stub(mockAtmsRepo) { mock in
            when(mock.atms(viewPort: any())).thenReturn(Single.just([node1, node2]))
        }
        
        _ = viewModel.empty().subscribe(emptyObserver)
        _ = viewModel.atms().subscribe(atmsObserver)
        
        let emptyValues = [
            next(0, false),
            next(0, false)
        ]
        
        let atmValues = [
            next(0, [node1, node2])
        ]
        
        XCTAssertEqual(emptyValues, emptyObserver.events)
        XCTAssertEqual(atmValues, atmsObserver.events)
    }
    
    func testEmptyLargeZoom() {
        
        let tag = Tag(name: "", city: "", houseNumber: "", postCode: "", street: "")
        
        let node1 = AtmNode(id: 0, lat: 0, lon: 0, tags: tag)
        let node2 = AtmNode(id: 1, lat: 0, lon: 0, tags: tag)
        
        stub(mockAtmsRepo) { mock in
            when(mock.atms(viewPort: any())).thenReturn(Single.just([node1, node2]))
        }
        
        viewModel.zoom = 4
        
        _ = viewModel.atms().subscribe(atmsObserver)
       
        let atmValues = [
            next(0, [AtmNode]())
        ]
        
        XCTAssertEqual(atmValues, atmsObserver.events)
    }
    
    func testSearch() {
        
        let tag1 = Tag(name: "nametags", city: "", houseNumber: "", postCode: "", street: "")
        let tag2 = Tag(name: "taFddsvcc", city: "", houseNumber: "", postCode: "", street: "")
        let tag3 = Tag(name: "ataga", city: "", houseNumber: "", postCode: "", street: "")

        let node1 = AtmNode(id: 0, lat: 0, lon: 0, tags: tag1)
        let node2 = AtmNode(id: 1, lat: 0, lon: 0, tags: tag2)
        let node3 = AtmNode(id: 2, lat: 0, lon: 0, tags: tag3)

        stub(mockAtmsRepo) { mock in
            when(mock.atms(viewPort: any())).thenReturn(Single.just([node1, node2, node3]))
        }
        
        viewModel.searchQuery = "TaG"
        
        _ = viewModel.atms().subscribe(atmsObserver)
        
        let atmValues = [
            next(0, [node1, node3])
        ]
        
        XCTAssertEqual(atmValues, atmsObserver.events)
    }

    func testSearchVisibleMapAtmNotSelected() {
        
        viewModel.tab = .map
        
        _ = viewModel.searchVisible().subscribe(searchVisibleObserver)
        
        let visibilityValues = [
            next(0, true)
        ]
        
        XCTAssertEqual(visibilityValues, searchVisibleObserver.events)
    }

    func testSearchVisibleListAtmNotSelected() {
        
        viewModel.tab = .list
        
        _ = viewModel.searchVisible().subscribe(searchVisibleObserver)
        
        let visibilityValues = [
            next(0, true)
        ]
        
        XCTAssertEqual(visibilityValues, searchVisibleObserver.events)
    }
    
    func testSearchNotVisibleSettings() {
        
        viewModel.tab = .settings
        
        _ = viewModel.searchVisible().subscribe(searchVisibleObserver)
        
        let visibilityValues = [
            next(0, false)
        ]
        
        XCTAssertEqual(visibilityValues, searchVisibleObserver.events)
    }
    
    func testSearchNotVisibleMapAtmSelected() {
        
        let tag1 = Tag(name: "nametags", city: "", houseNumber: "", postCode: "", street: "")
        let node1 = AtmNode(id: 0, lat: 0, lon: 0, tags: tag1)

        viewModel.select(atmNode: node1)
        
        viewModel.tab = .map
        
        _ = viewModel.searchVisible().subscribe(searchVisibleObserver)
        
        let visibilityValues = [
            next(0, false)
        ]
        
        XCTAssertEqual(visibilityValues, searchVisibleObserver.events)
    }
    
    func testSearchVisibleListAtmSelected() {
        
        let tag1 = Tag(name: "nametags", city: "", houseNumber: "", postCode: "", street: "")
        let node1 = AtmNode(id: 0, lat: 0, lon: 0, tags: tag1)
        
        viewModel.select(atmNode: node1)

        viewModel.tab = .list
        
        _ = viewModel.searchVisible().subscribe(searchVisibleObserver)
        
        let visibilityValues = [
            next(0, true)
        ]
        
        XCTAssertEqual(visibilityValues, searchVisibleObserver.events)
    }
    
    func testZoomFurtherVisible() {
    
        _ = viewModel.zoomfurther().subscribe(zoomFurtherObserver)
        
        viewModel.zoom = 4
        
        let visibilityValues = [
            next(0, false),
            next(0, true)
        ]
        
        XCTAssertEqual(visibilityValues, zoomFurtherObserver.events)
    }
    
    func testZoomFurtherNotVisible() {

        _ = viewModel.zoomfurther().subscribe(zoomFurtherObserver)
        
        viewModel.zoom = 18
        
        let visibilityValues = [
            next(0, false),
            next(0, false)
        ]
        
        XCTAssertEqual(visibilityValues, zoomFurtherObserver.events)
    }
    
    func testProgressSuccess() {
        
        stub(mockAtmsRepo) { mock in
            when(mock.atms(viewPort: any())).thenReturn(Single.just([]))
        }
                
        _ = viewModel.progress().subscribe(progressObserver)
        _ = viewModel.atms().subscribe(atmsObserver)

        let progressValues = [
            next(0, false),
            next(0, true),
            next(0, false)
        ]
        
        XCTAssertEqual(progressValues, progressObserver.events)
    }
    
    func testProgressFailure() {
        
        stub(mockAtmsRepo) { mock in
            when(mock.atms(viewPort: any())).thenReturn(Single.error(NSError()))
        }
        
        _ = viewModel.progress().subscribe(progressObserver)
        _ = viewModel.atms().subscribe(atmsObserver)
        
        let progressValues = [
            next(0, false),
            next(0, true),
            next(0, false)
        ]
        
        XCTAssertEqual(progressValues, progressObserver.events)
    }
    
    func testNetworkingError() {
        
        stub(mockAtmsRepo) { mock in
            
            let error = URLError(.notConnectedToInternet)
            
            when(mock.atms(viewPort: any())).thenReturn(Single.error(error))
        }
        
        _ = viewModel.error().subscribe(errorObserver)
        _ = viewModel.atms().subscribe(atmsObserver)
        
        let errorValues = [
            next(0, "network_error".localized)
        ]
        
        XCTAssertEqual(errorValues, errorObserver.events)
    }
    
    func testGeneralError() {
        
        stub(mockAtmsRepo) { mock in
            
            when(mock.atms(viewPort: any())).thenReturn(Single.error(NSError()))
        }
        
        _ = viewModel.error().subscribe(errorObserver)
        _ = viewModel.atms().subscribe(atmsObserver)
        
        let errorValues = [
            next(0, "general_error".localized)
        ]
        
        XCTAssertEqual(errorValues, errorObserver.events)
    }
}
