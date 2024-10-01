//
//  ContentView.swift
//  EventKitExample
//
//  Created by yjc on 10/1/24.
//

import SwiftUI

struct ContentView: View {
    @State private var date = Date()
    @State private var id = ""
    @State private var title: String = ""
    @State private var memo = ""
    @State private var showEventEdit = false
    
    var body: some View {
        List {
            DatePicker("date", selection: $date)
            TextField("id", text: $id)
            TextField("title", text: $title)
            TextField("memo", text: $memo)
            Button("Submit") {
                submit()
            }
        }
        .sheet(
            isPresented: $showEventEdit,
            onDismiss: {
                print("dismiss")
            },
            content: {
                
            })
    }
    
    private func submit() {
    }
}

#Preview {
    ContentView()
}
