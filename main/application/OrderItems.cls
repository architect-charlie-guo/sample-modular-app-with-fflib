/**
 * @description Application layer for OrderItem-related operations
 * This class provides factory methods that use Force-DI to resolve implementations
 */
public class OrderItems {
    /**
     * Get the OrderItem selector implementation
     * @return Implementation of IOrderItemsSelector
     */
    public static IOrderItemsSelector selector() {
        return (IOrderItemsSelector) di_Injector.Org.getInstance(IOrderItemsSelector.class);
    }
    
    /**
     * Create a new domain instance for the given OrderItem records
     * @param records List of OrderItem records
     * @return Implementation of IOrderItems (if defined, otherwise a generic fflib_SObjectDomain)
     */
    public static fflib_SObjectDomain domain(List<OrderItem> records) {
        return (fflib_SObjectDomain) Application.Domain.newInstance(records);
    }
}