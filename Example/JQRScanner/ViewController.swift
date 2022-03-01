import UIKit
import AVFoundation
import JQRScanner

class ViewController: UIViewController {
    
    let scannerView = JQRScannerView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scannerView.delegate = self
        self.view.addSubview(scannerView)
        
        if !scannerView.isRunning {
            scannerView.start()
        }
    }
}

extension ViewController: JQRDelegate {
    func readerComplete(status: JQRStatus) {
        var message = ""
        
        switch status {
        case let .success(code):
            guard let code = code else {return}
            message = code
            print("QR success : \(message)")
        case .fail:
            message = "It's not found or perceived"
            print("QR error : \(message)")
        }
        
        let alert = UIAlertController(title: "JQRScanner", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Done", style: .default, handler: {_ in
            self.scannerView.start()
        })
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
