//
//  ImageActivityItem.swift
//  FileManager
//
//  Created by 전율 on 10/26/24.
//

import Foundation
import UIKit
import LinkPresentation // activity에 표신된 내용 바꾸기.
import UniformTypeIdentifiers // 공유할 데이터의 타입이 여기 있다.

class ImageActivityItem:NSObject, UIActivityItemSource {
    
    let image: UIImage
    let title: String
    let subTitle: String?
    
    init(image: UIImage, title: String, subTitle: String? = nil) {
        self.image = image
        self.title = title
        self.subTitle = subTitle
    }
    
    // 플레이스 홀더로 사용할 데이터 반환
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return title
    }
    
    // 실제로 공유할 데이터 반환
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    // 제목으로 사용할 타입 반환
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    
    // 공유할 데이터의 타입 반환
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return UTType.image.identifier
    }
    
    // activityView에 원하는 타이틀과 아이콘을 만들려면 이거 해야됨
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.iconProvider = NSItemProvider(object: UIImage(systemName: "photo")!)
        if let subTitle {
            metadata.originalURL = URL(fileURLWithPath: subTitle)
        }
        return metadata
    }
    
}
