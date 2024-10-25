//
//  DirectoryTableViewController.swift
//  FileManager
//
//  Created by 전율 on 10/25/24.
//

import UIKit

class DirectoryTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var currentDirectoryUrl: URL?
    var contents = [Content]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentDirectoryUrl == nil {
            currentDirectoryUrl = URL(fileURLWithPath: NSHomeDirectory())
        }
        setupMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContents()
        updateNavigationTitle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DirectoryTableViewController {
                vc.currentDirectoryUrl = contents[indexPath.row].url
            }
        }
    }
    
    // true를 반환하면 segue 실행
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "directorySegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                
                do {
                    let url = contents[indexPath.row].url
                    let reachable = try url.checkResourceIsReachable() // url에 파일이나 디렉토리가 있는지 확인
                    if !reachable {
                        return false
                    }
                } catch {
                    print(error)
                    return false
                }
                return contents[indexPath.row].type == .directory
            }
        }
        return true
    }
    
    func setupMenu() {
        menuButton.menu = UIMenu(children: [
            UIAction(title: "새 디렉토리",image: UIImage(systemName: "folder"), handler: { _ in
                self.showNameInputAlert()
            }),
            UIAction(title: "새 텍스트 파일",image: UIImage(systemName: "doc.text"), handler: { _ in
                self.addTextFile()
            }),
            UIAction(title: "새 이미지 파일",image: UIImage(systemName: "photo"), handler: { _ in
                
            }),
        ])
    }
    
    func showNameInputAlert() {
        let inputAlert  = UIAlertController(title: "새 디렉토리", message: nil, preferredStyle: .alert)
        inputAlert.addTextField { nameField in
            nameField.placeholder = "디렉토리 명을 입력해주세요."
            nameField.clearButtonMode = .whileEditing
            nameField.autocapitalizationType = .none
            nameField.autocorrectionType = .no
        }
        let createAction = UIAlertAction(title: "추가", style: .default) { _ in
            if let name = inputAlert.textFields?.first?.text {
                self.addDirectory(named: name)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        inputAlert.addAction(createAction)
        inputAlert.addAction(cancelAction)
        present(inputAlert, animated: true)
        
    }
    
    func addDirectory(named: String) {
        // appendingPathComponent: URL 마지막에 새로운 경로를 추가해서 리턴
        guard let url = currentDirectoryUrl?.appendingPathComponent(named, isDirectory: true) else { return }
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil )
        } catch {
            print(error)
        }
        refreshContents()
    }
    
    func addTextFile() {
        let content = Date.now.description
        guard let targetUrl = currentDirectoryUrl?.appendingPathComponent("current-time").appendingPathExtension("txt") else { return }
        do {
            try content.write(to: targetUrl, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
        refreshContents()
    }
    
    func updateNavigationTitle(){
        guard let url = currentDirectoryUrl else {
            self.navigationItem.title = "?"
            return
        }
        
        do {
            let values = try url.resourceValues(forKeys: [.localizedNameKey])
            self.navigationItem.title = values.localizedName
        } catch {
            print(error)
        }
    }
    
    func refreshContents(){
        contents.removeAll()
        defer {
            self.tableView.reloadData()
        }
        guard let url = currentDirectoryUrl else { fatalError() }
        do {
            let properties: [URLResourceKey] = [.localizedNameKey, .isDirectoryKey, .fileSizeKey, .isExcludedFromBackupKey]
            // 디렉토리에 포함된 항목 가져오기
            let currentContentUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: properties, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            for url in currentContentUrls {
                let content = Content(url: url)
                contents.append(content)
            }
            contents.sort { current, new in
                if current.type == new.type {
                    return current.name.lowercased() < new.name.lowercased()
                }
                return current.type.rawValue < new.type.rawValue
            }
            
        } catch {
            print(error)
        }
        
        if contents.isEmpty {
            let label = UILabel()
            label.text = "빈 디렉토리"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let target = contents[indexPath.row]
        cell.imageView?.image = target.image
        
        switch target.type {
        case .directory:
            cell.textLabel?.text = "[\(target.name)]"
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
        case .file:
            cell.textLabel?.text = target.name
            cell.detailTextLabel?.text = target.sizeString
            cell.accessoryType = .none
        }
        
        if target.isExcludedFromBackup {
            cell.textLabel?.textColor = .secondaryLabel
        } else {
            cell.textLabel?.textColor = .label
        }
        cell.detailTextLabel?.textColor = cell.textLabel?.textColor
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}
