# Modular Salesforce Application Architecture

This document explains the architecture of the modular Order Management application, which demonstrates how to use the fflib-apex-common, fflib-apex-mocks, and force-di frameworks together.

## Overview

The application implements a modular architecture for order processing, with the following key features:

1. **Layered Architecture**: Using fflib patterns to separate concerns
2. **Dependency Injection**: Using Force-DI to provide modularity and extensibility
3. **Extension Points**: Allowing other packages to extend functionality
4. **Unit Testing**: Using fflib-apex-mocks for comprehensive testing

## Key Components

### Application Layer

The Application layer serves as the entry point to the system's functionality and provides factory methods that use Force-DI to resolve implementations.

Key classes:
- `Application.cls`: Core factory methods for fflib patterns
- `Orders.cls`: Factory methods specific to Order functionality

Example:
```apex
// Accessing functionality through the application layer
Orders.service().processOrders(orderIds);
```

### Service Layer

The Service layer orchestrates business processes and handles coordinating the various components.

Key classes:
- `OrdersService.cls`: Implements order processing workflows

Example:
```apex
public void processOrders(Set<Id> orderIds) {
    // Get orders using selector
    List<Order> orders = Orders.selector().selectByIdWithItems(orderIds);
    
    // Execute extension points
    executeBeforeProcessExtensions(orders);
    
    // Apply domain logic
    IOrders ordersDomain = Orders.domain(orders);
    ordersDomain.process();
    
    // More processing...
}
```

### Domain Layer

The Domain layer contains business logic specific to the Order entity.

Key classes:
- `Orders.cls`: Domain implementation for Order object

Example:
```apex
public void calculateTotals() {
    for(Order record : (List<Order>) Records) {
        // Calculate totals with business rules
        
        // Use extension point for pricing if available
        IPricingCalculator pricingCalculator = getPricingCalculator();
        if(pricingCalculator != null) {
            // Use custom pricing logic
        } else {
            // Use default pricing logic
        }
    }
}
```

### Selector Layer

The Selector layer centralizes all database access.

Key classes:
- `OrdersSelector.cls`: Queries for Order data
- `OrderItemsSelector.cls`: Queries for OrderItem data

Example:
```apex
public List<Order> selectByIdWithItems(Set<Id> idSet) {
    fflib_QueryFactory ordersQueryFactory = newQueryFactory();
    
    // Add subselect for OrderItems
    ordersQueryFactory.subselectQuery('OrderItems')
        .selectFields(new List<String>{'Id', 'Quantity', 'UnitPrice'});
        
    // Set the condition
    ordersQueryFactory.setCondition('Id IN :idSet');
    
    // Execute the query
    return (List<Order>) Database.query(ordersQueryFactory.toSOQL());
}
```

### Controllers

Controllers serve as entry points from the UI or APIs.

Key classes:
- `OrderController.cls`: Entry point for order operations

Example:
```apex
@AuraEnabled
public static Map<String, Object> processOrders(List<Id> orderIds) {
    try {
        // Call through application layer
        Orders.service().processOrders(new Set<Id>(orderIds));
        return new Map<String, Object>{'success' => true};
    } catch (Exception e) {
        return new Map<String, Object>{'success' => false, 'message' => e.getMessage()};
    }
}
```

## Dependency Injection

The application uses Force-DI to provide dependency injection, which enables:

1. **Runtime resolution of implementations**
2. **Loosely coupled components**
3. **Extension points for modular development**

Key classes:
- `OrderManagementApplication.cls`: Initializes DI framework
- `CoreModule.cls`: Registers core extension points
- `StandardModule.cls`: Binds standard implementations

Example:
```apex
// Binding implementations
public class StandardModule extends di_Module {
    public override void configure() {
        // Bind service implementations
        bind(IOrdersService.class).to(OrdersService.class);
        
        // Bind selector implementations
        bind(IOrdersSelector.class).to(OrdersSelector.class);
    }
}
```

## Extension Points

Extension points allow other packages to add functionality without modifying core code.

Key interfaces:
- `IBeforeOrderProcess.cls`: Extension point for pre-processing
- `IAfterOrderProcess.cls`: Extension point for post-processing
- `IPricingCalculator.cls`: Extension point for custom pricing

Example:
```apex
// Registering an extension
public class ComplianceModule extends di_Module {
    public override void configure() {
        bind(IBeforeOrderProcess.class).to(ComplianceExtension.class);
    }
}

// Using extensions
private void executeBeforeProcessExtensions(List<Order> orders) {
    List<di_Binding> beforeProcessBindings = 
        di_Injector.Org.Bindings.byType(IBeforeOrderProcess.class).get();
    
    // Execute each extension
    for(di_Binding binding : beforeProcessBindings) {
        IBeforeOrderProcess extension = (IBeforeOrderProcess)binding.getInstance();
        extension.beforeProcess(orders);
    }
}
```

## Unit Testing

The application uses fflib-apex-mocks to facilitate comprehensive unit testing.

Key testing patterns:
- **Mock Services**: Testing controllers in isolation
- **Mock Selectors**: Testing services without database
- **Mock Domains**: Testing service orchestration

Example:
```apex
@isTest
static void testProcessOrders() {
    // Set up mocks
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    MockOrdersSelector selectorMock = new MockOrdersSelector(mocks);
    
    // Register mocks with Force-DI
    di_Injector.Org.Bindings.clear();
    di_Injector.Org.Bindings
        .bind(IOrdersSelector.class)
        .toObject(selectorMock);
    
    // Test the service
    IOrdersService service = new OrdersService();
    service.processOrders(new Set<Id>{ testOrder.Id });
    
    // Verify interactions
    ((IOrdersSelector)mocks.verify(selectorMock, 1))
        .selectByIdWithItems(new Set<Id>{ testOrder.Id });
}
```

## Flow Diagram

The application follows this general flow:

1. **Initialization**: 
   - DI modules register bindings
   - Extension modules register implementations

2. **Request Processing**:
   - Controller receives request
   - Application layer resolves implementations
   - Service orchestrates processing
   - Extension points are executed
   - Domain logic is applied
   - Selector retrieves data
   - Unit of Work commits changes

3. **Testing**:
   - Mocks are injected through DI
   - Components are tested in isolation
   - Interactions are verified

## Benefits of This Architecture

- **Modularity**: Components can be developed and deployed independently
- **Testability**: Each layer can be tested in isolation
- **Maintainability**: Clear separation of concerns
- **Extensibility**: Other packages can add functionality without modifying core code
- **Consistency**: Standard patterns across the application

## Conclusion

This architecture demonstrates how the fflib-apex-common, fflib-apex-mocks, and force-di frameworks can be combined to create a modular, maintainable, and extensible Salesforce application. By following these patterns, developers can build enterprise-grade applications that are easier to maintain and extend over time.