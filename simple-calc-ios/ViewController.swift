//
//  ViewController.swift
//  simple-calc-ios
//
//  Created by ​ on 10/20/17.
//  Copyright © 2017 iGuest. All rights reserved.
//

import UIKit

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

    var postCalc: Bool = false
    var rpnMode: Bool = false
    var precision: Int = 4
    var hist: [String] = []
    
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
    
    func reArrangeArr(_ arr: Array<String>) -> Array<String> {
        var cur: Array<String> = arr
        if (eleIsNumber(cur) && cur.count % 2 == 1) {
            for i in stride(from: 1, to: arr.count - 1 , by: 2) {
                switch cur[i] {
                case "*":
                    let temp = Double(cur[i - 1])! * Double(cur[i + 1])!
                    cur[i - 1] = "0"
                    cur[i] = "+"
                    cur[i + 1] = temp.clean
                case "/":
                    let temp = Double(cur[i - 1])! / Double(cur[i + 1])!
                    cur[i - 1] = "0"
                    cur[i] = "+"
                    cur[i + 1] = temp.clean
                case "%":
                    let temp = Double(cur[i - 1])!.truncatingRemainder(dividingBy: Double(cur[i + 1])!)
                    cur[i - 1] = "0"
                    cur[i] = "+"
                    cur[i + 1] = temp.clean
                case "-":
                    cur[i] = "+"
                    cur[i + 1] = (0.0 - Double(cur[i + 1])!).clean
                default: ()
                }
            }
        }
        return cur
    }
    
    @IBAction func histPressed(_ sender: Any) {
        postCalc = false;
    }
    
    @IBAction func stepperChange(_ sender: UIStepper) {
        precision = Int(sender.value)
        precisionText.text = sender.value.clean
    }
    
    @IBAction func modeControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            rpnMode = false
        case 1:
            rpnMode = true
        default:
            break
        }
    }
    
    @IBAction func cmdPressed(_ sender: UIButton) {
        postCalc = true
        if (rpnMode == true) {
            if let rawInput = Result.text {
                let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
                var result: String = ""
                var op: String = ""
                if !input.contains(" ") {
                    switch sender {
                    case count:
                        result = "1"
                        op = "count"
                        Result.text = result
                    case avg:
                        op = "avg"
                        result = input
                    case fact:
                        result = fact(input)
                        op = "fact"
                        Result.text = result
                    default: ()
                    }
                    let equation = "RPN Mode: \(input) \(op) = \(result)"
                    hist.append(equation)
                } else {
                    let numbers = input.condensedWhitespace.components(separatedBy: " ").flatMap {
                        Double($0)
                    }
                    switch sender {
                    case count:
                        op = "count"
                        result = String(numbers.count)
                        Result.text = result
                    case avg:
                        let sum = numbers.reduce(0, +)
                        let avg = sum / Double(numbers.count)
                        op = "avg"
                        result = avg.rounded(toPlaces: precision).clean
                        Result.text = result
                    case fact: Result.text = "too many operands"
                    default: ()
                    }
                    let equation = "RPN Mode: \(input) \(op) = \(result)"
                    hist.append(equation)
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
            let arr = reArrangeArr(rawArr)
            var resultNum:Double = 0
            var result:String = ""
            if (arr.count == 1 && eleIsNumber(arr)) {
                resultNum = Double(arr[0])!
                result = resultNum.rounded(toPlaces: precision).clean
                Result.text = result
                postCalc = true
                let equation = "\(input) = \(result)"
                hist.append(equation)
            } else {
                if (arr.count % 2 == 1 && eleIsNumber(arr) && sameOp(arr)) {
                    let op = arr[1]
                    switch op {
                    case "+":
                        for i in stride(from: 0, to: arr.count , by: 2) {
                            resultNum += Double(arr[i])!
                        }
                        result = (resultNum).rounded(toPlaces: precision).clean
                        Result.text = result
                    case "count":
                        result = String(Int(arr.count) / 2 + 1)
                        Result.text = result
                    case "avg":
                        let numbers = arr.flatMap {
                            Double($0)
                        }
                        let sum = numbers.reduce(0, +)
                        let avg = sum / Double(numbers.count)
                        result = avg.rounded(toPlaces: precision).clean
                        Result.text = result
                    default:
                        ()
                    }
                    let equation = "\(input) = \(result)"
                    hist.append(equation)
                } else {
                    Result.text = "error"
                }
            }
        }
    }
    
    @IBAction func operatorPressed(_ sender: UIButton) {
        if (rpnMode) {
            if let rawInput = Result.text {
                let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
                let arr = input.condensedWhitespace.components(separatedBy: " ")
                var resultNum: Double = 0
                var result: String = ""
                var op: String = ""
                if arr.count == 1 {
                    resultNum = Double(arr[0])!
                    result = resultNum.rounded(toPlaces: precision).clean
                    Result.text = result
                    postCalc = true
                } else {
                    postCalc = true
                    switch sender {
                    case add:
                        for ele in arr {
                            resultNum += Double(ele)!
                        }
                        result = resultNum.rounded(toPlaces: precision).clean
                        op = "+"
                        Result.text = result
                    case sub:
                        resultNum = Double(arr[0])! * 2
                        for ele in arr {
                            resultNum -= Double(ele)!
                        }
                        result = resultNum.rounded(toPlaces: precision).clean
                        op = "-"
                        Result.text = result
                    case mul:
                        resultNum = 1
                        for ele in arr {
                            resultNum *= Double(ele)!
                        }
                        result = resultNum.rounded(toPlaces: precision).clean
                        op = "*"
                        Result.text = result
                    case div:
                        resultNum = Double(arr[0])! * Double(arr[0])!
                        for ele in arr {
                            resultNum /= Double(ele)!
                        }
                        result = resultNum.rounded(toPlaces: precision).clean
                        op = "/"
                        Result.text = result
                    case mod:
                        resultNum = Double(arr[0])!
                        for i in stride(from: 2, to: arr.count , by: 1) {
                            resultNum = resultNum.truncatingRemainder(dividingBy: Double(arr[i])!)
                        }
                        result = resultNum.rounded(toPlaces: precision).clean
                        op = "%"
                        Result.text = result
                    default:
                        break
                    }
                    let equation = "RPN Mode: \(input) \(op) = \(result)"
                    hist.append(equation)
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
        print(hist)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let histView = segue.destination as! HistViewController
        histView.hist = self.hist
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

