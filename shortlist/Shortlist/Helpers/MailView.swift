//
//  MailView.swift
//  Shortlist
//
//  Created by Dustin Bergman on 7/16/25.
//


import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    let recipients: [String]?
    let subject: String
    let messageBody: String
    let isHTML: Bool
    let attachment: Data?
    let attachmentMimeType: String?
    let attachmentFilename: String?
    
    init(
        recipients: [String]? = nil,
        subject: String,
        messageBody: String,
        isHTML: Bool = false,
        attachment: Data? = nil,
        attachmentMimeType: String? = nil,
        attachmentFilename: String? = nil
    ) {
        self.recipients = recipients
        self.subject = subject
        self.messageBody = messageBody
        self.isHTML = isHTML
        self.attachment = attachment
        self.attachmentMimeType = attachmentMimeType
        self.attachmentFilename = attachmentFilename
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true) {
                self.parent.dismiss()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        
        if let recipients = recipients {
            vc.setToRecipients(recipients)
        }
        
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: isHTML)
        vc.mailComposeDelegate = context.coordinator

        if let attachment = attachment,
           let mimeType = attachmentMimeType,
           let filename = attachmentFilename {
            vc.addAttachmentData(attachment, mimeType: mimeType, fileName: filename)
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
