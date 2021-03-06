//
//  ViewController.swift
//  AlarmClockBeep
//
//  Created by Jemesson Lima on 22/04/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var clock: UIImageView!
    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var btnStartAlarm: UIButton!

    let secondsDataPicker =  ["5", "10", "15" , "20", "25", "30", "35", "40", "45", "50", "55", "60"]
    var timerCount = 0
    var isAlarmRunning = false
    var timer : Timer?
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        counter.isHidden = true

        self.picker.delegate = self
        self.picker.dataSource = self

        setClockImageOrientationChanged()
        askForAlarmPermission()
    }

    @IBAction func startAlarm(_ sender: UIButton) {
        handleAlarmState(Int(secondsDataPicker[picker.selectedRow(inComponent: 0)])!)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if UIDevice.current.orientation.isPortrait {
            self.clock.image = UIImage(named:"analog-clock")!
        } else {
            self.clock.image = UIImage(named:"digital-clock")!
        }
    }

    // MARK - Picker Selected value.

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return secondsDataPicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(secondsDataPicker[row]) seconds."
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Selected value \(secondsDataPicker[row])")
    }

    // MARK - Helper methods

    private func setClockImageOrientationChanged() {
        let orientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation

        if orientation == .portrait {
            self.clock.image = UIImage(named:"analog-clock")!
        } else if orientation == .landscapeRight || orientation == .landscapeLeft{
            self.clock.image = UIImage(named:"digital-clock")!
        }
    }

    private func startAlarmTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(performAlarmClock), userInfo: nil, repeats: true)
    }

    private func stopAlarmTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc func performAlarmClock() {
        timerCount = timerCount - 1
        counter.text = "\(timerCount)"

        if (timerCount <= 0) {
            playSound()
            stopAlarmTimer()
            shakeAlarmClock()
        }
    }

    private func showCounter() {
        counter.isHidden = false
        picker.isHidden = true
    }
    
    private func showAlarmPicker() {
        counter.isHidden = true
        picker.isHidden = false
    }
    
    private func toggleisAlarmRunning() {
        isAlarmRunning = !isAlarmRunning
    }

    private func playSound() {
        do {
            let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3")!
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }

            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        } catch {
            print(Error.self)
        }
    }

    private func shakeAlarmClock() {
        CATransaction.begin()

        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(cgPoint: CGPoint(x: clock.center.x - 10, y: clock.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: clock.center.x + 10, y: clock.center.y))
        animation.duration = 0.15
        animation.repeatCount = 12
        animation.autoreverses = true

        CATransaction.setCompletionBlock {
            self.btnStartAlarm.setTitle("Come??ar", for: .normal)
            self.toggleisAlarmRunning()
            self.showAlarmPicker()
            self.toggleisAlarmRunning()
        }

        clock.layer.add(animation, forKey: "position")
        CATransaction.commit()
    }

    private func askForAlarmPermission() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) {success, error in
            if success {
                let content = UNMutableNotificationContent()
                content.title = "Hello!"
                content.body = "Permission accepted."
                content.sound = UNNotificationSound.default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                let request = UNNotificationRequest(identifier: "Local Notification", content: content, trigger: trigger)
                center.add(request)
            } else {
                print("Permission denied")
            }
        }
    }

    private func handleAlarmState(_ pickerValue: Int) {
        if (!isAlarmRunning) {
            timerCount = pickerValue
            showCounter()
            counter.text = "\(pickerValue)"
            startAlarmTimer()
            toggleisAlarmRunning()
            btnStartAlarm.setTitle("Cancelar", for: .normal)
            
        } else {
            btnStartAlarm.setTitle("Come??ar", for: .normal)
            showAlarmPicker()
            stopAlarmTimer()
            toggleisAlarmRunning()
            clock.layer.removeAllAnimations()
            guard let player = audioPlayer else { return }
            player.stop()
        }
    }
}
