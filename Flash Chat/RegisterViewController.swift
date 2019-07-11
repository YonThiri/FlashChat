//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        

        SVProgressHUD.show()
        //TODO: Set up a new user on our Firbase database
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil{
                
                let alert = UIAlertController(title: "Error", message: "Something wrong", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                
                self.present(alert,animated: true,completion: nil)
                SVProgressHUD.dismiss()
                
            }
            else{
                self.passwordTextfield.text = ""
                SVProgressHUD.dismiss()
                print("Register Successfully")
                self.performSegue(withIdentifier: "goToChat", sender: self)
                
            }
        }
        

        
        
    } 
    
    
}
