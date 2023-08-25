//
//  ViewController.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/22.
//
import Foundation
import UIKit
import Kingfisher


class YoutubeSearchPage: UITableViewController {
    
    @IBOutlet weak var LogoView: UIView!
    @IBOutlet weak var YoutubeLogo: UIImageView!
    @IBOutlet weak var TitleView: UITextView!
    @IBOutlet var YouTubeTableView: UITableView!
    var text: String?
    @IBOutlet weak var Titlesend: UIButton!
    
    var delegate : SearchItemsProtocol?
    
    var items: [SearchItems] = [SearchItems]()
    
    var SearchId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.TitleView.text = text
        self.Titlesend.setTitle(text, for: .normal)
     
        Titlesend.contentHorizontalAlignment = .left
        print("")
        print("받았다")
        //    Do any additional setup after loading the view.
        //  MARK: - 유튜브 검색 하는 방법

        SearchId = text
 
        self.delegate = self
        print(text)
        
        if SearchId != nil {
            SearchId = text
        }
        else {
            SearchId = "canon"
        }
        let DTO = YoutubeData()
        let session = URLSession.shared
        //한국어 검색가능
        guard let urls = URL(string: DTO.getSearchSnippet(SearchId: SearchId!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)else{return}
        let url = urls
        print(url)
       // 서버에 데이터 전송 및 url 표시
        session.dataTask(with: url,completionHandler: { [self](data, response, error) in
            guard error == nil else{
                print(error?.localizedDescription as Any)
                return
            }
            if error != nil || data == nil
            {
                return }
            print("sucess")
            
            guard let resultData = data else { return }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SearchItemsModel.self, from: resultData)
                self.items = response.items
                self.delegate?.SearchItemsFetched()
                print("Yes")
            } catch {
                self.delegate?.SearchItemsError(error: error.localizedDescription)
                
            }
            print(response as Any)
        }).resume()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let detailVC = segue.destination as? DetailVideoPage {
                if let indexPath = self.tableView.indexPath(for: cell) {
                    if let data = getItemData(rowIndex: indexPath.row){
                        detailVC.setData(videoId: data.videoId, channelId: data.channelId)
                        detailVC.getData(publishedAt: data.publishedAt,ChannelTitle: data.channelTitle)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getDataCount()

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIVO.mainVideoCellName, for: indexPath) as! BasicYoutubeCell
        guard let data = getItemData(rowIndex:  indexPath.item) else {
            return cell
        }
        
        cell.updateCell(data)
        
        return cell
    }
    
    
    @IBAction func SendTexting(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "YoutubeSearhing")
        vc!.modalPresentationStyle = .overCurrentContext
        vc?.modalTransitionStyle = .coverVertical
        vc?.title = text
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func moving(_ sender: Any) {
        self.movingpage()
        
    }
 
    
    func movingpage(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "YoutubeSearhing")
        vc!.modalPresentationStyle = .overCurrentContext
        vc?.modalTransitionStyle = .coverVertical
        self.present(vc!, animated: true, completion: nil)
        
    }
    // 유튜브 검색 영상 가져오기
    func getItemData(rowIndex: Int) -> SearchItems? {
        guard rowIndex < items.count else {
            return nil
        }
        return items[rowIndex]
    }
    
    func getDataCount() -> Int {
        return items.count
    }
    
    
}
//
extension YoutubeSearchPage : SearchItemsProtocol {
    
    func SearchItemsFetched() {
        DispatchQueue.main.async {
            self.YouTubeTableView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func SearchItemsError(error: String) {
        print(error)
        
    }
    
    
}

