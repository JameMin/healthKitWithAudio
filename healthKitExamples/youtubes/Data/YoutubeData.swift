//
//  YoutubeData.swift
//  Youtubes
//
//  Created by 서민영 on 2021/06/23.
//

import Foundation

class YoutubeData {
    
    let mainPlaylistId = "PLis5WuyWOdrXqtkDLGwVeqzNzkr16gdHL"
    let APIKEY = Constants.API
    
    let YOUTUBEURL = Constants.URL
    let PlaylistItemURL = "playlistItems"
    let SearchURL = "search"
    let VideoURL = "videos"
    let ChannelsURL = "channels"
    let CommentURL = "commentThreads"
 
    //MARK: "유튜브와 통신"
    
    // 유튜브 검색//
    func getSearchSnippet(SearchId: String)-> String {
        return "\(YOUTUBEURL)\(SearchURL)?part=snippet&q=\(SearchId)&regionCode=kr&key=\(APIKEY)"
    }
       
    // 비디오 가져오기//
    func getVideosDetail(videoId: String)-> String {
        return  "\(YOUTUBEURL)\(VideoURL)?part=snippet,contentDetails,statistics&id=\(videoId)&regionCode=kr&key=\(APIKEY)"
    }
    //채널 썸네일//
    func getChannelThumbnail(channelId: String) -> String {
        return "\(YOUTUBEURL)\(ChannelsURL)?part=snippet&id=\(channelId)&regionCode=kr&key=\(APIKEY)"
    }
    // 비디오 정보//
    func getMainVideoSubData(videoId: String) -> String {
        return "\(YOUTUBEURL)\(VideoURL)?part=contentDetails,statistics&id=\(videoId)&regionCode=kr&key=\(APIKEY)"
    }
    // 채널 정보//
    func getChannelData(channelId: String) -> String {
        return "\(YOUTUBEURL)\(ChannelsURL)?part=snippet,statistics&id=\(channelId)&regionCode=kr&key=\(APIKEY)"
    }
    // 영상 플레이리스트//
    func getPlayItemsSnippet(playlistId: String) -> String {
        return "\(YOUTUBEURL)\(PlaylistItemURL)?part=snippet&playlistId=\(playlistId)&regionCode=kr&key=\(APIKEY)"
    }

}
