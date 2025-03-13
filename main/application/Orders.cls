/**
 * @description Application layer for Order-related operations
 * This class provides factory methods that use Force-DI to resolve implementations
 */
public class Orders {
    /**
     * Get the Order service implementation
     * @return Implementation of IOrdersService
     */
    public static IOrdersService service() {
        return (IOrdersService) di_Injector.Org.getInstance(IOrdersService.class);
    }
    
    /**
     * Get the Order selector implementation
     * @return Implementation of IOrdersSelector
     */
    public static IOrdersSelector selector() {
        return (IOrdersSelector) di_Injector.Org.getInstance(IOrdersSelector.class);
    }
    
    /**
     * Create a new domain instance for the given Order records
     * @param records List of Order records
     * @return Implementation of IOrders
     */
    public static IOrders domain(List<Order> records) {
        return (IOrders) Application.Domain.newInstance(records);
    }
    
    /**
     * Create a new domain instance for the given Order ids
     * @param orderIds Set of Order ids
     * @return Implementation of IOrders
     */
    public static IOrders newInstance(Set<Id> orderIds) {
        return domain(selector().selectById(orderIds));
    }
}