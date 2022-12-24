//
//  LinesVC.swift
//  bussin
//
//  Created by Rafał Gawlik on 19/12/2022.
//

import Foundation
import UIKit

class LinesVC: UIViewController {
    // MARK: - Properties
    struct RouteModel: Decodable{
        let route_id : String
    }
    //var lines = [RouteModel]()
    var defaultLines: [String] = UserDefaults.standard.object(forKey: "selectedLines") as? [String] ?? ["1"]
    let label = UILabel()
    var selectLinesCV: UICollectionView?
    
    var routesManager = RoutesManager()
    lazy var lines = [String]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Wybrano: \(defaultLines.joined(separator: ", "))"
        label.textAlignment = .center
        label.clipsToBounds = false
        label.backgroundColor = .systemBackground
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 2
        


        //automaticallyAdjustsScrollViewInsets = false
        //contentInsetAdjustmentBehavior = false

        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing=10
        layout.minimumInteritemSpacing=1
        layout.sectionInset = UIEdgeInsets(top: 150, left: 10, bottom: 100, right: 10)
        layout.itemSize = CGSize(width: (view.frame.size.width/3)-12.5, height: 60)
        selectLinesCV = UICollectionView(frame: .zero,collectionViewLayout: layout)
        
        guard let selectLinesCV = selectLinesCV else {
            return
        }
        
        
        selectLinesCV.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        
        selectLinesCV.delegate = self
        selectLinesCV.dataSource = self
        
        view.addSubview(selectLinesCV)
        view.addSubview(label)
        
        let topConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 40)
        let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
        heightConstraint.constant = 60
        view.addConstraint(heightConstraint)
        view.addConstraint(topConstraint)

       NSLayoutConstraint.activate([
           label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
           label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           //label.heightAnchor.constraint(equalToConstant: 40)
       ])
        //view.addSubview(label)

        selectLinesCV.frame = view.frame
        selectLinesCV.contentInsetAdjustmentBehavior = .never

        selectLinesCV.allowsMultipleSelection = true
        routesManager.delegate = self
        routesManager.fetchRoutes()
        
        DispatchQueue.main.async {
            selectLinesCV.reloadData()

        }
        //getLineData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomOffset: CGFloat = (tabBarController?.tabBar.frame.height)!
        selectLinesCV?.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: bottomOffset,right: 0)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func contentSizeCategoryDidChange(_ notification: Notification) {
        label.font = UIFont.preferredFont(forTextStyle: .title1)
    }

}
extension LinesVC: RoutesManagerDelegate {
    func didSendRoutesData(_ routesManager: RoutesManager, with routez: [String]) {
        self.lines.append(contentsOf: routez)
        DispatchQueue.main.async {
            self.selectLinesCV?.reloadData()
            //print(self.lines.count)
        }
    
    }
}
    
// MARK: - UICollectionViewDataSource
extension LinesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lines.count
    }


    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        
        if ([lines[indexPath.row]] == defaultLines.filter {$0 == lines[indexPath.row]}) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        }
        cell.labelText = lines[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if ([lines[indexPath.row]] == defaultLines.filter {$0 == lines[indexPath.row]}) {
            cell.isSelected = true
            cell.contentView.backgroundColor = .systemBlue
            
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let line = collectionView.cellForItem(at: indexPath)
        defaultLines.append(lines[indexPath.row])
        label.text = "Wybrano: \(defaultLines.joined(separator: ", "))"
        UserDefaults.standard.set(defaultLines, forKey: "selectedLines")
        line?.layer.borderColor = UIColor.red.cgColor
        line?.isSelected = true
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        defaultLines = defaultLines.filter {$0 != lines[indexPath.row]}
        label.text = "Wybrano: \(defaultLines.joined(separator: ", "))"

        UserDefaults.standard.set(defaultLines, forKey: "selectedLines")

      

        cell?.layer.borderColor = UIColor.black.cgColor
        cell?.isSelected = false
    }
}
