//
//  DetailView.swift
//  Cryptocurrency
//
//  Created by Deimante Valunaite on 18/11/2023.
//

import SwiftUI
import Kingfisher

extension Notification.Name {
    static let chartPriceSelected = Notification.Name("chartPriceSelected")
}

struct DetailView: View {
    @StateObject var viewModel: DetailViewModel
    @State private var showFullDescription: Bool = false
    @State private var selectedPrice: Double? = nil
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    private let spacing: CGFloat = 30
    
    init(coin: Coin) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                ChartView(coin: viewModel.coin)
                    .padding(.vertical)
                
                VStack(spacing: 20) {
                    // Summary Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(getSummaryTitle())
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                        
                        // Price Movement Summary
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Price Movement")
                                .font(.headline)
                                .foregroundColor(Color.theme.secondaryText)
                            
                            Text("Bitcoin has shown strong momentum today, gaining 3.2% in the last 24 hours. The cryptocurrency broke through key resistance levels at $45,000, supported by increased institutional buying and positive market sentiment. Trading volume has increased by 25% compared to yesterday, indicating strong market participation.")
                                .font(.callout)
                                .foregroundColor(Color.theme.secondaryText)
                                .lineLimit(nil)
                        }
                        
                        // News Highlights
                        VStack(alignment: .leading, spacing: 8) {
                            // Text("News Highlights")
                            //     .font(.headline)
                            //     .foregroundColor(Color.theme.secondaryText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // News Card 1
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 24, height: 24)
                                            Text("Reuters")
                                                .font(.caption)
                                                .foregroundColor(Color.theme.secondaryText)
                                        }
                                        
                                        Text("SEC approves new Bitcoin ETF applications, boosting institutional adoption")
                                            .font(.callout)
                                            .foregroundColor(.primary)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text("2 hours ago")
                                            .font(.caption2)
                                            .foregroundColor(Color.theme.secondaryText)
                                    }
                                    .frame(width: 280, height: 120)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                    
                                    // News Card 2
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 24, height: 24)
                                            Text("Bloomberg")
                                                .font(.caption)
                                                .foregroundColor(Color.theme.secondaryText)
                                        }
                                        
                                        Text("Major banks announce cryptocurrency custody services for institutional clients")
                                            .font(.callout)
                                            .foregroundColor(.primary)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text("4 hours ago")
                                            .font(.caption2)
                                            .foregroundColor(Color.theme.secondaryText)
                                    }
                                    .frame(width: 280, height: 120)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                    
                                    // News Card 3
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Circle()
                                                .fill(Color.orange)
                                                .frame(width: 24, height: 24)
                                            Text("CNBC")
                                                .font(.caption)
                                                .foregroundColor(Color.theme.secondaryText)
                                        }
                                        
                                        Text("Global regulatory framework discussions gain momentum in G20 summit")
                                            .font(.callout)
                                            .foregroundColor(.primary)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text("6 hours ago")
                                            .font(.caption2)
                                            .foregroundColor(Color.theme.secondaryText)
                                    }
                                    .frame(width: 280, height: 120)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    
                    Text("Overview")
                        .font(.title)
                        .bold()
                        .foregroundColor(Color.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    
                    ZStack {
                        if let coinDescription = viewModel.coinDescription, !coinDescription.isEmpty {
                            VStack(alignment: .leading) {
                                Text(coinDescription)
                                    .lineLimit(showFullDescription ? nil : 3)
                                    .font(.callout)
                                    .foregroundColor(Color.theme.secondaryText)
                                
                                Button(action: {
                                    withAnimation(.easeOut) {
                                        showFullDescription.toggle()
                                    }
                                }, label: {
                                    Text(showFullDescription ? "Less" : "Read more...")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.vertical, 4)
                                })
                                .accentColor(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    LazyVGrid(
                        columns: columns,
                        alignment: .leading,
                        spacing: spacing,
                        pinnedViews: [],
                        content: {
                            ForEach(viewModel.overviewStatistics) { stat in
                                StatisticView(stat: stat)
                            }
                        })
                    
                    Text("Aditional Details")
                        .font(.title)
                        .bold()
                        .foregroundColor(Color.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    
                    LazyVGrid(
                        columns: columns,
                        alignment: .leading,
                        spacing: spacing,
                        pinnedViews: [],
                        content: {
                            ForEach(viewModel.additionalStatistics) { stat in
                                StatisticView(stat: stat)
                                
                            }
                        })
                    
                    VStack(alignment: .leading, spacing: 20) {
                        if let websiteString = viewModel.websiteURL, let url = URL(string: websiteString) {
                            Link("Website", destination: url)
                        }
                        
                        if let reddittring = viewModel.redditURL, let url = URL(string: reddittring) {
                            Link("Reddit", destination: url)
                        }
                    }
                    .accentColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                }
                .padding()
            }
            
        }
        .navigationTitle(selectedPrice != nil ? "$\(selectedPrice!.asCurrencyWith6Decimals())" : "$\(viewModel.coin.currentPrice.asCurrencyWith6Decimals())")
        .onReceive(NotificationCenter.default.publisher(for: .chartPriceSelected)) { notification in
            if let price = notification.object as? Double {
                selectedPrice = price
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                        Text(viewModel.coin.symbol.uppercased())
                            .font(.headline)
                            .foregroundColor(Color.theme.secondaryText)
                    KFImage(viewModel.coin.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
            }
        }
    }
    
    private func getSummaryTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(currentDate) {
            return "Today's Summary"
        } else {
            return formatter.string(from: currentDate)
        }
    }
}
