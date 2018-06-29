//
//  WindowController.swift
//  FileViewer
//
//  Created by YangWei on 2018/6/28.
//  Copyright © 2018年 razeware. All rights reserved.
//



import Cocoa

class WindowController: NSWindowController {

  @IBAction func openDocument(_ sender: AnyObject?) {

    let openPanel = NSOpenPanel()
    openPanel.showsHiddenFiles = false
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true

    openPanel.beginSheetModal(for: self.window!) { response in
      guard response == NSModalResponseOK else {
        return
      }
      self.contentViewController?.representedObject = openPanel.url
    }
  }

}
