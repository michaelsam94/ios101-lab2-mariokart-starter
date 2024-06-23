//
//  ViewController.swift
//  Mario Cart
//
//  Created by Charles Hieger on 1/25/19.
//  Copyright © 2019 Charles Hieger. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
                      UIGestureRecognizerDelegate,
                      SettingsViewControllerDelegate {
  // Bowser
  @IBOutlet weak var kartView0: UIImageView!
  // Mario
  @IBOutlet weak var kartView1: UIImageView!
  // Toad
  @IBOutlet weak var kartView2: UIImageView!
  // Mushroom
  @IBOutlet weak var mushroomView: UIImageView!
  // Mystery Box
  @IBOutlet weak var mysteryBox: UIImageView!
  
  // Keeps track of the original position of the karts when the view is initially loaded
  var originalKartCenters = [CGPoint]()
  // Acts as a multiplier to determine how fast to translate the kart
  private var speedMultiplier = 1.0
  // Settings applied from the settings screen
  var settings: [String: Any]?
  
  // Called when the view controller has awakened and is finished
  // setting up it's views
  override func viewDidLoad() {
    super.viewDidLoad()
    
    originalKartCenters = [kartView0.center,
                           kartView1.center,
                           kartView2.center]
  }
  
  //  Called when user double-taps a kart
  @IBAction func didDoubleTapKart(_ sender: UITapGestureRecognizer) {
    translate(kart: sender.view, by: view.frame.width)
  }
  
  // Called when the user pans on a kart
  @IBAction func didPanKart(_ sender: UIPanGestureRecognizer) {
    moveKart(using: sender)
  }
  
  // Called when the user long-presses on the background
  @IBAction func didLongPressBackground(_ sender: UILongPressGestureRecognizer) {
    if sender.state == .began {
      resetKarts()
    }
  }
  
  
  // Called when user taps on the mushroom
  @IBAction func didTapMushroom(_ sender: UITapGestureRecognizer) {
    animateMushroom()
    
    // Exercise 1: Assign the result of MushroomGenerator.maybeGenerateMushroomPowerup()
    // to a variable. Print something if it's not nil
    // ...
      guard let powerup = MushroomGenerator.maybeGenerateMushroomPowerup() else {
          print("does not have powerup")
          return
      }
      useMushroomPowerupOnMario(powerup: powerup)
      
      
    
    // Exercise 2: Use the powerup on Mario using the useMushroomPowerupOnMario function
    // ...
  }
  
  private func useMushroomPowerupOnMario(powerup: MushroomPowerup) {
    scale(kart: kartView1)
  }
  
  // This function is called when the user taps on the mystery box
  @IBAction func didTapMysteryBox(_ sender: UITapGestureRecognizer) {
    animateMysteryBox()
    let mysteryBox = MysteryBoxGenerator.generateMysteryBox()
    decipher(mysteryBox: mysteryBox)
  }
  
  // Exercise 3: Decipher the mystery box and apply the correct effect on mario
  private func decipher(mysteryBox: MysteryBox) {
      print(mysteryBox.mysteryEffect)
      guard let mystryDictionary = mysteryBox.mysteryEffect as? [String: String] else {
          assertionFailure("expection effect is dictionarly of type [String: String]")
          return
      }
      guard let effect = mystryDictionary["effect"] else {
          assertionFailure("expected effedt as key in dictionary")
          return
      }
      switch effect {
      case "rotate":
          rotate(kart: kartView0)
          rotate(kart: kartView1)
          rotate(kart: kartView2)
      case "scale":
          scale(kart: kartView0)
          scale(kart: kartView1)
          scale(kart: kartView2)
      case "translate":
          translate(kart: kartView0, by: view.bounds.width)
          translate(kart: kartView1, by: view.bounds.width)
          translate(kart: kartView2, by: view.bounds.width)
      default:
          assertionFailure("expecting rotate,scale and translate")
      }
  }
  
  private func translate(kart: UIView?,
                         by xPosition: Double) {
    guard let kart = kart else { return }
    UIView.animateKeyframes(withDuration: 0.5 - 0.05 * Double(speedMultiplier),
                            delay: 0.0) {
      kart.center.x = kart.center.x + xPosition
    }
  }
  
  private func rotate(kart: UIView) {
    UIView.animate(withDuration: 0.25) {
      kart.transform = kart.transform.rotated(by: 180.0)
    }
  }
  
  private func scale(kart: UIView) {
    UIView.animate(withDuration: 0.25) {
      kart.transform = kart.transform.scaledBy(x: 1.05, y: 1.05)
    }
  }
  
  // Called with the user taps on the settings button
  @IBAction func didTapSettingsButton(_ sender: UIButton) {
    performSegue(withIdentifier: "SettingsViewControllerSegue", sender: nil)
  }
  
  // Prepare the settings screen before showing it to the user
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SettingsViewControllerSegue" {
      let navigationController = segue.destination as! UINavigationController
      let viewController = navigationController.topViewController as! SettingsViewController
      viewController.delegate = self
      viewController.preloadedSettings = settings
    }
  }
  
  // Applies the correct settings after exiting the settings screen
  // This function is called before dismissing the settings screen
  func didChangeSettings(settings: [String : Any]) {
    self.settings = settings
      print(settings)
    applyNumKartsSetting(settings)
    applyKartSizeSetting(settings)
    applySpeedMultiplierSetting(settings)
  }
  
  // Exercise 4: Implement applyNumKartsSetting to show the correct number of karts
  func applyNumKartsSetting(_ settings: [String : Any]) {
      guard let numOfKarts = settings["numKarts"] as? Int else {
          assertionFailure("expecting kart size int but got nil")
          return
      }
      kartView0.isHidden = numOfKarts < 2
      kartView2.isHidden = numOfKarts < 3
  }
  
  // Exercise 5: Implement applyKartSizeSetting to set the correct kart size
  func applyKartSizeSetting(_ settings: [String : Any]) {
      guard let sizeMulitiplier = settings["kartSize"] as? Int else {
          assertionFailure("kart size is must be int not nil")
          return
      }
      let scaleBy = 1.0 + 0.05 * Double(sizeMulitiplier)
      let transform = CGAffineTransformIdentity.scaledBy(x: scaleBy,y: scaleBy)
      kartView0.transform = transform
      kartView1.transform = transform
      kartView2.transform = transform
  }
  
  // Exercise 6: Implement applySpeedMultiplierSetting to set the correct speed
  func applySpeedMultiplierSetting(_ settings: [String : Any]) {
      guard let speedMultiplier = settings["speedMultiplier"] as? Int else {
          assertionFailure("speed multiplier must be int not nil")
          return
      }
      self.speedMultiplier = Double(speedMultiplier)
      
  }
}

