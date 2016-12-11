//
//  ViewController.swift
//  Demo_ContactManager
//
//  Created by Morteza on 10/06/16.
//
//

import UIKit
import AVFoundation
import Contacts

class ViewController: UIViewController, UISearchResultsUpdating, ContactListTableViewCellProtocol,UITableViewDelegate {
    
    @IBOutlet var IBtblViewContactList: UITableView!
    var preventAnimation = Set<NSIndexPath>()
    lazy var arrContacts = [CNContact]()
    lazy var arrFilteredContacts = [CNContact]()
    lazy var contactStore = CNContactStore()
//    var arrIndexSection : NSMutableArray = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var headers:[String] = []
    var numbers:[String] = []
    var contacts = ContactsDetails(work: "", home: "", iphone: "", mobile: "", main: "", other: "")
    var soundFileURL:NSURL!
    internal var prefixNumeber:NSString!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    let defaults = NSUserDefaults.standardUserDefaults()
    let audioSession = AVAudioSession.sharedInstance()
    let searchController = UISearchController(searchResultsController: nil)
    let recordSettings:[String : AnyObject] = [
        AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatAppleLossless),
        AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
        AVEncoderBitRateKey : 320000,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey : 44100.0
    ]
    
    //MARK:- UIViewController Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkforContactPermission()
        setSearchController()
        setRefreshControl()

        if defaults.valueForKey("defaultPrefix") == nil {
            defaults.setValue("1-514-908-9016 , 011", forKey: "defaultPrefix")
        }
       
        prefixNumeber = defaults.stringForKey("defaultPrefix")
        self.definesPresentationContext = true
//        arrIndexSection.removeAllObjects()
////        for (var i = 0; arrContacts.count > i ; i += 1){
////            
////            
////            arrIndexSection.addObject(String(arrContacts[i].givenName.characters.first!))
////
////        }
//       
//
//        IBtblViewContactList.reloadData()
//        print("unique \(arrIndexSection)")

    }
    
    //MARK:- Screen setup -
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: .ValueChanged)
        IBtblViewContactList.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        
        checkforContactPermission()
        refreshControl.endRefreshing()
    }
    
    func setSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        IBtblViewContactList.tableHeaderView = searchController.searchBar
    }
    
    //MARK:- Contact related methods -
    
    func checkforContactPermission() {
        switch CNContactStore.authorizationStatusForEntityType(.Contacts) {
            
        case .Authorized:
            fetchContacts()
            
        case .NotDetermined:
            contactStore.requestAccessForEntityType(.Contacts){succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                self.fetchContacts()
            }
        default:
            print("Not handled")
        }
    }
    
    func fetchContacts() {
        
        //reset contact list
        arrContacts.removeAll()
        
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataKey]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                arrContacts.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        arrContacts.sortInPlace({ $0.givenName < $1.givenName })

        IBtblViewContactList.reloadData()
        
    }
    
    func filterContentForSearchText(searchText: String) {
        
        arrFilteredContacts = arrContacts.filter { contact in
            
            return (contact.givenName.lowercaseString.containsString(searchText.lowercaseString) ||
                contact.familyName.lowercaseString.containsString(searchText.lowercaseString))
        }
        
        IBtblViewContactList.reloadData()
    }
    
    
    //MARK:- Audio related methods -
    func getSoundURLForIndex(index : Int) -> NSURL {
        
        let dirPaths =
            NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                                                .UserDomainMask, true)
        let docsDir = dirPaths[0]
        let soundFilePath = docsDir + "/sound\(index).m4a"
        return NSURL(fileURLWithPath: soundFilePath)
        
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
        } catch  {
            print("could not set session category")
        }
        
        do {
            try session.setActive(true)
        } catch  {
            print("could not make session active")
        }
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    
    
    //MARK:- UITableView delegate -
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return arrFilteredContacts.count
        }
        return arrContacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ContactListTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactListTableViewCellID", forIndexPath: indexPath) as! ContactListTableViewCell
        let currentContact : CNContact!
        if searchController.active && searchController.searchBar.text != "" {
            currentContact = arrFilteredContacts[indexPath.row]
        } else {
            currentContact = arrContacts[indexPath.row]
        }
        
        cell.contactListTableViewCellDelegate = self
        
        //AVAudio related code
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: getSoundURLForIndex(indexPath.row),
                                                settings: recordSettings)
            cell.audioRecorder = audioRecorder
            
        }
        catch {
        }
        
        cell.IBlblName.text = "\(currentContact.givenName) \(currentContact.familyName)"
        
        
        getContactDetails(indexPath)
        
        if (!contacts.home.isEmpty) {
             cell.IBlblPhoneNumber?.text = "🏚 " + contacts.home
            
        }else if (!contacts.mobile.isEmpty){
             cell.IBlblPhoneNumber?.text = "📱 " + contacts.mobile
            
        }else if (!contacts.iphone.isEmpty){
             cell.IBlblPhoneNumber?.text = "📱 " + contacts.iphone
            
        }else if (!contacts.work.isEmpty){
             cell.IBlblPhoneNumber?.text = "💰 " + contacts.work
            
        }else if (!contacts.main.isEmpty){
             cell.IBlblPhoneNumber?.text = "📞 " +  contacts.main
            
        }else if (!contacts.other.isEmpty){
             cell.IBlblPhoneNumber?.text = "☎️ " + contacts.other
            
        }else {
             cell.IBlblPhoneNumber?.text = "❗️ N/A"
        }
        
        
        
//        if (currentContact.isKeyAvailable(CNContactPhoneNumbersKey)) {
//            for phoneNumber:CNLabeledValue in currentContact.phoneNumbers {
//                
//                if phoneNumber.label == CNLabelPhoneNumberMobile {
//                 
//                    let primaryPhoneNumber = phoneNumber.value as! CNPhoneNumber
//                    cell.IBlblPhoneNumber?.text = primaryPhoneNumber.stringValue
//                }
//              
//                if (cell.IBlblPhoneNumber?.text == "N/A") {
//                    let primaryPhoneNumber = phoneNumber.value as! CNPhoneNumber
//                    cell.IBlblPhoneNumber?.text = primaryPhoneNumber.stringValue
//                }
//                
//                if (CNLabelPhoneNumberMobile.isEmpty){
//                    print("Empty")
//                    cell.IBlblPhoneNumber?.text = "N/A"
//                }
//                
//            }
//        }
//        
//        
       
        
        
        // Set the contact image.
        let intialFirst = currentContact.givenName.characters.first
        let intialSecond = currentContact.familyName.characters.first
        
        cell.IBViewProfilePic.imageView?.image = nil
        if let imageData = currentContact.imageData {
            cell.IBViewProfilePic.setValueForProfile(true, imageData: imageData)
        } else {
            cell.IBViewProfilePic.setValueForProfile(true, nameInitials: "\(intialFirst ?? "N")\(intialSecond ?? "A")", fontSize: 32.0, imageData: nil)
        }
        return cell
    }

    
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !preventAnimation.contains(indexPath) {
            preventAnimation.insert(indexPath)
            TipInCellAnimator.animate(cell)
        }
    }
    
    
    
    //MARK:- UISearch Delegates -
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    //MARK:- ContactListTableViewCellProtocol -
    
    func onRecordStop(activeRecorder: AVAudioRecorder?) {
        activeRecorder?.stop()
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
        } catch {
        }
        
    }
    
    func onRecordStart(activeRecorder: AVAudioRecorder?) {
        recordWithPermission(false)
        activeRecorder?.prepareToRecord()
        if activeRecorder?.recording == false {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                activeRecorder?.record()
            } catch {
            }
        }
    }
    
    func onPlayStart(activeRecorder: AVAudioRecorder?) {
        if (activeRecorder != nil && activeRecorder?.recording == false){
            AudioPlayerManager.audioPlayerSharedManager.playContent(activeRecorder!.url)
        }
    }
    
    func onPlayStop(activeRecorder: AVAudioRecorder?) {
        if (activeRecorder != nil && activeRecorder?.recording == false){
            AudioPlayerManager.audioPlayerSharedManager.stopContent(activeRecorder!.url)
        }
    }
    
    //MARK - Saving Data
    @IBAction func Setting(sender: AnyObject) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Change Prefix", message: "Enter Prefix:", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = self.prefixNumeber! as String
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.defaults.setValue(textField.text, forKey: "defaultPrefix")
            self.prefixNumeber = self.defaults.stringForKey("defaultPrefix")
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "detailSegue") {
            let svc = segue.destinationViewController as! ContactsDetailsTableView;
            headers.removeAll()
            numbers.removeAll()
            let indexPath = IBtblViewContactList.indexPathForSelectedRow!
            
          let currentCell = IBtblViewContactList.cellForRowAtIndexPath(indexPath)! as! ContactListTableViewCell
            
            let currentContact : CNContact!
            
            if searchController.active && searchController.searchBar.text != "" {
                currentContact = arrFilteredContacts[indexPath.row]
            } else {
                currentContact = arrContacts[indexPath.row]
            }
            
            if (currentContact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                for phoneNumber:CNLabeledValue in currentContact.phoneNumbers {
                    
                    if phoneNumber.label == CNLabelPhoneNumberMain {
                        let primaryPhoneNumber = phoneNumber.value as! CNPhoneNumber
                        headers.append("Main")
                        numbers.append(primaryPhoneNumber.stringValue)
                    }else if phoneNumber.label == CNLabelHome {
                        let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                        headers.append("Home")
                        numbers.append(PhoneNumber.stringValue)
                    }else if phoneNumber.label == CNLabelPhoneNumberMobile {
                        let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                        headers.append("Mobile")
                        numbers.append(PhoneNumber.stringValue)
                    }else if phoneNumber.label == CNLabelPhoneNumberiPhone {
                        let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                        headers.append("iphone")
                        numbers.append(PhoneNumber.stringValue)
                    }else if phoneNumber.label == CNLabelWork {
                        let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                        headers.append("Work")
                        numbers.append(PhoneNumber.stringValue)
                    }else if phoneNumber.label == CNLabelOther {
                        let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                        headers.append("Other")
                        numbers.append(PhoneNumber.stringValue)
                    }
                    
                }
            }
            
            
            if let imageData =  currentContact.imageData {
            svc.image = imageData
            }
            svc.name = currentCell.IBlblName.text!
            svc.headers = self.headers
            svc.numbers = self.numbers
            
        }
    }
    
    
    func getContactDetails(index:NSIndexPath) {
        
       
         contacts = ContactsDetails(work: "", home: "", iphone: "", mobile: "", main: "", other: "")
        
        let indexPath = index
        
        let currentContact : CNContact!
        
        if searchController.active && searchController.searchBar.text != "" {
            currentContact = arrFilteredContacts[indexPath.row]
        } else {
            currentContact = arrContacts[indexPath.row]
        }

        
        if (currentContact.isKeyAvailable(CNContactPhoneNumbersKey)) {
            for phoneNumber:CNLabeledValue in currentContact.phoneNumbers {
                
                if phoneNumber.label == CNLabelPhoneNumberMain {
                    let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                    contacts.main = PhoneNumber.stringValue
                }else if phoneNumber.label == CNLabelHome {
                    let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                    contacts.home = PhoneNumber.stringValue
                }else if phoneNumber.label == CNLabelPhoneNumberMobile {
                    let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                   contacts.mobile = PhoneNumber.stringValue
                }else if phoneNumber.label == CNLabelPhoneNumberiPhone {
                    let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                    
                    contacts.iphone = PhoneNumber.stringValue
                }else if phoneNumber.label == CNLabelWork {
                    let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                    
                    contacts.work = PhoneNumber.stringValue
                }else if phoneNumber.label == CNLabelOther {
                    let PhoneNumber = phoneNumber.value as! CNPhoneNumber
                   
                    contacts.other = PhoneNumber.stringValue
                }
                
            }
        }
        
    }
    
}



struct ContactsDetails{
    
    var work:String
    var home:String
    var iphone:String
    var mobile:String
    var main:String
    var other:String
    
}

extension UIButton {
    
    public func changeColor() {
        
        self.backgroundColor = UIColor.redColor()
    }
    
}

extension Array where Element: Equatable {
    
    public func uniq() -> [Element] {
        var arrayCopy = self
        arrayCopy.uniqInPlace()
        return arrayCopy
    }
    
    mutating public func uniqInPlace() {
        var seen = [Element]()
        var index = 0
        for element in self {
            if seen.contains(element) {
                removeAtIndex(index)
            } else {
                seen.append(element)
                index += 1
            }
        }
    }
}

