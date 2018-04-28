//
//  PrimarySplitViewVC.swift
//  LeoChat
//
//  Created by Leobit_13 on 4/27/18.
//  Copyright © 2018 Roman Shveda. All rights reserved.
//

import UIKit

class PrimarySplitViewVC: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
    

}
