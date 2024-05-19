//
//  ViewController.swift
//  RasterLab
//
//  Created by Ivan Milinkovic on 15.7.23..
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var infoLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView.wantsLayer = true
//        imageView.layer?.borderWidth = 1
//        imageView.layer?.borderColor = NSColor.purple.cgColor
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let char = event.characters?.first else { return event }
            switch char {
            case "a":
                renderer.rotateY(clockwise: false)
                self?.render()
                return nil
            case "d":
                renderer.rotateY(clockwise: true)
                self?.render()
                return nil
            case "w":
                renderer.rotateX(clockwise: false)
                self?.render()
                return nil
            case "s":
                renderer.rotateX(clockwise: true)
                self?.render()
                return nil
            default:
                return event
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        render()
    }
    
    override func mouseDragged(with event: NSEvent) {
        let dx = event.deltaX
        let dy = event.deltaY
        renderer.rotate(dx: Float(dx), dy: Float(dy))
        render()
    }
    
    override func scrollWheel(with event: NSEvent) {
        let dy = event.deltaY
        renderer.translateDepth(Float(dy))
        render()
    }
    
    private func render() {
        renderer.render()
        let img = Images.cgImageSRGB(renderer.frameBuffer.pixels, w: renderer.w, h: renderer.h, pixelSize: 4)
        imageView.image = NSImage(cgImage: img, size: NSSize(width: renderer.w, height: renderer.h))
        infoLabel.stringValue = String(format: "%.2fms, would be: %dfps", renderer.lastRenderTimeMs, Int(1000/renderer.lastRenderTimeMs))
    }
    
}
