//
//  InformationController.swift
//  SocialProject
//
//  Created by Mac on 2018/8/23.
//  Copyright © 2018年 ZYY. All rights reserved.
//

import UIKit
import DNSPageView

class InformationController: ZYYBaseViewController {
    
    var model: ConnectionModel?
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var concernBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bgView.backgroundColor = .themOneColor
        nameLabel.text = model?.name
        avatarImg.setWebImage(with: Image_Path+(model?.headImg)!)
        let titles: [String] = ["简介", "相册", "动态"]
        var childViewControllers: [UIViewController] = []
        let describtionVC = UIStoryboard(name: .connection).initialize(class: OthersDescribtionController.self)
        describtionVC.ID = String(format: "%d", (model?.id)!)
        childViewControllers.append(describtionVC)
        let albumVC = UIStoryboard(name: .connection).initialize(class: OthersAlbumController.self)
        albumVC.ID = String(format: "%d", (model?.id)!)
        albumVC.presentAction = { [unowned self] vc in
            self.present(vc, animated: true, completion: nil)
        }
        childViewControllers.append(albumVC)
        let dynamicVC = UIStoryboard(name: .mine).initialize(class: MyDynamicController.self)
        dynamicVC.others = true
        dynamicVC.ID = String(format: "%d", (model?.id)!)
        childViewControllers.append(dynamicVC)
        
        // 创建DNSPageStyle，设置样式
        let style = DNSPageStyle()
        style.titleSelectedColor = .yellow
        style.titleColor = .white
        style.titleViewBackgroundColor = .themOneColor
        
        // 创建对应的DNSPageView，并设置它的frame
        let pageView = DNSPageView(frame: CGRect(x: 0, y: 110, width: DEVICE_WIDTH, height: DEVICE_HEIGHT - 44 - 110), style: style, titles: titles, childViewControllers: childViewControllers)
        self.view.addSubview(pageView)
        self.view.bringSubview(toFront: bottomView)
        
        if (model?.followState)! {
            concernBtn.setTitle("取消关注", for: .normal)
        } else {
            concernBtn.setTitle("+ 关注", for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func concernAction(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        if sender.titleLabel?.text == "取消关注" {
            showBlurHUD()
            let req = CancelAttentionReq(id: userID, otherId: String(format: "%d", (model?.id)!))
            WebAPI.send(req) { (isSuccess, result, error) in
                self.hideBlurHUD()
                if isSuccess {
                    self.showBlurHUD(result: .success, title: "取消成功") { [unowned self] in
                        sender.setTitle("+ 关注", for: .normal)
                        sender.isUserInteractionEnabled = true
                    }
                } else {
                    self.showBlurHUD(result: .failure, title: error?.errorMsg)
                }
            }
        } else {
            self.showBlurHUD()
            let req = AttentionReq(id: userID, otherId: String(format: "%d", (model?.id)!))
            WebAPI.send(req) { (isSuccess, result, error) in
                self.hideBlurHUD()
                if isSuccess {
                    self.showBlurHUD(result: .success, title: "关注成功") { [unowned self] in
                        sender.setTitle("取消关注", for: .normal)
                        sender.isUserInteractionEnabled = true
                    }
                } else {
                    self.showBlurHUD(result: .failure, title: error?.errorMsg)
                }
            }
        }
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        let vc = RCConversationViewController(conversationType: .ConversationType_PRIVATE, targetId: String(format: "%d", (model?.id)!))
        vc?.title = model?.name
        navigationController?.pushViewController(vc!, animated: true)
    }
}
