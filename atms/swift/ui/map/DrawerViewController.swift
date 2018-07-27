import UIKit
import Pulley
import RxSwift
import MapKit


class DrawerViewController: UIViewController {
    
    var viewModel: MainViewModel!
    
    var addressFormatter: AddressFormatter!
    
    var distanceFormatter: DistanceFormatter!
    
    var atmNode: AtmNode!
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var atmTitle: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBAction func doneTapped(_ sender: Any) {
        viewModel.clearSelectedAtm()
    }
    
    @IBAction func navigateTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: atmNode.tags.name, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "nav_walk".localized, style: .default, handler: { [unowned self] (action) in
            
            
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        }))
        
        alert.addAction(UIAlertAction(title: "nav_drive".localized, style: .default, handler: { [unowned self] (action) in
            
            
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        }))
        
        alert.addAction(UIAlertAction(title: "open_in_map".localized, style: .default, handler: {  [unowned self]  (action) in
            
            let link = "http://maps.apple.com/?ll=\(self.atmNode.lat),\(self.atmNode.lon)"
            
            if let url = URL(string: link) {
                
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],
                                              completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "copy_address".localized, style: .default, handler: { [unowned self] (action) in
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        alert.popoverPresentationController?.sourceView = view
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        self.address.text = "Address not available :("
                    }
                    
                    if let location = res.1 {
                        self.distance.text = self.distanceFormatter.formatDistance(locationOne: Location(lat: atm.lat, lng: atm.lon), locationTwo: location)
                        
                    } else {
                        self.distance.text = "GPS is disabled"
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
        return 256.0
    }
}
