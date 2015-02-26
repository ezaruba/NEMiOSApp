import UIKit
import AddressBook

class AddressBook: UIViewController , UITableViewDelegate , UIAlertViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    let dataManager :CoreDataManager = CoreDataManager()
    let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    var contacts :NSArray = NSArray()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if State.fromVC != SegueToAddressBook
        {
            State.fromVC = SegueToAddressBook
        }
        
        State.currentVC = SegueToAddressBook

        
        ABAddressBookRequestAccessWithCompletion(addressBook,
            {
                (granted : Bool, error: CFError!) -> Void in
                if granted == true
                {
                    self.contacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
                    self.tableView.reloadData()
                }
                else
                {
                    var alert :UIAlertView = UIAlertView(title: "Info", message: "Can not access adressbook", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
        })
        
        var alert :UIAlertView = UIAlertView(title: "Info", message: "Currently without UI.\nIn developing process.", delegate: self, cancelButtonTitle: "OK")
        alert.show()

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()


    }

    @IBAction func addContact(sender: AnyObject)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook,
            {
                (granted : Bool, error: CFError!) -> Void in
                if granted == true
                {
                    var newContact  :ABRecordRef! = ABPersonCreate().takeRetainedValue()
                    
                    var error: Unmanaged<CFErrorRef>? = nil
                    var emailMultiValue :ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABPersonEmailProperty)).takeRetainedValue()
                    
                    var alert1 :UIAlertController = UIAlertController(title: "Add NEM account", message: "Input your data", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    var firstName :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.placeholder = "firstName"
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            firstName = textField
                            
                    }
                    
                    var lastName :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.placeholder = "lastName"
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            lastName = textField
                            
                    }
                    
                    var address :UITextField!
                    alert1.addTextFieldWithConfigurationHandler
                        {
                            textField -> Void in
                            textField.placeholder = "address"
                            textField.keyboardType = UIKeyboardType.ASCIICapable
                            textField.returnKeyType = UIReturnKeyType.Done
                            
                            address = textField
                            
                    }
                    
                    var addNEMaddress :UIAlertAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default)
                        {
                            alertAction -> Void in

                            ABRecordSetValue(newContact, kABPersonFirstNameProperty, firstName.text, &error)
                            ABRecordSetValue(newContact, kABPersonLastNameProperty, lastName.text, &error)
                            ABMultiValueAddValueAndLabel(emailMultiValue, address.text, "NEM", nil)
                            ABRecordSetValue(newContact, kABPersonEmailProperty, emailMultiValue, &error)
                            ABAddressBookAddRecord(self.addressBook, newContact, &error)
                            ABAddressBookSave(self.addressBook, &error)
                                
                            self.tableView.reloadData()
                        }
                    
                    
                    var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                        {
                            alertAction -> Void in
                            alert1.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    alert1.addAction(addNEMaddress)
                    alert1.addAction(cancel)
                    
                    self.presentViewController(alert1, animated: true, completion: nil)
                    
                    self.tableView.reloadData()
                

                }
                else
                {
                    println("no access")
                    
                }
        })
        
        self.contacts = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : AddressCell = self.tableView.dequeueReusableCellWithIdentifier("address cell") as AddressCell
        var person :ABRecordRef = contacts[indexPath.row]
        
        cell.user.text = ""
        
        if var name = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString
        {
            cell.user.text = name + " "
        }
        
        if var surname = ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString
        {
            cell.user.text = cell.user.text! +  (ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)!
        }
        
        let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeUnretainedValue()  as ABMultiValueRef
        let count  :Int = ABMultiValueGetCount(emails)
        
        if count > 0
        {
            for var index:CFIndex = 0; index < count; ++index
            {
                var lable  = ABMultiValueCopyLabelAtIndex(emails, index)
                if lable != nil
                {
                    if lable.takeUnretainedValue()  == "NEM"
                    {
                        cell.indicator.hidden = false
                    }
                    else
                    {
                        cell.indicator.hidden = true
                    }
                }
            }
        }
        else
        {
            cell.indicator.hidden = true
        }

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var cell :AddressCell = tableView.cellForRowAtIndexPath(indexPath) as AddressCell
        
        if cell.indicator.hidden
        {
            var alert1 :UIAlertController = UIAlertController(title: "Add NEM address", message: "Input new address", preferredStyle: UIAlertControllerStyle.Alert)
            
            var address :UITextField!
            alert1.addTextFieldWithConfigurationHandler
                {
                    textField -> Void in
                    textField.placeholder = "address"
                    textField.keyboardType = UIKeyboardType.ASCIICapable
                    textField.returnKeyType = UIReturnKeyType.Done
                    
                    address = textField
                    
            }
            
            var addNEMaddress :UIAlertAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default)
                {
                    alertAction -> Void in
                    
                    if(address != "")
                    {
                        var emailMultiValue :ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABPersonEmailProperty)).takeRetainedValue()
                        var error: Unmanaged<CFErrorRef>? = nil
                        
                        ABMultiValueAddValueAndLabel(emailMultiValue, address.text, "NEM", nil)
                        ABRecordSetValue(self.contacts[indexPath.row], kABPersonEmailProperty, emailMultiValue, &error)
                        ABAddressBookSave(self.addressBook, &error)
                        
                        self.tableView.reloadData()
                    }

            }
            
            var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
                {
                    alertAction -> Void in
                    alert1.dismissViewControllerAnimated(true, completion: nil)
                    cell.setSelected(false, animated: true)
            }
            
            alert1.addAction(addNEMaddress)
            alert1.addAction(cancel)
            
            self.presentViewController(alert1, animated: true, completion: nil)

        }
        else
        {
            var person :ABRecordRef = contacts[indexPath.row]
            
            let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
            let count  :Int = ABMultiValueGetCount(emails)
            
            var key :String!

            for var index = 0; index < count; ++index
            {
                var lable : String = ABMultiValueCopyLabelAtIndex(emails, index).takeRetainedValue()
                if lable == "NEM"
                {
                    key = ABMultiValueCopyValueAtIndex(emails, index).takeUnretainedValue() as String
                    break
                }
            }
            var title :String = ""
            
            if var name = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString
            {
                title = name + " "
            }
            
            if var surname = ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString
            {
                title = title +  (ABRecordCopyValue(person, kABPersonLastNameProperty).takeUnretainedValue() as? NSString)!
            }
            
            State.currentContact = nil
            
            State.toVC = SegueToPasswordValidation
            
            var correspondents : NSArray = dataManager.getCorrespondents()
            
            for correspondent  in correspondents
            {
               if (correspondent as Correspondent).key == key
               {
                    State.currentContact = correspondent as? Correspondent
                    break
                }
            }
            if State.currentContact == nil
            {
                State.currentContact = dataManager.addCorrespondent(key, name: title)
            }

            NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToMessages )

        }
    }
}
