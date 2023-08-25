//
//  ChannelThumbnailViewModel.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

protocol ChannelThumbnailProtocol {
    func channelThubmanilFetched(_ thumbnail: URL)
    func channelThubmanilError(_ error: String)
}

class ChannelThumbnailViewModel {
 
    var delegate: ChannelThumbnailProtocol?
    
    init(_ id: String) {
          let DTO = YoutubeData()
        guard let url = URL(string: DTO.getChannelThumbnail(channelId: id)) else { return }
          let session = URLSession.shared
          session.dataTask(with: url, completionHandler: { (data, response, error) in
        
              if error != nil || data == nil { return }
              
              do {
              
              let decoder = JSONDecoder()
              let model = try decoder.decode(ChannelThumbnailModel.self, from: data!)
 
                self.delegate?.channelThubmanilFetched(model.thumbanil.url)
                
                } catch {
                    self.delegate?.channelThubmanilError(error.localizedDescription)
                 }
                 
                 }).resume()
    }
}
