//
//  ChannelsMode.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//
import Foundation


struct ChannelsModel: Decodable {

    var channel: channelsData
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subDatas =  try container.decode([channelsData].self, forKey: .items)
        self.channel = subDatas[0]
    }
}


struct channelsData: Decodable {
    
    let title: String
    let url: URL
    let subscriberCount: String
    
    enum CodingKeys: String, CodingKey {
       case snippet
        case title
        
        case thumbnails
        case defaultThumbnail = "default"
        case url
        
        case statistics
        case subscriberCount
        
    }
    
    init (from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
             
        let snippetContainer =  try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        
        let thumbnailsContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
              let defaultThumbContainer = try thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .defaultThumbnail)
              self.url = try defaultThumbContainer.decode(URL.self, forKey: .url)
          
        let statisticsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .statistics)
          self.subscriberCount = try statisticsContainer.decode(String.self, forKey: .subscriberCount)
    }

}
