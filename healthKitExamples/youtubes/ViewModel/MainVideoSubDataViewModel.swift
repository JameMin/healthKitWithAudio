//
//  MainVideoSubDataViewModel.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

protocol MainVideoSubDataProtocol {
    func MainVideoSubDataFetched(_ data: mainVideoSubData)
    func MainVideoSubDataError(_ error: String)
}

class MainVideoSubDataViewModel {
 
    var delegate: MainVideoSubDataProtocol?
    
    init(_ id: String) {
          let DTO = YoutubeData()
        guard let url = URL(string: DTO.getMainVideoSubData(videoId: id)) else { return }
          let session = URLSession.shared
          session.dataTask(with: url, completionHandler: { (data, response, error) in
        
              if error != nil || data == nil { return }
              
              do {
              
              let decoder = JSONDecoder()
              let model = try decoder.decode(MainVideoSubDataModel.self, from: data!)
 
                self.delegate?.MainVideoSubDataFetched(model.subData)
                
                } catch {
                    self.delegate?.MainVideoSubDataError(error.localizedDescription)
                 }
                 
                 }).resume()
    }
}
