//
//  prayerTimeWidget.swift
//  prayerTimeWidget
//
//  Created by Anton Borries on 04.10.20.
//

import WidgetKit
import SwiftUI



private let widgetGroupId = "group.com.jafar.alQibla.Widget"    

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ExampleEntry {
        ExampleEntry(date: Date(), title: "Placeholder Title", message: "Placeholder Message",location:"",prayerTimes:["00:00","00:00","00:00","00:00","00:00"])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ExampleEntry) -> ()) {
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let entry = ExampleEntry(date: Date(), title: data?.string(forKey: "title") ?? "", message: data?.string(forKey: "message") ?? "",location: data?.string(forKey: "location") ?? "", prayerTimes: data?.array(forKey:"prayerTimes") as? [String] ?? ["00:00","00:00","00:00","00:00","00:00"])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}


struct ExampleEntry: TimelineEntry {
    let date: Date
    let title: String
    let message: String
    let location: String
    let prayerTimes: [String]
}


struct prayerTimeWidgetEntryView : View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName:widgetGroupId)
    
    @Environment(\.widgetFamily) var family: WidgetFamily
    var body: some View {
        
        switch family {
        case .systemSmall:
            VStack {
            
        HStack{
            Text(entry.title)
                .font(.title)
            Spacer()
        }
        
        .padding(.horizontal,15)

        
        HStack {

            Text(entry.message)
                .font(Font.custom("Arial", size: 40)).bold()
            Spacer()
        }

        .padding(.horizontal,15)
        
            
            HStack {
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15)
                    .foregroundColor(.green)
                Text(entry.location)
                    .font(Font.custom("Arial", size: 15)).widgetURL(URL(string: "homeWidgetExample://message?message=\(entry.message)&homeWidget"))
                Spacer()
            }
        
        .padding(.horizontal,15)
        .padding(.bottom,4)
        
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
        case .systemMedium:
            HStack {
                VStack {
            
        HStack{
            Text(entry.title)
                .font(.title)
            Spacer()
        }
        
        .padding(.horizontal,15)

        
        HStack {

            Text(entry.message)
                .font(Font.custom("Arial", size: 40)).bold()
            Spacer()
        }

        .padding(.horizontal,15)
        
            
            HStack {
                Image(systemName: "location")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15)
                    .foregroundColor(.green)
                Text(entry.location)
                    .font(Font.custom("Arial", size: 15)).widgetURL(URL(string: "homeWidgetExample://message?message=\(entry.message)&homeWidget"))
                Spacer()
            }
        
        .padding(.horizontal,15)
        .padding(.bottom,4)
        
    }
    HStack {
         VStack(alignment: .leading, spacing: 5) {
        Text("Fajr")
        Text("Dhuhr")
        Text("Asr")
        Text("Maghrib")
        Text("Isha")
    }
    Spacer()
     VStack ( spacing: 5){
        Text(entry.prayerTimes[0])
        Text(entry.prayerTimes[1])
        Text(entry.prayerTimes[2])
        Text(entry.prayerTimes[3])
        Text(entry.prayerTimes[4])
    }
    }.padding(.horizontal,15)
   
            }
        @unknown default:
            EmptyView()
        

       
    }
}
}

@main
struct prayerTimeWidget: Widget {
    let kind: String = "prayerTimeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            prayerTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall,.systemMedium])
    }
}

struct prayerTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        prayerTimeWidgetEntryView(entry: ExampleEntry(date: Date(), title: "Example Title", message: "Example Message",location:"",prayerTimes:["00:00","00:00","00:00","00:00","00:00"]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
