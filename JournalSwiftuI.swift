//
//  JournalSwiftuI.swift
//  Goshsha Capstone
//
//  Created by In4matx_inst on 11/12/24.
//

import SwiftUI

struct Journal: View{
    @State var fluidText: String = "Type Here"
    var body: some View{
        NavigationView{
            VStack{
                TextEditor(text: $fluidText)
            }
            .navigationTitle("GOSHSHA")
        }
    }
}
