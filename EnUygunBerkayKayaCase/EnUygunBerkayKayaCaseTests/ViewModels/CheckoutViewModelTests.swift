//
//  CheckoutViewModelTests.swift
//  EnUygunBerkayKayaCaseTests
//
//  Created by Berkay Kaya
//

import XCTest
import RxSwift
import RxBlocking
@testable import EnUygunBerkayKayaCase

final class CheckoutViewModelTests: XCTestCase {
    
    var sut: CheckoutViewModel!
    var mockStorageService: MockStorageService!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockStorageService = MockStorageService()
        sut = CheckoutViewModel(storageService: mockStorageService)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        sut = nil
        mockStorageService = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Email Validation Tests
    
    func testEmailValidation_ValidEmail() {
        // Given
        let validEmails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "test123@test.com"
        ]
        
        for email in validEmails {
            // When
            sut.fullName.accept("Test User")
            sut.email.accept(email)
            sut.phone.accept("1234567890")
            sut.address.accept("Test Address")
            
            let isValid = try! sut.isFormValid.toBlocking().first()
            
            // Then
            XCTAssertTrue(isValid == true, "Email \(email) should be valid")
        }
    }
    
    func testEmailValidation_InvalidEmail() {
        // Given
        let invalidEmails = [
            "invalid-email",
            "test@",
            "@domain.com",
            "test@domain"
        ]
        
        for email in invalidEmails {
            // When
            sut.fullName.accept("Test User")
            sut.email.accept(email)
            sut.phone.accept("1234567890")
            sut.address.accept("Test Address")
            
            let isValid = try! sut.isFormValid.toBlocking().first()
            
            // Then
            XCTAssertTrue(isValid == false, "Email \(email) should be invalid")
        }
    }
    
    // MARK: - Form Validation Tests
    
    func testFormValidation_AllFieldsEmpty() {
        // Given - all fields empty
        
        // When
        let isValid = try! sut.isFormValid.toBlocking().first()
        
        // Then
        XCTAssertFalse(isValid ?? true, "Form should be invalid when all fields are empty")
    }
    
    func testFormValidation_AllFieldsValid() {
        // Given
        sut.fullName.accept("John Doe")
        sut.email.accept("john@example.com")
        sut.phone.accept("1234567890")
        sut.address.accept("123 Main St, City")
        
        // When
        let isValid = try! sut.isFormValid.toBlocking().first()
        
        // Then
        XCTAssertTrue(isValid ?? false, "Form should be valid when all fields are filled correctly")
    }
    
    func testFormValidation_MissingName() {
        // Given
        sut.fullName.accept("")
        sut.email.accept("john@example.com")
        sut.phone.accept("1234567890")
        sut.address.accept("123 Main St")
        
        // When
        let isValid = try! sut.isFormValid.toBlocking().first()
        
        // Then
        XCTAssertFalse(isValid ?? true, "Form should be invalid when name is missing")
    }
    
    func testFormValidation_MissingPhone() {
        // Given
        sut.fullName.accept("John Doe")
        sut.email.accept("john@example.com")
        sut.phone.accept("")
        sut.address.accept("123 Main St")
        
        // When
        let isValid = try! sut.isFormValid.toBlocking().first()
        
        // Then
        XCTAssertFalse(isValid ?? true, "Form should be invalid when phone is missing")
    }
    
    // MARK: - Price Calculation Tests
    
    func testSubtotalCalculation() {
        // Given
        let product = Product.mock(price: 100, discountPercentage: 0)
        mockStorageService.addToCart(product)
        
        // When
        let subtotal = try! sut.subtotal.toBlocking().first()
        
        // Then
        XCTAssertEqual(subtotal ?? 0, 100.0, accuracy: 0.01)
    }
    
    func testTaxCalculation() {
        // Given
        let product = Product.mock(price: 100, discountPercentage: 0)
        mockStorageService.addToCart(product)
        
        // When
        let tax = try! sut.tax.toBlocking().first()
        
        // Then
        XCTAssertEqual(tax ?? 0, 18.0, accuracy: 0.01, "Tax should be 18% of 100")
    }
    
    func testTotalCalculation() {
        // Given
        let product = Product.mock(price: 100, discountPercentage: 0)
        mockStorageService.addToCart(product)
        
        // When
        let total = try! sut.total.toBlocking().first()
        
        // Then
        XCTAssertEqual(total ?? 0, 118.0, accuracy: 0.01, "Total should be 100 + 18")
    }
    
    func testTotalCalculationWithMultipleItems() {
        // Given
        mockStorageService.addToCart(Product.mock(id: 1, price: 100, discountPercentage: 0))
        mockStorageService.addToCart(Product.mock(id: 2, price: 200, discountPercentage: 0))
        
        // When
        let subtotal = try! sut.subtotal.toBlocking().first()
        let tax = try! sut.tax.toBlocking().first()
        let total = try! sut.total.toBlocking().first()
        
        // Then
        XCTAssertEqual(subtotal ?? 0, 300.0, accuracy: 0.01)
        XCTAssertEqual(tax ?? 0, 54.0, accuracy: 0.01, "Tax should be 18% of 300")
        XCTAssertEqual(total ?? 0, 354.0, accuracy: 0.01)
    }
    
    func testTaxCalculationWithDiscount() {
        // Given
        let product = Product.mock(price: 100, discountPercentage: 10) // $90 after discount
        mockStorageService.addToCart(product)
        
        // When
        let subtotal = try! sut.subtotal.toBlocking().first()
        let tax = try! sut.tax.toBlocking().first()
        let total = try! sut.total.toBlocking().first()
        
        // Then
        XCTAssertEqual(subtotal ?? 0, 90.0, accuracy: 0.01)
        XCTAssertEqual(tax ?? 0, 16.2, accuracy: 0.01, "Tax should be 18% of 90")
        XCTAssertEqual(total ?? 0, 106.2, accuracy: 0.01)
    }
    
    // MARK: - Payment Method Tests
    
    func testDefaultPaymentMethod() {
        // Given
        
        // When
        let paymentMethod = sut.selectedPaymentMethod.value
        
        // Then
        XCTAssertEqual(paymentMethod, .creditCard, "Default payment method should be credit card")
    }
    
    func testChangePaymentMethod() {
        // Given
        let newMethod = PaymentMethod.cashOnDelivery
        
        // When
        sut.selectedPaymentMethod.accept(newMethod)
        
        // Then
        XCTAssertEqual(sut.selectedPaymentMethod.value, newMethod)
    }
    
    // MARK: - Place Order Tests
    
    func testPlaceOrder_ClearsCart() {
        // Given
        mockStorageService.addToCart(Product.mock())
        sut.fullName.accept("John Doe")
        sut.email.accept("john@example.com")
        sut.phone.accept("1234567890")
        sut.address.accept("123 Main St")
        
        let expectation = self.expectation(description: "Order placed")
        
        sut.orderPlaced
            .subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        // When
        sut.placeOrder.onNext(())
        
        // Then
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(self.mockStorageService.clearCartCalled, "Cart should be cleared after order")
            let cartItems = try! self.mockStorageService.cart.toBlocking().first()
            XCTAssertEqual(cartItems?.count, 0, "Cart should be empty")
        }
    }
    
    func testPlaceOrder_InvalidForm_DoesNothing() {
        // Given
        mockStorageService.addToCart(Product.mock())
        
        var orderPlacedCalled = false
        sut.orderPlaced
            .subscribe(onNext: { _ in
                orderPlacedCalled = true
            })
            .disposed(by: disposeBag)
        
        // When
        sut.placeOrder.onNext(())
        
        // Wait a bit
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        XCTAssertFalse(orderPlacedCalled, "Order should not be placed with invalid form")
        XCTAssertFalse(mockStorageService.clearCartCalled, "Cart should not be cleared")
    }
}
