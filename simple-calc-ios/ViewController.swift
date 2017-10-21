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



class ViewController: UIViewController {
    @IBOutlet weak var precisionStepper: UIStepper!
    @IBOutlet weak var precisionText: UILabel!
    @IBOutlet weak var avg: UIButton!
    @IBOutlet weak var count: UIButton!
    @IBOutlet weak var fact: UIButton!
    @IBOutlet weak var mod: UIButton!
    @IBOutlet weak var div: UIButton!
    @IBOutlet weak var mul: UIButton!
    @IBOutlet weak var sub: UIButton!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var Result: UILabel!
    
    var postCalc = false
    var RPNmode = false

    var precision: Int = 4
    @IBAction func stepperChange(_ sender: UIStepper) {
        precision = Int(sender.value)
        precisionText.text = sender.value.clean
    }
    
    func fact(_ input: String) -> String {
        if (Int(input) == nil || Int(input)! > 20) {
            return "too large or not integer"
        } else {
            var fact: Int = 1
            let n: Int = Int(input)! + 1
            for i in 1..<n {
                fact = fact * i
            }
            return String(fact)
        }
    }
    
    func eleIsNumber(_ arr: Array<String>) -> Bool {
        var count:Int = 0
        for i in stride(from: 0, to: arr.count , by: 2) {
            if (Double(arr[i]) == nil) {
                count += 1
            }
        }
        return count == 0
    }
    
    func sameOp(_ arr: Array<String>) -> Bool {
        var count:Int = 0
        for i in stride(from: 1, to: arr.count - 3 , by: 2) {
            if (arr[i] != arr[i + 2]) {
                count += 1
            }
        }
        return count == 0
    }
    
    func reArrangearr(_ arr: Array<String>) -> Array<String> {
        var arr1 = arr
        for i in stride(from: 1, to: arr.count - 1 , by: 2) {
                switch arr1[i] {
                case "*":
                    let temp = Double(arr1[i - 1])! * Double(arr1[i + 1])!
                    arr1[i - 1] = "0"
                    arr1[i] = "+"
                    arr1[i + 1] = temp.clean
                case "/":
                    let temp = Double(arr1[i - 1])! / Double(arr1[i + 1])!
                    arr1[i - 1] = "0"
                    arr1[i] = "+"
                    arr1[i + 1] = temp.clean
                case "%":
                    let temp = Double(arr1[i - 1])!.truncatingRemainder(dividingBy: Double(arr1[i + 1])!)
                    arr1[i - 1] = "0"
                    arr1[i] = "+"
                    arr1[i + 1] = temp.clean
                case "-":
                    arr1[i] = "+"
                    arr1[i + 1] = (0.0 - Double(arr1[i + 1])!).clean
                default: ()
                }
        }
        return arr1
    }
    
    @IBAction func modeControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            RPNmode = false
        case 1:
            RPNmode = true
        default:
            break
        }
    }
    
    @IBAction func cmdPressed(_ sender: UIButton) {
        postCalc = true
        if (RPNmode == true) {
            if let rawInput = Result.text {
                let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
                if !input.contains(" ") {
                    switch sender {
                    case count: Result.text = "1"
                    case avg: ()
                    case fact:
                        Result.text = fact(input)
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
                        Result.text = avg.rounded(toPlaces: precision).clean
                    case fact: Result.text = "too many operands"
                    default: ()
                    }
                }
            }
        } else {
            postCalc = false
            switch sender {
            case count: Result.text = Result.text! + " count "
            case avg: Result.text = Result.text! + " avg "
            case fact:
                postCalc = true
                if let rawInput = Result.text {
                    let input  = rawInput.trimmingCharacters(in: .whitespacesAndNewlines).condensedWhitespace.components(separatedBy: " ")
                    if input.count == 1 && eleIsNumber(input) {
                        Result.text = fact(input[0])
                    } else {
                        Result.text = "too many operands or invalid input"
                    }
                } else {
                    Result.text = "error"
                }
            default: break
            }
        }
    }
    
    @IBAction func equalPressed(_ sender: Any) {
        postCalc = true
        if let rawInput = Result.text {
            let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
            let rawArr = input.condensedWhitespace.components(separatedBy: " ")
            let arr = reArrangearr(rawArr)
            var result:Double = 0
            if arr.count == 1 {
                result = Double(arr[0])!
                Result.text = result.rounded(toPlaces: precision).clean
                postCalc = true
            } else {
                if (arr.count % 2 == 1 && eleIsNumber(arr) && sameOp(arr)) {
                    let op = arr[1]
                    switch op {
                    case "+":
                        for i in stride(from: 0, to: arr.count , by: 2) {
                            result += Double(arr[i])!
                        }
                        Result.text = (result).rounded(toPlaces: precision).clean
                    case "count":
                        Result.text = String(Int(arr.count) / 2 + 1)
                    case "avg":
                        let numbers = arr.flatMap {
                            Double($0)
                        }
                        let sum = numbers.reduce(0, +)
                        let avg = sum / Double(numbers.count)
                        Result.text = avg.rounded(toPlaces: precision).clean
                    default:
                        break
                    }
                } else {
                    Result.text = "error"
                }
            }
        }
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        if (RPNmode) {
            if let rawInput = Result.text {
                let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
                let arr = input.condensedWhitespace.components(separatedBy: " ")
                var result: Double = 0
                if arr.count == 1 {
                    result = Double(arr[0])!
                    Result.text = result.rounded(toPlaces: precision).clean
                    postCalc = true
                } else {
                    postCalc = true
                    switch sender {
                    case add:
                        for ele in arr {
                            result += Double(ele)!
                        }
                        Result.text = result.rounded(toPlaces: precision).clean
                    case sub:
                        result = Double(arr[0])! * 2
                        for ele in arr {
                            result -= Double(ele)!
                        }
                        Result.text = result.rounded(toPlaces: precision).clean
                    case mul:
                        result = 1
                        for ele in arr {
                            result *= Double(ele)!
                        }
                        Result.text = result.rounded(toPlaces: precision).clean
                    case div:
                        result = Double(arr[0])! * Double(arr[0])!
                        for ele in arr {
                            result /= Double(ele)!
                        }
                        Result.text = result.rounded(toPlaces: precision).clean
                    case mod:
                        result = Double(arr[0])!
                        for i in stride(from: 2, to: arr.count , by: 1) {
                            result = result.truncatingRemainder(dividingBy: Double(arr[i])!)
                        }
                        Result.text = result.rounded(toPlaces: precision).clean

                    default:
                        break
                    }

                }
            } else {
                Result.text = "error"
            }
        } else {
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

