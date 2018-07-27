import UIKit
import RxSwift

class ListViewController: UIViewController {
    
    var viewModel: MainViewModel!
    
    var addressFormater: AddressFormatter!
    
    var distanceFormatter: DistanceFormatter!
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var empty: UILabel!
    
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    var atms: [AtmNode] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var location: Location?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Observable.combineLatest(viewModel.atms(), viewModel.location()) {
            return ($0, $1)
            }
            .bind { [unowned self] res in
                self.location = res.1
                self.atms = res.0
            }.disposed(by: disposeBag)
        
        
        viewModel.empty()
            .bind { [unowned self] in
                self.empty.isHidden = !$0
            }.disposed(by: disposeBag)
        
        viewModel.progress()
            .bind { [unowned self] in
                if $0 {
                    self.progress.startAnimating()
                } else {
                    self.progress.stopAnimating()
                }
            }.disposed(by: disposeBag)
        
    }
}

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.select(atmNode: atms[indexPath.row])
        viewModel.tab = .map
    }
    
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return atms.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "atmItem", for: indexPath) as! AtmCell
        
        let item = atms[indexPath.row]
        
        cell.atmTitle.text = item.tags.name
        
        let formattedAddress = addressFormater.format(atmNode: item)
        
        if formattedAddress.isNotEmpty {
            cell.atmAddress.text = addressFormater.format(atmNode: item)
        } else {
            cell.atmAddress.text = "Address not available :("
        }
        
        if location == nil {
            cell.distance.text = ""
        } else {
            
            cell.distance.text = distanceFormatter.formatDistance(locationOne: Location(lat: item.lat, lng: item.lon), locationTwo: location!)
        }
        
        return cell
    }
    
}
