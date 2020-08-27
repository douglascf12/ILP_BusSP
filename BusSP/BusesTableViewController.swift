//
//  BusesTableViewController.swift
//  BusSP
//
//  Created by Douglas Cardoso Ferreira on 16/07/20.
//  Copyright © 2020 Douglas Cardoso. All rights reserved.
//

import UIKit

class BusesTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var buses: [Bus] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.placeholder = "Prefixo ou nome da linha"
        navigationItem.searchController = searchController

        searchController.searchBar.delegate = self
        
        loadBuses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! MapViewController
        vc.bus = buses[tableView.indexPathForSelectedRow!.row]
    }
    
    func loadBuses(_ termosBusca: String = " ") {
        SPTransOlhoVivo.autenticar { (response) in
            SPTransOlhoVivo.buscarLinhas(termosBusca, onComplete: { (buses) in
                self.buses = buses
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }) { (error) in
                print(error)
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BusTableViewCell
        let bus = buses[indexPath.row]
        cell.lbCarPrefix.text = "\(bus.lt)-\(bus.tl)"
        cell.lbNameLine.text = bus.sl == 1 ? "DE: \(bus.ts)\nPARA: \(bus.tp)" : "DE: \(bus.tp)\nPARA: \(bus.ts)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busSelected = buses[indexPath.row]
        performSegue(withIdentifier: "mapSegue", sender: busSelected)
    }

}

extension BusesTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadBuses("")
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadBuses(searchBar.text!)
        tableView.reloadData()
    }
}
