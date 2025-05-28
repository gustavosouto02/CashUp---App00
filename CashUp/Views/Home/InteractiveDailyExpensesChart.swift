//
//  InteractiveDailyExpensesChart.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 27/05/25.
//

import SwiftUI
import Charts

struct InteractiveDailyExpensesChart: View {
    let dailyData: [DailyExpenseItem]
    
    @State private var selectedDate: Date? = nil
    @State private var deselectionTask: Task<Void, Never>? = nil

    // Define a cor azul de destaque para a barra selecionada
    let selectedBarBlue = Color(red: 0.1, green: 0.45, blue: 1.0) // Um azul vibrante

    var body: some View {
        Chart {
            ForEach(dailyData) { item in
                BarMark(
                    x: .value("Dia", item.date, unit: .day),
                    y: .value("Gasto", item.totalExpenses)
                )
                .foregroundStyle(barColor(for: item))
                .cornerRadius(4)

                if let currentSelectedDate = selectedDate, Calendar.current.isDate(item.date, inSameDayAs: currentSelectedDate) {
                    RuleMark(x: .value("Selected Day", currentSelectedDate))
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .zIndex(-1)
                        .annotation(position: .top, alignment: .center, spacing: 0) {
                            if item.totalExpenses > 0 || Calendar.current.isDate(item.date, inSameDayAs: Date()) {
                                valueAnnotation(for: item)
                            }
                        }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: calculateXAxisStride())) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day(.defaultDigits), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(preset: .automatic, values: .automatic(desiredCount: 4)) { value in
                 AxisGridLine()
                 AxisValueLabel()
             }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                deselectionTask?.cancel()
                                
                                // Use plotFrame (iOS 17+) safely
                                guard let plotFrame = proxy.plotFrame else {
                                    // Se plotFrame for nil, não podemos calcular a origem.
                                    // Podemos limpar a seleção ou não fazer nada.
                                    self.selectedDate = nil
                                    return
                                }
                                let origin = geometry[plotFrame].origin
                                
                                let location = CGPoint(
                                    x: value.location.x - origin.x,
                                    y: value.location.y - origin.y
                                )

                                if let interpolatedDate: Date = proxy.value(atX: location.x, as: Date.self) {
                                    let calendar = Calendar.current
                                    if let nearestDataPoint = dailyData.min(by: { abs($0.date.timeIntervalSince(interpolatedDate)) < abs($1.date.timeIntervalSince(interpolatedDate)) }) {
                                        if calendar.isDate(nearestDataPoint.date, inSameDayAs: interpolatedDate) || dailyData.count == 1 {
                                            self.selectedDate = nearestDataPoint.date
                                        } else {
                                            if let closestDateOnSameDay = dailyData.first(where: {calendar.isDate($0.date, inSameDayAs: interpolatedDate)})?.date {
                                                self.selectedDate = closestDateOnSameDay
                                            } else {
                                                if abs(nearestDataPoint.date.timeIntervalSince(interpolatedDate)) < (12 * 60 * 60) { // 12 horas
                                                    self.selectedDate = nearestDataPoint.date
                                                } else {
                                                    self.selectedDate = nil
                                                }
                                            }
                                        }
                                    } else {
                                        self.selectedDate = nil
                                    }
                                } else {
                                    self.selectedDate = nil
                                }
                            }
                            .onEnded { _ in
                                if self.selectedDate != nil {
                                    deselectionTask?.cancel()
                                    deselectionTask = Task {
                                        do {
                                            try await Task.sleep(for: .seconds(3))
                                            if !Task.isCancelled {
                                                self.selectedDate = nil
                                            }
                                        } catch {
                                            if !(error is CancellationError) {
                                                print("Deselection timer error: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                    )
            }
        }
    }

    private func barColor(for item: DailyExpenseItem) -> Color {
        if let currentSelectedDate = selectedDate, Calendar.current.isDate(item.date, inSameDayAs: currentSelectedDate) {
            // Barra selecionada: Um azul vibrante e totalmente opaco.
            return selectedBarBlue
        }
        // Barra de "hoje": accentColor com alta opacidade.
        // Outras barras: accentColor com opacidade ainda significativa.
        return item.isToday ? Color.accentColor.opacity(0.9) : Color.accentColor.opacity(0.7)
    }

    @ViewBuilder
    private func valueAnnotation(for item: DailyExpenseItem) -> some View {
        VStack(spacing: 2) {
            Text(item.totalExpenses, format: .currency(code: "BRL").precision(.fractionLength(item.totalExpenses == 0 ? 0 : 2)))
                .font(.caption.weight(.bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.thinMaterial, in: Capsule())
        .shadow(radius: 1)
        .offset(y: item.totalExpenses > 0 ? -5 : -15)
    }
    
    private func calculateXAxisStride() -> Int {
        let count = dailyData.count
        if count == 0 { return 1}
        if count <= 7 {
            return 1
        } else if count <= 15 {
            return 2
        } else if count <= 21 {
            return 3
        }
        return 5
    }
}
