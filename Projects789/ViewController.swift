//
//  ViewController.swift
//  Projects789
//
//  Created by thomas on 28/12/2021.
//

import UIKit

class ViewController: UIViewController {
    let letterView = UILabel()
    let guessesLeft = UILabel()
    let guessesView = UIView()
    let guessButton = UIButton(type: .system)
    let letterInput = UITextField()
    let incorrectGuessesAllowed = 7
    
    var word = String()
    
    var guesses = [Character]() {
        didSet {
            if let lastGuess = guesses.last {
                if word.contains(lastGuess) {
                    print("last guess = \(lastGuess)")
                }
            }
        }
    }
    
    var incorrectGuessCount = 0 {
        didSet {
            if incorrectGuessCount == incorrectGuessesAllowed {
                incorrectGuessCount = 0
                newGame()
            }
        }
    }
    
    @objc func newGame() {
        let url = URL(string: "https://random-word-api.herokuapp.com//word?number=1")!
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let randomWord = try? decoder.decode([String].self, from: data) {
                if let randomWord = randomWord.first {
                    word = randomWord
                    print("The word is \(word)")
                    let count = word.count
                    DispatchQueue.main.async { [weak self] in
                        self?.letterView.text = String(repeating: "?", count: count)
                    }
                }
            }
        }
    }
    
    /// Make textfield accept only one letter
    @objc private func letterInputChanged(sender: UITextField) {
        guard let input = sender.text else { return }
        switch input.count {
        case 1:
            // user adds first input
            let firstInput = input.lowercased().first!
            if firstInput.isLetter && !guesses.contains(firstInput) {
                sender.text = String(firstInput)
                guessButton.isEnabled = true
            } else {
                sender.text = nil
            }
        case 2:
            // user adds second input
            let firstInput = input.lowercased().first!
            let secondInput = input.lowercased().last!
            // check if second input is valid
            if secondInput.isLetter && !guesses.contains(secondInput) {
                sender.text = String(secondInput)
            } else {
                sender.text = String(firstInput)
            }
        default:
            guessButton.isEnabled = false
        }
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        letterView.translatesAutoresizingMaskIntoConstraints = false
        letterView.font = UIFont.systemFont(ofSize: 50)
        view.addSubview(letterView)
        guessesLeft.translatesAutoresizingMaskIntoConstraints = false
        guessesLeft.text = "\(incorrectGuessesAllowed - incorrectGuessCount) guesses left"
        view.addSubview(guessesLeft)
        guessesView.translatesAutoresizingMaskIntoConstraints = false
        guessesView.layer.borderWidth = 2
        guessesView.layer.borderColor = UIColor.tertiarySystemFill.cgColor
        guessesView.backgroundColor = .secondarySystemBackground
        view.addSubview(guessesView)
        letterInput.addTarget(self, action: #selector(letterInputChanged(sender:)), for: .editingChanged)
        letterInput.borderStyle = .roundedRect
        letterInput.becomeFirstResponder()
        letterInput.textAlignment = .center
        letterInput.clearButtonMode = .always
        letterInput.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(letterInput)
        guessButton.translatesAutoresizingMaskIntoConstraints = false
        guessButton.isEnabled = false
        guessButton.setTitle("Guess!", for: .normal)
        guessButton.addTarget(self, action: #selector(guessButtonTapped), for: .touchUpInside)
        view.addSubview(guessButton)
        NSLayoutConstraint.activate([
            letterView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            letterView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            guessesLeft.topAnchor.constraint(equalTo: letterView.bottomAnchor),
            guessesLeft.centerXAnchor.constraint(equalTo: letterView.centerXAnchor),
            guessesView.topAnchor.constraint(equalTo: guessesLeft.bottomAnchor, constant: 10),
            guessesView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            guessesView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            guessesView.heightAnchor.constraint(equalToConstant: 50),
            letterInput.topAnchor.constraint(equalTo: guessesView.bottomAnchor, constant: 10),
            letterInput.centerXAnchor.constraint(equalTo: guessesView.centerXAnchor),
            letterInput.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            guessButton.topAnchor.constraint(equalTo: letterInput.bottomAnchor, constant: 10),
            guessButton.centerXAnchor.constraint(equalTo: letterInput.centerXAnchor)
        ])
    }
    
    @objc func guessButtonTapped(_ sender: UIButton) {
        if let letter = letterInput.text {
            if letter.isEmpty == false {
                let guess = Character(letter)
                if guesses.contains(guess) == false {
                    print("Guessing \(guess)")
                    guesses.append(guess)
                }
                letterInput.text = nil
                guessButton.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(newGame), with: nil)
    }
    
}
