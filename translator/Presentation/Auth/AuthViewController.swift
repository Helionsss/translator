import UIKit

final class AuthViewController: UIViewController, UITextFieldDelegate {

    private let loginUseCase: LoginUseCase
    private let validator: CredentialsValidator
    private let onLoginSuccess: () -> Void

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var stack = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var emailField = DSTextField()
    private lazy var passwordField = DSTextField()
    private lazy var loginButton = DSButton(style: .primary)
    private lazy var activity = UIActivityIndicatorView(style: .medium)

    init(loginUseCase: LoginUseCase, validator: CredentialsValidator, onLoginSuccess: @escaping () -> Void) {
        self.loginUseCase = loginUseCase
        self.validator = validator
        self.onLoginSuccess = onLoginSuccess
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.background
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
        stack.spacing = DS.Spacing.m
        stack.alignment = .fill
        stack.distribution = .fill

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DS.Spacing.m),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DS.Spacing.m),
            stack.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: DS.Spacing.xl),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -DS.Spacing.m)
        ])

        titleLabel.text = "Authorization"
        titleLabel.apply(.title)
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(DS.Spacing.xl, after: titleLabel)

        emailField.configure(with: DSTextField.Configuration(
            placeholder: "Email",
            accessibilityIdentifier: "emailField"
        ))
        emailField.keyboardType = .emailAddress
        emailField.textContentType = .username
        emailField.returnKeyType = .next
        emailField.delegate = self
        emailField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        stack.addArrangedSubview(emailField)
        
        passwordField.configure(with: DSTextField.Configuration(
            placeholder: "Password",
            accessibilityIdentifier: "passwordField"
        ))
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.returnKeyType = .go
        passwordField.delegate = self
        passwordField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        stack.addArrangedSubview(passwordField)
        
        loginButton.configure(with: DSButton.Configuration(
            title: "Enter",
            accessibilityIdentifier: "loginButton"
        ))
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
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

        emailField.error = emailValid || emailText.isEmpty ? nil : "Write a valid email"
        passwordField.error = passwordValid || passwordText.isEmpty ? nil : "Password must be at least 6 characters"

        loginButton.isEnabled = emailValid && passwordValid
    }

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        loading ? activity.startAnimating() : activity.stopAnimating()
    }

    private func showError(_ error: Error) {
        if let err = error as? LocalizedError, let message = err.errorDescription {
            passwordField.error = message
        } else {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailField.textField {
            _ = passwordField.becomeFirstResponder()
        } else if textField === passwordField.textField {
            if loginButton.isEnabled { loginTapped() }
        }
        return true
    }
}