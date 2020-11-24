//
//  ViewController.swift
//  Browser
//
//  Created by Astemir Shibzuhov on 11/24/20.
//

import UIKit
import WebKit

enum SearchSystemDomens: String {
  case google = "https://google.com/search"
}

class ViewController: UIViewController {
  
  var arrayURL = [URL]()
  var currentPageIndex: Int?
  var flag = false
  
  @IBOutlet weak var historyButton: UIButton!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var forwardButton: UIButton!
  @IBOutlet weak var heightConstraintProgressBar: NSLayoutConstraint!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var progressView: UIProgressView!
  
  // Create webView
  @IBOutlet weak var webView: WKWebView!
  
  private var coreDataStack: CoreDataStack!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    coreDataStack = CoreDataStack(modelName: "Browser")
    setupUI()
  }
  
  
  // Here we configure UI
  private func setupUI() {
    webView.navigationDelegate = self
    webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    searchBar.delegate = self
    
    progressView.progress = 0
    heightConstraintProgressBar.constant = 0
    
    searchBar.searchTextField.font = UIFont.systemFont(ofSize: 15)
    backButton.imageView?.contentMode = .scaleAspectFit
    forwardButton.imageView?.contentMode = .scaleAspectFit
    shareButton.imageView?.contentMode = .scaleAspectFit
    historyButton.imageView?.contentMode = .scaleAspectFit
  }
  
  // Here we animate the height for progress
  private func showProgressAnimation() {
    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.2) { [unowned self] in
      self.heightConstraintProgressBar.constant = 2
      self.view.layoutIfNeeded()
    }
  }
  
  //  Here we animate height reduction for progress
  private func hideProgressAnimation() {
    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.2) { [unowned self] in
      self.heightConstraintProgressBar.constant = 0
      self.view.layoutIfNeeded()
    }
  }
  
  // observe estimatedProgress
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "estimatedProgress" {
      progressView.progress = Float(webView.estimatedProgress)
    }
  }
    
  
  // previeurl
  @IBAction func previewButtonAction(_ sender: Any) {
    if let currentIndex = currentPageIndex, currentIndex - 1 >= 0 {
      currentPageIndex! -= 1
      let reqUrl = arrayURL[currentPageIndex!]
      print(arrayURL[currentIndex])
      let req = URLRequest(url: reqUrl)
      flag = false
      webView.load(req)
      
    }
  }
  
  // previeurl
  @IBAction func nextButtonAction(_ sender: Any) {
    if let currentIndex = currentPageIndex, currentIndex + 1 > arrayURL.count - 1 {
      currentPageIndex! += 1
      print(arrayURL[currentPageIndex!])
      let reqUrl = arrayURL[currentPageIndex!]
      let req = URLRequest(url: reqUrl)
      flag = false
      webView.load(req)
    }
  }
  
  @IBAction func shareButtonAction(_ sender: Any) {
    guard let url = webView.url else {return}
    let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    activity.excludedActivityTypes = [.airDrop]
    present(activity, animated: true)
  }
  
  @IBAction func historyButtonAction(_ sender: Any) {
    // initilaize historyVC fro storyboard
    guard let historyVC = storyboard?.instantiateViewController(identifier: String(describing: HistoryViewController.self)) as? HistoryViewController else {return}
    historyVC.coreDataStack = coreDataStack
    historyVC.delegate = self
    // presemt history view controller
    present(historyVC, animated: true, completion: nil)
  }
}


// Extension ViewController for UISearch Delegate
extension ViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let searchText = searchBar.text,  var urlComponents = URLComponents(string: SearchSystemDomens.google.rawValue) else {return}
    urlComponents.queryItems = [URLQueryItem(name: "q", value: searchText)]
    guard let searchUrl = urlComponents.url else {return}
    let urlRequest = URLRequest(url: searchUrl)
    webView.load(urlRequest)
    searchBar.endEditing(true)
    arrayURL.removeAll()
    currentPageIndex = nil
    flag = true
  }

}


// Extention ViewController for WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    showProgressAnimation()
    let history = History(context: coreDataStack.managedContext)
    history.url = webView.url
    history.date = Date()
    coreDataStack.saveContext()
    if flag {
      if let url = webView.url {
        arrayURL.append(url)
        currentPageIndex = arrayURL.count - 1
      }
    }
    flag = true
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    hideProgressAnimation()
  }
}


// Extension ViewController For HistoryViewController Delegate
extension ViewController: HistoryViewControllerDelegate {
  func didSelectHistoryUrl(url: URL) {
    print(url.absoluteString)
    webView.load(URLRequest(url: url))
  }
}



