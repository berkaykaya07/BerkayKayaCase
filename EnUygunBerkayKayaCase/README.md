# 🛍️ EnUygun iOS Case Study

Modern iOS e-commerce application built for EnUygun.

## 🎯 Project Overview

A full-featured e-commerce iOS application with product browsing, shopping cart, favorites management, and checkout functionality.

## 🏗️ Architecture

- **Pattern**: MVVM (Model-View-ViewModel)
- **Reactive Programming**: RxSwift & RxCocoa
- **UI**: Programmatic Auto Layout (No Storyboards)
- **Network**: Native URLSession with Generic Layer
- **Storage**: UserDefaults + Codable for persistence

## ✨ Features

- [x] Product listing with search, filter, and sort
- [x] Debounced search (300ms)
- [x] Pull to refresh
- [x] Infinite scroll pagination
- [x] Product detail with image carousel
- [x] Shopping cart management
- [x] Favorites system
- [x] Form validation on checkout
- [x] Persistent cart and favorites
- [x] Real-time badge updates
- [x] Skeleton loading states
- [x] Empty state views
- [x] Dark mode support

## 🛠️ Technologies

- **Language**: Swift 5.9+
- **Minimum iOS**: 15.0
- **Dependencies**:
  - RxSwift 6.6+
  - RxCocoa
  - Kingfisher 7.10+ (Image caching)

## 📊 Code Quality

- **Unit Test Coverage**: 70%+
- **Code Style**: SwiftLint
- **Architecture**: Clean MVVM with Repository Pattern

## 🚀 Setup Instructions

1. Clone the repository
```bash
git clone [repository-url]
cd EnUygunBerkayKayaCase
```

2. Open the project
```bash
open EnUygunBerkayKayaCase.xcodeproj
```

3. Dependencies are managed via Swift Package Manager
   - RxSwift will be automatically resolved
   - Kingfisher will be automatically resolved

4. Build and Run
   - Select simulator or device
   - Press Cmd + R

No CocoaPods or Carthage needed! ✅

## 📱 Screens

1. **Product List** - Browse all products with search and filters
2. **Product Detail** - View product details with image carousel
3. **Cart** - Manage shopping cart items
4. **Favorites** - View and manage favorite products
5. **Checkout** - Complete order with form validation
6. **Filter** - Advanced product filtering

## 🧪 Testing

Run tests with:
```bash
Cmd + U
```

## 📄 API

Using DummyJSON API: https://dummyjson.com

## 👨‍💻 Developer

**Berkay Kaya**

---

*This project is a case study for EnUygun.*
