//
//  VUMeterViewController.swift
//  VUMeter
//
//  Created by Mathijs Bernson on 03/03/2017.
//  Copyright © 2017 Duckson. All rights reserved.
//

import UIKit
import AVFoundation

struct MeterState {
  let referenceDb: Float = -60
  var running: Bool = false
}

class VUMeterViewController: UIViewController {

  var vuMeter: VUMeter!
  var ledStrip: LEDStrip!
  var running = false { didSet { stateChanged() } }
  let minDecibels: Float = -40

  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var toggleButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    vuMeter = App.vuMeter
    vuMeter.delegate = self

    ledStrip = App.ledStrip
  }

  private func stateChanged() {
    if running {
      vuMeter.startUpdating(success: {}, failure: {})
      activityIndicator.startAnimating()
      toggleButton.titleLabel?.text = "Stop"
    } else {
      vuMeter.stopUpdating()
      activityIndicator.stopAnimating()
      toggleButton.titleLabel?.text = "Start"
    }
  }
  
  @IBAction func toggleButtonPressed(_ sender: UIButton) {
    running = !running
//    if running {
//      vuMeter.startUpdating(success: {}, failure: {})
//      activityIndicator.startAnimating()
//      sender.titleLabel?.text = "Stop"
//    } else {
//      vuMeter.stopUpdating()
//      activityIndicator.stopAnimating()
//      sender.titleLabel?.text = "Start"
//    }
  }

  fileprivate func updateLedStrip(level: Float) {
    let activeLeds = Int(level * Float(ledStrip.ledcount))
    let remainingLeds = ledStrip.ledcount - activeLeds
    let message: [UInt8] = Array(repeating: 255, count: activeLeds * 3) + Array(repeating: 0, count: remainingLeds * 3)
    ledStrip.send(message)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    running = true
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    running = false
  }
}

extension VUMeterViewController: VUMeterDelegate {
  func didUpdateResult(decibels: Float) {
    let level = decibelsToLinear(decibels: decibels, minDecibels: minDecibels)
    print("level: \(level)")
    progressView.setProgress(level, animated: true)
    updateLedStrip(level: level)
  }
}
