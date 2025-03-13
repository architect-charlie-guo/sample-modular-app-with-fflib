# Modular Salesforce Application Example

This example application demonstrates how to use three powerful frameworks together to build a modular, maintainable Salesforce application:

1. **fflib-apex-common** - Provides application architecture patterns including Selector, Domain, Service, and Unit of Work layers
2. **fflib-apex-mocks** - Enables effective unit testing through mocking
3. **force-di** - Implements dependency injection to support modularity and extension points

## Application Overview

This application manages a fictional Order Processing system with:

- Core functionality in the main package
- Extension modules that can be independently developed and deployed
- Clean separation of concerns using the fflib pattern
- Dependency injection to support modularity and testability

## Key Components

### Main Package
- **Application Layer**: Factory methods for accessing functionality
- **Service Layer**: Business processes and orchestration
- **Domain Layer**: SObject-specific business logic
- **Selector Layer**: Database interaction
- **Controllers**: Entry points from UI or API
- **DI Modules**: Binding configurations for the application

### Extension Package
- **Extension Points**: Additional functionality that plugs into the main application
- **Custom Logic**: Business rules specific to extensions

## How It Works

1. **Application Initialization**: DI framework is initialized with module bindings
2. **Request Processing**: Controllers call services through the Application layer
3. **Extension Point Execution**: Custom extensions are discovered and executed
4. **Data Access**: Selectors retrieve data and domain objects apply business rules

## File Structure

```
sample-modular-app-with-fflib/
├── README.md                  # Overview documentation
├── docs/                      # Detailed documentation
│   ├── ARCHITECTURE.md        # Architectural explanation
│   └── architecture.puml      # PlantUML diagram
├── extensions/                # Extension packages
│   ├── compliance/            # Compliance extension
│   │   ├── ComplianceExtension.cls
│   │   └── ComplianceModule.cls
│   └── pricing/               # Pricing extension
│       ├── CustomPricingCalculator.cls
│       └── PricingModule.cls
├── main/                      # Core application package
│   ├── application/           # Application layer
│   │   ├── Application.cls
│   │   ├── Orders.cls
│   │   └── OrderItems.cls
│   ├── controllers/           # API entry points
│   │   └── OrderController.cls
│   ├── di/                    # Dependency injection config
│   │   ├── CoreModule.cls
│   │   ├── OrderManagementApplication.cls
│   │   └── StandardModule.cls
│   ├── domains/               # Domain layer
│   │   └── Orders.cls
│   ├── interfaces/            # Interfaces and contracts
│   │   ├── IAfterOrderProcess.cls
│   │   ├── IBeforeOrderProcess.cls
│   │   ├── IOrders.cls
│   │   ├── IOrderItemsSelector.cls
│   │   ├── IOrdersSelector.cls
│   │   ├── IOrdersService.cls
│   │   └── IPricingCalculator.cls
│   ├── selectors/             # Selector layer
│   │   ├── AccountsSelector.cls
│   │   ├── OrderItemsSelector.cls
│   │   └── OrdersSelector.cls
│   ├── services/              # Service layer
│   │   └── OrdersService.cls
│   └── triggers/              # Triggers
│       └── OrderTrigger.trigger
└── tests/                     # Unit tests
    ├── OrderControllerTest.cls
    └── OrdersServiceTest.cls
```

## Key Design Patterns

- **Dependency Injection**: Using Force-DI to decouple components
- **Factory Pattern**: Application layer provides factory methods
- **Interface-based Design**: All components interact through interfaces
- **Unit of Work**: Managing database operations
- **Domain Model**: Encapsulating business logic
- **Selector Layer**: Centralizing data access

## Testing Strategy

The application uses fflib-apex-mocks to facilitate comprehensive unit testing by:
- Injecting mock implementations through Force-DI
- Testing each layer in isolation
- Creating stubs that verify interactions
