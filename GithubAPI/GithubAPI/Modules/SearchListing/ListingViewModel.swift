//
//  ListingViewModel.swift
//  GithubAPI
//
//  Created by Emre Alpago on 29.09.2024.
//

import Foundation

protocol ListingViewModelInterface {
    var view: ListingViewInterface? { get set }
    var numberOfRowsInSection: Int { get }

    func viewDidLoad()
    func beginPagination(user: String, page: Int)
    func changeUI()
    func sortByStar()
    func sortByCreatedDate()
    func sortByUpdatedDate()
    func collectionViewLayout(width: CGFloat, minimumSpacing: CGFloat, columns: Int) -> CGSize
    func cellForItem(at item: Int) -> String
}

final class ListingViewModel {
    weak var view: ListingViewInterface?
    private var repos: [GitHubRepo] = []
    var sortedRepos: [GitHubRepo] = []
    private var itemsPerRow = 1

    private func getRepos(user: String, page: Int) {
        ReposStoreManager.shared.fetchRepos(user: user, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let repos):
                DispatchQueue.main.async {
                    self.repos = repos
                    self.view?.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError(title: "Error", message: error.localizedDescription, buttonTitle: "OK", completion: {
                        self.view?.popToRoot()
                    })
                }
            }
        }
    }}

extension ListingViewModel: ListingViewModelInterface {
    func cellForItem(at item: Int) -> String {
        guard let name = repos[item].name else { return "" }
        return name
    }
    
    func collectionViewLayout(width: CGFloat, minimumSpacing: CGFloat, columns: Int) -> CGSize {
        let spaceBetweenCells = minimumSpacing * (CGFloat(columns) - 1)
        let adjustedWidth = width - spaceBetweenCells
        let width: CGFloat = adjustedWidth / CGFloat(columns)
        let height: CGFloat = width * 2
        return CGSize(width: width, height: height)
    }
    
    func changeUI() {
        itemsPerRow = itemsPerRow >= 3 ? 1 : itemsPerRow + 1
        self.view?.setupCollectionViewLayout(itemsPerRow: itemsPerRow)
        self.view?.scrollToItem()
        self.view?.reloadData()
    }
    
    var numberOfRowsInSection: Int {
        repos.count
    }

    func viewDidLoad() {
        self.view?.prepareTableView()
        self.view?.setupCollectionViewLayout(itemsPerRow: 1)
        self.getRepos(user: view?.userName ?? "", page: 1)
    }

    func sortByStar() {}
    
    func sortByCreatedDate() {}
    
    func sortByUpdatedDate() {}

    func beginPagination(user: String, page: Int) {
        self.getRepos(user: view?.userName ?? "", page: 1)
    }
}
