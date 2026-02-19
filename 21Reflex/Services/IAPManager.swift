//
//  IAPManager.swift
//  21Reflex
//
//  In-App Purchase management using StoreKit 2
//

import StoreKit
import SwiftUI
import SwiftData

/// Product ID for Remove Ads IAP
enum IAPProduct: String, CaseIterable {
    case removeAds = "com.ricaud.21reflex.removeads"

    var displayName: String {
        switch self {
        case .removeAds:
            return "Remove Ads"
        }
    }

    var description: String {
        switch self {
        case .removeAds:
            return "Remove all banner ads from the app"
        }
    }
}

/// Manages in-app purchases using StoreKit 2
@Observable
class IAPManager {
    static let shared = IAPManager()

    // MARK: - State

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []

    var isLoading = false
    var errorMessage: String?
    var showError = false

    /// Check if user has purchased Remove Ads
    var hasRemovedAds: Bool {
        purchasedProductIDs.contains(IAPProduct.removeAds.rawValue)
    }

    // MARK: - Private

    private var updateListenerTask: Task<Void, Never>?

    private init() {
        // Start transaction listener
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Product Loading

    /// Load available products from App Store
    func loadProducts() async {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }

        do {
            let productIDs = IAPProduct.allCases.map { $0.rawValue }
            let loadedProducts = try await Product.products(for: productIDs)
            print("[IAPManager] Loaded \(loadedProducts.count) products")

            // Sort products by display order
            let sortedProducts = loadedProducts.sorted { p1, p2 in
                let order1 = IAPProduct(rawValue: p1.id)?.hashValue ?? 0
                let order2 = IAPProduct(rawValue: p2.id)?.hashValue ?? 0
                return order1 < order2
            }

            await MainActor.run {
                self.products = sortedProducts
            }
        } catch {
            print("[IAPManager] Failed to load products: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to load store products"
                self.showError = true
            }
        }
    }

    // MARK: - Purchase

    /// Purchase a product
    func purchase(_ product: Product) async -> Bool {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify transaction
                let transaction = try checkVerified(verification)

                // Deliver content
                await deliverPurchase(productID: transaction.productID)

                // Finish transaction
                await transaction.finish()

                print("[IAPManager] Purchase successful: \(product.displayName)")
                return true

            case .userCancelled:
                print("[IAPManager] User cancelled purchase")
                return false

            case .pending:
                print("[IAPManager] Purchase pending approval")
                await MainActor.run {
                    self.errorMessage = "Purchase is pending approval"
                    self.showError = true
                }
                return false

            @unknown default:
                print("[IAPManager] Unknown purchase result")
                return false
            }
        } catch StoreKitError.userCancelled {
            print("[IAPManager] User cancelled purchase")
            return false
        } catch {
            print("[IAPManager] Purchase failed: \(error)")
            await MainActor.run {
                self.errorMessage = "Purchase failed: \(error.localizedDescription)"
                self.showError = true
            }
            return false
        }
    }

    /// Restore previous purchases
    func restorePurchases() async {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }

        do {
            // Iterate through all purchased products
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)

                // Deliver content for each purchased product
                await deliverPurchase(productID: transaction.productID)

                print("[IAPManager] Restored purchase: \(transaction.productID)")
            }

            print("[IAPManager] Restore completed")
        } catch {
            print("[IAPManager] Restore failed: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }

    // MARK: - Transaction Handling

    /// Listen for transaction updates (purchases on other devices, refunds, etc.)
    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }

                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver content
                    await self.deliverPurchase(productID: transaction.productID)

                    // Finish transaction
                    await transaction.finish()

                    print("[IAPManager] Transaction update processed: \(transaction.productID)")
                } catch {
                    print("[IAPManager] Transaction verification failed: \(error)")
                }
            }
        }
    }

    /// Check transaction verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw IAPError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Content Delivery

    /// Deliver purchased content to the user
    /// Note: Caller is responsible for saving premium status to PersistentPlayer
    @MainActor
    private func deliverPurchase(productID: String) {
        purchasedProductIDs.insert(productID)

        // Update AdManager based on purchase
        if productID == IAPProduct.removeAds.rawValue {
            AdManager.shared.setPremiumUser(true)
            print("[IAPManager] Premium content delivered for: \(productID)")
        }
    }

    /// Check current entitlements on app launch
    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                await deliverPurchase(productID: transaction.productID)
                print("[IAPManager] Found entitlement: \(transaction.productID)")
            } catch {
                print("[IAPManager] Entitlement verification failed: \(error)")
            }
        }
    }

    /// Sync premium status from PersistentPlayer (used on app launch)
    @MainActor
    func syncPremiumStatusFromPersistentPlayer(_ player: PersistentPlayer) {
        if player.isPremiumUser {
            purchasedProductIDs.insert(IAPProduct.removeAds.rawValue)
            AdManager.shared.setPremiumUser(true)
            print("[IAPManager] Synced premium status from PersistentPlayer: true")
        }
    }
}

// MARK: - Errors

enum IAPError: Error {
    case failedVerification
    case productNotFound
}

extension IAPError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        case .productNotFound:
            return "Product not found in App Store"
        }
    }
}
