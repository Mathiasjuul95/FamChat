//
//  RegisterView.swift
//  FamChat
//
//  Created by Mathias Juul on 07/07/2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var displayName = ""
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Fullt navn", text: $fullName)
                TextField("Displaynavn", text: $displayName)
                TextField("Email", text: $email)
                SecureField("Passord", text: $password)
                
                Button("Velg profilbilde") {
                    showImagePicker = true
                }
                
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                
                Button("Registrer") {
                    register()
                }
                .padding()
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
        }
        .navigationTitle("Registrer")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
        .alert("Feil", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    func register() {
        guard let image = profileImage else {
            errorMessage = "Vennligst velg et profilbilde."
            showError = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                storageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                        showError = true
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        guard let downloadURL = url else { return }
                        
                        // 🔤 Lag en keywords-array for søk
                        let nameLower = fullName.lowercased()
                        let emailLower = email.lowercased()
                        let keywords = [nameLower, emailLower]
                        
                        let db = Firestore.firestore()
                        db.collection("users").document(uid).setData([
                            "fullName": fullName,
                            "displayName": displayName,
                            "email": email,
                            "profileImageURL": downloadURL.absoluteString,
                            "keywords": keywords
                        ]) { error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                                showError = true
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}
