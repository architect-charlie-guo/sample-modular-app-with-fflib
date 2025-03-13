# Detailed Design Explanation

## Introduction
This document provides an in-depth explanation of the design choices, architecture, and flow of the **Modular Salesforce Application** that utilizes **fflib-apex-common**, **fflib-apex-mocks**, and **force-di** for dependency injection.

## Purpose
The purpose of this detailed design explanation is to:
- Clarify how each layer is structured and how responsibilities are delegated.
- Illustrate how the system leverages dependency injection to maintain modularity.
- Highlight key extension points and how new modules can be added.
- Outline recommended improvements for maintainability, scalability, and testability.

## Overall Architecture
The system is organized around the fflib layers (Domain, Selector, Service, etc.) with a clear separation of concerns:
1. **Application Layer**: High-level entry points and dependency resolution.
2. **Service Layer**: Orchestrates complex business logic and uses Domain and Selector layers.
3. **Domain Layer**: Encapsulates SObject-specific rules and processes (e.g., Orders.cls).
4. **Selector Layer**: Centralized data access methods (e.g., OrdersSelector.cls).
5. **Controller Layer**: Apex classes exposed to UI or external consumers.
6. **Dependency Injection**: Facilitated by Force-DI in classes like StandardModule.cls and CoreModule.cls.
7. **Extensions**: Additional modules that implement extension interfaces and bind them via new di_Module classes.

Below is a high-level flow of an order processing request:
1. **Initialize**: The `OrderManagementApplication.initialize()` method registers DI modules.
2. **Controller**: `OrderController.processOrders()` is called, which delegates to `Orders.service()`.
3. **Service**: `OrdersService.processOrders()` orchestrates domain logic, extension execution, and database interactions.
4. **Domain**: `Orders.cls` applies business rules to the `Order` records.
5. **Extensions**: Custom classes implementing `IBeforeOrderProcess`, `IAfterOrderProcess`, or `IPricingCalculator` are invoked.
6. **Selector**: Retrieves or updates data in the database using query factories or other fflib utilities.
7. **Commit**: The changes are ultimately persisted or rolled back via a Unit of Work (if implemented).

---

## Key Components

### 1. Dependency Injection (DI)
- **`OrderManagementApplication.cls`** is the main initializer, ensuring the DI container is set up with `CoreModule` and `StandardModule`.
- **`CoreModule.cls`**: Binds fundamental or shared interfaces (e.g., extension points).
- **`StandardModule.cls`**: Binds concrete implementations used by the application (e.g., `IOrdersSelector` to `OrdersSelector`).

By using Force-DI, the application stays loosely coupled. Different implementations can be swapped out based on organizational needs or extension packages.

### 2. Extension Modules
- **`ComplianceModule.cls`** registers the `ComplianceExtension.cls` class under `IBeforeOrderProcess`.
- **`PricingModule.cls`** registers custom pricing calculators under `IPricingCalculator`.
- The framework automatically discovers these bindings whenever a new module is registered. The application code in the main package does not require modification to support new extension implementations.

### 3. Service and Domain Layers
- **`OrdersService.cls`** orchestrates order processing:  
  - Retrieves orders (via `Orders.selector()`).
  - Invokes domain logic (via `Orders.domain()`).
  - Executes extension points (like `executeBeforeProcessExtensions()`).
  - Applies business rules and commits changes.  
- **`Orders.cls`** in the `domains` folder encapsulates rules and behaviors for the `Order` object, such as `process()` and `calculateTotals()`.

### 4. Selector Layer
- **`OrdersSelector.cls`**, **`OrderItemsSelector.cls`**, etc., centralize SOQL queries.
- This approach reduces duplication and ensures consistent query logic across the application.

### 5. Controllers
- **`OrderController.cls`** receives requests from LWC, Aura, or external services.
- Each method handles top-level error handling (try/catch) and returns a standardized response object or map to the UI layer.

---

## Recommended Improvements

1. **Advanced Error Handling and Logging**  
   - Introduce a custom exception class (e.g., `OrderProcessingException`) to distinguish business logic errors from technical errors.
   - Implement a logging interface (e.g., `ILogger`) that can be injected, enabling different logging behaviors (to custom objects, external logs, or standard debug).

2. **Batch Processing for Large-Scale Orders**  
   - If the number of orders can grow large, consider a `Queueable` or `Batchable` approach for order processing.  
   - Services can queue asynchronous work for better scalability.

3. **Transactional Control / Unit of Work**  
   - Expand usage of the fflib Unit of Work pattern to group all DML statements in a single transaction and manage rollbacks if needed.
   - This enhances data integrity and performance.

4. **Enhanced Test Coverage**  
   - Create dedicated test classes for each extension module, verifying they handle edge cases.
   - Mock domain and selector layers thoroughly in the service tests to ensure isolation.

5. **Granular Extension Points**  
   - If there is a need to handle partial successes, add extension points for error handling or fallback logic. 
   - This could allow compliance or pricing modules to define custom behaviors when certain records fail to process.

6. **Metadata-Driven Configuration**  
   - For more complex scenarios, consider storing extension configuration or business rules in Custom Metadata Types, making it easier to configure and update the system without code changes.

---

## Adding a New Extension
To illustrate how to add a custom extension for an after-processing workflow:
1. Create a new interface that extends `IAfterOrderProcess` with required methods (if needed).
2. Implement the interface in a new class, e.g., `CustomAfterProcess.cls`.
3. Create a new DI module class, e.g. `CustomAfterProcessModule.cls`, which binds the interface to the implementation.
4. Register the new module by calling `di_Injector.Org.bindModule(new CustomAfterProcessModule())` in your initialization code or packaging scripts.
5. The main system will discover and invoke the new extension automatically whenever order processing completes.

---

## Conclusion
The modular architecture showcased in this application demonstrates how combining fflib-apex-common, fflib-apex-mocks, and force-di can produce a highly maintainable, testable, and extensible Salesforce application. By following the recommended improvements and design considerations, organizations can leverage this pattern to build robust enterprise solutions that adapt to evolving business requirements.
