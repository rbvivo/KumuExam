//
//  MainTableViewController.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//

import UIKit

class MainTableViewController: UIViewController {
    
    private let searchController = UISearchController()
    
    private let viewModel: MainTableViewModel = MainTableViewModel(appDelegate: UIApplication.shared.delegate as? AppDelegate ?? AppDelegate())
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.registerCell(TrackTableViewCell.self)
        tableView.separatorColor = .separator
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black
        return activityIndicator
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    private func setupUI() {
        setupSearch()
        setupTableView()
        setupIndicator()
    }
    
    
    private func setupViewModel() {
        activityIndicator.startAnimating()
        viewModel.retrieveTracks()
        viewModel.fetchTracksCompleted = { [weak self] in
            //do something after fetch suceed
            guard let `self` = self else { return }
            self.viewModel.saveContextSuccessHandler = { [weak self] in
                guard let `self` = self else { return }
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
            self.viewModel.saveContext()
        }
        
        viewModel.fetchTracksFailedHandler = { [weak self] error in
            //do something after fetch failed
            guard let `self` = self else { return }
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
            let alertView = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    private func setupSearch() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.accessibilityIdentifier = "searchBar"
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        searchController.searchBar.returnKeyType = .done
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["All", "Favorites"]
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func setupIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
}

extension MainTableViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        if text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return
        }
        
        viewModel.isSearching = true
        viewModel.searchTracks(searchString: text)
        tableView.reloadData()
    }
}

extension MainTableViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isSearching = false
        viewModel.searchTracks(searchString: "")
        tableView.reloadData()
        searchBar.showsCancelButton = false
    }
    
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.text = ""
        if selectedScope == 1 {
            viewModel.fetchFavorites()
        }
        self.tableView.reloadData()
    }
}


extension MainTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            return viewModel.isSearching ? viewModel.searchList.count : viewModel.trackList.count
        } else {
            return viewModel.isSearching ? viewModel.searchList.count : viewModel.favoriteList.count
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //check if searching and in favorites
        var currentList: [Track]
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
             currentList = viewModel.isSearching ? viewModel.searchList : viewModel.trackList
        } else {
            currentList = viewModel.isSearching ? viewModel.searchList : viewModel.favoriteList
        }
        
        let cell: TrackTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configureCell(track: currentList[indexPath.row])
        return cell
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //check if searching and in favorites
        var currentList: [Track]
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
             currentList = viewModel.isSearching ? viewModel.searchList : viewModel.trackList
        } else {
            currentList = viewModel.isSearching ? viewModel.searchList : viewModel.favoriteList
        }
        let trackDetail = TrackDetailViewController(viewModel: TrackDetailViewModel(track: currentList[indexPath.row]))
        self.navigationController?.pushViewController(trackDetail, animated: true)
        
    }
}
