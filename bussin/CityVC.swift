//
//  CityVC.swift
//  bussin
//
//  Created by Rafał Gawlik on 19/12/2022.
//

import Foundation
import UIKit


class CityVC: UIViewController {
    // MARK: - Properties
    let cities = ["Szczecin", "Gdansk", "Krakow", "Lodz", "Wroclaw", "Poznan"]
    let tableView = UITableView()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    // MARK: - Setup
    func setupTableView() {
        tableView.frame = view.frame
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource
extension CityVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cities[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate
extension CityVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = cities[indexPath.row]
        UserDefaults.standard.set(city, forKey: "selectedCity")
        navigationController?.popViewController(animated: true)
    }
}
