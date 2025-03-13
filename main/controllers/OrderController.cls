/**
 * @description Controller for Order-related operations
 * Entry point for API or UI interactions
 */
public with sharing class OrderController {
    /**
     * Process the specified orders
     * @param orderIds List of Order Ids to process
     * @return ProcessResult with success/failure information
     */
    @AuraEnabled
    public static Map<String, Object> processOrders(List<Id> orderIds) {
        Map<String, Object> result = new Map<String, Object>{
            'success' => true,
            'message' => 'Orders processed successfully'
        };
        
        try {
            // Call through application layer to service
            Orders.service().processOrders(new Set<Id>(orderIds));
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Error processing orders: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * Submit orders for approval
     * @param orderIds List of Order Ids to submit
     * @return List of ProcessResult with detailed results for each order
     */
    @AuraEnabled
    public static List<Map<String, Object>> submitOrdersForApproval(List<Id> orderIds) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        try {
            // Call through application layer to service
            List<IOrdersService.ProcessResult> serviceResults = 
                Orders.service().submitOrdersForApproval(new Set<Id>(orderIds));
            
            // Convert service results to format suitable for UI
            for(IOrdersService.ProcessResult serviceResult : serviceResults) {
                results.add(new Map<String, Object>{
                    'recordId' => serviceResult.recordId,
                    'success' => serviceResult.success,
                    'message' => serviceResult.message
                });
            }
        } catch (Exception e) {
            // If an exception occurs, return error for all orders
            for(Id orderId : orderIds) {
                results.add(new Map<String, Object>{
                    'recordId' => orderId,
                    'success' => false,
                    'message' => 'Error: ' + e.getMessage()
                });
            }
        }
        
        return results;
    }
    
    /**
     * Calculate order totals
     * @param orderIds List of Order Ids to calculate totals for
     * @return Map with success/failure information
     */
    @AuraEnabled
    public static Map<String, Object> calculateOrderTotals(List<Id> orderIds) {
        Map<String, Object> result = new Map<String, Object>{
            'success' => true,
            'message' => 'Order totals calculated successfully'
        };
        
        try {
            // Call through application layer to service
            Orders.service().calculateOrderTotals(new Set<Id>(orderIds));
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Error calculating order totals: ' + e.getMessage());
        }
        
        return result;
    }
}