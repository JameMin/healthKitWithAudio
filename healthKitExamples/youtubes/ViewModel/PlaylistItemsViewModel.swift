//
//  PlaylistItemsViewModel.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/24.
//

import Foundation

// Base ViewModel 같은걸로 묶도록.
protocol PlaylistItemsProtocol {
    func playlistItemsFetched()
    func playlistItemsError(_ error: String)
}

class PlaylistItemsViewModel {
    
    var delegate: PlaylistItemsProtocol?
    
    var items: [playlistItems] = [playlistItems]()
    
    init() {
        let DTO = YoutubeData()
        print(DTO)
        guard let url = URL(string: DTO.getPlayItemsSnippet(playlistId: DTO.mainPlaylistId)) else { return }
        print(url)
        let session = URLSession.shared
        session.dataTask(with: url, completionHandler: { (data, response, error) in
      
            if error != nil || data == nil { return }
            
            do {
            
            let decoder = JSONDecoder()
            let model = try decoder.decode(PlaylistItemsModel.self, from: data!)
            self.items = model.items
            
            self.delegate?.playlistItemsFetched()
                
                
            } catch {
                self.delegate?.playlistItemsError(error.localizedDescription)
            }
            
            }).resume()
        
    }
    
    func getItemData(rowIndex: Int) -> playlistItems? {
        guard rowIndex < items.count else {
            return nil
        }
        
        return items[rowIndex]
    }
    
    func getDataCount() -> Int {
        return items.count
    }
    
}
