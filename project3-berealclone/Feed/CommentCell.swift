//
//  CommentCell.swift
//  project3-berealclone
//
//  Created by Luis Delgado on 3/23/26.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with comment: Comment) {
        // Set Username (Bold it slightly to stand out)
        usernameLabel.text = comment.user?.username ?? "Unknown User"
        
        // Set Comment Text
        commentLabel.text = comment.text
        
        // Set Date (Format it to look like "2 mins ago" or "Oct 12")
        if let createdAt = comment.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: createdAt)
        }
        
        // Fix the "White on White" issue
        usernameLabel.textColor = .label // Adapts to Dark/Light mode
        commentLabel.textColor = .secondaryLabel
        dateLabel.textColor = .tertiaryLabel
    }
}
