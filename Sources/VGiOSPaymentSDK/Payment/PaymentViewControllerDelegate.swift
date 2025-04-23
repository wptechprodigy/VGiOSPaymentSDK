//
//  PaymentViewControllerDelegate.swift
//
//
//  Created by waheedCodes on 23/04/2025.
//

import Foundation

public protocol PaymentViewControllerDelegate: AnyObject {
    func didCompletePayment(with response: PaymentResponse)
    func didFailPayment(with error: VGPaymentError)
    func didCancelPayment()
}
