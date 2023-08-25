//
//  ChannelThumbnailModel.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

struct ChannelThumbnailModel: Decodable {
    
        var thumbanil: channelThumbnail
        
        enum CodingKeys: String, CodingKey {
            case items
        }
        
        init (from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let thumbnails =  try container.decode([channelThumbnail].self, forKey: .items)
            self.thumbanil = thumbnails[0]
        }
    }


struct channelThumbnail: Decodable {
    
    let url: URL
    
    enum CodingKeys: String, CodingKey {
       case snippet

        case thumbnails
        case defaultThumbnail = "default"
        case url
    }
    
    init (from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
             
        let snippetContainer =  try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .snippet)
        let thumbnailsContainer = try snippetContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnails)
        let defaultThumbContainer = try thumbnailsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .defaultThumbnail)
        self.url = try defaultThumbContainer.decode(URL.self, forKey: .url)
    }

}

