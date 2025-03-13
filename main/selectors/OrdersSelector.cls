/**
 * @description Selector class for Order object
 * Contains all query logic for the Order entity
 */
public class OrdersSelector extends fflib_SObjectSelector implements IOrdersSelector {
    /**
     * Define fields to query by default
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Order.Id,
            Order.AccountId,
            Order.OrderNumber,
            Order.OrderNumber__c,
            Order.Status,
            Order.EffectiveDate,
            Order.Description,
            Order.LastReviewDate__c,
            Order.Subtotal__c,
            Order.TaxAmount__c,
            Order.ShippingAmount__c,
            Order.GrandTotal__c
        };
    }
    
    /**
     * Define the SObject type for this selector
     */
    public Schema.SObjectType getSObjectType() {
        return Order.SObjectType;
    }
    
    /**
     * Select Orders by their Ids
     * @param idSet Set of Order Ids to query
     * @return List of Order records
     */
    public List<Order> selectById(Set<Id> idSet) {
        return (List<Order>) selectSObjectsById(idSet);
    }
    
    /**
     * Select Orders with related OrderItems by Order Ids
     * @param idSet Set of Order Ids to query
     * @return List of Order records with related OrderItems
     */
    public List<Order> selectByIdWithItems(Set<Id> idSet) {
        fflib_QueryFactory ordersQueryFactory = newQueryFactory();
        
        // Add subselect for OrderItems
        ordersQueryFactory.subselectQuery('OrderItems')
            .selectFields(new List<String>{
                'Id', 'OrderId', 'Product2Id', 'Quantity', 
                'UnitPrice', 'TotalPrice', 'Description'
            });
            
        // Set the condition
        ordersQueryFactory.setCondition('Id IN :idSet');
        
        // Execute the query
        return (List<Order>) Database.query(ordersQueryFactory.toSOQL());
    }
    
    /**
     * Select Orders by Account Id
     * @param accountIds Set of Account Ids
     * @return List of Order records for the given accounts
     */
    public List<Order> selectByAccountId(Set<Id> accountIds) {
        return Database.query(
            newQueryFactory()
                .setCondition('AccountId IN :accountIds')
                .toSOQL()
        );
    }
    
    /**
     * Select Orders created between the given dates
     * @param startDate Beginning date range
     * @param endDate Ending date range
     * @return List of Order records created in the date range
     */
    public List<Order> selectByDateRange(Date startDate, Date endDate) {
        return Database.query(
            newQueryFactory()
                .setCondition('EffectiveDate >= :startDate AND EffectiveDate <= :endDate')
                .toSOQL()
        );
    }
}