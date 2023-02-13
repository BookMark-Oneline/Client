//
//  CommunityInsideViewController.swift
//  BookMark
//
//  Created by Jin younkyum on 2023/01/30.
//


import UIKit

class CommunityInsideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//MARK: NetworkTintin
    let network = NetworkTintin()
    
    var clubID: Int = 0
    var announceID: Int?
    
    var postData = [PostInfo]()

    struct PostInfo {
        let postID: Int
        let postTitle: String
        let postContent: String
        let likeNum: Int
        let commentNum: Int
        let createdAt: String?
    }
    
    let layout_post = Posts()
    var selectedIndexPath = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = layout_post.layout_posts.indexPathForSelectedRow {
            layout_post.layout_posts.deselectRow(at: selectedIndexPath, animated: animated)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCommunityInsideData()
        print(self.postData.count)
        setNavCustom()
        layout_post.initViews(view: self.view)
        layout_post.layout_posts.delegate = self
        layout_post.layout_posts.dataSource = self

        layout_post.btn_posting.addTarget(self, action: #selector(pushCreatePostViewController), for: .touchUpInside)
    }
    
    @objc func pushCreatePostViewController(_ sender: UIButton) {
        self.navigationController?.pushViewController(CreatePostViewController(), animated: true)
    }
    
    func setNavCustom() {
        self.setNavigationCustom(title: "책과 무스비")
        self.setNavigationImageButton(imageName: ["group_member", "group_setting"], action: [#selector(pushCommunityMemberViewController), #selector(pushCommunitySettingViewController)])
    }
    
    @objc func pushCommunitySettingViewController(_ sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(SetCommunityViewController(), animated: true)
    }
    
    @objc func pushCommunityMemberViewController(_ sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(CommunityMemberViewController(), animated: true)
    }

}

extension CommunityInsideViewController {
    func getCommunityInsideData() {
        network.getCommunityInfo { res in
            switch res {
            case .success(let communityInfo):
                if let comInfo = communityInfo as? CommunityInfo {
                    print("club ID : \(comInfo.clubID)")
                    print(comInfo.announcementID)
                    self.announceID = comInfo.announcementID
                    self.clubID = comInfo.clubID
                    
                    comInfo.postResponse.forEach({ item in
                        let post: PostInfo = PostInfo(postID: item.clubPostID, postTitle: item.clubPostTitle, postContent: item.postContentText, likeNum: item.likeNum, commentNum: item.commentNum, createdAt: item.createdAt ?? nil)
                        
                        self.postData.append(post)
                    })
                    
                    self.layout_post.layout_posts.reloadData()
                    
                    print(self.postData)
                }
//                self.dataReload(status: 0)
            default:
                print("failed")
            }
        }
    }
}

// MARK: - TableView Delegate & Datasource
extension CommunityInsideViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.announceID == nil) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: postCell.identifier, for: indexPath) as? postCell else { return postCell() }

            cell.label_comment.text = String(self.postData[indexPath.row].commentNum)
            cell.label_like.text = String(self.postData[indexPath.row].likeNum)
            cell.label_title.text = self.postData[indexPath.row].postTitle
            cell.label_context.text = self.postData[indexPath.row].postContent

            return cell
        } else {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: noticePostCell.identifier, for: indexPath) as? noticePostCell else { return noticePostCell() }

                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: postCell.identifier, for: indexPath) as? postCell else { return postCell() }

                cell.label_comment.text = String(self.postData[indexPath.row-1].commentNum)
                cell.label_like.text = String(self.postData[indexPath.row-1].likeNum)
                cell.label_title.text = self.postData[indexPath.row-1].postTitle
                cell.label_context.text = self.postData[indexPath.row-1].postContent

                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.announceID == nil) {
            return 95
        } else {
            if indexPath.row == 0 {
                return 50
            } else {
                return 95
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(PostDetailViewController(), animated: true)
    }
}


// MARK: - Performing TableView
class Posts {
    var layout_posts: UITableView =  {
        let layout_posts = UITableView()
        layout_posts.backgroundColor = .white
        layout_posts.register(noticePostCell.self, forCellReuseIdentifier: noticePostCell.identifier)
        layout_posts.register(postCell.self, forCellReuseIdentifier: postCell.identifier)
        layout_posts.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout_posts.translatesAutoresizingMaskIntoConstraints = false
        return layout_posts
    }()
    
    let btn_posting = UIButton()
    
    func initViews(view: UIView) {
        view.addSubviews(layout_posts, btn_posting)
        layout_posts.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        btn_posting.snp.makeConstraints { make in
            make.width.equalTo(55)
            make.height.equalTo(55)
            make.right.equalToSuperview().offset(-23)
            make.bottom.equalToSuperview().offset(-49)
        }
        
        btn_posting.layer.cornerRadius = 27.5
        btn_posting.backgroundColor = .orange
        btn_posting.setImage(UIImage(named: "group_posting"), for: .normal)

    }
}


// MARK: - Notice Post Cell Layout
class noticePostCell: UITableViewCell {
    static let identifier = "noticeCell"
    let label_title = UILabel()
    let label_noticeTitle = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews(label_title, label_noticeTitle)
        
        label_title.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        label_title.textAlignment = .center
        label_title.text = "[공지]"
        label_title.textColor = UIColor(red: 249/255, green: 144/256, blue: 1/256, alpha: 1)
        label_title.font = .systemFont(ofSize: 16)
        
        
        label_noticeTitle.snp.makeConstraints { make in
            make.left.equalTo(label_title.snp.right).offset(6)
            make.centerY.equalTo(label_title)
            make.height.equalTo(20)
        }
        label_noticeTitle.text = "공지사항 제목"
        label_noticeTitle.textAlignment = .natural
        label_noticeTitle.textColor = .black
        label_noticeTitle.font = .systemFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Normal Post Cell Layout
class postCell: UITableViewCell {
    static let identifier = "postCell"
    let label_title = UILabel()
    let label_context = UILabel()
    let label_time = UILabel()
    let layout_like = UIImageView()
    let layout_comment = UIImageView()
    let label_like = UILabel()
    let label_comment = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews(label_title, label_context, label_time, layout_like, label_like, layout_comment, label_comment)
        
        label_title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(23)
            make.top.equalToSuperview().offset(13)
            make.width.equalTo(200)
            make.height.equalTo(19)
        }
//        label_title.text = "게시물 제목입니다."
        label_title.numberOfLines = 1
        label_title.lineBreakMode = .byTruncatingTail
        label_title.textColor = .black
        label_title.font = .boldSystemFont(ofSize: 15)
        
        label_context.snp.makeConstraints { make in
            make.leading.equalTo(label_title)
            make.top.equalTo(label_title.snp.bottom).offset(3)
            make.right.equalToSuperview().offset(-23)
            make.height.equalTo(20)
        }
//        label_context.text = "게시물 내용입니다. 게시물 내용입니다. 게시물 내용입니다. 게시물 내용입니다."
        label_context.font = .systemFont(ofSize: 13)
        label_context.numberOfLines = 1
        label_context.lineBreakMode = .byTruncatingTail
        label_context.textColor = .black
        
        label_time.snp.makeConstraints { make in
            make.leading.equalTo(label_title)
            make.top.equalTo(label_context.snp.bottom).offset(8)
            make.width.equalTo(70)
            make.height.equalTo(15)
        }
        
        label_time.font = .systemFont(ofSize: 12)
//        label_time.text = "5시간전"
        label_time.textColor = .textGray
        
        label_comment.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-23)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(18)
            make.width.equalTo(18)
        }
//        label_comment.text = "11"
        label_comment.textColor = .black
        label_comment.font = .systemFont(ofSize: 11)
        
        layout_comment.snp.makeConstraints { make in
            make.right.equalTo(label_comment.snp.left).offset(-3)
            make.centerY.equalTo(label_comment)
            make.height.equalTo(label_comment)
            make.width.equalTo(label_comment.snp.height)
        }
        layout_comment.image = UIImage(named: "balloon")
        
        label_like.snp.makeConstraints { make in
            make.height.equalTo(label_comment)
            make.width.equalTo(label_comment)
            make.centerY.equalTo(label_comment)
            make.right.equalTo(layout_comment.snp.left).offset(-3)
        }
        label_like.text = "10"
        label_like.textColor = .red
        label_like.font = .systemFont(ofSize: 11)
        
        layout_like.snp.makeConstraints { make in
            make.right.equalTo(label_like.snp.left).offset(-3)
            make.centerY.equalTo(label_comment)
            make.height.equalTo(label_comment)
            make.width.equalTo(label_comment)
        }
        layout_like.image = UIImage(named: "heart")
  
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
