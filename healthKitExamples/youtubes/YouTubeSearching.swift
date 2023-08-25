//
//  YouTubeSearching.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import UIKit

class YoutubeSearhing: UIViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var titles:String?

    override func viewDidLoad() {
        searchBar.delegate = self
        print("검색했어요")
        super.viewDidLoad()
    }
    private func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        dismissKeyboard()
        // 검색어가 있는지
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else { return }
        
        print("--> 검색어: \(searchTerm)")
           
            print("성공")
            self.movepage()
            
            self.searchBar.text = titles
        
        
    }

    func movepage() {
            let vc = storyboard?.instantiateViewController(withIdentifier: "YoutubeSearchPage") as? YoutubeSearchPage
            vc!.modalPresentationStyle = .overCurrentContext
            vc?.modalTransitionStyle = .coverVertical
            vc!.text = searchBar.text
            self.present(vc!, animated: true, completion: nil)
    
        }
    
    
    
}
