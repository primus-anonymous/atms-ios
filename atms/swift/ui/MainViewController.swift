import UIKit
import RxSwift
import CoreLocation


class MainViewController: UITabBarController {
    
    var viewModel: MainViewModel!
    
    var searchBar: UISearchBar!
    
    let disposeBag = DisposeBag()
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        definesPresentationContext = true
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 48))
        
        searchBar.placeholder = "Filter"
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        viewModel.searchVisible()
            .bind { [unowned self] in
                if $0 {
                    self.view.addSubview(self.searchBar)
                } else {
                    self.searchBar.removeFromSuperview()
                }
            }.disposed(by: disposeBag)
        
        viewModel.selectedTab()
            .bind { [unowned self] in
                
                switch $0 {
                case .map:
                    self.selectedIndex = 0
                case .list:
                    self.selectedIndex = 1
                case .settings:
                    self.selectedIndex = 2
                }
                
            }.disposed(by: disposeBag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchBar.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: 48)
        
        searchBar.sizeToFit()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            viewModel.locationPermission = true
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.delegate = nil
        
        viewModel.locationPermission = false
        
        locationManager.stopUpdatingLocation()
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        viewModel.searchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
    }
}


extension MainViewController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag {
        case 0:
            viewModel.tab = .map
        case 1:
            viewModel.tab = .list
        case 2:
            viewModel.tab = .settings
        default:
            break
        }
        
    }
    
}

extension MainViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            viewModel.locationPermission = true
            locationManager.startUpdatingLocation()
        } else {
            viewModel.locationPermission = false
            locationManager.stopUpdatingLocation()

        }        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            viewModel.setLocation(location: Location(lat: location.coordinate.latitude, lng: location.coordinate.longitude))
            
        }
        
    }
}
