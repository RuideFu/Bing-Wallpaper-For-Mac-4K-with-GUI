//
//  GetWallpaper.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Foundation

class wallpaperApi {
    let metaURLpt1 = "https://www.bing.com/HPImageArchive.aspx?format=js&idx="
    let metaURLpt2 = "&setlang="
    let metaURLpt3 = "&n=1&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"
    
    
    func fetchMeta(index: Int, language: String){
        let metaURL = "\(metaURLpt1)\(index)\(metaURLpt2)\(language)\(metaURLpt3)"
        let myurl = URL(string: metaURL)!
        let request = URLRequest(url: myurl)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, err) in
            self.wallpaperFromJSON(data: data!)
        })
        task.resume()
    }
    
    func wallpaperFromJSON(data: Data){
        
        do {
//            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//            print(json)
            let decoder = JSONDecoder();
            let formatter = DateFormatter();
            formatter.dateFormat = "yyyyMMdd";
            decoder.dateDecodingStrategy = .formatted(formatter)
            let result = try decoder.decode(Bingfeedback.self, from: data)
            print(result.images[0].getUrl())
        } catch {
            NSLog("JSON Parsing fialed: \(error)")
        }

    }
    
//    func formattedDateFromString(dateString: String) -> Date {
//
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "yyyy/MM/dd"
//        return inputFormatter.date(from: dateString)!
//    }
}
