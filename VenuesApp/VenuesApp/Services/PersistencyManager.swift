//
//  PersistencyManager.swift
//  
//
//  Created by GEORGE QUENTIN on 10/05/2019.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//
import Foundation
import UIKit

final class PersistencyManager {
    private var documents: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    
    init() {
        
    }
    
    func saveVenuesData(with data: Data?) {
        
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
