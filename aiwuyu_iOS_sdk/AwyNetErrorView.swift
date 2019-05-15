//
//  AwyNetErrorView.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/17.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit

class AwyNetErrorView: UIView {
    
    lazy var imageView:UIImageView = {
        let img = UIImageView(frame: CGRect(x: (Awy_Screen_Width-160)/2, y: 110, width: 160, height: 160))
        img.contentMode = UIView.ContentMode.scaleAspectFit
        img.image =  awy_image("img_network_error@2x")
        return img
    }()
    
    lazy var resetBtn:UIButton = {
        let btn = UIButton(frame: CGRect(x: (Awy_Screen_Width-100)/2, y: 325, width: 100, height: 34))
        btn.backgroundColor = UIColor(0xFF3433)
        btn.layer.cornerRadius = 17
        btn.layer.masksToBounds = true
        btn.setTitle("刷新", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.addTarget(self, action: #selector(click), for: .touchUpInside)
        return btn
    }()
    
    lazy var tipsLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 285, width: Awy_Screen_Width, height: 20))
        label.text = "网络异常，请检查网络环境"
        label.textAlignment = .center
        label.textColor = UIColor(0x909090)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    var resetClick:(()->Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.addSubview(imageView)
        self.addSubview(tipsLabel)
        self.addSubview(resetBtn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func click(){
        resetClick?()
        self.removeFromSuperview()
    }

}
