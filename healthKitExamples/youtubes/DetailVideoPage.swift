//
//  DetailVideoPage.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/22.
//

import UIKit
import YouTubePlayer
import Kingfisher

class DetailVideoPage: UIViewController{
   
    //
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var VideoPlayer: YouTubePlayerView?
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var VideoInfoLabel: UILabel!
    @IBOutlet weak var ChannelImageView: UIImageView!
    @IBOutlet weak var ChannelTitleLabel: UILabel!
    @IBOutlet weak var SubscriberNumLabel: UILabel!
    @IBOutlet weak var SubscribeButton: UIButton!
    @IBOutlet weak var DetailTableView: UITableView!
    @IBOutlet weak var SubScribingButton: UIButton!
    private var videoId = ""
    private var channelId = ""
    private var publishedAt = ""
    var text : String?
    var titles: String?
    private let videoVM = VideosViewModel()
    private let channelVM = ChannelsViewModel()
    private var channelThumbnailVM: ChannelThumbnailViewModel?
    private var mainVideoSubDataVM: MainVideoSubDataViewModel?
    
    private let vm = YoutubeSearchPage()
    private let vms =  PlaylistItemsViewModel()
    
//    PlaylistItemsViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
        vms.delegate = self
        print("아이콘입니다")
        DetailTableView.delegate = self
        DetailTableView.dataSource = self
        
        VideoInfoLabel.text = text
        if videoId != "" && channelId != "" {
            
            let playerVars: [AnyHashable: Any] = [ "playsinline": 1 ]
            VideoPlayer?.loadVideoID(self.videoId)
            
            videoVM.delegate = self
            videoVM.FetchVideos(videoId: self.videoId)
            
            channelVM.delegate = self
            channelVM.FetchChannels(channelsId: self.channelId)
            
            
            
        }
    }
    
    func getData(publishedAt: String,ChannelTitle: String) {
        self.publishedAt = publishedAt
        
        // ViewModel 로 이동
        let formatter = ISO8601DateFormatter()
        let publishedDate = formatter.date(from: publishedAt)!
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
        print("가격")
        print("\(time)")
        text = time
        titles = ChannelTitle
        
    }
    
    func setData(videoId: String, channelId: String) {
        self.videoId = videoId
        self.channelId = channelId
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let detailVC = segue.destination as? DetailVideoPage {
                if let indexPath = self.DetailTableView.indexPath(for: cell) {
                    if let data = vms.getItemData(rowIndex: indexPath.row) {
                        detailVC.setData(videoId: data.videoId, channelId: data.channelId)
                        detailVC.getData(publishedAt: data.publishedAt,ChannelTitle: data.channelTitle)
                    }
                }
            }
        }
    }
    
    
    @IBAction func closeScene(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension DetailVideoPage : VideosProtocol {
    func VideosFetched() {
        if let video = videoVM.videos {
            DispatchQueue.main.async {
                self.TitleLabel.text = video.title
            }
        }
    }
    
    func VideosError(_ error: String) {
        print(error)
    }
}



extension DetailVideoPage : ChannelsProtocol {
    
    func ChannelsFetched() {
        if let channel = channelVM.channel {
            DispatchQueue.main.async { [self] in
                self.ChannelTitleLabel.text = channel.title
                self.ChannelImageView.layer.cornerRadius = ChannelImageView.frame.height/2
                self.ChannelImageView.kf.setImage(with: channel.url)
                self.SubscriberNumLabel.text = "구독자수 \(channel.subscriberCount)명"
            }
        }
    }
    
    func ChannelsError(_ error: String) {
        print(error)
    }
    
}

extension DetailVideoPage : SearchItemsProtocol {
    
    func SearchItemsFetched() {
        DispatchQueue.main.async {
            self.DetailTableView.reloadData()
            
        }
    }
    
    func SearchItemsError(error: String) {
        print(error)
        
    }
    
    
}

extension DetailVideoPage : PlaylistItemsProtocol {
    
    func playlistItemsFetched() {
        DispatchQueue.main.async {
            self.DetailTableView.reloadData()
            
        }
    }
    
    func playlistItemsError(_ error: String) {
        print(error)
        
    }
    
    
}

extension DetailVideoPage: MainVideoSubDataProtocol {
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
extension DetailVideoPage : UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vms.getDataCount() + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIVO.mainVideoCellName, for: indexPath) as! BasicYoutubeCell
        guard let data = vms.getItemData(rowIndex: indexPath.item) else {
            return cell
        }
        
        cell.NewCell(data)
        
        return cell
    }
}

