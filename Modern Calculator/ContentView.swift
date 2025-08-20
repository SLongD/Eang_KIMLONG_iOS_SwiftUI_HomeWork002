//
//  ContentView.swift
//  Modern Calculator
//
//  Created by Eang Kimlong on 8/15/25.
//

import SwiftUI

enum Operator : String {
    case add = "+"
    case subtract = "-"
    case multiply = "x"
    case divide = "/"
    case modulo = "%"
    case defaultValue = ""
}
enum MathError : Error {
    case divisionByZero
}

struct ContentView: View {
    @State private var firstNumberInput: String = ""
    @State private var secondNumberInput: String = ""
    @State private var numberInput: String = ""
    @State private var operatorInput: Operator = .defaultValue
    @State private var resultCalculator : String = ""
    @State private var isEnteringSecondNumber: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing){
            HStack {
                Text(isEnteringSecondNumber ? numberInput : (numberInput.isEmpty && !firstNumberInput.isEmpty ? firstNumberInput : numberInput))
                    .foregroundStyle(.red)
                    .font(.system(size: 20))
                Spacer()
                Text(operatorInput.rawValue)
                    .foregroundStyle(.green)
                    .font(.system(size: 20))
            }
            Text(resultCalculator)
                .foregroundStyle(.black)
                .font(.system(size: 30))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        Spacer()
        VStack {
            HStack{
                HStack{
                   Button(action: {
                       clearAll()
                    }) {
                        Text("C")
                            .frame(width: 60, height: 70)
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                            .padding()
                            .background(.black)
                            .cornerRadius(10)
                   }
                }
                HStack{
                    customHStack("+/-","%", "/",
                                 actions: {
                        toggleSign()
                    },{
                        handleOperator(.modulo)
                    },{
                        handleOperator(.divide)
                    }
                    )
                }
            }
            
            customHStack("7","8","9", "X",
                         actions: {
                appendNumber("7")
            }, {
                appendNumber("8")
            }, {
                appendNumber("9")
            },{
                handleOperator(.multiply)
            }
            )
            customHStack("4","5","6", "-",
                         actions: {
                appendNumber("4")
            },{
                appendNumber("5")
            },{
                appendNumber("6")
            },{
                handleOperator(.subtract)
            }
            )
            customHStack("1","2","3", "+",
                         actions: {
                appendNumber("1")
            },{
                appendNumber("2")
            },{
                appendNumber("3")
            },{
                handleOperator(.add)
            }
            )
            HStack{
                HStack{
                   Button(action: {
                        appendNumber("0")
                    }) {
                        Text("0")
                            .frame(width: 160, height: 70)
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black)
                            .cornerRadius(10)
                   }
                }
                HStack{
                    customHStack(".",
                                 actions: {
                        appendDecimal()
                    }
                    )
                }
                HStack{
                   Button(action: {
                       calculateResult()
                    }) {
                        Text("=")
                            .frame(width: 60, height: 70)
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                            .padding()
                            .background(.blue)
                            .cornerRadius(10)
                   }
                }
                
            }
        }
        .padding()
    }
    
    func clearAll() {
        firstNumberInput = ""
        secondNumberInput = ""
        numberInput = ""
        operatorInput = .defaultValue
        resultCalculator = ""
        isEnteringSecondNumber = false
    }
    
    func appendNumber(_ digit: String) {
        if numberInput == "0" {
            numberInput = digit
        } else {
            numberInput += digit
        }
        if operatorInput != .defaultValue {
            isEnteringSecondNumber = true
        }
    }
    
    func appendDecimal() {
        if numberInput.isEmpty {
            numberInput = "0."
        } else if !numberInput.contains(".") {
            numberInput += "."
        }
        if operatorInput != .defaultValue {
            isEnteringSecondNumber = true
        }
    }
    
    func toggleSign() {
        if numberInput.isEmpty {
            return
        }
        if numberInput.hasPrefix("-") {
            numberInput = String(numberInput.dropFirst())
        } else {
            numberInput = "-" + numberInput
        }
    }
    
    func handleOperator(_ newOperator: Operator) {
        if (numberInput.isEmpty ) {
            operatorInput = newOperator
            return
        }
        
        if firstNumberInput.isEmpty {
            firstNumberInput = numberInput
            numberInput = ""
            operatorInput = newOperator
            isEnteringSecondNumber = false
            return
        }
        
        if !firstNumberInput.isEmpty && !numberInput.isEmpty {
            secondNumberInput = numberInput
            do {
                    let result = try calculateProcess(
                        operatorInput,
                        Double(firstNumberInput) ?? 0.0,
                        Double(secondNumberInput) ?? 0.0
                    )
                    resultCalculator = formatResult(result)
                    firstNumberInput = resultCalculator
            } catch MathError.divisionByZero {
                resultCalculator = "Error: Division by zero"
            } catch {
                resultCalculator = "Error"
            }
            secondNumberInput = ""
            numberInput = ""
            isEnteringSecondNumber = false
        }
        
        operatorInput = newOperator
    }
    
    func calculateResult() {
        guard !firstNumberInput.isEmpty && !numberInput.isEmpty else {
            return
        }
        
        secondNumberInput = numberInput
        do {
                let result = try calculateProcess(
                    operatorInput,
                    Double(firstNumberInput) ?? 0.0,
                    Double(secondNumberInput) ?? 0.0
                )
                resultCalculator = formatResult(result)
                firstNumberInput = resultCalculator
            } catch MathError.divisionByZero {
                resultCalculator = "Error: Division by zero"
            } catch {
                resultCalculator = "Error"
            }
//        let result = try calculateProcess(operatorInput,
//                                    Double(firstNumberInput) ?? 0.0,
//                                    Double(secondNumberInput) ?? 0.0)
//        resultCalculator = formatResult(result)
        firstNumberInput = resultCalculator
        secondNumberInput = ""
        numberInput = ""
        //operatorInput = .defaultValue
        isEnteringSecondNumber = false
    }
    
    func formatResult(_ result: Double) -> String {
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(result))
        } else {
            return String(format: "%.2f", result)
        }
    }
}

func customHStack<T: CustomStringConvertible>(_ parameter: T...,actions: (() -> Void)...) -> some View {
    HStack {
        ForEach(parameter.indices, id: \.self) { i in
            Button(action: {
                if i < actions.count {
                    actions[i]()
                }
            }) {
                customBtn(parameter[i])
            }
        }
    }
}

func customBtn<T: CustomStringConvertible>(_ parameter: T) -> some View {
    Text(parameter.description)
        .frame(width: 60, height: 70)
        .font(.system(size: 24))
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .cornerRadius(10)
}

func calculateProcess(_ op: Operator, _ numberA: Double, _ numberB: Double) throws -> Double {
    let result: Double
    
    switch op {
    case .add:
        result = numberA + numberB
    case .subtract:
        result = numberA - numberB
    case .multiply:
        result = numberA * numberB
    case .divide:
            if numberB != 0 {
                result =  numberA / numberB
            } else {
                throw MathError.divisionByZero
            }
    case .modulo:
        result = numberB != 0 ? numberA.truncatingRemainder(dividingBy: numberB) : 0
    default:
        result = numberA
    }
    return result
}

#Preview {
    ContentView()
}
