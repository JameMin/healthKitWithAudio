//
//  VideoViewModel.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

protocol VideosProtocol {
    func VideosFetched()
    func VideosError(_ error: String)
}

class VideosViewModel {

var delegate: VideosProtocol?

var videos: videosData?

    func FetchVideos(videoId: String) {
    let DTO = YoutubeData()
    guard let url = URL(string: DTO.getVideosDetail(videoId: videoId)) else { return }
    let session = URLSession.shared
    session.dataTask(with: url, completionHandler: { (data, response, error) in
  
        if error != nil || data == nil { return }
        
        do {
        
        let decoder = JSONDecoder()
        let model = try decoder.decode(VideosModel.self, from: data!)
            self.videos = model.video
        
            self.delegate?.VideosFetched()
            
            
        } catch {
            self.delegate?.VideosError(error.localizedDescription)
        }
        
        }).resume()
    
}
}

