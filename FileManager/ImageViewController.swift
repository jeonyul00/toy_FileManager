//
//  ImageViewController.swift
//  FileManager
//
//  Created by 전율 on 10/26/24.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var url:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url, let data = try? Data(contentsOf: url) {
            imageView.image = UIImage(data: data)
            self.navigationItem.title = url.lastPathComponent
        }
    }
    
    @IBAction func share(_ sender: Any) {
        guard let image = imageView.image else { return }
        // 데이터 공유
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
        
    @IBAction func closeVC(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
