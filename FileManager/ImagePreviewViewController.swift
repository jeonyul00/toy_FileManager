//
//  ImagePreviewViewController.swift
//  FileManager
//
//  Created by 전율 on 10/27/24.
//

import UIKit

class ImagePreviewViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    
}
