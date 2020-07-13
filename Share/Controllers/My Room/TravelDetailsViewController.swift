//
//  TravelDetailsViewController.swift
//  Share
//
//  Created by Dominique Michael Abejar on 30/03/2019.
//  Copyright © 2019 Share. All rights reserved.
//

import UIKit

class TravelDetailsViewController: UIViewController {
    
    @IBOutlet weak var travelDetailsTableView: UITableView!

    var sections = ["Travel Location", "Travel Time/Fare", "Taxi Details"]
    
    var Orig = ""
    var Destin = ""
    var departureTime = ""
    var minFare = ""
    var maxFare = ""
    var taxiOperator = ""
    var taxiPlateNum = ""
    var taxiNum = ""
    var estimatedTime = ""
    
    override func viewDidLoad() {
        
        travelDetailsTableView.delegate = self
        travelDetailsTableView.dataSource = self
        travelDetailsTableView.backgroundColor = UIColor(hex: "#151515")
        travelDetailsTableView.tableFooterView = UIView()

        super.viewDidLoad()

    }

}

extension TravelDetailsViewController : UITableViewDataSource, UITableViewDelegate{
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if taxiOperator == ""{
            return sections.count - 1
        }else{
            return sections.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerFrame = tableView.frame
        let myLabel = UILabel()
        
        myLabel.frame = CGRect(x: 15, y: 20, width: headerFrame.size.width-20, height: 20)
        myLabel.font = UIFont.systemFont(ofSize: 12)
        myLabel.text = self.tableView(travelDetailsTableView, titleForHeaderInSection: section)
        myLabel.textColor = UIColor.lightGray
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.addSubview(myLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRow = 2
        
        if section == 2 || section == 1{
            numOfRow = 3
        }
        return numOfRow
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.travelDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! TravelDetailsTableViewCell
        
        
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                cell.originLabel.text = "Origin: " + Orig
                return cell
            case 1:
                cell.originLabel.text = "Destination: " + Destin
                return cell
            default:
                break
            }
        case 1:
            switch indexPath.row{
            case 0:
                cell.originLabel.text = "Departure Time: " + departureTime
                return cell
            case 1:
                cell.originLabel.text = "Estimated Travel Time: " + estimatedTime + " Minutes"
            case 2:
                cell.originLabel.text = "Fare: ₱ " + minFare + "-" + maxFare
                return cell
            default:
                break
            }
        case 2:
            switch indexPath.row{
            case 0:
                cell.originLabel.text = "Taxi Operator: " + taxiOperator
                return cell
            case 1:
                cell.originLabel.text = "Taxi Plate Number: " + taxiPlateNum
                return cell
            case 2:
                cell.originLabel.text = "Taxi Number: " + taxiNum
                return cell
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
    
    
}
