//
//  SearchModel.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

struct SearchItemsModel : Decodable {
    
    var items: [SearchItems]
    
    enum Codingkeys: String, CodingKey {
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Codingkeys.self)
        self.items = try container.decode([SearchItems].self, forKey: .items)
    }
}

class SearchItems: Decodable {
  
    var kind: String
    var videoId: String
    
    var thumbnailURL: URL
    var publishedAt: String
    var channelId: String
    var channelTitle: String
    var title: String
    let description: String

    
    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case videoId
        
        case snippet
        case publishedAt
        case channelId
        case channelTitle
        case title
        case description
        
        case thumbnails
        case high
        case url

    }
    
    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let IdContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .id)
        self.kind = try IdContainer.decode(String.self, forKey: .kind)
        self.videoId = try IdContainer.decode(String.self, forKey: .videoId)

        
        let snippetContainer =  try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.publishedAt = try snippetContainer.decode(String.self, forKey: .publishedAt)
        self.channelId = try snippetContainer.decode(String.self, forKey: .channelId)
        self.channelTitle = try snippetContainer.decode(String.self, forKey: .channelTitle)
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        self.description = try snippetContainer.decode(String.self, forKey: .description)
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnailURL = try highContainer.decode(URL.self, forKey: .url)
      
    }
    
}
