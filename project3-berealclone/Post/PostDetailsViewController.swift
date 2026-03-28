//


import UIKit
import ParseSwift

class PostDetailsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    var post: Post! // This will be passed from the Feed
    var comments = [Comment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the outlet is connected
            if tableView == nil {
                print("DEBUG: 🚨 The tableView IBOutlet is NOT connected in Storyboard!")
            }
        
        tableView.dataSource = self
        fetchComments()
    }

    func fetchComments() {
        guard let post = self.post else {
            print("DEBUG: ⚠️ No post found in DetailView")
            return
        }

        // Use 'try?' to satisfy the compiler.
        // This creates the query or returns nil if it fails.
        guard let query = try? Comment.query("post" == post) else {
            print("DEBUG: ❌ Could not construct the query")
            return
        }

        query
            .include("user")
            .order([.descending("createdAt")])
            .find { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedComments):
                        print("DEBUG: ✅ Found \(fetchedComments.count) comments")
                        self?.comments = fetchedComments
                        self?.tableView.reloadData()
                    case .failure(let error):
                        print("DEBUG: ❌ Query Error: \(error.localizedDescription)")
                    }
                }
            }
    }

    @IBAction func onSendCommentTapped(_ sender: Any) {
        var newComment = Comment()
            newComment.text = commentTextField.text
            newComment.user = User.current
            newComment.post = post

            newComment.save { [weak self] result in
                switch result {
                case .success(let savedComment):
                    print("✅ Comment saved: \(savedComment)")
                    
                    // CRITICAL: Move back to the Main Thread for UI updates
                    DispatchQueue.main.async {
                        self?.commentTextField.text = "" // Clear the text field
                        self?.commentTextField.resignFirstResponder() // Optional: Hide the keyboard
                        self?.fetchComments() // This reloads the table, so it MUST be here
                    }
                    
                case .failure(let error):
                    print("❌ Error saving comment: \(error.localizedDescription)")
                    // You should also wrap alerts in DispatchQueue.main.async!
                }
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("DEBUG: 📊 TableView asking for row count. Returning: \(comments.count)")
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = comments[indexPath.row]
        
        // Assuming your cell has two labels tagged or connected via a custom class
        cell.textLabel?.text = comment.user?.username
        cell.detailTextLabel?.text = comment.text
        return cell
    }
}
