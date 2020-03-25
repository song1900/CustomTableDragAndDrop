//
//  ViewController.swift
//  TableDragAndDrop
//
//  Created by WooJin Song on 2020/03/25.
//  Copyright © 2020 viewmotion. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {

    var tableView = UITableView()
    var numbers = ["1","2","3","4","5","6","7","8","9","0"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.frame = CGRect(x: 0, y: 60, width: 150, height: 400)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCalled(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    func snapshotOfCell(_ inputView: UIView) -> UIView {
            UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
            inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
            UIGraphicsEndImageContext()
            
            let cellSnapshot: UIView = UIImageView(image: image)
            cellSnapshot.layer.masksToBounds = false
            cellSnapshot.layer.cornerRadius = 0.0
            cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
            cellSnapshot.layer.shadowRadius = 5.0
            cellSnapshot.layer.shadowOpacity = 0.4
            return cellSnapshot
        }
        
        @objc func longPressCalled(_ longPress: UILongPressGestureRecognizer) {
            print("longPressCalled")
            
            // 누른 위치의 indexPath
            let locationInView = longPress.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: locationInView)
            
            // 스냅샷과 최초 indexPath 변수
            struct My {
                static var cellSnapshot: UIView?
            }
            
            struct Path {
                static var initialIndexPath: IndexPath?
            }
            
            switch longPress.state {
            case UIGestureRecognizer.State.began:
                print("began")
                
                // 최초 indexPath 설정 및 스냅샷 찍기
                guard let indexPath = indexPath else { return }
                guard let cell = tableView.cellForRow(at: indexPath) else { return }
                Path.initialIndexPath = indexPath
                My.cellSnapshot = snapshotOfCell(cell)
                
                // 스냅샷의 센터지점 설정하고 테이블에 추가
                var center = cell.center
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                
                // 스냅샷 나타남 및 원래 셀 사라짐 애니메이션 효과
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = locationInView.y
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    
                }) { (finished) in
                    if finished {
                        cell.isHidden = true
                    }
                }
                
            case UIGestureRecognizer.State.changed:
                print("changed")
                
                // 위아래로 스냅샷을 끌고 갈 때마다 스냅샷의 y축 위치 변화시켜 같이 움직이도록 함
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                // 최초 indexPath가 아닌 다른 indexPath로 이동한 경우 데이터와 테이블뷰 모두 업데이트함
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    numbers.swapAt(indexPath!.row, Path.initialIndexPath!.row)
                    tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    Path.initialIndexPath = indexPath
                }
                
            default:
                print("finished")
                
                // 손가락을 떼면 이동한 indexPath에 셀이 나타나는 애니메이션 준비
                guard let cell = tableView.cellForRow(at: Path.initialIndexPath!) else { return }
                cell.isHidden = false
                cell.alpha = 0.0
                
                // 스냅샷 사라짐 및 셀 나타내는 애니메이션
                UIView.animate(withDuration: 0.25, animations: {
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                    
                }) { (finished) in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                }
                
            }
            
            
        }
        


}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = self.numbers[indexPath.row]
        
        return cell
    }
    

    
   
}
