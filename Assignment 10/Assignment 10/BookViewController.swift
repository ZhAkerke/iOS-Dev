//
//  BookViewController.swift
//  Assignment 10
//
//  Created by Akerke Zhanykul on 12.11.2026.
//


import UIKit

class BooksViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BooksData.books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "BookCell",
            for: indexPath
        ) as! BookTableViewCell

        let book = BooksData.books[indexPath.row]
        cell.configure(with: book)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard segue.identifier == "showDetail",
              let destination = segue.destination as? BookDetailViewController,
              let indexPath = tableView.indexPathForSelectedRow else {
            return
        }

        destination.book = BooksData.books[indexPath.row]
    }

}
