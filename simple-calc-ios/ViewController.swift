//
//  ViewController.swift
//  simple-calc-ios
//
//  Created by ​ on 10/20/17.
//  Copyright © 2017 iGuest. All rights reserved.
//

import UIKit

extension Double {
    func rounded(toPlaces places: Int) -> Double {
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

    func fact2(_ input: Double) -> Double {
        if (input <= 1) {
            return 1.0
        } else {
            return (input * fact2(input - 1.0))
        }
    }

    func eleIsNumber(_ arr: Array<String>) -> Bool {
        var count: Int = 0
        for i in stride(from: 0, to: arr.count, by: 2) {
            if (Double(arr[i]) == nil) {
                count += 1
            }
        }
        return count == 0
    }

    func sameOp(_ arr: Array<String>) -> Bool {
        var count: Int = 0
        for i in stride(from: 1, to: arr.count - 3, by: 2) {
            if (arr[i] != arr[i + 2]) {
                count += 1
            }
        }
        return count == 0
    }

    func reArrangeArr(_ arr: Array<String>) -> Array<String> {
        var cur: Array<String> = arr
        if (eleIsNumber(cur) && cur.count % 2 == 1) {
            for i in stride(from: 1, to: arr.count - 1, by: 2) {
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

    @IBAction func stepperChange(_ sender: UIStepper) {
        precision = Int(sender.value)
        precisionText.text = sender.value.clean
    }

    @IBAction func modeControl(_ sender: UISegmentedControl) {
        postCalc = true
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
        var result: String = ""
        var op: String = ""
        if (rpnMode == true) {
            if let rawInput = Result.text {
                let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
                if !input.contains(" ") {
                    switch sender {
                    case count:
                        result = "1"
                        op = "count"
                        let equation = "RPN Mode:\n\(input) \(op) = \(result)"
                        hist.append(equation)
                    case avg:
                        op = "avg"
                        result = input
                        let equation = "RPN Mode:\n\(input) \(op) = \(result)"
                        hist.append(equation)
                    case fact:
                        if (Double(input)! < 0 || Double(input)! > 168 || Double(input)!.truncatingRemainder(dividingBy: 1) != 0) {
                            Result.text = "too large to calculate or not a non-negative integer"
                        } else {
                            let temp: Double = fact2(Double(input)!)
                            result = temp.rounded(toPlaces: precision).clean
                            op = "fact"
                            Result.text = result
                            let equation = "RPN Mode:\n\(input) \(op) = \(result)"
                            hist.append(equation)
                        }
                    default: ()
                    }
                } else {
                    let numbers = input.condensedWhitespace.components(separatedBy: " ").flatMap {
                        Double($0)
                    }
                    switch sender {
                    case count:
                        op = "count"
                        result = String(numbers.count)
                        Result.text = result
                        let equation = "RPN Mode:\n\(input) \(op) = \(result)"
                        hist.append(equation)
                    case avg:
                        let sum = numbers.reduce(0, +)
                        let avg = sum / Double(numbers.count)
                        op = "avg"
                        result = avg.rounded(toPlaces: precision).clean
                        Result.text = result
                        let equation = "RPN Mode:\n\(input) \(op) = \(result)"
                        hist.append(equation)
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
                    let input = rawInput.trimmingCharacters(in: .whitespacesAndNewlines).condensedWhitespace.components(separatedBy: " ")
                    if input.count == 1 && eleIsNumber(input) {
                        if (Double(input[0])! < 0 || Double(input[0])! > 168 || Double(input[0])!.truncatingRemainder(dividingBy: 1) != 0) {
                            Result.text = "too large to calculate or not a non-negative integer"
                        } else {
                            let temp = fact2(Double(input[0])!)
                            result = temp.rounded(toPlaces: precision).clean
                            op = "fact"
                            Result.text = result
                            let equation = "\(input[0]) \(op) = \(result)"
                            hist.append(equation)
                        }
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
            var resultNum: Double = 0
            var result: String = ""
            if (arr.count == 1 && eleIsNumber(arr)) {
                resultNum = Double(arr[0])!
                result = resultNum.rounded(toPlaces: precision).clean
                Result.text = result
                let equation = "\(input) = \(result)"
                hist.append(equation)
            } else {
                if (arr.count % 2 == 1 && eleIsNumber(arr) && sameOp(arr)) {
                    let op = arr[1]
                    switch op {
                    case "+":
                        for i in stride(from: 0, to: arr.count, by: 2) {
                            resultNum += Double(arr[i])!
                        }
                        result = (resultNum).rounded(toPlaces: precision).clean
                    case "count":
                        result = String(Int(arr.count) / 2 + 1)
                    case "avg":
                        let numbers = arr.flatMap {
                            Double($0)
                        }
                        let sum = numbers.reduce(0, +)
                        let avg = sum / Double(numbers.count)
                        result = avg.rounded(toPlaces: precision).clean
                    default:
                        ()
                    }
                    Result.text = result
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
                } else {
                    switch sender {
                    case add:
                        for ele in arr {
                            resultNum += Double(ele)!
                        }
                        op = "+"
                    case sub:
                        resultNum = Double(arr[0])! * 2
                        for ele in arr {
                            resultNum -= Double(ele)!
                        }
                        op = "-"
                    case mul:
                        resultNum = 1
                        for ele in arr {
                            resultNum *= Double(ele)!
                        }
                        op = "*"
                    case div:
                        resultNum = Double(arr[0])! * Double(arr[0])!
                        for ele in arr {
                            resultNum /= Double(ele)!
                        }
                        op = "/"
                    case mod:
                        resultNum = Double(arr[0])!
                        for i in stride(from: 2, to: arr.count, by: 1) {
                            resultNum = resultNum.truncatingRemainder(dividingBy: Double(arr[i])!)
                        }
                        op = "%"
                    default:
                        break
                    }
                }
                result = resultNum.rounded(toPlaces: precision).clean
                let equation = "RPN Mode:\n\(input) \(op) = \(result)"
                hist.append(equation)
                Result.text = result
            } else {
                Result.text = "error"
            }
            postCalc = true
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

