//
//  pageVC.swift
//  swipeTest
//
//  Created by William Leahy on 4/11/17.
//  Copyright © 2017 William Leahy. All rights reserved.
//

import UIKit

class pageVC: UIPageViewController, UIPageViewControllerDataSource {
    
    lazy var viewControllerList: [UIViewController] = {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = sb.instantiateViewController(withIdentifier: "screen1")
        let vc2 = sb.instantiateViewController(withIdentifier: "screen2")
        let vc3 = sb.instantiateViewController(withIdentifier: "screen3")
        
        return [vc1, vc2, vc3]
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        if let firstViewController = viewControllerList.first {
            
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
       
        guard let viewIndex = viewControllerList.index(of: viewController) else { return nil }
        let previousIndex = viewIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard viewControllerList.count > previousIndex else { return nil }
        return viewControllerList[previousIndex]
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // provisions after screen and ensures that it's not out of scope
        
        guard let viewIndex = viewControllerList.index(of: viewController) else { return nil }
        let nextIndex = viewIndex + 1
        guard viewControllerList.count != nextIndex else { return nil }
        guard viewControllerList.count > nextIndex else { return nil }
        return viewControllerList[nextIndex]
    }
    
    
    

}
