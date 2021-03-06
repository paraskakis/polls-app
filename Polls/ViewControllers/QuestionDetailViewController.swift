//
//  QuestionDetailViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit
import SVProgressHUD


/// A view controller for showing specific questions
class QuestionDetailViewController : UITableViewController {
  /// The view model backing this view controller
  var viewModel:QuestionDetailViewModel? {
    didSet {
      if isViewLoaded() {
        updateState()
      }
    }
  }

  // MARK: View life-cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("QUESTION_DETAIL_TITLE", comment: "")
    updateState()
  }

  // MARK: UITableViewDelegate

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if viewModel == nil {
      return 0
    }
    return 2
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }

    return viewModel?.numberOfChoices() ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier("QuestionCell") as! UITableViewCell
      cell.textLabel?.text = viewModel?.question
      cell.detailTextLabel?.text = nil
      cell.accessoryType = .None
      return cell
    }

    let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceCell") as! UITableViewCell
    cell.textLabel?.text = viewModel?.choice(indexPath.row)
    cell.detailTextLabel?.text = viewModel?.votes(indexPath.row).description

    if viewModel!.canVote(indexPath.row) {
      cell.accessoryType = .DisclosureIndicator
    } else {
      cell.accessoryType = .None
    }

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 && viewModel!.canVote(indexPath.row) {
      // Vote on the question
      vote(indexPath.row)
    } else {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return NSLocalizedString("QUESTION_DETAIL_QUESTION_TITLE", comment: "")
    }

    return NSLocalizedString("QUESTION_DETAIL_CHOICE_LIST_TITLE", comment: "")
  }

  /// Vote on the given choice
  private func vote(index:Int) {
    SVProgressHUD.showWithStatus(NSLocalizedString("QUESTION_DETAIL_CHOICE_VOTING", comment: ""), maskType: .Gradient)

    viewModel?.vote(index) { voted in
      SVProgressHUD.dismiss()
      self.tableView.reloadData()
    }
  }

  func updateState() {
    if viewModel?.canReload ?? false {
      if refreshControl == nil {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action:Selector("reload"), forControlEvents:.ValueChanged)
      }
    } else {
      refreshControl = nil
    }

    tableView?.reloadData()
  }

  func reload() {
    if let viewModel = viewModel {
      viewModel.reload { result in
        self.refreshControl?.endRefreshing()
        self.updateState()
      }
    } else {
      refreshControl?.endRefreshing()
    }
  }
}
