//
//  ChartView.swift
//  Cryptocurrency
//
//  Created by Deimante Valunaite on 20/11/2023.
//

import SwiftUI

enum ChartTimeRange: String, CaseIterable {
    case day1 = "1d"
    case week1 = "1w"
    case month1 = "1m"
    case month3 = "3m"
    case month6 = "6m"
    case year1 = "1y"
    case all = "All"
}

struct ChartView: View {
    @StateObject var viewModel: DetailViewModel
    @State private var percentage: CGFloat = 0
    @State private var selectedRange: ChartTimeRange = .week1
    
    private var data: [Double] {
        switch selectedRange {
        case .day1:
            return viewModel.dailyData.isEmpty ? viewModel.coin.sparklineIn7D?.price ?? [] : viewModel.dailyData
        case .week1:
            return viewModel.weeklyData.isEmpty ? viewModel.coin.sparklineIn7D?.price ?? [] : viewModel.weeklyData
        case .month1:
            return viewModel.monthlyData.isEmpty ? viewModel.coin.sparklineIn7D?.price ?? [] : viewModel.monthlyData
        case .month3:
            return viewModel.threeMonthData.isEmpty ? viewModel.coin.sparklineIn7D?.price ?? [] : viewModel.threeMonthData
        case .month6:
            let sixMonthData = viewModel.sixMonthData.isEmpty ? viewModel.coin.sparklineIn7D?.price ?? [] : viewModel.sixMonthData
            print("DEBUG: 6m data - isEmpty: \(viewModel.sixMonthData.isEmpty), count: \(sixMonthData.count)")
            return sixMonthData
        case .year1:
            return viewModel.yearlyData.isEmpty ? viewModel.coin.sparklineIn7D?.price ?? [] : viewModel.yearlyData
        case .all:
            return viewModel.allTimeData.isEmpty ? viewModel.coin.sparklineIn7D?.price ?? [] : viewModel.allTimeData
        }
    }
    
    private var maxY: Double {
        data.max() ?? 0
    }
    
    private var minY: Double {
        data.min() ?? 0
    }
    
    private var lineColor: Color {
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        return priceChange > 0 ? Color.theme.green : Color.theme.red
    }
    
    private var dateRange: (start: Date, end: Date) {
        let end = Date(coinGeckoString: viewModel.coin.lastUpdated ?? "") ?? Date()
        let start: Date
        switch selectedRange {
        case .day1:
            start = end.addingTimeInterval(-1*24*60*60)
        case .week1:
            start = end.addingTimeInterval(-7*24*60*60)
        case .month1:
            start = end.addingTimeInterval(-30*24*60*60)
        case .month3:
            start = end.addingTimeInterval(-90*24*60*60)
        case .month6:
            start = end.addingTimeInterval(-180*24*60*60)
        case .year1:
            start = end.addingTimeInterval(-365*24*60*60)
        case .all:
            start = end.addingTimeInterval(-3650*24*60*60) // ~10 years
        }
        return (start, end)
    }
    
    private var endingDate: Date {
        dateRange.end
    }
    
    private var startingDate: Date {
        dateRange.start
    }
    
    init(coin: Coin) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    var body: some View {
        VStack {            
            // Chart view
            chartView
                .frame(height: 200)
                .background(chartBackground)
                .overlay(chartYAxis.padding(.horizontal, 4), alignment: .leading)
            
            // Date labels
            chartDateLabels
                .padding(.horizontal, 4)
            
            // Time range selector
            HStack(spacing: 16) {
                ForEach(ChartTimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedRange = range
                        switch range {
                        case .day1:
                            Task {
                                await viewModel.loadDailyData()
                            }
                        case .week1:
                            Task {
                                await viewModel.loadWeeklyData()
                            }
                        case .month1:
                            Task {
                                await viewModel.loadMonthlyData()
                            }
                        case .month3:
                            Task {
                                await viewModel.loadThreeMonthData()
                            }
                        case .month6:
                            Task {
                                await viewModel.loadSixMonthData()
                            }
                        case .year1:
                            Task {
                                await viewModel.loadYearlyData()
                            }
                        case .all:
                            Task {
                                await viewModel.loadAllTimeData()
                            }
                        }
                    }) {
                        Text(range.rawValue)
                            .font(.caption)
                            .fontWeight(selectedRange == range ? .bold : .regular)
                            .foregroundColor(selectedRange == range ? .white : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedRange == range ? Color.blue : Color.gray.opacity(0.2))
                            )
                    }
                }
            }
            .padding(.top, 8)
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.linear(duration: 2.0)) {
                    percentage = 1.0
                }
            }
        }
    }
}

extension ChartView {
    private var chartView: some View {
        GeometryReader { geometry in
            Path { path in
                for index in data.indices {
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    let yAxis = maxY - minY
                    let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .shadow(color: lineColor, radius: 10, x: 0, y: 10)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x: 0, y: 20)
            .shadow(color: lineColor.opacity(0.2), radius: 10, x: 0, y: 30)
            .shadow(color: lineColor.opacity(0.1), radius: 10, x: 0, y: 40)
        }
    }
    
    private var chartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    private var chartYAxis: some View {
        VStack {
            Text(formatNumber(maxY))
            Spacer()
            Text(formatNumber((maxY + minY) / 2))
            Spacer()
            Text(formatNumber(minY))
        }
    }
    
    private var chartDateLabels: some View {
        HStack {
            Text(startingDate.asShortDateString())
            Spacer()
            Text(endingDate.asShortDateString())
        }
    }
    
    func formatNumber(_ number: Double) -> String {
        if number < 1000 {
            return "\(number.asCurrencyWith6Decimals())"
        } else if number < 1000000 {
            return String(format: "%.1fK", Double(number) / 1000)
        } else if number < 1000000000 {
            return String(format: "%.1fM", Double(number) / 1000000)
        } else {
            return String(format: "%.1fB", Double(number) / 1000000000)
        }
    }
}

// struct ChartView_Previews: PreviewProvider {
//     static var previews: some View {
//         ChartView(coin: dev.coin)
//     }
// }