/**
 * @description Selector interface for OrderItem queries
 * This interface defines the contract for all OrderItem-related database operations
 */
public interface IOrderItemsSelector {
    /**
     * Select OrderItems by their Ids
     * @param idSet Set of OrderItem Ids to query
     * @return List of OrderItem records
     */
    List<OrderItem> selectById(Set<Id> idSet);
    
    /**
     * Select OrderItems by Order Ids
     * @param orderIds Set of Order Ids
     * @return List of OrderItem records for the given orders
     */
    List<OrderItem> selectByOrderId(Set<Id> orderIds);
    
    /**
     * Select OrderItems by Product Ids
     * @param productIds Set of Product Ids
     * @return List of OrderItem records for the given products
     */
    List<OrderItem> selectByProductId(Set<Id> productIds);
}