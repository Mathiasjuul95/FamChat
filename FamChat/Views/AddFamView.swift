//
//  AddFamView.swift
//  FamChat
//
//  Created by Mathias Juul on 08/07/2025.
//
import SwiftUI
import FirebaseAuth
import CoreImage.CIFilterBuiltins
import Combine

struct AddFamView: View {
    @State private var famIDs: [String] = []
    @State private var isScanningQR = false
    @State private var scannedUser: UserProfile?
    @State private var showConfirmation = false
    @State private var currentUserID = ""
    @State private var currentUserEmail = ""
    @StateObject private var viewModel = SearchViewModel()

    private let userService = UserService()
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    // 🎯 QR-kodegenerator
    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg).resized(to: CGSize(width: 300, height: 300))
            }
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Legg til Fam")
                    .font(.title)

                // 🔍 Søkefelt
                VStack(alignment: .leading) {
                    Text("Søk etter navn eller e-post")
                        .font(.headline)
                    TextField("Skriv inn navn eller e-post", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, 4)
                }

                // 🧍 Søkeresultater
                if !viewModel.searchResults.isEmpty {
                    ForEach(viewModel.searchResults) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Legg til") {
                                userService.addFamMember(for: currentUserID, famUserID: user.id) { error in
                                    if let error = error {
                                        print("Feil ved lagring: \(error.localizedDescription)")
                                    } else {
                                        showConfirmation = true
                                        fetchFamIDs()
                                        viewModel.removeUserFromResults(user.id)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Divider()

                // 📤 Din QR-kode
                VStack(spacing: 8) {
                    Text("Din QR-kode")
                        .font(.headline)

                    if let qrImage = generateQRCode(from: currentUserID) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 200, height: 200)
                    }

                    Text(currentUserEmail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // 📷 Skann QR-kode
                Button {
                    isScanningQR = true
                } label: {
                    Label("Skann en QR-kode", systemImage: "qrcode.viewfinder")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }

                // 🎯 Resultat av skanning
                if let user = scannedUser {
                    VStack(spacing: 8) {
                        Text("Fant bruker:")
                            .font(.headline)
                        Text("Navn: \(user.name)")
                        Text("E-post: \(user.email)")
                        Button("Legg til Fam") {
                            userService.addFamMember(for: currentUserID, famUserID: user.id) { error in
                                if let error = error {
                                    print("Feil ved lagring: \(error.localizedDescription)")
                                } else {
                                    showConfirmation = true
                                    scannedUser = nil
                                    fetchFamIDs()
                                }
                            }
                        }
                        .foregroundColor(.green)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .sheet(isPresented: $isScanningQR) {
            QRScannerView { code in
                isScanningQR = false
                userService.fetchUser(uid: code) { profile in
                    if let profile = profile {
                        scannedUser = profile
                    } else {
                        print("Fant ikke bruker med UID: \(code)")
                    }
                }
            }
        }
        .alert("Fam lagt til!", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                currentUserID = user.uid
                currentUserEmail = user.email ?? "ukjent@bruker.no"
                viewModel.setCurrentUserID(user.uid)
                fetchFamIDs()
            }
        }
    }

    // 🔄 Hent eksisterende Fam-medlemmer
    func fetchFamIDs() {
        userService.fetchFamMembers(for: currentUserID) { ids in
            DispatchQueue.main.async {
                famIDs = ids
                viewModel.setFamIDs(ids)
            }
        }
    }
}

