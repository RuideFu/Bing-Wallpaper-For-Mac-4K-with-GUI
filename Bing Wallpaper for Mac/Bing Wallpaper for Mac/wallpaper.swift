//
//  wallpaper.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Foundation

struct Bingfeedback: Decodable {
    let images: [Wallpaper];
}

struct Wallpaper: Decodable {
    let startdate: Date;
    let url: String;
    let title: String;
    let copyright: String;
    let quiz: String;
    let err: Bool?;
    var wallpaperURL: URL {
        return bingURL(halfurl: url)
    }
    var quizURL: URL {
        return bingURL(halfurl: quiz)
    }
    var description: String {
        return "\(startdate)\n\(title)\n\(wallpaperURL)"
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
