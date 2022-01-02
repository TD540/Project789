//
//  ViewController.swift
//  Projects789
//
//  Created by thomas on 28/12/2021.
//

import UIKit

class LetterField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

class ViewController: UIViewController {
    var score = 0
    var inCompleteWord: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.incompleteWordLabel.text = self?.inCompleteWord
            }
        }
    }
    let incompleteWordLabel = UILabel()
    let guessesLeftLabel = UILabel()
    let guessesView = UIView()
    var guessLabels = [UILabel]() {
        willSet {
            if newValue.isEmpty {
                let labels = guessLabels
                DispatchQueue.main.async {
                    for label in labels {
                        label.removeFromSuperview()
                    }
                }
            }
        }
    }
    let guessButton = UIButton(type: .system)
    let letterInput = LetterField()
    
    var completeWord = String() {
        didSet {
            inCompleteWord = String(repeating: "•", count: completeWord.count)
        }
    }
    
    var correctLetters = [Character]() {
        didSet {
            var newIncompleteWord = ""
            for letter in completeWord {
                if correctLetters.contains(letter) {
                    newIncompleteWord.append(letter)
                } else {
                    newIncompleteWord.append("•")
                }
            }
            inCompleteWord = newIncompleteWord
            if completeWord == inCompleteWord {
                score += 1
                let ac = UIAlertController(title: "You found \"\(completeWord)\"", message: "Score: \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Give me another", style: .default, handler: nil))
                performSelector(inBackground: #selector(newGame), with: nil)
            }
        }
    }
    
    var usedLetters = [Character]() {
        willSet {
            if newValue.isEmpty && !correctLetters.isEmpty {
                correctLetters.removeAll()
            }
        }
        didSet {
            guard let lastGuess = usedLetters.last else { return }
            let correctGuess = completeWord.contains(lastGuess)
            if correctGuess {
                correctLetters.append(lastGuess)
            } else {
                wrongAnswers += 1
                if wrongAnswers == wrongAnswersAllowed {
                    return
                }
            }
            // Add label to guesses
            let guessLabel = UILabel()
            guessLabel.text = String(lastGuess)
            guessLabel.textColor = correctGuess ? .systemGreen : .systemRed
            guessLabel.translatesAutoresizingMaskIntoConstraints = false
            guessesView.addSubview(guessLabel)
            let leftAnchor = guessLabels.last?.rightAnchor ?? guessesView.leftAnchor
            guessLabels.append(guessLabel)
            NSLayoutConstraint.activate([
                guessLabel.heightAnchor.constraint(equalTo: guessesView.heightAnchor),
                guessLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4)
            ])
        }
    }
    
    let wrongAnswersAllowed = 7
    var wrongAnswers = 0 {
        didSet {
            if wrongAnswers == wrongAnswersAllowed {
                performSelector(inBackground: #selector(newGame), with: nil)
            } else {
                let guessesLeft = wrongAnswersAllowed - wrongAnswers
                DispatchQueue.main.async { [weak self] in
                    self?.guessesLeftLabel.text = "\(guessesLeft) incorrect guesses left"
                }
            }
        }
    }
    
    @objc func newGame() {
        wrongAnswers = 0
        guessLabels.removeAll()
        usedLetters.removeAll()
        let url = URL(string: "https://random-word-api.herokuapp.com//word?number=1")!
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let randomWord = try? decoder.decode([String].self, from: data) {
                if let randomWord = randomWord.first {
                    completeWord = randomWord
                    print("The word is \(randomWord)")
                }
            }
        }
    }
    
    /// Make textfield accept only one unguessed letter as input
    @objc func letterInputChanged(sender: UITextField) {
        guard let input = sender.text else { return }
        switch input.count {
        case 0:
            guessButton.isEnabled = false
        case 1:
            // user adds first input
            let firstInput = input.lowercased().first!
            if firstInput.isLetter && !usedLetters.contains(firstInput) {
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
            if secondInput.isLetter && !usedLetters.contains(secondInput) {
                sender.text = String(secondInput)
            } else {
                sender.text = String(firstInput)
            }
        default:
            // user tried pasting in more than 2 letters,
            // which is not allowed, so:
            sender.text = nil
        }
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        incompleteWordLabel.translatesAutoresizingMaskIntoConstraints = false
        incompleteWordLabel.font = UIFont.systemFont(ofSize: 50)
        view.addSubview(incompleteWordLabel)
        guessesLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        guessesLeftLabel.textColor = .tertiaryLabel
        view.addSubview(guessesLeftLabel)
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
            incompleteWordLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            incompleteWordLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            guessesLeftLabel.topAnchor.constraint(equalTo: incompleteWordLabel.bottomAnchor),
            guessesLeftLabel.centerXAnchor.constraint(equalTo: incompleteWordLabel.centerXAnchor),
            guessesView.topAnchor.constraint(equalTo: guessesLeftLabel.bottomAnchor, constant: 10),
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
        guard let guess = letterInput.text?.first else { return }
        usedLetters.append(guess)
        letterInput.text = nil
        guessButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(newGame), with: nil)
    }
    
}
