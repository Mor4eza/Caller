//
//  ContactsDetailsTableView.swift
//  Caller
//
//  Created by Morteza Gharedaghi on 8/10/16.
//
//

import UIKit
class ContactsDetailsTableView: UITableViewController {

    var headers:[String] = []
    var numbers:[String] = []
    var name:String! = ""
    var image:NSData!

    override func viewDidLoad() {
        super.viewDidLoad()
        if image == nil {
            image = UIImagePNGRepresentation(UIImage(named: "background")!);
        }
      
        
        let colors = UIImage(data: image)!.getColors()
        
        
        let headerView: ParallaxHeaderView = ParallaxHeaderView.parallaxHeaderViewWithImage(UIImage(data: image), forSize: CGSizeMake(self.tableView.frame.size.height, 150)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
        headerView.headerTitleLabel.text = name.uppercaseString
        headerView.headerTitleLabel.font = UIFont.boldSystemFontOfSize(30.0)
        headerView.headerTitleLabel.textColor = colors.primaryColor
        self.definesPresentationContext = true
        

        
        // Override point for customization after application launch.
        // Sets background to a blank/empty image
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.navigationController?.navigationBar.translucent = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (headers.count > 0){
            return headers.count
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if (headers.count > 0){
            return headers[section]
        }
        return "No Number"
       
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : detailsCell = tableView.dequeueReusableCellWithIdentifier("detailsCell", forIndexPath: indexPath) as! detailsCell

        if (numbers.count > 0){
        cell.lblnumber.text = numbers[indexPath.section]
        }else {
            cell.lblnumber.text = "No Number"
            cell.btnCall.hidden = true
            cell.lblnumber.textAlignment = .Center
        }
        
        
        return cell
        
    }
    override func viewWillDisappear(animated: Bool) {
        self.headers.removeAll()
        self.numbers.removeAll()
    }
    
    override func  scrollViewDidScroll(scrollView: UIScrollView) {
        let header: ParallaxHeaderView = self.tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
        self.tableView.tableHeaderView = header
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}