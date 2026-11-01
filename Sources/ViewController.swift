import UIKit

/// Phone-side screen: CarPlay has no keyboard, so the home page is chosen here.
class ViewController: UIViewController, UITextFieldDelegate {

    private let urlField = UITextField()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "CarPlay Browser"
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textAlignment = .center

        let infoLabel = UILabel()
        infoLabel.text = "Connect to CarPlay to browse. Choose the page CarPlay opens first:"
        infoLabel.font = .preferredFont(forTextStyle: .body)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0

        urlField.borderStyle = .roundedRect
        urlField.placeholder = BrowserSettings.defaultHomeURL.absoluteString
        urlField.text = BrowserSettings.homeURL.absoluteString
        urlField.keyboardType = .URL
        urlField.autocapitalizationType = .none
        urlField.autocorrectionType = .no
        urlField.clearButtonMode = .whileEditing
        urlField.returnKeyType = .done
        urlField.delegate = self

        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Home Page", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset to YouTube", for: .normal)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, infoLabel, urlField, saveButton, resetButton, statusLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        guard let url = BrowserSettings.normalizedURL(from: urlField.text ?? "") else {
            show("Enter a valid web address, for example youtube.com", isError: true)
            return
        }
        BrowserSettings.homeURL = url
        BrowserSettings.lastURL = nil // so the new home page is used on the next connection
        urlField.text = url.absoluteString
        show("Saved. CarPlay will open this page the next time it connects.", isError: false)
    }

    @objc private func resetTapped() {
        view.endEditing(true)
        BrowserSettings.homeURL = BrowserSettings.defaultHomeURL
        BrowserSettings.lastURL = nil
        urlField.text = BrowserSettings.defaultHomeURL.absoluteString
        show("Home page reset to YouTube.", isError: false)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func show(_ message: String, isError: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isError ? .systemRed : .secondaryLabel
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
