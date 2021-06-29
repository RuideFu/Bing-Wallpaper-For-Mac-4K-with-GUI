//
//  fileManagement.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/23.
//

import Foundation
import Cocoa

class cacheManager {
    var wallpaperAPI = WallpaperApi()
    let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let fileManager = FileManager.default
    
    func setImage(meta: Wallpaper, workspace: NSWorkspace, screen: NSScreen, completionHandeler: @escaping ()->Void){
        self.storImage(meta: meta){ file in
            do {
                try workspace.setDesktopImageURL(file, for: screen, options: [:])
                completionHandeler()
            } catch {
                completionHandeler()
                NSLog("Setting Wallpaper Failed")
            }
        }
    }
    
    func storImage(meta: Wallpaper, callback: @escaping (_ filePath: URL)-> Void){
        let file = meta.imageFileUrl
        if !fileManager.fileExists(atPath: file.path) {
            wallpaperAPI.fetchImage(url: meta.wallpaperURL) { tempURL in
                do {
                    try FileManager.default.moveItem(atPath: tempURL.path, toPath: file.path)
                    callback(file)
                } catch {
                    NSLog("Wallpaper \(self.dateToStr(date: meta.startdate)) Save Failed")
                }
            }
        } else {
            NSLog("Image Exists \(String(describing: file.path))")
            callback(file)
        }
    }
    
    func storMeta(meta: Wallpaper) {
        if meta.err == nil {
            let encoder = JSONEncoder()
            do {
                let jsonData = try encoder.encode(meta)
                if !fileManager.fileExists(atPath: meta.metaFileUrl.path) {
                    fileManager.createFile(atPath: meta.metaFileUrl.path, contents: jsonData, attributes: nil)
                } else {
                    NSLog("Meta Exists \(String(describing: meta.metaFileUrl.path))")
                }
                
            } catch {
                NSLog("Encode Failed \(meta.startdate)")
            }
        }
    }
    
    func readMeta(date: Date) -> Wallpaper {
        let file = self.pathFromDate(date: date, type: ".json")
        if fileManager.fileExists(atPath: file.path) {
            do {
                let jsonStr = try String(contentsOf: file, encoding: .utf8)
                let jsonData = Data(jsonStr.utf8)
                return wallpaperAPI.wallpaperFromJSON(data: jsonData)
            } catch {
                NSLog("Json Reading Failed \(self.dateToStr(date: date))")
                return Wallpaper.init()
            }
        } else {
            NSLog("Json File Doesn' Exist \(self.dateToStr(date: date))")
            return Wallpaper.init()
        }
    }
    
    func cleanCache(maxIndex: Int, language: String){
        wallpaperAPI.fetchMeta(index: 0, language: language) { meta in
            let manager = FileManager.default
            let fileTypes = [".jpeg", ".json"]
            for fileType in fileTypes {
                var date = meta.startdate
                var allowed: [URL] = []
                var existing: [URL] = []
                do {
                    let files = try manager.contentsOfDirectory(atPath: self.cache.path)
                    for item in files  {
                        if item.hasPrefix("bing") && item.hasSuffix(fileType){
                            existing.append((self.cache.appendingPathComponent(item)))
                        }
                    }
                    for i in 0...maxIndex-1 {
                        if i != 0 {
                            date.addTimeInterval(TimeInterval(-24*60*60))
                        }
                        allowed.append(self.pathFromDate(date: date, type: fileType))
                    }
                    let toBeRm = self.outOfScope(arr1: existing, arr2: allowed)
                    for item in toBeRm{
                        do {
                            try manager.removeItem(at: item)
                            NSLog("Remove file \(item)")
                        } catch {
                            NSLog("Remove file Failed \(item)")
                        }
                    }
                } catch {
                    NSLog("Remove File (\(fileType)) Failed Completely")
                }
            }
        }
    }
    
    func dateToStr(date: Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    func pathFromDate(dateStr: String, type: String)->URL{
        return cache.appendingPathComponent("bing\(dateStr)\(type)")
    }
    
    func pathFromDate(date: Date, type: String)->URL{
        let dateStr = self.dateToStr(date: date)
        return pathFromDate(dateStr: dateStr, type: type)
    }
    
    func outOfScope(arr1:[URL], arr2: [URL])->[URL]{
        var arrReturn: [URL] = []
        for item in arr1{
            var appear = false
            for std in arr2{
                if item.absoluteString == std.absoluteString{
                    appear = true
                }
            }
            if !appear {
                arrReturn.append(item)
            }
        }
        return arrReturn
    }
    
}
