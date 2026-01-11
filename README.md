# 🛍️ E-Commerce iOS Application

<div align="center">

A modern, feature-rich iOS e-commerce application built with **Swift** and **RxSwift**, demonstrating industry-standard architecture patterns, reactive programming, and best practices.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://www.apple.com/ios/)
[![RxSwift](https://img.shields.io/badge/RxSwift-6.9.1-red.svg)](https://github.com/ReactiveX/RxSwift)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📱 Overview

This project is a comprehensive e-commerce iOS application developed as a case study, showcasing modern iOS development practices, clean architecture, and reactive programming paradigms. The app provides a complete shopping experience with product browsing, search, filtering, favorites, shopping cart, and checkout functionality.

### ✨ Key Highlights

- 🏗️ **Clean Architecture** - MVVM pattern with clear separation of concerns
- ⚡ **Reactive Programming** - RxSwift for asynchronous operations and data binding
- 🧪 **Comprehensive Testing** - Unit tests with 70%+ coverage
- 🎨 **Modern UI/UX** - Programmatic UI with smooth animations and haptic feedback
- 📦 **Dependency Injection** - Protocol-based architecture for testability
- 🔄 **Real-time Updates** - Reactive data flow with BehaviorRelay
- 💾 **Local Persistence** - UserDefaults for cart and favorites
- 🌐 **RESTful API Integration** - Clean network layer with error handling
- 📊 **Comprehensive Logging** - Detailed logging for debugging and monitoring

---

## 🎯 Features

### 🛒 Core Shopping Features

- **Product Listing**
  - Infinite scroll pagination
  - Pull-to-refresh
  - Product grid with images, prices, and ratings
  - Real-time favorite status updates
  - Empty state handling

- **Product Search**
  - Debounced search (300ms)
  - Real-time search results
  - Keyboard dismissal (tap outside, scroll, search button)
  - Clear search on pull-to-refresh

- **Product Sorting**
  - Sort by price (low to high, high to low)
  - Sort by rating
  - Sort by popularity
  - API-based sorting with server-side support

- **Product Filtering**
  - Category-based filtering
  - Combine search + filter (hybrid approach)
  - Visual feedback for active filters
  - Reset functionality with immediate application

- **Product Details**
  - Image carousel with multiple product images
  - Detailed product information
  - Discount price calculation
  - Stock availability
  - Add to cart functionality
  - Add/remove from favorites
  - Smooth animations and transitions

### 💝 Favorites

- Add/remove products to favorites
- Persistent storage (survives app restarts)
- Real-time synchronization across screens
- Badge count on tab bar
- Empty state with call-to-action

### 🛍️ Shopping Cart

- Add/remove items
- Quantity management (increment/decrement)
- Real-time total price calculation
- Persistent cart (survives app restarts)
- Badge count on tab bar
- Empty state handling
- Price formatting (2 decimal places)

### 💳 Checkout

- Order summary
  - Subtotal calculation
  - Tax calculation (18%)
  - Total price
- Form validation
  - Email validation (regex-based)
  - Real-time validation feedback
  - Required field validation
- Payment methods
  - Credit/Debit Card
  - PayPal
  - Apple Pay (UI ready)
- Order confirmation
  - Success state
  - Clear cart after order

### 🎨 User Experience

- **Splash Screen**
  - Logo animation
  - Loading indicator
  - Smooth transition to main app

- **Tab Bar Navigation**
  - Products, Favorites, Cart tabs
  - Real-time badge updates
  - Custom appearance (opaque, shadows)

- **Loading States**
  - Skeleton loading for product list
  - Loading indicators for pagination
  - Activity indicators for async operations

- **Empty States**
  - Contextual empty state messages
  - Call-to-action buttons
  - Professional design

- **Animations & Feedback**
  - Smooth transitions
  - Haptic feedback on interactions
  - Toast messages for user actions
  - Fade-in/fade-out animations

- **Accessibility**
  - Dynamic Type support
  - VoiceOver ready
  - High contrast support
  - Dark mode support

---

## 🏗️ Architecture

The application follows the **MVVM (Model-View-ViewModel)** architecture pattern combined with **RxSwift** for reactive programming.

### Architecture Layers

```
┌─────────────────────────────────────────┐
│           View (UI Layer)               │
│  ViewControllers, Custom Views          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│        ViewModel (Logic Layer)          │
│  Business Logic, Data Transformation    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Repository (Data Layer)            │
│  Data Abstraction, Source Management    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│   Service (Network/Storage Layer)       │
│  API Calls, Local Storage               │
└─────────────────────────────────────────┘
```

### Design Patterns

- **MVVM (Model-View-ViewModel)** - Separation of UI and business logic
- **Repository Pattern** - Abstraction of data sources
- **Dependency Injection** - Protocol-based DI for testability
- **Observer Pattern** - RxSwift observables for reactive programming
- **Singleton Pattern** - Shared services (Logger, StorageService)
- **Strategy Pattern** - Payment methods, sorting strategies

### Data Flow

1. **View** → User interaction triggers action
2. **ViewModel** → Processes action, updates observables
3. **Repository** → Fetches/updates data from service
4. **Service** → API call or local storage operation
5. **Repository** → Returns data/error
6. **ViewModel** → Transforms data, updates state
7. **View** → Observes ViewModel, updates UI

---

## 🛠️ Tech Stack

### Core Technologies

- **Swift 5.9+** - Modern Swift with latest features
- **iOS 15.0+** - Support for modern iOS versions
- **Xcode 15+** - Latest Xcode development tools

### Frameworks & Libraries

- **RxSwift 6.9.1** - Reactive extensions for Swift
  - Observable sequences
  - BehaviorRelay for state management
  - Operators (map, filter, debounce, catch, etc.)
  
- **RxCocoa 6.9.1** - RxSwift extensions for Cocoa
  - UI binding
  - Driver and Signal for UI updates
  
- **Kingfisher 8.6.2** - Async image downloading and caching
  - Image loading and caching
  - Placeholder and error handling
  - Memory and disk cache management

### Native iOS Frameworks

- **UIKit** - User interface (programmatic)
- **Foundation** - Core functionality
- **Combine** - (for future enhancements)

---

## 📁 Project Structure

```
EnUygunBerkayKayaCase/
├── App/
│   ├── AppDelegate.swift          # App lifecycle
│   └── SceneDelegate.swift        # Scene configuration, TabBar setup
│
├── Scenes/
│   ├── Splash/
│   │   └── SplashViewController.swift
│   ├── ProductList/
│   │   ├── ProductListViewController.swift
│   │   ├── ProductListViewModel.swift
│   │   └── ProductCell.swift
│   ├── ProductDetail/
│   │   ├── ProductDetailViewController.swift
│   │   └── ProductDetailViewModel.swift
│   ├── Favorites/
│   │   ├── FavoritesViewController.swift
│   │   └── FavoritesViewModel.swift
│   ├── Cart/
│   │   ├── CartViewController.swift
│   │   ├── CartViewModel.swift
│   │   └── CartItemCell.swift
│   ├── Checkout/
│   │   ├── CheckoutViewController.swift
│   │   └── CheckoutViewModel.swift
│   ├── Filter/
│   │   ├── FilterViewController.swift
│   │   └── FilterViewModel.swift
│   └── Components/
│       ├── EmptyStateView.swift
│       └── LoadingView.swift
│
├── Models/
│   ├── Product.swift              # Product, ProductResponse, Review
│   ├── CartItem.swift             # Shopping cart item
│   ├── Category.swift             # Product category
│   └── FilterOptions.swift        # Filter configuration
│
├── Network/
│   ├── APIClient.swift            # HTTP client with RxSwift
│   ├── APIError.swift             # Error handling
│   ├── Endpoints/
│   │   └── APIEndpoint.swift      # URL endpoint definitions
│   └── Services/
│       ├── ProductService.swift   # Product API service
│       └── StorageService.swift   # Local storage (UserDefaults)
│
├── Repositories/
│   └── ProductRepository.swift    # Data abstraction layer
│
└── Common/
    ├── Constants/
    │   └── Constants.swift        # App-wide constants
    ├── Extensions/
    │   ├── String+Extensions.swift
    │   ├── Double+Extensions.swift
    │   └── UIView+Layout.swift    # Auto Layout helpers
    └── Logger.swift               # Logging utility
```

### Test Structure

```
EnUygunBerkayKayaCaseTests/
├── ViewModels/
│   ├── ProductListViewModelTests.swift
│   ├── ProductDetailViewModelTests.swift
│   ├── CartViewModelTests.swift
│   ├── CheckoutViewModelTests.swift
│   ├── FavoritesViewModelTests.swift
│   └── FilterViewModelTests.swift
├── Services/
│   └── StorageServiceTests.swift
├── Mocks/
│   ├── MockProductRepository.swift
│   └── MockStorageService.swift
└── Helpers/
    └── TestHelpers.swift
```

---

## 🚀 Getting Started

### Prerequisites

- **macOS** 13.0 or later
- **Xcode** 15.0 or later
- **iOS Simulator** or physical device running iOS 15.0+
- **Swift Package Manager** (included with Xcode)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd EnUygunBerkayKayaCase
   ```

2. **Open the project**
   ```bash
   open EnUygunBerkayKayaCase.xcodeproj
   ```

3. **Resolve dependencies**
   - Xcode will automatically resolve Swift Package Manager dependencies
   - Wait for packages to download (RxSwift, RxCocoa, Kingfisher)

4. **Build and Run**
   - Select a simulator or device
   - Press `Cmd + R` or click the Run button
   - The app will launch with the splash screen

### Configuration

The app uses the **DummyJSON API** (`https://dummyjson.com`) for product data. No API keys or configuration required.

---

## 📖 Usage

### Running the App

1. Launch the app → Splash screen appears
2. After 2.5 seconds → Main app loads with TabBar
3. Navigate between tabs:
   - **Products** - Browse and search products
   - **Favorites** - View favorite products
   - **Cart** - Manage shopping cart

### Key Interactions

- **Search**: Tap search bar, type query (debounced)
- **Filter**: Tap filter button, select category, apply
- **Sort**: Available in product list (when implemented)
- **Add to Cart**: Tap product → Detail screen → Add to Cart
- **Favorite**: Tap heart icon on product or detail screen
- **Checkout**: Cart screen → Checkout → Fill form → Place Order

---

## 🧪 Testing

The project includes comprehensive unit tests with **70%+ code coverage**.

### Running Tests

1. **Run all tests**
   ```bash
   Cmd + U
   ```
   Or use Test Navigator in Xcode

2. **Run specific test class**
   - Open test file
   - Click diamond icon next to class name

3. **Run single test**
   - Click diamond icon next to test method

### Test Coverage

- ✅ **ViewModels** - Business logic testing
  - ProductListViewModel
  - ProductDetailViewModel
  - CartViewModel
  - CheckoutViewModel
  - FavoritesViewModel
  - FilterViewModel

- ✅ **Services** - Data layer testing
  - StorageService (Cart, Favorites)

- ✅ **Mock Objects** - Dependency injection for testing
  - MockProductRepository
  - MockStorageService

### Testing Approach

- **RxBlocking** - Testing Observable sequences
- **RxTest** - Testing reactive streams
- **XCTest** - Standard iOS testing framework
- **Mock Objects** - Protocol-based mocking for DI

---

## 🔑 Key Implementation Details

### Reactive Programming with RxSwift

- **Observables** for async operations (network, storage)
- **BehaviorRelay** for state management (cart, favorites)
- **Drivers** for UI updates (safe on main thread)
- **Operators** for data transformation (map, filter, debounce)

### Network Layer

- **Protocol-based** APIClient for testability
- **URLSession** for HTTP requests
- **Codable** for JSON parsing
- **Error handling** with custom APIError enum
- **Request/Response logging** for debugging

### Local Storage

- **UserDefaults** for persistence
- **JSON encoding/decoding** for complex objects
- **Reactive updates** with BehaviorRelay
- **Thread-safe** operations

### UI Architecture

- **100% Programmatic UI** - No Storyboards or XIBs
- **Auto Layout** - Programmatic constraints
- **Extension helpers** - UIView+Layout for cleaner code
- **Reusable components** - EmptyStateView, LoadingView
- **Modern APIs** - UIButton.Configuration (iOS 15+)

### Error Handling

- **Centralized error handling** in ViewModels
- **User-friendly error messages**
- **Retry mechanisms** where appropriate
- **Network error detection**
- **Empty state handling**

### Performance Optimizations

- **Image caching** with Kingfisher
- **Debounced search** (300ms) to reduce API calls
- **Pagination** for efficient data loading
- **Lazy loading** of images
- **Memory management** with weak references

---

### Screens Overview

- Splash Screen
- Product List with Search
- Product Detail
- Shopping Cart
- Favorites
- Checkout
- Filter Sheet

---

## 📝 Code Quality

### Best Practices

- ✅ **Clean Code** - Readable, maintainable code
- ✅ **SOLID Principles** - Single responsibility, dependency inversion
- ✅ **DRY** - Don't Repeat Yourself
- ✅ **Naming Conventions** - Clear, descriptive names
- ✅ **Comments** - Documented complex logic
- ✅ **Error Handling** - Comprehensive error management
- ✅ **Memory Management** - ARC, weak references
- ✅ **Thread Safety** - Main thread for UI updates

### Code Style

- Swift naming conventions
- MARK comments for organization
- Consistent formatting
- Clear file structure
- Protocol-oriented programming

---

## 🤝 Contributing

This is a case study project. For questions or suggestions:

1. Open an issue
2. Provide detailed description
3. Include code examples if applicable

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- **DummyJSON** - For providing free test API
- **RxSwift Community** - For excellent reactive programming library
- **Kingfisher** - For powerful image loading and caching
- **EnUygun** - For the case study opportunity

---

## 📚 Resources

- [RxSwift Documentation](https://github.com/ReactiveX/RxSwift)
- [MVVM Pattern](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [Swift Package Manager](https://www.swift.org/package-manager/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)

---

<div align="center">

**Built with using Swift and RxSwift**

⭐ Star this repo if you found it helpful!

</div>
