//
//  IconPickerView.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import SwiftUI
import LocalizationHandler
import ChoreHandler

struct IconPickerView: View {
    @Binding var selectedIconId: String
    var onDismiss: () -> Void

    @Environment(\.presentationMode) private var presentationMode

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                // Icon grid - all icons in one batch
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(ChoreHandler.allIcons, id: \.id) { icon in
                        IconPickerItem(
                            icon: icon,
                            isSelected: selectedIconId == icon.id,
                            onSelect: {
                                selectedIconId = icon.id
                                presentationMode.wrappedValue.dismiss()
                                onDismiss()
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(LocalizationHandler.localize("chores.selectIcon"))
            .navigationBarItems(trailing: Button(LocalizationHandler.localize("common.cancel")) {
                presentationMode.wrappedValue.dismiss()
                onDismiss()
            })
        }
    }
}

struct IconPickerItem: View {
    let icon: ChoreIcon
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Image(systemName: icon.systemName)
                .font(.system(size: 30))
                .foregroundColor(isSelected ? .white : Color("AccentColor"))
                .frame(width: 60, height: 60)
                .background(isSelected ? Color("AccentColor") : Color("AccentColor").opacity(0.1))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color("AccentColor"), lineWidth: isSelected ? 3 : 0)
                )
                .padding(8)
        }
        .buttonStyle(PlainButtonStyle())
        .id(icon.id) // Ensure each item has a unique ID
    }
}

struct IconPickerView_Previews: PreviewProvider {
    static var previews: some View {
        IconPickerView(
            selectedIconId: .constant("dishes"),
            onDismiss: {}
        )
    }
}
