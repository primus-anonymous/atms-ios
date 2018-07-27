import Foundation
import SwinjectStoryboard
import Swinject

extension SwinjectStoryboard {
    
    @objc class func setup() {
        defaultContainer.storyboardInitCompleted(MainViewController.self) { resolve, controller in
            controller.viewModel = resolve.resolve(MainViewModel.self)
        }

        defaultContainer.storyboardInitCompleted(MapViewController.self) { resolve, controller in
            controller.viewModel = resolve.resolve(MainViewModel.self)
        }
        
        defaultContainer.storyboardInitCompleted(ListViewController.self) { resolve, controller in
            controller.viewModel = resolve.resolve(MainViewModel.self)
            controller.addressFormater = resolve.resolve(AddressFormatter.self)
            controller.distanceFormatter = resolve.resolve(DistanceFormatter.self)
        }
        
        defaultContainer.storyboardInitCompleted(MapHostViewController.self) { resolve, controller in
            controller.viewModel = resolve.resolve(MainViewModel.self)
        }
        
        defaultContainer.storyboardInitCompleted(DrawerViewController.self) { resolve, controller in
            controller.viewModel = resolve.resolve(MainViewModel.self)
            controller.addressFormatter = resolve.resolve(AddressFormatter.self)
            controller.distanceFormatter = resolve.resolve(DistanceFormatter.self)
        }
        
        defaultContainer.register(AtmsProtocol.self) { _ in AtmsRepo() }
            .inObjectScope(.container)
        
        defaultContainer.register(AddressFormatter.self) { _ in AddressFormatter() }
            .inObjectScope(.container)

        defaultContainer.register(DistanceFormatter.self) { _ in DistanceFormatter() }
            .inObjectScope(.container)

        defaultContainer.register(MainViewModel.self) { resolve in
            MainViewModel(atmsRepo: resolve.resolve(AtmsProtocol.self)!)
        }.inObjectScope(.container)
    }
}

