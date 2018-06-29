//
//  ViewController.swift
//  FileViewer
//
//  Created by YangWei on 2018/6/28.
//  Copyright © 2018年 razeware. All rights reserved.
//


import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var statusLabel: NSTextField!

  let sizeFormatter = ByteCountFormatter()
  var directory: Directory?
  var directoryItems: [Metadata]?
  var sortOrder = Directory.FileOrder.Name
  var sortAscending = true

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.target = self
    tableView.doubleAction = #selector(tableViewDoubleClick(_:))
    
    tableView.dataSource = self
    tableView.delegate = self

  
    statusLabel.stringValue = "File List"
  }

  func reloadFileList() {
    directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
    tableView.reloadData()
  }
  
  func updateStatus() {
    let text: String
    let itemsSelected = tableView.selectedRowIndexes.count
    
    if directoryItems == nil {
      text = "NO Items"
    }else if(itemsSelected == 0) {
      text = "total \(directoryItems!.count) items"
    }else {
      text = "\(itemsSelected) of \(directoryItems!.count) selected"
    }
     statusLabel.stringValue = text
  }
  
  //双击cell
  func tableViewDoubleClick(_ sender: AnyObject) {
    guard tableView.selectedRow >= 0, let item = directoryItems?[tableView.selectedRow] else {
      return
    }
    
    if item.isFolder {
      self.representedObject = item.url as Any
    }else {
      NSWorkspace.shared().open(item.url as URL)
    }
  }
  
  //当一个新的目录被选中时调用
  override var representedObject: Any? {
    didSet {
      if let url = representedObject as? URL {
        directory = Directory(folderURL: url)
        reloadFileList()
        updateStatus()
      }
    }
  }
}

extension ViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return directoryItems?.count ?? 0
  }
}

extension ViewController: NSTableViewDelegate {
  fileprivate enum CellIdentifiers {
    static let NameCell = "NameCellID"
    static let DateCell = "DateCellID"
    static let SizeCell = "SizeCellID"
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var image: NSImage?
    var text: String = ""
    var cellIdentifier: String = ""
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    
    guard let item = directoryItems?[row] else {
      return nil
    }
    
    if tableColumn == tableView.tableColumns[0] {
      image = item.icon
      text = item.name
      cellIdentifier = CellIdentifiers.NameCell
    }else if tableColumn == tableView.tableColumns[1] {
      text = dateFormatter.string(from: item.date)
      cellIdentifier = CellIdentifiers.DateCell
    }else if tableColumn == tableView.tableColumns[2] {
      text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
      cellIdentifier = CellIdentifiers.SizeCell
    }
    
    if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      cell.imageView?.image = image ?? nil
      return cell
    }
    return nil
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    updateStatus()
  }
  
}

