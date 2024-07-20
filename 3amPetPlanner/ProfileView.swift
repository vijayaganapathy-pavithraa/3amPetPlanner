//
//  profileView.swift
//  petPlanner
//
//  Created by Vijayaganapathy Pavithraa on 13/7/24.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @State private var isShowingSheet = false
    
    var age = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    @AppStorage("selectedAge") private var selectedAge = 5
    
    var gender = ["Male", "Female"]
    @AppStorage("selectedGender") private var selectedGender = "Male"
    
    @AppStorage("petName") private var petName: String = ""
    @State var birthday = Date()
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var shouldPresentPhotoPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack{
                        VStack {
                            Button(action: {
                                shouldPresentPhotoPicker = true;
                            }, label: {
                                if(avatarImage == nil) {
                                    Image(systemName: "pawprint.circle").font(.system(size: 60, weight: .medium))
                                } else {
                                    avatarImage?
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(40)
                                    
                                }
                            })
                            .photosPicker(isPresented: $shouldPresentPhotoPicker,
                                          selection: $avatarItem)                    }.onChange(of: avatarItem) {
                                Task {
                                    if let loaded = try? await avatarItem?.loadTransferable(type: Image.self) {
                                        avatarImage = loaded
                                    } else {
                                        print("Failed")
                                    }
                                }
                            }
                        
                        VStack {
                            Text(petName)
                                .font(.title)
                                .frame(maxWidth: .infinity,
                                       alignment: .leading)
                        }
                    }.listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                Section{
                    VStack(alignment: .leading){
                        Text("Age")
                        Text("\(selectedAge) years old")
                            .font(.title2)
                    }
                    VStack(alignment: .leading){
                        Text("Gender")
                        Text("\(selectedGender)")
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading){
                        Text("Birthday")
                        Text("\(birthday.formatted(date: .long, time: .omitted))")
                            .font(.title2)
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Edit") {
                        isShowingSheet.toggle()
                    }
                    .sheet(isPresented: $isShowingSheet,
                           onDismiss: didDismiss) {
                        VStack{
                            Text("Edit Pet")
                                .font(.title)
                                .padding()
                            Form{
                                HStack{
                                    Text("Pet name")
                                        .padding()
                                    TextField("Pet name", text: $petName)
                                        .padding()
                                }
                                .cornerRadius(12)
                                
                                HStack{
                                    Picker("Gender", selection: $selectedGender) {
                                        ForEach(gender, id: \.self) { gender in
                                            Text("\(gender)")
                                        }
                                    }
                                    .padding()
                                }                                .cornerRadius(12)
                                
                                HStack{
                                    Picker("Age", selection: $selectedAge) {
                                        ForEach(age, id: \.self) { age in
                                            Text("\(age)")
                                        }
                                    }
                                    .padding()
                                }
                                .cornerRadius(12)
                                
                                HStack{
                                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                                        .padding()
                                }
                                .cornerRadius(12)
                                
                                Button{
                                    isShowingSheet.toggle()
                                }label: {
                                    Text("Save Changes")
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                                
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }
}
func didDismiss() {
    // dismisses the sheet
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

#Preview {
    ProfileView()
}
