//
//  GetWallpaper.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Foundation

class wallpaperApi {
    let metaURLpt1 = "https://www.bing.com/HPImageArchive.aspx?format=js&idx="
    let metaURLpt2 = "&n=1&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"
    
    
    func fetchMeta(index: Int){
        let metaURL = "\(metaURLpt1)\(index)\(metaURLpt2)"
        let myurl = URL(string: metaURL)!
        let request = URLRequest(url: myurl)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, err) in
            let str = String(data: data!, encoding: .utf8)!
            NSLog(str)
        })
        task.resume()
    }
}
