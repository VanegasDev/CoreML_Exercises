//
//  UIViewController+Extensions.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/20/21.
//

import SwiftUI
import TinyConstraints

extension UIViewController {
    func add(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        
        viewController.view.edgesToSuperview()
        viewController.didMove(toParent: self)
    }
    
    func addHosting<T: SwiftUI.View>(view: T) {
        let hostingController = UIHostingController(rootView: view)
        add(hostingController)
    }
}
