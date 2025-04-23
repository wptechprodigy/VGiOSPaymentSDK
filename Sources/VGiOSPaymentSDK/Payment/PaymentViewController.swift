//
//  PaymentViewController.swift
//  
//
//  Created by waheedCodes on 23/04/2025.
//

import UIKit
import WebKit

public class PaymentViewController: UIViewController {
    // MARK: - Properties
    // webView internal instead of private for testing
    internal var webView: WKWebView!
    
    private let paymentRequest: PaymentRequest
    private let configuration: Configuration
    private weak var delegate: PaymentViewControllerDelegate?
    
    // API client injection
    private var apiClient: APIClient
    
    // MARK: - Initialization
    // Update initializer to support dependency injection
    init(
        paymentRequest: PaymentRequest,
        configuration: Configuration,
        delegate: PaymentViewControllerDelegate,
        apiClient: APIClient = .shared
    ) {
        self.paymentRequest = paymentRequest
        self.configuration = configuration
        self.delegate = delegate
        self.apiClient = apiClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializePayment()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Payment"
        view.backgroundColor = .white
        
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        
        // For iOS 13+ compatibility
        if #available(iOS 13.0, *) {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
            navigationItem.rightBarButtonItem = closeButton
        } else {
            // For earlier iOS versions
            let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeTapped))
            navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    // MARK: - Actions
    // Make method internal for testing
    @objc internal func closeTapped() {
        dismiss(animated: true) {
            self.delegate?.didCancelPayment()
        }
    }
    
    // MARK: - Payment Processing
    private func initializePayment() {
        // Prepare API request
        guard let url = URL(string: "\(configuration.baseURL)/payments") else {
            delegate?.didFailPayment(with: .unexpectedError("Invalid URL"))
            return
        }
        
        let headers = [
            "Authorization": "Bearer \(configuration.publicKey)",
            "Content-Type": "application/json"
        ]
        
        let paymentData = paymentRequest.toDict()
        
        guard let body = try? JSONSerialization.data(withJSONObject: paymentData) else {
            delegate?.didFailPayment(with: .invalidRequest)
            return
        }
        
        // Make API request
        apiClient.request(
            url: url,
            method: .post,
            headers: headers,
            body: body
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let data = response["data"] as? [String: Any],
                          let paymentLink = data["link"] as? String,
                          let url = URL(string: paymentLink) else {
                        self.delegate?.didFailPayment(with: .unexpectedError("Invalid payment link"))
                        return
                    }
                    
                    let request = URLRequest(url: url)
                    self.webView.load(request)
                    
                case .failure(let error):
                    self.delegate?.didFailPayment(with: error)
                }
            }
        }
    }
    
    // MARK: - Payment Verification
    internal func verifyPayment(reference: String) {
        guard let url = URL(string: "\(configuration.baseURL)/transactions/verify_by_reference?tx_ref=\(reference)") else {
            delegate?.didFailPayment(with: .unexpectedError("Invalid verification URL"))
            return
        }
        
        let headers = [
            "Authorization": "Bearer \(configuration.publicKey)",
            "Content-Type": "application/json"
        ]
        
        apiClient.request(
            url: url,
            method: .get,
            headers: headers,
            body: nil
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let paymentResponse = PaymentResponse(from: response) {
                        self.dismiss(animated: true) {
                            self.delegate?.didCompletePayment(with: paymentResponse)
                        }
                    } else {
                        self.dismiss(animated: true) {
                            self.delegate?.didFailPayment(with: .unexpectedError("Invalid verification response"))
                        }
                    }
                    
                case .failure(let error):
                    self.dismiss(animated: true) {
                        self.delegate?.didFailPayment(with: error)
                    }
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension PaymentViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // Check for callback URLs
        if url.absoluteString.contains("flutterwave-callback") {
            // Extract transaction reference
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                decisionHandler(.cancel)
                return
            }
            
            if let statusItem = queryItems.first(where: { $0.name == "status" }),
               let status = statusItem.value,
               let txRefItem = queryItems.first(where: { $0.name == "tx_ref" }),
               let txRef = txRefItem.value {
                
                if status.lowercased() == "successful" {
                    // Verify payment
                    verifyPayment(reference: txRef)
                } else {
                    // Payment failed or was cancelled
                    dismiss(animated: true) {
                        self.delegate?.didFailPayment(with: .paymentCancelled)
                    }
                }
                
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
}
