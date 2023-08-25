////
////  PlaylistItemsViewModel.swift
////  Youtubes
////
////  Created by 서민영 on 2021/06/23.
////
import UIKit
import Foundation

protocol SearchItemsProtocol {
    func SearchItemsFetched()
    func SearchItemsError(error: String)
}
