//
//  LanguageViewModel.swift
//  Wordix
//
//  Created by Ігор on 10/29/20.
//  Copyright © 2020 Igor Zalisky. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireImage

class LanguageViewModel: LanguageViewModelType {
    var languages = try! Realm().objects(Language.self)
    var buttons = [UIButton]()
    
    func setupButtons(view:UIView){
        self.allButtons(view: view)
        self.allLanguages().forEach{
            buttonLanguage(lang: $0)
        }
    }
    
    func allButtons(view:UIView){
        view.subviews.forEach{
            if $0 is UIStackView {
                ($0 as! UIStackView).arrangedSubviews.forEach{
                    ($0 as! UIStackView).arrangedSubviews.forEach{
                        buttons.append($0 as! UIButton)
                        $0.alpha = 0.0
                    }
                }
            }
        }
    }
    
    func allLanguages() -> [Language] {
        return Array(languages)
    }
    
    func currentLanguage() -> Language {
        return Language.currentLanguage()
    }
    
    
    func selectLanguage(index:Int) {
        if self.allLanguages().count > index {
        let selectedLanguage = self.allLanguages()[index]
        try! Realm().write() {
            let lang = Array(try! Realm().objects(AppLanguage.self)).first ?? AppLanguage()
            lang.id = selectedLanguage.id
            try! Realm().add(lang, update: Realm.UpdatePolicy.modified)
        }
        }
    }
    
    func buttonLanguage(lang:Language){
        let btn = buttons.filter{$0.tag == lang.id}.first
        btn?.setTitle(lang.name, for: .normal)
        let downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: lang.imageUrl())!)
        let filter = AspectScaledToFillSizeCircleFilter(size: CGSize(width: 32, height: 32))
        downloader.download(urlRequest, filter: filter, completion:  { response in
            if case .success(let image) = response.result {
                btn?.setImage(image, for: .normal)
            }
        })
        btn?.isSelected = lang.isCurrent() == true
        btn?.alpha = 1.0
    }
}
