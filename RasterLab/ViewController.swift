//
//  ViewController.swift
//  RasterLab
//
//  Created by Ivan Milinkovic on 15.7.23..
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        renderer.render()
        let img = Images.cgImageSRGB(renderer.pixels, w: renderer.w, h: renderer.h, pixelSize: 4)
        imageView.image = NSImage(cgImage: img, size: NSSize(width: renderer.w, height: renderer.h))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

