//
//  BasicYoutubeCell.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/22.
//

import UIKit


class BasicYoutubeCell: UITableViewCell{
 
    @IBOutlet weak var ThumbNailView: UIImageView!
    @IBOutlet weak var ChannelImageView: UIImageView!
    @IBOutlet weak var ChannelTitle: UILabel!
    @IBOutlet weak var ChannelDate: UILabel!
    @IBOutlet weak var RunTime: UITextField!
    
    
    
    private var channelThumbnailVM: ChannelThumbnailViewModel?
    private var mainVideoSubDataVM: MainVideoSubDataViewModel?
    

    var videoId = ""
    var channelId = ""
    
    func updateCell(_ data: SearchItems) {
     
        channelId = data.channelId
        
        ThumbNailView.kf.setImage(with: data.thumbnailURL)
        
        let imagedata = data.thumbnailURL.standardizedFileURL
        ChannelTitle.text = data.title
      
        // ViewModel 로 이동
        let formatter = ISO8601DateFormatter()
        let publishedDate = formatter.date(from: data.publishedAt)!
        let calendar = Calendar.current
        let interval = calendar.dateComponents([.year,.month,.day,.hour], from: publishedDate, to: Date.init())
        var time = ""
        
        if interval.year! > 0 {
            time = "\(interval.year!)년 전"
        } else if interval.month! > 0 {
            time = "\(interval.month!)개월 전"
        } else if interval.day! > 0 {
            time = "\(interval.day!)일 전"
        } else if interval.hour! > 0 {
            time = "\(interval.hour!)시간 전"
        } else {
            time = "방금 전"
        }
        
        ChannelDate.text = "\(data.channelTitle) • \(time)"
    
        self.channelThumbnailVM = ChannelThumbnailViewModel(data.channelId)
        self.channelThumbnailVM?.delegate = self
//        
        self.mainVideoSubDataVM = MainVideoSubDataViewModel(data.videoId)
        self.mainVideoSubDataVM?.delegate = self
        
    }
    
    func NewCell(_ data: playlistItems) {
     
        channelId = data.channelId
        
        ThumbNailView.kf.setImage(with: data.thumbnailURL)
        
        let imagedata = data.thumbnailURL.standardizedFileURL
        ChannelTitle.text = data.title
      
        // ViewModel 로 이동
        let formatter = ISO8601DateFormatter()
        let publishedDate = formatter.date(from: data.publishedAt)!
        let calendar = Calendar.current
        let interval = calendar.dateComponents([.year,.month,.day,.hour], from: publishedDate, to: Date.init())
        var time = ""
        
        if interval.year! > 0 {
            time = "\(interval.year!)년 전"
        } else if interval.month! > 0 {
            time = "\(interval.month!)개월 전"
        } else if interval.day! > 0 {
            time = "\(interval.day!)일 전"
        } else if interval.hour! > 0 {
            time = "\(interval.hour!)시간 전"
        } else {
            time = "방금 전"
        }
        
        ChannelDate.text = "\(data.channelTitle) • \(time)"
    
        self.channelThumbnailVM = ChannelThumbnailViewModel(data.channelId)
        self.channelThumbnailVM?.delegate = self
//
        self.mainVideoSubDataVM = MainVideoSubDataViewModel(data.videoId)
        self.mainVideoSubDataVM?.delegate = self
        
    }
    
 
}


extension BasicYoutubeCell: ChannelThumbnailProtocol {
    
    func channelThubmanilFetched(_ thumbnail: URL) {
        
        ChannelImageView.layer.cornerRadius = ChannelImageView.frame.height/2
        
        ChannelImageView.kf.setImage(with: thumbnail)
        
        self.channelThumbnailVM?.delegate = nil
        self.channelThumbnailVM = nil
    }
    
    func channelThubmanilError(_ error: String) {
        print(error)
    }
}


extension BasicYoutubeCell: MainVideoSubDataProtocol {
    func MainVideoSubDataFetched(_ data: mainVideoSubData) {

        DispatchQueue.main.async {
            var durationDate = data.duration.replacingOccurrences(of: "M", with: ":")
            durationDate = durationDate.replacingOccurrences(of: "PT", with: "")
            durationDate = durationDate.replacingOccurrences(of: "S", with: "")
            self.RunTime.text = durationDate
            
            var viewCountKr = ""
            let viewCountParsing = Int(data.viewCount)
            if viewCountParsing! >= 100000 {
                viewCountKr = "조회수 \(viewCountParsing! / 10000)만회"
            } else if viewCountParsing! >= 10000 {
                viewCountKr = "조회수 \(Double(viewCountParsing! / 1000) * 0.1)만회"
            } else if viewCountParsing! >= 1000 {
                viewCountKr = "조회수 \(Double(viewCountParsing! / 100) * 0.1)천회"
            } else {
                viewCountKr = "조회수 \(viewCountParsing!)회"
            }
            self.ChannelDate.text = "\(self.ChannelDate.text!) • \(viewCountKr)"
        }
        self.mainVideoSubDataVM?.delegate = nil
        self.mainVideoSubDataVM = nil
    }
    
    func MainVideoSubDataError(_ error: String) {
        print(error)
    }
    
    
}

