//
//  DetailInfoCell.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/25.
//

import UIKit

class DetailInfoCell: UITableViewCell {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var VideoInfoLabel: UILabel!
    @IBOutlet weak var ChannelImageView: UIImageView!
    @IBOutlet weak var ChannelTitleLabel: UILabel!
    @IBOutlet weak var SubscriberNumLabel: UILabel!
    @IBOutlet weak var CommentImageView: UIImageView!
    @IBOutlet weak var CommentLabel: UILabel!
    @IBOutlet weak var CommentNumberLabel: UILabel!
    @IBOutlet weak var CommentInfoLabel: UILabel!
    @IBOutlet weak var SubscribeButton: UIButton!
    
    private var channelThumbnailVM: ChannelThumbnailViewModel?
    private var mainVideoSubDataVM: MainVideoSubDataViewModel?
    private let channelVM = ChannelsViewModel()
    var videoId = ""
    var channelId = ""
    
    func updateCell(_ data: SearchItems) {
     
        channelId = data.channelId
        print("나는 다른셀이에요")
        print(channelId)
        
        
        let imagedata = data.thumbnailURL.standardizedFileURL
        print(imagedata)
        TitleLabel.text = data.title
        ChannelTitleLabel.text = data.channelTitle
        print("나는 다른셀이에요")
      
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
        
        VideoInfoLabel.text = "\(time)"
    
        self.channelThumbnailVM = ChannelThumbnailViewModel(data.channelId)
        self.channelThumbnailVM?.delegate = self
//
        self.mainVideoSubDataVM = MainVideoSubDataViewModel(data.videoId)
        self.mainVideoSubDataVM?.delegate = self
        
    }
 
}


extension DetailInfoCell: ChannelThumbnailProtocol {
    
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


extension DetailInfoCell : ChannelsProtocol {

    func ChannelsFetched() {
        if let channel = channelVM.channel {
            DispatchQueue.main.async {

                self.SubscriberNumLabel.text = "구독자수 \(channel.subscriberCount)"
            }
        }
    }

    func ChannelsError(_ error: String) {
        print(error)
    }
}


extension DetailInfoCell: MainVideoSubDataProtocol {
    func MainVideoSubDataFetched(_ data: mainVideoSubData) {

        DispatchQueue.main.async {
            var durationDate = data.duration.replacingOccurrences(of: "M", with: ":")
            durationDate = durationDate.replacingOccurrences(of: "PT", with: "")
            durationDate = durationDate.replacingOccurrences(of: "S", with: "")
           
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
            self.VideoInfoLabel.text = "\(self.VideoInfoLabel.text!) • \(viewCountKr)"
        }
        self.mainVideoSubDataVM?.delegate = nil
        self.mainVideoSubDataVM = nil
    }
    
    func MainVideoSubDataError(_ error: String) {
        print(error)
    }
    
    
}
