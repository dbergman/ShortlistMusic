//
//  ExportShortListProvider.swift
//  shortList
//
//  Created by Dustin Bergman on 1/15/22.
//  Copyright © 2022 Dustin Bergman. All rights reserved.
//

import Foundation
import MessageUI

class ExportShortListProvider: NSObject {
    private weak var vc: UIViewController?
    
    @objc init(vc: UIViewController) {
        super.init()
        
        self.vc = vc
    }
    
    @objc func emailShortList() {
        SLParseController.getUsersShortLists { shortlists in
            self.sendEmail(with: shortlists)
        }
    }
    
    private func sendEmail(with shortlists: [SLShortlist]) {
        guard MFMailComposeViewController.canSendMail() else { return }

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("ShortListMusic Export")
        mail.setMessageBody(buildEmailBody(shortlists: shortlists), isHTML: true)
        vc?.present(mail, animated: true)
    }
    
    private func buildEmailBody(shortlists: [SLShortlist]) -> String {
        let htmlStart = "<html><body>"
        var shortListBodyHTML = ""
        
        for shortlist in shortlists {
            guard
                let shortlistName = shortlist.shortListName,
                let shortlistYer = shortlist.shortListYear
            else
            {
                continue
            }

            let shortlistHeader = "<table border=\"1\"><tr><th colspan = 3>\(shortlistName)</th><th colspan = 1>\(shortlistYer)</th></tr>"
            
            var albumRows = ""
            for album in shortlist.shortListAlbums {
                guard
                    let albumName = album.albumName,
                    let artistName = album.artistName,
                    let releaseYear = album.releaseYear
                else {
                    continue
                }

                albumRows = albumRows + "<tr><td>\(album.shortListRank)</td><td>\(albumName)</td><td>\(artistName)</td><td>\(releaseYear)</td></tr>"
            }
            
            shortListBodyHTML = shortListBodyHTML + shortlistHeader + albumRows + "</table> <br><br>"
        }
        
        let completeHTML = htmlStart + shortListBodyHTML + "</body></html>"
        
        return completeHTML
    }

}

extension ExportShortListProvider: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?)
    {
        controller.dismiss(animated: true)
    }
}
