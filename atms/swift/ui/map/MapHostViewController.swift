import UIKit
import Pulley
import RxSwift

class MapHostViewController: PulleyViewController {
    
    var viewModel: MainViewModel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDrawerPosition(position: .closed, animated: false)
        
        viewModel.selectedAtm()
            .bind { [unowned self] atm in
                
                if atm == nil {
                    self.setDrawerPosition(position: .closed, animated: true)
                } else {
                    self.setDrawerPosition(position: .partiallyRevealed, animated: true)
                }
                
        }.disposed(by: disposeBag)
    }
}
