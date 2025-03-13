/**
 * @description Service interface for Order processing operations
 * This interface defines the contract for all Order-related business processes
 */
public interface IOrdersService {
    /**
     * Process the given orders, applying all business rules and validations
     * @param orderIds Set of Order ids to process
     */
    void processOrders(Set<Id> orderIds);
    
    /**
     * Submit orders for approval workflow
     * @param orderIds Set of Order ids to submit
     * @return List of ProcessResult with success/failure information
     */
    List<ProcessResult> submitOrdersForApproval(Set<Id> orderIds);
    
    /**
     * Calculate order totals including line items, tax, and shipping
     * @param orderIds Set of Order ids to calculate totals for
     */
    void calculateOrderTotals(Set<Id> orderIds);
    
    /**
     * Inner class to return processing results
     */
    class ProcessResult {
        public Id recordId { get; private set; }
        public Boolean success { get; private set; }
        public String message { get; private set; }
        
        public ProcessResult(Id recordId, Boolean success, String message) {
            this.recordId = recordId;
            this.success = success;
            this.message = message;
        }
    }
}