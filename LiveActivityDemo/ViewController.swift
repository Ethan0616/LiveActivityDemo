//
//  ViewController.swift
//  LiveActivityDemo
//
//  Created by Ethan on 2022/10/26.
//

import UIKit

class ViewController: UIViewController {
    var Score : Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.systemYellow
        LiveActivityInterface<VJLiveActivityAttributes>.addActivityObserver { tokenStr in
            print("==================\n\(tokenStr)\n=================")
        }
    }

    // left
    @IBAction func action1(_ sender: UIButton) {
        
        let gameAttributes = VJLiveActivityAttributes(orderType: .procfootballMatchessing)
        let gameState = VJLiveActivityAttributes.VJAttributesState(timestamp: "", driverName: "Ethan", courier: "", numberOfPizzas: "",Score: "20",originScore: "0", totalAmount:"", avatar: "person.circle", deliveryState: VJLiveActivityAttributesState.completed)
        
        if #available(iOS 16.1, *) {
            do {
                try LiveActivityInterface.start(staticData:gameAttributes, contentState: gameState,nickName: "EthanLiveActivity")
            } catch (let error) {
                print(error)
            }
        }
    }
    
    @IBAction func update1(_ sender: UIButton) {

        if #available(iOS 16.1, *) {
            Task {
                repeat {
                    Score += 1
                    print(Score)
                    let gameState = VJLiveActivityAttributes.VJAttributesState(timestamp: "", driverName: "Ethan", courier: "", numberOfPizzas: "",Score: "\(Score + 3)",originScore: "\(Score)", totalAmount:"", avatar: "person.circle", deliveryState: VJLiveActivityAttributesState.completed)
                    do {
                        try LiveActivityInterface<VJLiveActivityAttributes>.update(contentState: gameState,nickNmae: "EthanLiveActivity")
                    } catch (let error) {
                        print(error)
                    }
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }while true
            }
        }
    }
    
    @IBAction func cancel1(_ sender: UIButton) {
        LiveActivityInterface<VJLiveActivityAttributes>.stopActivity(nickName: "EthanLiveActivity")
    }
    // right
    @IBAction func action2(_ sender: UIButton) {
        let gameAttributes = VJLiveActivityAttributes(orderType: .pizzaDelivery)
        let gameState = VJLiveActivityAttributes.VJAttributesState(timestamp: "", driverName: "Ethan", courier: "", numberOfPizzas: "123123",Score: "20",originScore: "0", totalAmount:"10100", avatar: "person.circle", deliveryState: .prepping)
        
        if #available(iOS 16.1, *) {
            do {
                try LiveActivityInterface.start(staticData:gameAttributes, contentState: gameState,nickName: "pizzaDeliveryLiveActivity")
            } catch (let error) {
                print(error)
            }
        }
    }
    
    @IBAction func update2(_ sender: UIButton) {
        let gameState = VJLiveActivityAttributes.VJAttributesState(timestamp: "", driverName: "Ethan123455", courier: "", numberOfPizzas: "",Score: "20",originScore: "0", totalAmount:"", avatar: "person.circle", deliveryState: VJLiveActivityAttributesState.completed)
        
        if #available(iOS 16.1, *) {
            do {
                try LiveActivityInterface<VJLiveActivityAttributes>.update(contentState: gameState,nickNmae: "pizzaDeliveryLiveActivity")
            } catch (let error) {
                print(error)
            }
        }
    }
    
    @IBAction func cancel2(_ sender: UIButton) {
        LiveActivityInterface<VJLiveActivityAttributes>.stopActivity(nickName: "pizzaDeliveryLiveActivity")
    }
    // all
    @IBAction func cancelAll(_ sender: UIButton) {
        LiveActivityInterface<VJLiveActivityAttributes>.stopAllActivities()
    }
    @IBAction func showAllActivities(_ sender: UIButton) {
        LiveActivityInterface<VJLiveActivityAttributes>.showAllActivity()
    }
    
}

