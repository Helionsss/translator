import UIKit

final class AuthViewController: UIViewController, UITextFieldDelegate {

    private let loginUseCase: LoginUseCase
    private let validator: CredentialsValidator
    private let onLoginSuccess: () -> Void

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let emailField = UITextField()
    private let emailErrorLabel = UILabel()
    private let passwordField = UITextField()
    private let passwordErrorLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let activity = UIActivityIndicatorView(style: .medium)

    init(loginUseCase: LoginUseCase, validator: CredentialsValidator, onLoginSuccess: @escaping () -> Void) {
        self.loginUseCase = loginUseCase
        self.validator = validator
        self.onLoginSuccess = onLoginSuccess
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupKeyboardObservers()
        updateValidationState()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        navigationItem.title = "Login"

        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])

        titleLabel.text = "Authorization"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.textContentType = .username
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.borderStyle = .roundedRect
        emailField.delegate = self
        emailField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        emailField.returnKeyType = .next
        emailField.accessibilityIdentifier = "emailField"

        emailErrorLabel.textColor = .systemRed
        emailErrorLabel.font = .preferredFont(forTextStyle: .footnote)
        emailErrorLabel.numberOfLines = 0
        emailErrorLabel.isHidden = true

        let emailStack = UIStackView(arrangedSubviews: [emailField, emailErrorLabel])
        emailStack.axis = .vertical
        emailStack.spacing = 4
        stack.addArrangedSubview(emailStack)

        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.borderStyle = .roundedRect
        passwordField.delegate = self
        passwordField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        passwordField.returnKeyType = .go
        passwordField.accessibilityIdentifier = "passwordField"

        passwordErrorLabel.textColor = .systemRed
        passwordErrorLabel.font = .preferredFont(forTextStyle: .footnote)
        passwordErrorLabel.numberOfLines = 0
        passwordErrorLabel.isHidden = true

        let passwordStack = UIStackView(arrangedSubviews: [passwordField, passwordErrorLabel])
        passwordStack.axis = .vertical
        passwordStack.spacing = 4
        stack.addArrangedSubview(passwordStack)

        loginButton.setTitle("Enter", for: .normal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.configuration = .filled()
        loginButton.accessibilityIdentifier = "loginButton"
        stack.addArrangedSubview(loginButton)

        activity.hidesWhenStopped = true
        stack.addArrangedSubview(activity)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillChangeFrame(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardInView = view.convert(endFrame, from: nil)
        let intersection = view.bounds.intersection(keyboardInView)
        scrollView.contentInset.bottom = intersection.height
        scrollView.verticalScrollIndicatorInsets.bottom = intersection.height
    }

    @objc private func textChanged() {
        updateValidationState()
    }

    @objc private func loginTapped() {
        view.endEditing(true)
        setLoading(true)
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await self.loginUseCase.execute(LoginRequest(email: email, password: password))
                self.setLoading(false)
                self.onLoginSuccess()
            } catch {
                self.setLoading(false)
                self.showError(error)
            }
        }
    }

    private func updateValidationState() {
        let emailText = emailField.text ?? ""
        let passwordText = passwordField.text ?? ""

        let emailValid = validator.isValidEmail(emailText)
        let passwordValid = validator.isValidPassword(passwordText)

        emailErrorLabel.text = emailValid ? nil : "Write a valid email"
        emailErrorLabel.isHidden = emailValid || emailText.isEmpty

        passwordErrorLabel.text = passwordValid ? nil : "Password must be at least 6 characters"
        passwordErrorLabel.isHidden = passwordValid || passwordText.isEmpty

        loginButton.isEnabled = emailValid && passwordValid
    }

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loading ? activity.startAnimating() : activity.stopAnimating()
    }

    private func showError(_ error: Error) {
        if let err = error as? LocalizedError, let message = err.errorDescription {
            passwordErrorLabel.text = message
            passwordErrorLabel.isHidden = false
        } else {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailField {
            passwordField.becomeFirstResponder()
        } else if textField === passwordField {
            if loginButton.isEnabled { loginTapped() }
        }
        return true
    }
}
