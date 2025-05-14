//
//  ViewController.swift
//  testMetalFilter
//
//  Created by Igor Borzenkov on 15.01.2025.
//

//https://stackoverflow.com/questions/54818120/average-color-of-a-ciimage-a-faster-method
//https://stackoverflow.com/questions/8017840/coreimage-create-a-ciimage-with-solid-color-and-display-it-in-nsimageview
//CIConstantColorGenerator
//CIAreaAverage
//https://steps3d.narod.ru/tutorials/core-image-tutorial.html
//https://nooverviewavailable.com/core-image/
//https://stackoverflow.com/questions/54354138/how-can-you-make-a-cvpixelbuffer-directly-from-a-ciimage-instead-of-a-uiimage-in
//kCVPixelBufferIOSurfaceCoreAnimationCompatibilityKey
//CVPixelBufferGetIOSurface
//https://stackoverflow.com/questions/46300907/render-a-cvpixelbuffer-to-an-nsview-macos

//https://bignerdranch.com/blog/core-graphics-part-2-contextually-speaking//

//https://stackoverflow.com/questions/32339247/swift-image-filter

//https://stackoverflow.com/questions/29692275/how-to-output-a-cifilter-to-a-camera-view

//CIFilter.personSegmentation()
//https://www.appcoda.com.tw/vision-person-segmentation/

//UIImage vs CIImage vs CGImage
//https://stackoverflow.com/questions/55848348/what-is-the-difference-between-uiimage-ciimage-and-cgimage-in-swift
import Cocoa
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

//    https://nooverviewavailable.com/core-image/

//    let filter = {
//        let f = CIFilter.gaussianBlur()
//        f.setDefaults()
//        f.radius = 10.0 //0.3
//        return f
//    }()
    
//    let filter = {
//        let f = CIFilter.areaAverage()
//        return f
//    }()
    
    
//    let filter = {
//        let f = CIFilter.bloom()
//        f.radius = 10
//        f.intensity = 1
//        return f
//    }()
    
    let filter = {
        let f = CIFilter.personSegmentation()
        f.qualityLevel = 1
        return f
    }()
    
    let context = {
        let c = CIContext(options: nil) //CIContext(options: [CIContextOption.useSoftwareRenderer : true])
        return c
    }()
    
    var captureSession : AVCaptureSession? = nil
    
    @IBAction func onItem1Pressed(_ sender: Any) {
        if let captureSession, captureSession.isRunning { return }
        
        captureSession = AVCaptureSession()
        
        guard let captureSession else { return }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        if let input = try? AVCaptureDeviceInput(device: captureDevice), captureSession.canAddInput( input){
            captureSession.addInput( input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate( self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        captureSession.startRunning()
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(10.0))
            captureDevice.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(10.0))
            captureDevice.unlockForConfiguration()
        } catch {
            print( error)
        }
    }
    
    @IBAction func onItem2Pressed(_ sender: Any) {
        captureSession?.stopRunning()
    }
    
    @IBAction func onItem3Pressed(_ sender: Any) {
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let pixelBuffer : CVPixelBuffer /*CVImageBuffer*/ /*CVPixelBuffer*/ =  CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
  
//////// 1 ---->>>
//            let inputImage = CIImage(cvPixelBuffer: pixelBuffer)
//            filter.inputImage = inputImage
//            if let maskImage = filter.outputImage {
//                
//                let ciContext = CIContext(options: nil)
//                
//                let maskScaleX = inputImage.extent.width / maskImage.extent.width
//                let maskScaleY = inputImage.extent.height / maskImage.extent.height
//                
//                let maskScaled =  maskImage.transformed(by: __CGAffineTransformMake(maskScaleX, 0, 0, maskScaleY, 0, 0))
//                
//                view.layer?.contents = ciContext.createCGImage(maskScaled, from: maskScaled.extent)
//                //                  let maskRef = ciContext.createCGImage(maskScaled, from: maskScaled.extent)
//                //                  self.outputImage = UIImage(cgImage: maskRef!)
//            }

//////// 2 ---->>>
            filter.inputImage = CIImage(cvPixelBuffer: pixelBuffer)
            if let outputImage = filter.outputImage {
                print( outputImage.extent)
                view.layer?.contents = context.createCGImage(outputImage, from: outputImage.extent)
            }

//////// 3 ---->>>
//            view.layer?.contents = context.createCGImage(CIImage.cyan, from: CIImage(cvPixelBuffer: pixelBuffer).extent)

//////// 4 ---->>>
//            view.layer?.contents = context.createCGImage(CIImage.cyan, from: CGRect(x: 10, y: 10, width: 20, height: 20))

 
//////// 5 ---->>>
//            filter.inputImage = CIImage(cvPixelBuffer: pixelBuffer)
//            if let outputImage = filter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//                view.layer?.contents = cgImage
//            }

//////// 6 ---->>>
//            guard let ioSurface : IOSurfaceRef? = CVPixelBufferGetIOSurface(  pixelBuffer /*maskPixelBuffer*/ /*pixelBuffer*/ /*maskPixelBuffer*/ /*pixelBuffer*/)?.takeUnretainedValue() else { return }
//
//            view.layer?.contents = ioSurface
        }
    }
}

//func sample2 {
//    //            if let pb = CIImage(cvPixelBuffer: pixelBuffer).pixelBuffer /*CIImage.green.pixelBuffer*/ {
//    //                print()
//    //            }
//
////                let c = NSGraphicsContext.current?.cgContext
////                print()
//
//}


//func sample1 {
//    //        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//    //        var pixelBuffer : CVPixelBuffer?
//    //        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int( 100), Int(100), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
//    //        guard (status == kCVReturnSuccess) else {
//    //            print()
//    //            return
//    //        }
//
//    //        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//    //        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
//    //        let videoRecContext = CGContext(data: pixelData,
//    //                                    width: Int(image.size.width),
//    //                                    height: Int(image.size.height),
//    //                                    bitsPerComponent: 8,
//    //                                    bytesPerRow: videoRecBytesPerRow,
//    //                                    space: (MTLCaptureView?.colorSpace)!, // It's getting the current colorspace from a MTKView
//    //                                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
//
//    //            videoRecContext?.translateBy(x: 0, y: image.size.height)
//    //            videoRecContext?.scaleBy(x: 1.0, y: -1.0)
//
//    //            UIGraphicsPushContext(videoRecContext!)
//    //            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//    //            UIGraphicsPopContext()
//    //            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//
//    //            return pixelBuffer
//            
//    //        Create a CIContext and use it to render the CIImage directly to your CVPixelBuffer using CIContext.render(_: CIImage, to buffer: CVPixelBuffer).
//
//    //        CIContext
//    //        let context : CIContext
//    //        context.render(<#T##image: CIImage##CIImage#>, to: <#T##CVPixelBuffer#>)
//            
//    //        CIContext(cgContext: <#T##CGContext#>)
//    //        NSGraphicsContext.currentContext()?.CGContext
//    //        let c = NSGraphicsContext.current?.cgContext
//    //        print()
//
//}


