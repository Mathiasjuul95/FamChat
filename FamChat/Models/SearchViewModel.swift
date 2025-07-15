//
//  SearchViewModel.swift
//  FamChat
//
//  Created by Mathias Juul on 09/07/2025.
//

import Foundation
import FirebaseAuth
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [UserProfile] = []

    private var cancellables = Set<AnyCancellable>()
    private let userService = UserService()
    private var currentUserID: String = ""
    private var famIDs: [String] = []

    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }

                if query.isEmpty {
                    self.searchResults = []
                    return
                }

                self.userService.searchUsers(query: query) { users in
                    DispatchQueue.main.async {
                        self.searchResults = users.filter {
                            $0.id != self.currentUserID && !self.famIDs.contains($0.id)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    func setCurrentUserID(_ id: String) {
        currentUserID = id
    }

    func setFamIDs(_ ids: [String]) {
        famIDs = ids
    }

    func removeUserFromResults(_ userID: String) {
        searchResults.removeAll(where: { $0.id == userID })
    }
}
