import AVFoundation

extension AVMetadataObject.ObjectType {
    public static var metadata: [AVMetadataObject.ObjectType] = [
        .aztec, .code128, .code39, .code39Mod43, .code93,
        .dataMatrix, .ean8, .ean13, .face, .interleaved2of5,
        .itf14, pdf417, .qr, .upce
    ]
}
