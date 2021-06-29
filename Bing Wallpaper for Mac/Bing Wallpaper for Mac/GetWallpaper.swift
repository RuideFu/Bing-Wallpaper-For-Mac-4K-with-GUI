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
    

    
    func fetchMeta(index: Int, language: String, completeHandeler: @escaping (Wallpaper) -> Void){
        let metaURL = "\(metaURLpt1)\(index)\(metaURLpt2)\(language)\(metaURLpt3)"
        NSLog(metaURL)
        let myurl = URL(string: metaURL)!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3.0
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: myurl, completionHandler: { (data, response, err) in
            if let error = err{
                completeHandeler(Wallpaper.init())
                NSLog("Fetching Meta (index \(index)) Failed \(error)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse!.statusCode == 200 {
                    var image = self.wallpaperFromJSON(data: data!)
                    if image.title == "" {
                        NSLog("Meta info is not complete")
                        image = Wallpaper.init()
                    }
                    completeHandeler(image)
                } else {
                    completeHandeler(Wallpaper.init())
                    NSLog("Parsing Meta (index \(index)) failed")
                }
            }
        })
        task.resume()
    }
    
    func fetchImage(url: URL, completionHandler: @escaping (_ tempURL: URL) -> Void){
        let task = URLSession.shared.downloadTask(with: url) {localURL, urlResponse, error in
            let httpResponse = urlResponse as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                completionHandler(localURL!)
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
            do {
                let decoder = JSONDecoder();
                let result = try decoder.decode(Wallpaper.self, from: data)
                return result
            } catch {
                NSLog("JSON Parsing failed: \(error)")
                return Wallpaper.init()
            }
        }

    }

}
