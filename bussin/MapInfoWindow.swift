//
//  MapInfoWindow.swift
//  bussin
//
//  Created by Rafał Gawlik on 22/12/2022.
//


import UIKit

class MapInfoWindow: UIView {

    static let identifier = "MapInfoWindow"
    
    
    
    private let lineLabel: UILabel = {
        let label = UILabel()
        //font
        let font = UIFont.boldSystemFont(ofSize: 40)
        //let font = UIFont.
        label.text = "custom"
        label.textColor = .label
        label.font = font
        label.textAlignment = .left
        
        
        return label
    }()
    
    
    private let kierunekLabel: UILabel = {
        let label = UILabel()
        //font
        let font = UIFont.boldSystemFont(ofSize: 18)
        //let font = UIFont.
        label.text = "custom"
        label.textColor = .label
        label.font = font
        label.textAlignment = .left
        
        
        return label
    }()

    
    private let opoznienieLabel: UILabel = {
        let label = UILabel()
        //font
        
        let font = UIFont.systemFont(ofSize: 15)
        //let font = UIFont.
        label.text = "jade z jakiegos miejsca"
        label.textColor = .label
        label.font = font
        label.textAlignment = .left
        
        
        return label
    }()
    
    private let doLabel: UILabel = {
        let label = UILabel()
        //font
        
        let font = UIFont.systemFont(ofSize: 15)
        //let font = UIFont.
        label.text = "jade z jakiegos miejsca"
        label.textColor = .label
        label.font = font
        label.textAlignment = .left
        
        
        return label
    }()
    
    
//    private let doLabel: UILabel = {
//        let label = UILabel()
//        //font
//        let font = UIFont.systemFont(ofSize: 20)
//        //let font = UIFont.
//        label.text = "jade do jakiegos miejsca"
//        label.textColor = .label
//        label.font = font
//        label.textAlignment = .left
//
//
//        return label
//    }()
    
    
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.backgroundColor = .systemBackground
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 45
        self.layer.borderWidth = 2
        self.layer.masksToBounds = true
        

        self.addSubview(lineLabel)
        self.addSubview(kierunekLabel)
        //self.addSubview(brygLabel)
//        self.addSubview(zLabel)
        self.addSubview(doLabel)
        self.addSubview(opoznienieLabel)
        self.clipsToBounds = true
    }
    
    override var isHidden: Bool{
        didSet{
            
        }
    }
    
    
    public func configure(lineLab: String?,kierunekLab: String? = "kierunek",opoznienieLab: String? = "0",doLab: String?){
        lineLabel.text = lineLab
        kierunekLabel.text = "\(String(describing: kierunekLab!))"
        opoznienieLabel.text = "\(String(describing: opoznienieLab!))"
        doLabel.text = "Nast.: \(doLab ?? "Brak")"

        if String(describing: opoznienieLab!).prefix(13) == "przyspieszony"{
            opoznienieLabel.textColor = UIColor.systemGreen
        }else if String(describing: opoznienieLab!).prefix(9) == "opóźniony"{
            opoznienieLabel.textColor = UIColor.systemRed
        }else {
            opoznienieLabel.textColor = .label
        }
    }
    
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        lineLabel.frame = CGRect(x: 40,
//                               y: 20,
//                               width: self.frame.size.width-10,
//                               height: 50)
//
//
//        kierunekLabel.font = UIFont.systemFont(ofSize: 20)
//        kierunekLabel.textColor = .label
//        while true{
//            let sizeThatFits = kierunekLabel.sizeThatFits(frame.size)
//            // If the size of the label is larger than the size of the view, decrease the font size
//            if sizeThatFits.width > frame.size.width || sizeThatFits.height > frame.size.height {
//                kierunekLabel.font = kierunekLabel.font.withSize(kierunekLabel.font.pointSize - 1)
//            } else {
//                // The label fits within the view, so break out of the loop
//                break
//            }
//
//
//        // Set the frame of the kierunekLabel label to the calculated size
//        kierunekLabel.frame = CGRect(origin: CGPoint(x: self.frame.size.width-260, y: 0), size: sizeThatFits)
//
//
//    }
//
//
//
////
////        doLabel.frame = CGRect(x: self.frame.size.width-240,
////                               y: 50,
////                               width: self.frame.size.width-10,
////                               height: 50)
//
//        opoznienieLabel.frame = CGRect(x:  self.frame.size.width-260,
//                                       y: 37.5,
//                                      width: self.frame.size.width-10,
//                                      height: 50)
//    }


    override func layoutSubviews() {
        super.layoutSubviews()
        
        lineLabel.frame = CGRect(x: 30,
                                 y: 20,
                                 width: 55,
                                 height: 55)
        
        kierunekLabel.frame = CGRect(x:  self.frame.size.width-270,
                                    y: 0,
                                    width: 260,
                                    height: 50)
        doLabel.frame = CGRect(x: self.frame.size.width-270,y: 34, width: 260, height: 25)

        opoznienieLabel.frame = CGRect(x:  self.frame.size.width-270,
                                       y: 55,
                                      width: 260,
                                      height: 25)
        }
    
    init(labelText: String){
        super.init(frame: .zero)
        
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

