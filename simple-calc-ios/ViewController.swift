//
//  ViewController.swift
//  simple-calc-ios
//
//  Created by ​ on 10/20/17.
//  Copyright © 2017 iGuest. All rights reserved.
//

import UIKit

extension String: Error {
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension String {
    var condensedWhitespace: String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter {
            !$0.isEmpty
            }.joined(separator: " ")
    }
}

var postCalc = false

class ViewController: UIViewController {
    @IBOutlet weak var avg: UIButton!
    @IBOutlet weak var count: UIButton!
    @IBOutlet weak var fact: UIButton!
    @IBOutlet weak var mod: UIButton!
    @IBOutlet weak var div: UIButton!
    @IBOutlet weak var mul: UIButton!
    @IBOutlet weak var sub: UIButton!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var Result: UILabel!
    
    @IBAction func cmdPressed(_ sender: UIButton) {
        postCalc = true
        if let rawInput = Result.text {
            let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
            if !input.contains(" ") {
                switch sender {
                case count: Result.text = "1"
                case avg: ()
                case fact:
                    if (Int(input)! > 20) {
                        Result.text = "too large"
                    } else {
                        var fact: Int = 1
                        let n: Int = Int(input)! + 1
                        for i in 1..<n {
                            fact = fact * i
                        }
                        Result.text = String(fact)
                    }
                default: ()
                }
            } else {
                let numbers = input.condensedWhitespace.components(separatedBy: " ").flatMap {
                    Double($0)
                }
                switch sender {
                case count: Result.text = String(numbers.count)
                case avg:
                    let sum = numbers.reduce(0, +)
                    let avg = sum / Double(numbers.count)
                    Result.text = avg.clean
                case fact: Result.text = "too many operands"
                default: ()
                }
            }
        }
    }
    
    @IBAction func equalPressed(_ sender: Any) {
        postCalc = true
        if let rawInput = Result.text {
            let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
            let arr = input.condensedWhitespace.components(separatedBy: " ")
            if arr.count == 1 {
                Result.text = Result.text! + ""
                postCalc = false
            } else {
                let op = arr[1]
                switch op {
                case "+":
                    Result.text = (Double(arr[0])! + Double(arr[2])!).rounded(toPlaces: 4).clean
                case "-":
                    Result.text = (Double(arr[0])! - Double(arr[2])!).rounded(toPlaces: 4).clean
                case "*":
                    Result.text = (Double(arr[0])! * Double(arr[2])!).rounded(toPlaces: 4).clean
                case "/":
                    Result.text = (Double(arr[0])! / Double(arr[2])!).rounded(toPlaces: 4).clean
                case "%":
                    Result.text = String(Int(arr[0])! % Int(arr[2])!)
                default:
                    break
                }
            }
        }
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        postCalc = false
        switch sender {
        case add:
            Result.text = Result.text! + " + "
        case sub:
            Result.text = Result.text! + " - "
        case mul:
            Result.text = Result.text! + " * "
        case div:
            Result.text = Result.text! + " / "
        case mod:
            Result.text = Result.text! + " % "
        default:
            break
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        if (sender.tag == -1) {
            Result.text = Result.text! + "."
        } else if (Result.text == "0" || postCalc) {
            Result.text = String(sender.tag)
            postCalc = false
        } else {
            Result.text = Result.text! + String(sender.tag)
        }
    }
    
    @IBAction func spaceClearPressed(_ sender: UIButton) {
        switch sender.tag {
        case -2:
            Result.text = "0"
        case -3:
            Result.text = Result.text! + " "
            postCalc = false
        default:
            ()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

