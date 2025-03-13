/**
 * @description Selector interface for Order queries
 * This interface defines the contract for all Order-related database operations
 */
public interface IOrdersSelector {
    /**
     * Select Orders by their Ids
     * @param idSet Set of Order Ids to query
     * @return List of Order records
     */
    List<Order> selectById(Set<Id> idSet);
    
    /**
     * Select Orders with related OrderItems by Order Ids
     * @param idSet Set of Order Ids to query
     * @return List of Order records with related OrderItems
     */
    List<Order> selectByIdWithItems(Set<Id> idSet);
    
    /**
     * Select Orders by Account Id
     * @param accountIds Set of Account Ids
     * @return List of Order records for the given accounts
     */
    List<Order> selectByAccountId(Set<Id> accountIds);
    
    /**
     * Select Orders created between the given dates
     * @param startDate Beginning date range
     * @param endDate Ending date range
     * @return List of Order records created in the date range
     */
    List<Order> selectByDateRange(Date startDate, Date endDate);
}