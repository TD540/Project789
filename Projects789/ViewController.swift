//
//  ViewController.swift
//  Projects789
//
//  Created by thomas on 28/12/2021.
//

import UIKit

class ViewController: UIViewController {
    var wordLabel = [UILabel]()
    var letterView = UIView()
    var guessAmount = 0 {
        didSet {
            if guessAmount == 7 {
                newGame()
            }
        }
    }
    
    @objc func newGame() {
        guessAmount = 0
        let url = URL(string: "https://random-word-api.herokuapp.com//word?number=1")!
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let randomWord = try? decoder.decode([String].self, from: data) {
                if let word = randomWord.first {
                    print("The word is \(word)")
                    DispatchQueue.main.async { [weak self] in
                        guard let letterView = self?.letterView else { return }
                        let height = 100
                        let width = Int(letterView.frame.width) / word.count
                        for (index, letter) in word.enumerated() {
                            let label = UILabel()
                            label.text = String(letter)
                            let frame = CGRect(
                                x: index * width,
                                y: 0,
                                width: width,
                                height: height
                            )
                            label.frame = frame
                            label.textAlignment = .center
                            letterView.addSubview(label)
                        }
                    }
                }
            }
        }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        letterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(letterView)
        NSLayoutConstraint.activate([
            letterView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            letterView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            letterView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            letterView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(newGame), with: nil)
    }

}
