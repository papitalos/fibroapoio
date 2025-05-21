//
//  GraphView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 19/04/2025.
//


import SwiftUI

struct GraphView: View {
    let data: [Int]
    let weekdays = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
    
    let primaryColor: Color
    let secondaryColor: Color
    let backgroundColor: Color
    
    init(
        data: [Int],
        primaryColor: Color,
        secondaryColor: Color,
        backgroundColor: Color
    ) {
        if data.count == 7 {
            self.data = data
        } else if data.count < 7 {
            self.data = data + Array(repeating: 0, count: 7 - data.count)
        } else {
            self.data = Array(data.prefix(7))
        }
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Atividade Física")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack(alignment: .bottom, spacing: 15) {
                ForEach(0..<7) { index in
                    let height = calculateHeight(for: data[index])
                    
                    VStack {
                        ZStack(alignment: .bottom) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 24, height: 100)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: index % 2 == 0
                                                ? [primaryColor, secondaryColor]
                                                : [secondaryColor, secondaryColor]
                                        ),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 24, height: height)
                        }
                        
                        Text(weekdays[index])
                            .font(.caption2)
                    }
                    .frame(width: 32, alignment: .center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
    
    private func calculateHeight(for value: Int) -> CGFloat {
        let normalizedValue = min(max(value, 0), 10)
        return CGFloat(40 + normalizedValue * 6)
    }
}

// Preview atualizada
struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(
            data: [3, 5, 8, 4, 7, 6, 9],
            primaryColor: .purple,
            secondaryColor: .blue,
            backgroundColor: Color.gray.opacity(0.1)
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
