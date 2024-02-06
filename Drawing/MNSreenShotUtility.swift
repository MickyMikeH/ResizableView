//
//  MNSreenShotUtility.swift
//  Drawing
//
//  Created by MickyMikeH on 2024/2/6.
//

import UIKit

class MNSreenShotUtility: NSObject {
    static func takeScreenShot(view: UIView) -> UIImage? {
        // 創建一個 UIImageRenderer 來渲染畫面
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        
        // 進行畫面截圖
        let screenshot = renderer.image { (context) in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }

        return screenshot
    }
}
