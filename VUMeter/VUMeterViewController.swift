//
//  VUMeterViewController.swift
//  VUMeter
//
//  Created by Mathijs Bernson on 03/03/2017.
//  Copyright © 2017 Duckson. All rights reserved.
//

import UIKit

class VUMeterViewController: UIViewController {

  var vuMeter: VUMeter!
  var ledStrip: LEDStrip!
  var running = false { didSet { stateChanged() } }
  let minDecibels: Float = -90
  var color: Color = Color(red: 255, green: 0, blue: 0)
  var colorTimer: Timer? = nil
  let colors = [
    Color(red: 255, green: 255, blue: 255),
    Color(red: 255, green: 0, blue: 0),
    Color(red: 0, green: 255, blue: 0),
    Color(red: 0, green: 0, blue: 255),
    Color(red: 255, green: 255, blue: 0),
    Color(red: 255, green: 0, blue: 255),
    Color(red: 0, green: 255, blue: 255),
    Color(red: 255, green: 128, blue: 0),
    Color(red: 128, green: 0, blue: 128),
  ]

  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var toggleButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    vuMeter = App.vuMeter
    vuMeter.delegate = self

    ledStrip = App.ledStrip

    colorTimer = Timer(timeInterval: 3, repeats: true, block: self.selectRandomColor)
    RunLoop.current.add(colorTimer!, forMode: .defaultRunLoopMode)
  }

  func selectRandomColor(timer: Timer) {
    var randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
    var newColor = colors[randomIndex]
    while newColor == color {
      randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
      newColor = colors[randomIndex]
    }
    color = colors[randomIndex]
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
  }

  fileprivate func message(forLevel level: Float, ledCount: Int, reversed: Bool = false) -> [UInt8] {
    let activeLeds = max(Int(level * Float(ledCount) * 2), 0)
    let remainingLeds = max(ledCount - activeLeds, 0)
    var message = [UInt8]()
    for _ in 0...activeLeds {
      message.append(color.green)
      message.append(color.red)
      message.append(color.blue)
    }
    let fill: [UInt8] = Array(repeating: 0, count: remainingLeds * 3)
    if reversed {
      return fill + message
    } else {
      return message + fill
    }
  }

  fileprivate func updateLedStrip(level: Float) {
    let message1 = message(forLevel: level, ledCount: ledStrip.ledcount / 2)
    let message2 = message(forLevel: level, ledCount: ledStrip.ledcount / 2, reversed: true)
    ledStrip.send(message1 + message2)
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
    progressView.setProgress(level, animated: true)
    updateLedStrip(level: level)
  }
}
