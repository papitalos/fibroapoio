//
//  AtomListItem.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 19/04/2025.
//
import SwiftUI

struct AtomListItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    var subtitleDate: Date?
    let image: Image?
    let tag: String?
    let tagBackgroundColor: Color?
    let tagTextColor: Color?
    let imageBackground: Color?
    let actions: [(name: String, action: () -> Void)]
}

