//
//  ScreenShotDemoViewController.swift
//  Drawing
//
//  Created by MickyMikeH on 2024/2/6.
//

import UIKit

class ScreenShotDemoViewController: UIViewController {

    var image: UIImage = UIImage(){
        didSet {
            imageView.image = image
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.frame = view.bounds
    }
}
