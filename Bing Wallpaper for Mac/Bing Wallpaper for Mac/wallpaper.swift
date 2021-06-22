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

    
    func getUrl()->URL{
        let urlStr = "www.bing.com\(url)";
        return URL(string: urlStr)!;
    }
    
    func getQuizUrl()->URL{
        let urlStr = "www.bing.com\(quiz)";
        return URL(string: urlStr)!;
    }
}
