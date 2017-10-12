//
//  SideMenu.swift
//  samplemap
//
//  Created by AppCircle on 2017/07/14.
//  Copyright © 2017年 AppCircle. All rights reserved.
//

//import UIKit
//
//class SideMenu: UIView {
//
//    var size: CGRect?
//    
//    init(image: [UIImage],parentViewController: UIViewController){
//        self.size = CGRect(x:UIScreen.main.bounds.width,
//                           y:0,
//                           width:UIScreen.main.bounds.width*2,
//                           height:UIScreen.main.bounds.height
//        )
//        super.init(frame: size)
//        self.backgroundColor = UIColor.darkGray
//        self.alpha = 0.8
//        
//        self.buttonSet(num: image.count,image: image)
//        self.parentVC = parentViewController
//    }
//    required init?(coder aDecoder: NSCoder){
//        fatalError("init(coder:)has not been implented")
//    }
//    
//    func buttonSet(num:Int, image:[UIImage]){
//        for i in 0..<num{
//            let button =
//                UIButton(frame:CGRect(x:10,
//                                      y:50+110*i,
//                                      width:90, height:90))
//            
//            button.setImage(image[i], for: .normal)
//            button.imageEdgeInsets = UIEdgeInsetsMake(20,20,20,20)
//            button.backgroundColor = UIColor.yellow
//            button.layer.cornerRadius = 45
//            button.tag = i
//            button.addTarget(self,
//                             action:#selector(self.onClickButton(sender:)),
//                             for: .touchUpInside)
//            self.addSubview(button)
//            
//        }
//    }
//
//}
