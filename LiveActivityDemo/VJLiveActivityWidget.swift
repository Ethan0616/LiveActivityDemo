//
//  PizzaDeliveryActivityWidget.swift
//  iOS16-Live-Activities
//
//  Created by Ethan on 2022/10/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct VJLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VJLiveActivityAttributes.self) { context in
            // 锁屏视图
            if context.attributes.orderType == .pizzaDelivery {
                LockScreenView(context: context)
            }else {
                LockScreenView2(context: context)
            }
        } dynamicIsland: { context in
            // 灵动岛
            switch context.attributes.orderType {
                case .pizzaDelivery:
                    return PizzaDynamicIslandView(context: context)
                case .procfootballMatchessing:
                    return DynamicIslandView(context: context)

            }
        }
    }
    
    func PizzaDynamicIslandView(context:ActivityViewContext<VJLiveActivityAttributes>) -> DynamicIsland {
        return DynamicIsland {
            // 扩展模式
            // 左侧
            DynamicIslandExpandedRegion(.leading) {

                
            }
            // 右侧
            DynamicIslandExpandedRegion(.trailing) {

            }
            // 灵动岛下 中心视图
            DynamicIslandExpandedRegion(.center) {
                Text("\(context.state.driverName) 在送披萨")
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            // 底部视图
            DynamicIslandExpandedRegion(.bottom) {
                // Deep Linking test
                 Link(destination: URL(string: "pizza://TIM")!) {
                     Label("right activity", systemImage: "phone").padding()
                 }.background(Color.accentColor)
                 .clipShape(RoundedRectangle(cornerRadius: 15))
            }

        } compactLeading: {
            // 左紧凑
            
        } compactTrailing: {
            // 右紧凑
            VoiceView(maxWidth:10,
                      voiceList: [0.0,
                                  Double.random(in: 0...1),
                                  Double.random(in: 0...1),
                                  Double.random(in: 0...1),
                                  Double.random(in: 0...1)])
            .frame(width:50.0)
        } minimal: {
            // 最小视图
            Image(systemName: context.state.avatar)
        }
    }
    
    func DynamicIslandView(context:ActivityViewContext<VJLiveActivityAttributes>) -> DynamicIsland {
        return DynamicIsland {
            // 扩展模式
            // 左侧
            DynamicIslandExpandedRegion(.leading) {
                VStack {
                    Label {
                        Text("勇士\n")
                    } icon: {}
                    .font(.system(.headline))
                    .frame(width: 80,height: 50)
                    Label {
                        Text("\(context.state.originScore) ")
                    } icon: {
                        Image(systemName: "football")
                    }
                    .font(.system(.headline))
                    .frame(width: 40,height: 30)
                }
            }
            // 右侧
            DynamicIslandExpandedRegion(.trailing) {
                VStack {
                    Label {
                        Text("湖人")
                    } icon: {}
                    .font(.system(.headline))
                    .frame(width: 60,height: 40)
                    
                    Label {
                        Text("\(context.state.Score) ")
                    } icon: {
                        Image(systemName: "football")
                    }
                    .font(.system(.headline))
                    .frame(width: 40,height: 30)
                }
            }
            // 灵动岛下 中心视图
            DynamicIslandExpandedRegion(.center) {
                // Deep Linking test
                 Link(destination: URL(string: "pizza://TIM")!) {
                     Label("left activity", systemImage: "phone").padding()
                 }.background(Color.accentColor)
                 .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            // 底部视图
            DynamicIslandExpandedRegion(.bottom) {
                Text("\(context.state.driverName) 比赛得分")
                    .lineLimit(1)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

        } compactLeading: {
            // 左紧凑
            VoiceView(maxWidth:10,
                      voiceList: [0.0,
                                  Double.random(in: 0...1),
                                  Double.random(in: 0...1),
                                  Double.random(in: 0...1),
                                  Double.random(in: 0...1)])
            .frame(width:50.0)
        } compactTrailing: {
            // 右紧凑

        } minimal: {
            // 最小视图

        }
    }
}


struct LockScreenView: View {
    
    let context: ActivityViewContext<VJLiveActivityAttributes>
    
    var body: some View {
        HStack {
            Image(systemName: context.state.avatar)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(5)
        }
        .activitySystemActionForegroundColor(.indigo)
        .activityBackgroundTint(.cyan)
    }
}


struct LockScreenView2: View {
    
    let context: ActivityViewContext<VJLiveActivityAttributes>
    
    var body: some View {
        // For devices that don't support the Dynamic Island.
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your \(context.state.driverName) is on the way!")
                        .font(.headline)
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.secondary)
                        HStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.blue)
                                .frame(width: 50)
                            Image(systemName: "shippingbox.circle.fill")
                                .foregroundColor(.white)
                                .padding(.leading, -25)
                            Image(systemName: "arrow.forward")
                                .foregroundColor(.white.opacity(0.5))
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white.opacity(0.5))
//                                    Text(timerInterval: context.state.timestamp, countsDown: true)
//                                        .bold()
//                                        .font(.caption)
//                                        .foregroundColor(.white.opacity(0.8))
//                                        .multilineTextAlignment(.center)
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white.opacity(0.5))
                            Image(systemName: "arrow.forward")
                                .foregroundColor(.white.opacity(0.5))
                            Image(systemName: "house.circle.fill")
                                .foregroundColor(.green)
                                .background(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                Spacer()
                VStack {
                    Text("\(context.state.numberOfPizzas) 🍕")
                        .font(.title)
                        .bold()
                    Spacer()
                }
            }.padding(5)
            Text("You've already paid: \(context.state.totalAmount) + $9.9 Delivery Fee 💸")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 5)
        }.padding(15)
    }
}
