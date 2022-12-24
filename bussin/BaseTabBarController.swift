//
//  BaseTabBarController.swift
//  bussin
//
//  Created by Rafał Gawlik on 22/12/2022.
//

import UIKit

class BaseTabBarController: UITabBarController{
    @IBInspectable var defaultIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
}
