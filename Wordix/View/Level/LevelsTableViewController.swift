//
//  LevelsTableViewController.swift
//  Wordix
//
//  Created by Ігор on 10/24/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import UIKit
import RealmSwift
import AlamofireImage
import Firebase

class LevelsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var languageBtn : UIButton!
    @IBOutlet weak var splash : UIView!
    @IBOutlet weak var footerLabel: UILabel!
    
    var user : User?
    
    var viewModel : LevelsTableViewModelType?
    var contentManager : OnboardingViewModelType?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentManager = OnboardingViewModel()
        contentManager?.loadContentIfNeed()
        self.contentManager?.loadingContentDidFinish = {
            UIView.animate(withDuration: 0.25) {
                self.splash?.alpha = 0.0
            }
        }
        
        self.view.addGradient(colors: Constants.gradientColors1)
        viewModel = LevelsTableViewModel()
        viewModel?.delegate = self
        viewModel?.loadUserInfo()
        viewModel?.userInfoDidLoad  = {
            self.user = self.viewModel?.user
        }
        let offset_top = UIScreen.main.bounds.size.width * 0.06763
        self.tableView.contentInset = UIEdgeInsets(top: offset_top, left: 0, bottom: 0, right: 0)
        footerLabel.text = NSLocalizedString("tbc..", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.loadLevels()
        self.viewModel?.updateLanguageImage(btn: self.languageBtn)
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.width * 0.444
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel?.cellViewModel(forIndexPath: indexPath)
        let id = indexPath.row % 2 == 0 ? "cell1" : "cell2"
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? LevelTableViewCell
        cell?.viewModel = cellViewModel
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectRow(indexPath: indexPath)
        let identifier = viewModel?.levels[indexPath.row].isComplited() == true ? "open_complited_level_segue" : "open_new_level_segue"
        let isSubscribed = self.viewModel?.isSubscribed()
        if isSubscribed == false {
            self.showSubscribeController()
        } else {
            if self.viewModel?.isUnlocked() == true {
            self.performSegue(withIdentifier: identifier, sender: nil)
            }
        }
    }
    
    @IBAction func chooseLanguageAction(){
        let controller = UIStoryboard.init(name: "Language", bundle: .main).instantiateViewController(identifier: "language") as? LanguageViewController
        controller?.from_main_screen = true
        self.navigationController?.pushViewController(controller!, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewModel = viewModel else { return }
        let dvc = segue.destination as? OpenLevelViewController
        dvc?.viewModel = viewModel.viewModelForSelectedRow()
    }
    
    func showSubscribeController(){
        let c = UIStoryboard(name: "Subscription", bundle: .main).instantiateViewController(identifier: "subscription") as? SubscriptionViewController
        self.navigationController?.pushViewController(c!, animated: true)
    }

}

