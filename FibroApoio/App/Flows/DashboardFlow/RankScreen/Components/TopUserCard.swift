//
//  TopUserCard.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/04/2025.
//
import SwiftUI

struct TopUserCard: View {
    var item: RankingItem
    let userName: String
    
    init(item: RankingItem,userName:String){
        self.item = item
        self.userName = userName
    }

    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.green.opacity(0.2)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(userName)
                    .font(.headline)
                    .foregroundColor(.black)
                HStack(spacing: 4) {
                    Text("Posição atual:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("#\(item.position ?? 999999)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            VStack {
                Text(item.rankName.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.brown.opacity(0.2))
                    .foregroundColor(.brown)
                    .cornerRadius(8)
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                    Text("\(item.pontuacao)")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
