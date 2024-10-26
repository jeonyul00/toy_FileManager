//
//  TextViewController.swift
//  FileManager
//
//  Created by 전율 on 10/26/24.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url {
            contentTextView.text = try? String(contentsOf: url)
            self.navigationItem.title = url.lastPathComponent
        }
    }
    
    @IBAction func share(_ sender: Any) {
        guard let contentTextViewText = contentTextView.text else { return }
        let dataToShare = contentTextViewText
        // 데이터 공유
        let activityViewController = UIActivityViewController(activityItems: [dataToShare], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    
    @IBAction func closeVC(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
