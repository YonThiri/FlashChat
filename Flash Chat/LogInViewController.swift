//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController,UITextFieldDelegate {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        
        SVProgressHUD.show()
        //TODO: Log in the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil{
                
                let alert = UIAlertController(title: "Error", message: "Something wrong", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                
                self.present(alert,animated: true,completion: nil)
                SVProgressHUD.dismiss()
            }
                
            else{
                
                SVProgressHUD.dismiss()
                self.passwordTextfield.text = ""
                print("Log in successfully")
                self.performSegue(withIdentifier: "goToChat", sender: self)
                
            }
        }
        
    }
    


    
}  
