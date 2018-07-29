import UIKit
import Pulley
import RxSwift
import MapKit


class DrawerViewController: UIViewController {
    
    static let drawerHeight = CGFloat(256.0)
    
    var viewModel: MainViewModel!
    
    var addressFormatter: AddressFormatter!
    
    var distanceFormatter: DistanceFormatter!
    
    var atmNode: AtmNode!
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var atmTitle: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var btnNavigate: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBAction func doneTapped(_ sender: Any) {
        viewModel.clearIfSelectedAtm()
    }
    
    @IBAction func navigateTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: atmNode.tags.name, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "nav_walk".localized, style: .default, handler: { [unowned self] (action) in
            
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.atmNode.lat, longitude: self.atmNode.lon), addressDictionary: nil)
            let mapitem = MKMapItem(placemark: placemark)
            
            mapitem.openInMaps(launchOptions: options)
            
        }))
        
        alert.addAction(UIAlertAction(title: "nav_drive".localized, style: .default, handler: { [unowned self] (action) in
            
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.atmNode.lat, longitude: self.atmNode.lon), addressDictionary: nil)
            let mapitem = MKMapItem(placemark: placemark)
            
            mapitem.openInMaps(launchOptions: options)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        alert.popoverPresentationController?.sourceView = btnNavigate
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCancel.setTitle("cancel".localized, for: .normal)
        btnCancel.setTitleColor(UIColor.purple, for: .normal)
        
        btnNavigate.setTitle("navigate".localized, for: .normal)
        btnNavigate.setTitleColor(UIColor.purple, for: .normal)

        Observable.combineLatest(viewModel.selectedAtm(), viewModel.location()) {
            return ($0, $1)
            }
            .bind { [unowned self] res in
                
                if let atm = res.0 {
                    self.atmTitle.text = atm.tags.name
                    
                    self.atmNode = atm
                    
                    let formattedAddress = self.addressFormatter.format(atmNode: atm)
                    
                    if formattedAddress.isNotEmpty {
                        self.address.text = self.addressFormatter.format(atmNode: atm)
                    } else {
                        self.address.text = "address_not_available".localized
                    }
                    
                    if let location = res.1 {
                        self.distance.text = self.distanceFormatter.formatDistance(locationOne: Location(lat: atm.lat, lng: atm.lon), locationTwo: location)
                        
                    } else {
                        self.distance.text = "gps_disabled".localized
                    }
                }
                
            }.disposed(by: disposeBag)
    }
}

extension DrawerViewController: PulleyDrawerViewControllerDelegate {
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.closed, .partiallyRevealed]
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return DrawerViewController.drawerHeight
    }
}
