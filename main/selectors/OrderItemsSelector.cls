/**
 * @description Selector class for OrderItem object
 * Contains all query logic for the OrderItem entity
 */
public class OrderItemsSelector extends fflib_SObjectSelector implements IOrderItemsSelector {
    /**
     * Define fields to query by default
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            OrderItem.Id,
            OrderItem.OrderId,
            OrderItem.Product2Id,
            OrderItem.Quantity,
            OrderItem.UnitPrice,
            OrderItem.TotalPrice,
            OrderItem.Description
        };
    }
    
    /**
     * Define the SObject type for this selector
     */
    public Schema.SObjectType getSObjectType() {
        return OrderItem.SObjectType;
    }
    
    /**
     * Select OrderItems by their Ids
     * @param idSet Set of OrderItem Ids to query
     * @return List of OrderItem records
     */
    public List<OrderItem> selectById(Set<Id> idSet) {
        return (List<OrderItem>) selectSObjectsById(idSet);
    }
    
    /**
     * Select OrderItems by Order Ids
     * @param orderIds Set of Order Ids
     * @return List of OrderItem records for the given orders
     */
    public List<OrderItem> selectByOrderId(Set<Id> orderIds) {
        return Database.query(
            newQueryFactory()
                .setCondition('OrderId IN :orderIds')
                .toSOQL()
        );
    }
    
    /**
     * Select OrderItems by Product Ids
     * @param productIds Set of Product Ids
     * @return List of OrderItem records for the given products
     */
    public List<OrderItem> selectByProductId(Set<Id> productIds) {
        return Database.query(
            newQueryFactory()
                .setCondition('Product2Id IN :productIds')
                .toSOQL()
        );
    }
}