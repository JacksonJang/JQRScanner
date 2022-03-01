import UIKit
import AVFoundation

public protocol JQRDelegate: AnyObject {
    func readerComplete(status: JQRStatus)
}

public class JQRScannerView: UIView {
    public weak var delegate: JQRDelegate?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?
    private let metadataObjectTypes: [AVMetadataObject.ObjectType] = AVMetadataObject.ObjectType.metadata

    private var frontCameraDevice: AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        }
        
        return AVCaptureDevice.default(for: .video)
    }

    private var backCameraDevice: AVCaptureDevice? {
      return AVCaptureDevice.default(for: .video)
    }
    
    public var isRunning: Bool {
        guard let captureSession = self.captureSession else {
            return false
        }

        return captureSession.isRunning
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialSetupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialSetupView()
    }
    
    private func initialSetupView() {
        self.clipsToBounds = true
        self.captureSession = AVCaptureSession()
        
        setupSessionInput()
        setupSessionOutput()
        setupPreviewLayer()
    }
    
    private func setupSessionInput() {
        guard let videoCaptureDevice = getCameraDevice(position: .back) else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            guard let captureSession = self.captureSession else {
                self.fail()
                return
            }
            
            captureSession.beginConfiguration()
            if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
              captureSession.removeInput(currentInput)
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                captureSession.commitConfiguration()
            } else {
                self.fail()
                return
            }
        } catch let error {
            print(error.localizedDescription)
            self.fail()
            return
        }
    }
    
    private func setupSessionOutput() {
        guard let captureSession = self.captureSession else {
            self.fail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = self.metadataObjectTypes
        } else {
            self.fail()
            return
        }
    }

    private func setupPreviewLayer() {
        guard let captureSession = self.captureSession else {
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = self.layer.bounds

        self.layer.addSublayer(previewLayer)

        self.previewLayer = previewLayer
    }
    
    private func getCameraDevice(position:AVCaptureDevice.Position) -> AVCaptureDevice? {
        return position == .front ? frontCameraDevice : backCameraDevice
    }
}

extension JQRScannerView {
    public func start() {
        self.captureSession?.startRunning()
    }
    
    private func stop() {
        self.captureSession?.stopRunning()
    }
    
    private func fail() {
        self.delegate?.readerComplete(status: .fail)
        self.captureSession = nil
    }
    
    private func found(code: String) {
        self.delegate?.readerComplete(status: .success(code))
    }
}

extension JQRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        stop()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue else {
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
    }
}

