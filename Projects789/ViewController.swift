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
    
    func getWord() {
        let url = URL(string: "https://random-word-api.herokuapp.com//word?number=1")!
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let randomWord = try? decoder.decode([String].self, from: data) {
                if let word = randomWord.first {
                    print("The word is \(word)")
                    DispatchQueue.main.async { [weak self] in
                        guard let letterView = self?.letterView else { return }
                        var prevWidth: CGFloat = 0
                        for (_, letter) in word.enumerated() {
                            let letterLabel = UILabel()
                            letterLabel.text = String(letter)
                            letterLabel.sizeToFit()
                            let frame = CGRect(x: prevWidth, y: 0, width: letterLabel.frame.width, height: letterLabel.frame.height)
                            letterLabel.frame = frame
                            prevWidth += letterLabel.frame.width
                            letterView.addSubview(letterLabel)
                        }
                    }
                }
            }
        }
    }
    
    @objc func newGame() {
        guessAmount = 0
        getWord()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        letterView.backgroundColor = .red
//        letterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(letterView)
//        NSLayoutConstraint.activate([
//            letterView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
//            letterView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor)
//        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(newGame), with: nil)
    }

}
