//
//  GetWallpaper.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Foundation
import Cocoa

class WallpaperApi {
    let metaURLpt1 = "https://www.bing.com/HPImageArchive.aspx?format=js&idx="
    let metaURLpt2 = "&setlang="
    let metaURLpt3 = "&n=1&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"
    

    
    func fetchMeta(index: Int, language: String, success: @escaping (Wallpaper) -> Void){
        NSLog("Start fetching (index \(index))")
        let metaURL = "\(metaURLpt1)\(index)\(metaURLpt2)\(language)\(metaURLpt3)"
        let myurl = URL(string: metaURL)!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3.0
        let request = URLRequest(url: myurl)
        let session = URLSession(configuration: config)
        NSLog("Session time \(config.timeoutIntervalForRequest)")
        let task = session.dataTask(with: request, completionHandler: { (data, response, err) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let image = self.wallpaperFromJSON(data: data!)
                success(image)
            } else {
                success(Wallpaper.init())
                NSLog("fetch meta (index \(index)) failed")
            }
            
        })
        task.resume()
    }
    
    func fetchImage(url: URL, path: String, completionHandler: @escaping () -> Void){
        let task = URLSession.shared.downloadTask(with: url) {localURL, urlResponse, error in
            let httpResponse = urlResponse as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                do {
                    try FileManager.default.moveItem(atPath: localURL!.path, toPath: path)
                    completionHandler()
                } catch {
                    print(error)
                }
            } else {
                NSLog("fetch image failed")
            }
        }
        task.resume()
            
    }
    
    
    func wallpaperFromJSON(data: Data)->Wallpaper{
        
        do {
            //customize decoder
            let decoder = JSONDecoder();
            let formatter = DateFormatter();
            formatter.dateFormat = "yyyyMMdd";
            decoder.dateDecodingStrategy = .formatted(formatter)
            //decode json using to wallpaper struct
            let result = try decoder.decode(Bingfeedback.self, from: data)
            return result.images[0]
        } catch {
            NSLog("JSON Parsing fialed: \(error)")
            return Wallpaper()
        }

    }

}
