/**
 * @description Main Application class that serves as the entry point to the application
 * This class provides static factory methods for accessing application components
 */
public class Application {
    /**
     * Factory method for unit of work
     */
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType>{
                Account.SObjectType,
                Order.SObjectType,
                OrderItem.SObjectType
            });
    
    /**
     * Factory method for domain layer
     */
    public static final fflib_Application.DomainFactory Domain =
        new fflib_Application.DomainFactory(
            new Map<SObjectType, Type>{
                Order.SObjectType => Orders.Constructor.class,
                OrderItem.SObjectType => OrderItems.Constructor.class
            });
    
    /**
     * Factory method for selector layer
     */
    public static final fflib_Application.SelectorFactory Selector =
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type>{
                Account.SObjectType => AccountsSelector.class,
                Order.SObjectType => OrdersSelector.class,
                OrderItem.SObjectType => OrderItemsSelector.class
            });
    
    /**
     * Factory method for service layer
     */
    public static final fflib_Application.ServiceFactory Service =
        new fflib_Application.ServiceFactory(
            new Map<Type, Type>{
                IOrdersService.class => OrdersService.class
            });
}