//
//  HistoryViewController.swift
//  Browser
//
//  Created by Astemir Shibzuhov on 11/24/20.
//

import UIKit
import CoreData

// History Delegate that open url from history
protocol HistoryViewControllerDelegate: class {
  func didSelectHistoryUrl(url: URL)
}

class HistoryViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var coreDataStack: CoreDataStack!
  
  // delegate
  weak var delegate: HistoryViewControllerDelegate?
  
  var history: [History] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchHistory()
  }
  
  // Fetching history from core data
  private func fetchHistory() {
    let fetchReq: NSFetchRequest<History> = History.fetchRequest()
    do {
      let result = try coreDataStack.managedContext.fetch(fetchReq)
      self.history = result
      tableView.reloadData()
    } catch {
      print(error)
    }
  }
  
}


// Extension UITableViewDelegate and UITableViewDataSource
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return history.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // initialize cell for table view
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let historyModel = history[indexPath.row]
    cell.textLabel?.text = historyModel.url?.absoluteString
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
    if let date = historyModel.date {
      cell.detailTextLabel?.text = dateFormatter.string(from: date)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // dismiss current viewController and open url in webView
    let historyModel = history[indexPath.row]
    guard let url = historyModel.url else {return}
    dismiss(animated: true) {
      self.delegate?.didSelectHistoryUrl(url: url)
    }
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // Delete row in tableview and coredata
      let historyModel = history[indexPath.row]
      history.remove(at: indexPath.row)
      self.tableView.deleteRows(at: [indexPath], with: .left)
      coreDataStack.managedContext.delete(historyModel)
      coreDataStack.saveContext()
    }
  }
  
}
