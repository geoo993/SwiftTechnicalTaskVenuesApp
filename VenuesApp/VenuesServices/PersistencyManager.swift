//
//  PersistencyManager.swift
//  
//
//  Created by GEORGE QUENTIN on 10/05/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//
import Foundation
import UIKit


extension Notification.Name {
    public static let downloadImageNotification = Notification.Name("DownloadImageNotification")
}

final class PersistencyManager {
    public static let shared = PersistencyManager()
    private var documents: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private init() {
        
    }
    
    // MARK: - Cache and load venues images
    @objc func downloadTransactionData(with notification: Notification) {
        guard let userInfo = notification.userInfo,
            let imageView = userInfo["venueImageView"] as? UIImageView,
            let imageUrl = userInfo["iconUrl"] as? String,
            let filename = URL(string: imageUrl)?.lastPathComponent else {
                return
        }
        if let savedImage = getImage(with: filename) {
            imageView.image = savedImage
            return
        }
        DispatchQueue.global().async { [weak self] () -> Void in
            guard let this = self else { return }
            let downloadedImage = this.downloadImage(imageUrl) ?? UIImage()
            DispatchQueue.main.async {
                imageView.image = downloadedImage
                this.saveImage(downloadedImage, filename: filename)
            }
        }
    }
    
    // MARK:- Cache and Load images
    private var cache: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
  
    func downloadImage(_ url: String) -> UIImage? {
        guard let aUrl = URL(string: url),
            let data = try? Data(contentsOf: aUrl),
            let image = UIImage(data: data) else {
                return nil
        }
        return image
    }
    
    func saveImage(_ image: UIImage, filename: String) {
        let url = cache.appendingPathComponent(filename)
        guard let data = image.pngData() else {
          return
        }
        try? data.write(to: url)
    }

    func getImage(with filename: String) -> UIImage? {
        let url = cache.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else {
          return nil
        }
        return UIImage(data: data)
    }
}
