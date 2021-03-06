//
//  FirstScreenViewController.swift
//  
//
//  Created by Isabel Pebaqué on 2019-03-13.
//

import UIKit
import Firebase
import SVProgressHUD

class FirstScreenViewController: UIViewController {
    let vc = UITabBarController()
    let userdef = UserDefaults.standard

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        if userdef.bool(forKey: "UserIsSignedIn") {
            self.openMainTabBar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissRecognizer()
    }
    
    // Metod som skapar TapGestureRecogniser, så keyboard försvinner vid tryck på vyn
    func setupKeyboardDismissRecognizer(){
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(FirstScreenViewController.dismissKeyboard))
        
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    // Action knapp som kollar data i email och password textfield om dom finns i Firebase Auth, om Ja så loggas man in och öppnar tabBarController
    @IBAction func loginButton(_ sender: UIButton) {
        
        SVProgressHUD.show(withStatus: "Loggar in")
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            if error == nil {
                // Sätter user default till true så användaren hålls inloggad tills man manuellt loggar ut
                self.userdef.set(true, forKey: "UserIsSignedIn")
                self.userdef.synchronize()
                SVProgressHUD.dismiss()
                self.openMainTabBar()
                
            } else {
                print("Fel vid inloggning \(error.debugDescription)")
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Kunde inte logga in!")
            }
        }
    }
    
    // Action knapp som skapar nytt konto i Firebase Auth, när detta är gjort öppnas tabBarController
    @IBAction func createAccountButton(_ sender: UIButton) {
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error == nil{
                Auth.auth().signIn(withEmail: email, password: password, completion: nil)
                print("Kontot skapat!")
                SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "Konto Skapat!")
                self.openMainTabBar()
                // Sätter user default till true så användaren hålls inloggad tills man manuellt loggar ut
                self.userdef.set(true, forKey: "UserIsSignedIn")
                self.userdef.synchronize()
            }else {
                print("kunde inte skapa konto! \(error.debugDescription)")
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Kunde inte skapa konto!")
            }
        }
        
    }
    
    // Metod som öppnar tabBarController
    func openMainTabBar(){
        
        if let mainTabBar = (self.storyboard!.instantiateViewController(withIdentifier: "afterLogin") as? UITabBarController) {
            self.present(mainTabBar, animated: true, completion: nil)
        }
    }
}

