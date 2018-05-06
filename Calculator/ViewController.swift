//
//  ViewController.swift
//  Calculator
//
//  Created by Takuya Matsuda on 2018/02/28.
//  Copyright © 2018年 Takuya Matsuda. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    var resultOutLabel = UILabel() //resultLabelの右端に余白をつけるために設置20180219
    var resultLabel = UILabel()
    let xButtonCount = 4    //1行に配置するボタンの数
    let yButtonCount = 6    //1列に配置するボタンの数
    var number1: NSDecimalNumber = 0.0    //入力数値を格納する変数１
    var number2: NSDecimalNumber = 0.0    //入力数値を格納する変数２
    //var number3:NSDecimalNumber = 0.0   //メモリーキーに格納する変数３
    var result: NSDecimalNumber = 0.0     //計算結果を格納する変数
    var operatorId: String = ""  //演算子を格納する変数
    
    
    /////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        //画面の背景色を設定(hexString値）
        self.view.backgroundColor = UIColor(hexString: "#232321")
        //画面の横幅を格納するメンバ変数
        let screenWidth: Double = Double(UIScreen.main.bounds.size.width)
        //画面の縦幅
        let screenHeight: Double = Double(UIScreen.main.bounds.size.height)
        //ボタン間の余白（横）
        let buttonMargin = 12.0
        //ボタン間の余白（縦）
        let buttonMarginHeight = 20.0
        
        
        
        //計算結果エリア
        //縦幅
        var resultArea: Double = 0.0
        //画面全体の縦幅に応じて計算結果表示エリアの縦幅を決定
        switch screenHeight {
        case 568:
            resultArea = 110.0 //iphone5,5s,5c,SE
        case 667:
            resultArea = 150.0 //iPhone6,6S,7,8
        case 736:
            resultArea = 180.0 //iPhone6Plus,6sPlus,7Plus,8Plus
        default:
            resultArea = 0.0
        }
        
        
        
        /* 計算結果ラベルの設定 */
        //フレームを設定
        resultLabel.frame = CGRect(x:10, y:20, width:screenWidth-20, height:resultArea-20)
        //背景色を設定
        resultLabel.backgroundColor = self.colorWithRGBHex(0xF5F5DC, alpha: 1.0)
        //フォントと文字サイズを設定
        resultLabel.font = UIFont(name: "Helvetica", size: 80)
        //右揃えに設定
        resultLabel.textAlignment = NSTextAlignment.right
        //表示行数を4行に設定
        resultLabel.numberOfLines = 4
        //初期値を0に設定
        resultLabel.text = "0"
        //resultLabelの土台（外枠）ラベルを設置（先に設置した方が背面となる）
        resultOutLabel.backgroundColor = self.colorWithRGBHex(0xF5F5DC, alpha: 1.0)
        resultOutLabel.frame = CGRect(x:0, y:20, width:screenWidth, height:resultArea-20)
        self.view.addSubview(resultOutLabel)
        //計算結果ラベルをViewControllerクラスのviewに設置
        self.view.addSubview(resultLabel)
        
        
        //ボタンのラベルタイトルを配列で用意
        let buttonLabels = [
            //        "mc","m+","m-","mr",
            "","","","",
            //        "c","+/-","÷","×",
            "c","","÷","×",
            "7","8","9","−",
            "4","5","6","+",
            "1","2","3","=",
            "0","",".","",
            ]
        
        
        //数字ボタンを作成
        for y in 2 ..< yButtonCount-1 {
            for x in 0 ..< xButtonCount-1 {
                //計算機のボタンを作成
                let button = UIButton()
                //ボタンタイトルのフォントサイズ
                button.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(23))
                //ボタンの横幅サイズ作成
                let buttonWidth = (screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)
                //ボタンの縦幅サイズ作成
                let buttonHeight = (screenHeight - resultArea - (buttonMarginHeight * (Double(yButtonCount)+1))) / Double(yButtonCount)
                //ボタンのx座標
                let buttonPositionX = (screenWidth - buttonMargin) / Double(xButtonCount) * Double(x) + buttonMargin
                //ボタンのy座標
                let buttonPositionY = (screenHeight - resultArea - buttonMarginHeight) / Double(yButtonCount) * Double(y) + resultArea + buttonMarginHeight
                //ボタンの配置場所、サイズを作成
                button.frame = CGRect(x:buttonPositionX, y:buttonPositionY, width: buttonWidth, height: buttonHeight)
                //ボタンの背景色設定
                //button.backgroundColor = UIColor.greenColor()
                //ボタン背景をグラデーション色設定
                let gradient = CAGradientLayer()
                gradient.frame = button.bounds
                
                let arrayColors = [colorWithRGBHex(0xFFFFFF, alpha: 0.2).cgColor as AnyObject,
                                   colorWithRGBHex(0x000000, alpha: 1.0).cgColor as AnyObject]
                gradient.colors = arrayColors
                button.layer.insertSublayer(gradient, at: 0)
                //ボタンを角丸にする
                button.layer.masksToBounds = true
                button.layer.cornerRadius = 5.0
                //ボタンのテキストカラーを設定
                button.setTitleColor(UIColor.white, for:UIControlState())
                button.setTitleColor(UIColor.gray, for:UIControlState.highlighted)
                
                //ボタンのラベルタイトルを取り出すインデックス番号
                let buttonNumber = y * xButtonCount + x
                //ボタンのラベルタイトルを設定
                button.setTitle(buttonLabels[buttonNumber], for:UIControlState())
                //ボタンタップ時のアクション設定
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
                //ボタン配置
                self.view.addSubview(button)
            }
        }
        
        
        //数字ボタン0を作成
        let button = UIButton()
        //ボタンタイトルのフォントサイズ
        button.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(23))
        //ボタンの横幅サイズ作成
        let buttonZeroWidth = ((screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)) * 2 + buttonMargin
        //ボタンの縦幅サイズ作成
        let buttonZeroHeight = (screenHeight - resultArea - (buttonMarginHeight * (Double(yButtonCount)+1))) / Double(yButtonCount)
        //ボタンのx座標
        let buttonZeroPositionX = buttonMargin
        //ボタンのy座標
        let buttonZeroPositionY = (screenHeight - resultArea - buttonMarginHeight) / Double(yButtonCount) * Double(5) + resultArea + buttonMarginHeight
        //ボタンの配置場所、サイズを作成
        button.frame = CGRect(x:buttonZeroPositionX, y:buttonZeroPositionY, width: buttonZeroWidth, height: buttonZeroHeight)
        //ボタン背景をグラデーション色設定
        let gradient = CAGradientLayer()
        gradient.frame = button.bounds
        let arrayColors = [colorWithRGBHex(0xFFFFFF, alpha: 0.2).cgColor as AnyObject,
                           colorWithRGBHex(0x000000, alpha: 1.0).cgColor as AnyObject]
        gradient.colors = arrayColors
        button.layer.insertSublayer(gradient, at: 0)
        //ボタンを角丸にする
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5.0
        //ボタンのテキストカラーを設定
        button.setTitleColor(UIColor.white, for:UIControlState())
        button.setTitleColor(UIColor.gray, for:UIControlState.highlighted)
        //ボタンのラベルタイトルを取り出すインデックス番号
        let buttonZeroNumber = 5 * xButtonCount + 0
        //ボタンのラベルタイトルを設定
        button.setTitle(buttonLabels[buttonZeroNumber], for:UIControlState())
        //ボタンタップ時のアクション設定
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        //ボタン配置
        self.view.addSubview(button)
        //ボタンテキスト0を左揃え
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 26, 0, 0)   // タイトルに余白をつける
        
        
        
        //数字ボタン"."(Point)を作成
        let buttonPoint = UIButton()
        //ボタンタイトルのフォントサイズ
        buttonPoint.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(23))
        //ボタンの横幅サイズ作成
        let buttonPointWidth = (screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)
        //ボタンの縦幅サイズ作成
        let buttonPointHeight = (screenHeight - resultArea - (buttonMarginHeight * (Double(yButtonCount)+1))) / Double(yButtonCount)
        //ボタンのx座標
        let buttonPointPositionX = (screenWidth - buttonMargin) / Double(xButtonCount) * Double(2) + buttonMargin
        //ボタンのy座標
        let buttonPointPositionY = (screenHeight - resultArea - buttonMarginHeight) / Double(yButtonCount) * Double(5) + resultArea + buttonMarginHeight
        //ボタンの配置場所、サイズを作成
        buttonPoint.frame = CGRect(x:buttonPointPositionX, y:buttonPointPositionY, width: buttonPointWidth, height: buttonPointHeight)
        //ボタン背景をグラデーション色設定
        let gradientPoint = CAGradientLayer()
        gradientPoint.frame = button.bounds
        let arrayColorsPoint = [colorWithRGBHex(0xFFFFFF, alpha: 0.2).cgColor as AnyObject,
                                colorWithRGBHex(0x000000, alpha: 1.0).cgColor as AnyObject]
        gradientPoint.colors = arrayColorsPoint
        buttonPoint.layer.insertSublayer(gradientPoint, at: 0)
        //ボタンを角丸にする
        buttonPoint.layer.masksToBounds = true
        buttonPoint.layer.cornerRadius = 5.0
        //ボタンのテキストカラーを設定
        buttonPoint.setTitleColor(UIColor.white, for:UIControlState())
        buttonPoint.setTitleColor(UIColor.gray, for:UIControlState.highlighted)
        //ボタンのラベルタイトルを取り出すインデックス番号
        let buttonPointNumber = 5 * xButtonCount + 2
        //ボタンのラベルタイトルを設定
        buttonPoint.setTitle(buttonLabels[buttonPointNumber], for:UIControlState())
        //ボタンタップ時のアクション設定
        buttonPoint.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        //ボタン配置
        self.view.addSubview(buttonPoint)
        
        
        
        //演算ボタンを作成
        for y in 1 ..< yButtonCount-4 {
            for x in 0 ..< xButtonCount {
                //計算機のボタンを作成
                let buttonOperator = UIButton()
                //ボタンタイトルのフォントサイズ
                buttonOperator.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(23))
                //ボタンの横幅サイズ作成
                let buttonWidth = (screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)
                //ボタンの縦幅サイズ作成
                let buttonHeight = (screenHeight - resultArea - (buttonMarginHeight * (Double(yButtonCount)+1))) / Double(yButtonCount)
                //ボタンのx座標
                let buttonPositionX = (screenWidth - buttonMargin) / Double(xButtonCount) * Double(x) + buttonMargin
                //ボタンのy座標
                let buttonPositionY = (screenHeight - resultArea - buttonMarginHeight) / Double(yButtonCount) * Double(y) + resultArea + buttonMarginHeight
                //ボタンの配置場所、サイズを作成
                buttonOperator.frame = CGRect(x:buttonPositionX, y:buttonPositionY, width: buttonWidth, height: buttonHeight)
                //ボタンの背景色設定
                buttonOperator.backgroundColor = UIColor(hexString: "#66544A")
                //ボタン背景をグラデーション色設定
                //let gradient = CAGradientLayer()
                //gradient.frame = button.bounds
                //let arrayColors = [colorWithRGBHex(0xFFFFFF, alpha: 0.2).cgColor as AnyObject,colorWithRGBHex(0x000000, alpha: 1.0).cgColor as AnyObject]
                //gradient.colors = arrayColors
                //button.layer.insertSublayer(gradient, at: 0)
                //ボタンを角丸にする
                buttonOperator.layer.masksToBounds = true
                buttonOperator.layer.cornerRadius = 5.0
                //ボタンのテキストカラーを設定
                buttonOperator.setTitleColor(UIColor.white, for:UIControlState())
                buttonOperator.setTitleColor(UIColor.gray, for:UIControlState.highlighted)
                
                //ボタンのラベルタイトルを取り出すインデックス番号
                let buttonNumber = y * xButtonCount + x
                //ボタンのラベルタイトルを設定
                buttonOperator.setTitle(buttonLabels[buttonNumber], for:UIControlState())
                //ボタンタップ時のアクション設定
                buttonOperator.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
                //ボタン配置
                self.view.addSubview(buttonOperator)
            }
        }
        
        
        
        //演算ボタンの-と+を作成（無理やり）
        for y in 2 ..< 4 {
            let buttonOperator = UIButton()
            //ボタンタイトルのフォントサイズ
            buttonOperator.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(26))
            //ボタンの横幅サイズ作成
            let buttonWidth = (screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)
            //ボタンの縦幅サイズ作成
            let buttonHeight = (screenHeight - resultArea - (buttonMarginHeight * (Double(yButtonCount)+1))) / Double(yButtonCount)
            //ボタンのx座標
            let buttonPositionX = (screenWidth - buttonMargin) / Double(xButtonCount) * Double(3) + buttonMargin
            //ボタンのy座標
            let buttonPositionY = (screenHeight - resultArea - buttonMarginHeight) / Double(yButtonCount) * Double(y) + resultArea + buttonMarginHeight
            //ボタンの配置場所、サイズを作成
            buttonOperator.frame = CGRect(x:buttonPositionX, y:buttonPositionY, width: buttonWidth, height: buttonHeight)
            buttonOperator.frame = CGRect(x:buttonPositionX, y:buttonPositionY, width: buttonWidth, height: buttonHeight)
            //ボタンの背景色設定
            buttonOperator.backgroundColor = UIColor(hexString: "#66544A")
            //ボタンを角丸にする
            buttonOperator.layer.masksToBounds = true
            buttonOperator.layer.cornerRadius = 5.0
            //ボタンのテキストカラーを設定
            buttonOperator.setTitleColor(UIColor.white, for:UIControlState())
            buttonOperator.setTitleColor(UIColor.gray, for:UIControlState.highlighted)
            //ボタンのラベルタイトルを取り出すインデックス番号
            let buttonNumber = y * xButtonCount + 3
            //ボタンのラベルタイトルを設定
            buttonOperator.setTitle(buttonLabels[buttonNumber], for:UIControlState())
            //ボタンタップ時のアクション設定
            buttonOperator.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
            //ボタン配置
            self.view.addSubview(buttonOperator)
        }
        
        
        
        //等号ボタンを作成
        let buttonEqual = UIButton()
        //ボタンタイトルのフォントサイズ
        buttonEqual.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(28))
        //ボタンの横幅サイズ作成
        let buttonWidth = (screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)
        //ボタンの縦幅サイズ作成
        let buttonHeight = (screenHeight - resultArea - (buttonMarginHeight * (Double(yButtonCount)+1))) / Double(yButtonCount)*2 + buttonMarginHeight
        //ボタンのx座標
        let buttonPositionX = (screenWidth - buttonMargin) / Double(xButtonCount) * Double(3) + buttonMargin
        //ボタンのy座標
        let buttonPositionY = (screenHeight - resultArea - buttonMarginHeight) / Double(yButtonCount) * Double(4) + resultArea + buttonMarginHeight
        //ボタンの配置場所、サイズを作成
        buttonEqual.frame = CGRect(x:buttonPositionX, y:buttonPositionY, width: buttonWidth, height: buttonHeight)
        buttonEqual.frame = CGRect(x:buttonPositionX, y:buttonPositionY, width: buttonWidth, height: buttonHeight)
        //ボタンの背景色設定
        buttonEqual.backgroundColor = UIColor(hexString: "#F47E1C")
        //ボタンを角丸にする
        buttonEqual.layer.masksToBounds = true
        buttonEqual.layer.cornerRadius = 5.0
        //ボタンのテキストカラーを設定
        buttonEqual.setTitleColor(UIColor.white, for:UIControlState())
        buttonEqual.setTitleColor(UIColor.gray, for:UIControlState.highlighted)
        //ボタンのラベルタイトルを取り出すインデックス番号
        let buttonNumber = 4 * xButtonCount + 3
        //ボタンのラベルタイトルを設定
        buttonEqual.setTitle(buttonLabels[buttonNumber], for:UIControlState())
        //ボタンタップ時のアクション設定
        buttonEqual.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        //ボタン配置
        self.view.addSubview(buttonEqual)
        
        
        
        //メモリーボタンを作成
        for y in 0 ..< 1 {
            for x in 0 ..< xButtonCount {
                //計算機のボタンを作成
                let buttonMemory = UIButton()
                //ボタンタイトルのフォントサイズ
                buttonMemory.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
                //ボタンの横幅サイズ作成
                let buttonWidth = (screenWidth - (buttonMargin * (Double(xButtonCount)+1))) / Double(xButtonCount)
                //ボタンの縦幅サイズ作成
                let buttonHeight = (screenHeight - resultArea - (buttonMarginHeight * (Double(yButtonCount)+1))) / Double(yButtonCount)
                //ボタンのx座標
                let buttonPositionX = (screenWidth - buttonMargin) / Double(xButtonCount) * Double(x) + buttonMargin
                //ボタンのy座標
                let buttonPositionY = (screenHeight - resultArea - buttonMarginHeight) / Double(yButtonCount) * Double(y) + resultArea + buttonMarginHeight
                //ボタンの配置場所、サイズを作成
                buttonMemory.frame = CGRect(x:buttonPositionX, y:buttonPositionY, width: buttonWidth, height: buttonHeight)
                //ボタンの背景色設定
                buttonMemory.backgroundColor = UIColor(hexString: "#585F65")
                //ボタン背景をグラデーション色設定
                //let gradient = CAGradientLayer()
                //gradient.frame = button.bounds
                //let arrayColors = [colorWithRGBHex(0xFFFFFF, alpha: 0.2).cgColor as AnyObject,colorWithRGBHex(0x000000, alpha: 1.0).cgColor as AnyObject]
                //gradient.colors = arrayColors
                //button.layer.insertSublayer(gradient, at: 0)
                //ボタンを角丸にする
                buttonMemory.layer.masksToBounds = true
                buttonMemory.layer.cornerRadius = 5.0
                //ボタンのテキストカラーを設定
                buttonMemory.setTitleColor(UIColor.white, for:UIControlState())
                buttonMemory.setTitleColor(UIColor.gray, for:UIControlState.highlighted)
                //ボタンのラベルタイトルを取り出すインデックス番号
                let buttonNumber = y * xButtonCount + x
                //ボタンのラベルタイトルを設定
                buttonMemory.setTitle(buttonLabels[buttonNumber], for:UIControlState())
                //ボタンタップ時のアクション設定
                buttonMemory.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
                //ボタン配置
                self.view.addSubview(buttonMemory)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    ///////////////////////////////////////////////////////////////////
    // 各種メソッド
    ///////////////////////////////////////////////////////////////////
    //ボタンがタップされた時のメソッド（計算処理など）
    @objc func buttonTapped(_ sender: UIButton) {
        let tappedButtonTitle: String = sender.currentTitle!
        print("\(tappedButtonTitle)ボタンが押されました！")
        //ボタンのタイトルで条件分岐
        switch tappedButtonTitle {
        case "0","1","2","3","4","5","6","7","8","9":   //数字ボタン
            numberButtonTapped(tappedButtonTitle)
        case "×","-","+","÷":                           //演算子ボタン
            operatorButtonTapped(tappedButtonTitle)
            //case "+/-":                                     //正負ボタン（表示してある数字を正数にしたり負数にしたり）
        //plusMinusButtonTapped(tappedButtonTitle)
        case "=":                                       //等号ボタン
            equalButtonTapped(tappedButtonTitle)
            //case "m+","m-":                                 //メモリー演算ボタン（直前の計算結果をメモリーに足す・引く）
            //memoryOperatorButtonTapped(tappedButtonTitle)
            //case "mr";                                      //メモリーリコールボタン（これまでのメモリー計算の結果を呼び出す）
            //memoryRecallButtonTapped(tappedButtonTitle)
            //case "mc":                                      //メモリークリアボタン
        //memoryClearButtonTappled(tappedButtonTitle)
        default:                                            //クリアボタン
            clearButtonTapped(tappedButtonTitle)
        }
    }
    
    
    
    //////////////////////////
    func numberButtonTapped(_ tappedButtonTitle: String) {
        print("数字ボタンタップ：\(tappedButtonTitle)")
        //タップされた数字タイトルを計算できるようにNSDecimalNumber型に変換
        let tappedButtonNum: NSDecimalNumber = NSDecimalNumber(string: tappedButtonTitle)
        //入力されていた値を10倍にして1桁大きくして、その変換した数値を加算
        number1 = number1.multiplying(by: NSDecimalNumber(string: "10")).adding(tappedButtonNum)
        //number1をカンマ区切りに変換
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        _ = formatter.string(from: number1)
        //計算結果ラベルに表示
        resultLabel.text = formatter.string(from: number1 as NSNumber)
    }
    
    
    func operatorButtonTapped(_ tappedButtonTitle:String) {
        print("演算子ボタンタップ：\(tappedButtonTitle)")
        operatorId = tappedButtonTitle
        number2 = number1
        number1 = NSDecimalNumber(string: "0")
        //等号ボタンを押さずに、続けて演算子ボタンを押しても計算できるようにコードを記述する必要がある
    }
    
    
    func equalButtonTapped(_ tappedButtonTitle:String) {
        print("等号ボタンタップ：\(tappedButtonTitle)")
        switch operatorId {
        case "+":
            result = number2.adding(number1)
        case "-":
            result = number2.subtracting(number1)
        case "×":
            result = number2.multiplying(by: number1)
        case "÷":
            if number1.isEqual(to: 0) {
                number1 = 0
                resultLabel.text = "∞"
                return
            } else {
                result = number2.dividing(by: number1)
            }
        default:
            print("その他")
        }
        //表示はされない内部の箱number1に変数resultを代入（今後の計算のために）
        number1 = result
       
        //resultをカンマ区切りに変換0219
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        _ = formatter.string(from: result)
        //計算結果ラベルに表示
        resultLabel.text = formatter.string(from: result as NSNumber)
    }
    
    
    func clearButtonTapped(_ tappedButtonTitle:String) {
        print("クリアボタンタップ：\(tappedButtonTitle)")
        number1 = NSDecimalNumber(string:"0")
        number2 = NSDecimalNumber(string:"0")
        result = NSDecimalNumber(string:"0")
        operatorId = ""
        resultLabel.text = "0"
    }
    
    
    //HEX値で設定するためのメソッド
    func colorWithRGBHex(_ hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}

