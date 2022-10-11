//
//  MyWidget.swift
//  MyWidget
//
//  Created by wanglixia05 on 2022/6/17.
//

import WidgetKit
import SwiftUI
import Intents

// 为小组件展示提供一切必要信息的结构体
struct Provider: IntentTimelineProvider {
    // 占位视图, 例如网络请求失败、发生未知错误、第一次展示小组件都会展示这个view
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }
    // 快照 编辑屏幕在左上角选择添加Widget  第一次展示时会调用该方法
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    // 生成一个事件线，更新数据&&进行数据的预处理，转化成Entry
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        var currentDate = Date()
        let oneMinute: TimeInterval = 60
        let entry = SimpleEntry(date: currentDate, configuration: configuration)
        entries.append(entry)
        currentDate += oneMinute
        let timeline = Timeline(entries: entries, policy: .after(currentDate))
        completion(timeline)
    }
}
// 渲染 Widget 所需的数据模型
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}
// widget 展示视图
struct MyWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family // 尺寸环境变量
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground() // 注意需要配合zStack
            //            switch widgetRenderingMode {
            //            case .fullColor: // 小组件
            //            case .vibrant: // 锁屏小组件
            //            case .accented:  // 只支持watch os
            //                 ZStack{ }   .widgetAccentable(true)
            //            default:
            //            }
            // 📢📢📢📢注意： 目前Widget中暂时不支持list视图
            switch family {
            case.accessoryCircular:
                Text("\(widgetRenderingMode.description)")
            case .accessoryRectangular, .systemSmall:
                HStack {
                    VStack {
                            Text("Rectangular")
                                .font(.system(size: 14))
                            Text("\(widgetRenderingMode.description)")
                                .foregroundColor(.blue)
                                .font(.system(size: 13))
//                        }
                    }
                    
                    Image("test")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .aspectRatio(contentMode: .fit)

                        
                    //                        .privacySensitive() // 私密设置
                }
            case .accessoryInline:
                ViewThatFits {
                    VStack {
                        Text("\(widgetRenderingMode.description)🐱\(entry.date, style: .timer)")
                    }
                }
            default:
                Text(entry.date, style: .timer)
                    .padding()
                    .foregroundColor(.green)
            }
        }
    }
}
@main
// widget
struct MyWidget: Widget {
    let kind: String = "MyWidget" // widget标识位
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget") // 添加组件时组件title
        .description("This is an example widget.") // 添加组件时组件描述
        // supportedFamilies 设置Widget支持的控件大小, 默认全部支持
#if os(watchOS)
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline])
#else
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
#endif
    }
}
// widget 预览视图
struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
            
            MyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")
        }
    }
}

