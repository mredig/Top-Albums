//
//  LargeTitleNavigationController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class LargeTitleNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
		navigationBar.prefersLargeTitles = true
		navigationBar.isTranslucent = true
	}

}
