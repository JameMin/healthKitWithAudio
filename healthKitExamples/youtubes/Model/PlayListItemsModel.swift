//
//  PlayListLtemsModel.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

struct PlaylistItemsModel : Decodable {
    
    var items: [playlistItems]
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items =  try container.decode([playlistItems].self, forKey: .items)
    }
}

struct playlistItems: Decodable {
    
    let thumbnailURL: URL
    let publishedAt: String
    let channelId: String
    let channelTitle: String
    let title: String
    let description: String
    let videoId: String
    
    enum CodingKeys: String, CodingKey {
        case snippet
        case publishedAt
        case channelId
        case channelTitle
        case title
        case description
        
        case thumbnails
        case high
        case url
        
        case resourceId
        case videoId
    }
    
    init (from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer =  try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        self.publishedAt = try snippetContainer.decode(String.self, forKey: .publishedAt)
        self.channelId = try snippetContainer.decode(String.self, forKey: .channelId)
        self.channelTitle = try snippetContainer.decode(String.self, forKey: .channelTitle)
        self.title = try snippetContainer.decode(String.self, forKey: .title)
        self.description = try snippetContainer.decode(String.self, forKey: .description)
        
        let thumbnailContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let highContainer = try thumbnailContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .high)
        self.thumbnailURL = try highContainer.decode(URL.self, forKey: .url)
        
        let resourceContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .resourceId)
        self.videoId = try resourceContainer.decode(String.self, forKey: .videoId)
    }
}
