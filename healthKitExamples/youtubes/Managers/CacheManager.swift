//
//  CacheManager.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

class CacheManager {
    
    static var cache = [String:Data]()
    
    static func setVideoCache(_ url:String, _ data:Data?) {
        
        cache[url] = data
        
    }
    
    static func getVideoCache(_ url:String) -> Data? {
        
        return cache[url]
         
    }
}
