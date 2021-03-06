//
//  wallpaper.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Foundation

let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first

struct Bingfeedback: Decodable {
    let images: [Wallpaper];
}

struct Wallpaper: Decodable, Encodable {
    let startdate: Date;
    let url: String;
    let title: String;
    let copyright: String;
    let quiz: String;
    var err: Bool?;
    var wallpaperURL: URL {
        return bingURL(halfurl: url)
    }
    var quizURL: URL {
        return bingURL(halfurl: quiz)
    }
    var description: String {
        return "\(startdate)\n\(title)\n\(wallpaperURL)"
    }
    var imageFileUrl: URL {
        let date = cacheManager().dateToStr(date: startdate)
        return (cache?.appendingPathComponent("bing\(date).jpeg"))!
    }
    var metaFileUrl : URL {
        let date = cacheManager().dateToStr(date: startdate)
        return (cache?.appendingPathComponent("bing\(date).json"))!
    }
    init() {
        err = true;
        startdate = Date();
        url = ""
        title = ""
        copyright = ""
        quiz = ""
    }
}




func bingURL(halfurl: String)->URL{
    return URL(string: "https://www.bing.com\(halfurl)")!
}
