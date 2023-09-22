//
//  CustomCollectionViewCell.swift
//  bussin
//
//  Created by Rafał Gawlik on 19/12/2022.
//


import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"
    
    
    
    private let myLabel: UILabel = {
        let label = UILabel()
        //font
        let font = UIFont.boldSystemFont(ofSize: 20)
        //let font = UIFont.
        
        label.font = font
        label.textAlignment = .center
        
        
        return label
    }()
    
    var labelText: String? {
        didSet {
            myLabel.text = labelText
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        //label
        contentView.backgroundColor = .systemGray6
        //contentView.backgroundColor = .lightText
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1
        contentView.layer.masksToBounds = true
        //shadow
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
        
        
        
        contentView.addSubview(myLabel)
        contentView.clipsToBounds = true
        
        
        
    }
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        myLabel.frame = CGRect(x: 5,
                               y: 5,
                               width: contentView.frame.size.width-10,
                               height: 50)
    }
    public func configure(label: String){
        myLabel.text = label
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myLabel.text = nil
    }
    override var isSelected: Bool{
        didSet {
            contentView.backgroundColor = self.isSelected ? .systemBlue : .systemGray6
            myLabel.textColor = self.isSelected ? .white : UIColor.label //UIColor {tc in switch.UITraitCollection.userInterfaceStyle {case .dark: return UIColor.white
            //default:
              //  return UIColor.black
            //}}
            
        }
    }
}
