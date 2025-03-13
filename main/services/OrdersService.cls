/**
 * @description Standard implementation of IOrdersService
 * This class orchestrates the order processing flow
 */
public class OrdersService implements IOrdersService {
    /**
     * Process the given orders, applying all business rules and validations
     * @param orderIds Set of Order ids to process
     */
    public void processOrders(Set<Id> orderIds) {
        // Get Unit of Work
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Get orders using selector
        List<Order> orders = Orders.selector().selectByIdWithItems(orderIds);
        
        // Execute all "before process" extension point implementations
        executeBeforeProcessExtensions(orders);
        
        // Apply domain logic through the domain layer
        IOrders ordersDomain = Orders.domain(orders);
        ordersDomain.process();
        
        // Calculate order totals
        ordersDomain.calculateTotals();
        
        // Validate orders
        List<IOrders.ValidationResult> validationResults = ordersDomain.validate();
        
        // Check for validation errors
        for(IOrders.ValidationResult result : validationResults) {
            if(!result.isValid) {
                throw new OrderProcessingException(result.errorMessage);
            }
        }
        
        // Register work and commit
        uow.registerDirty(orders);
        uow.commitWork();
        
        // Execute all "after process" extension point implementations
        executeAfterProcessExtensions(orders);
    }
    
    /**
     * Submit orders for approval workflow
     * @param orderIds Set of Order ids to submit
     * @return List of ProcessResult with success/failure information
     */
    public List<ProcessResult> submitOrdersForApproval(Set<Id> orderIds) {
        List<ProcessResult> results = new List<ProcessResult>();
        
        // Get orders using selector
        List<Order> orders = Orders.selector().selectById(orderIds);
        
        // Apply domain logic to validate before submission
        IOrders ordersDomain = Orders.domain(orders);
        List<IOrders.ValidationResult> validationResults = ordersDomain.validate();
        
        // Create approval requests for valid orders
        for(Order ord : orders) {
            // Find validation result for this order
            Boolean isValid = true;
            String errorMessage = '';
            
            for(IOrders.ValidationResult validationResult : validationResults) {
                if(validationResult.recordId == ord.Id && !validationResult.isValid) {
                    isValid = false;
                    errorMessage = validationResult.errorMessage;
                    break;
                }
            }
            
            if(isValid) {
                // In a real implementation, this would submit to approval process
                // For demo purposes, we're just returning success
                results.add(new ProcessResult(ord.Id, true, 'Successfully submitted for approval'));
            } else {
                results.add(new ProcessResult(ord.Id, false, 'Validation failed: ' + errorMessage));
            }
        }
        
        return results;
    }
    
    /**
     * Calculate order totals including line items, tax, and shipping
     * @param orderIds Set of Order ids to calculate totals for
     */
    public void calculateOrderTotals(Set<Id> orderIds) {
        // Get Unit of Work
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Get orders with items using selector
        List<Order> orders = Orders.selector().selectByIdWithItems(orderIds);
        
        // Calculate totals through domain layer
        IOrders ordersDomain = Orders.domain(orders);
        ordersDomain.calculateTotals();
        
        // Register work and commit
        uow.registerDirty(orders);
        uow.commitWork();
    }
    
    /**
     * Execute all registered BeforeOrderProcess extensions
     * @param orders List of orders to pass to extensions
     */
    private void executeBeforeProcessExtensions(List<Order> orders) {
        // Get all extension point implementations using Force-DI
        List<di_Binding> beforeProcessBindings = 
            di_Injector.Org.Bindings.byType(IBeforeOrderProcess.class).get();
        
        // Execute each extension
        for(di_Binding binding : beforeProcessBindings) {
            IBeforeOrderProcess extension = (IBeforeOrderProcess)binding.getInstance();
            extension.beforeProcess(orders);
        }
    }
    
    /**
     * Execute all registered AfterOrderProcess extensions
     * @param orders List of orders to pass to extensions
     */
    private void executeAfterProcessExtensions(List<Order> orders) {
        // Get all extension point implementations using Force-DI
        List<di_Binding> afterProcessBindings = 
            di_Injector.Org.Bindings.byType(IAfterOrderProcess.class).get();
        
        // Execute each extension
        for(di_Binding binding : afterProcessBindings) {
            IAfterOrderProcess extension = (IAfterOrderProcess)binding.getInstance();
            extension.afterProcess(orders);
        }
    }
    
    /**
     * Custom exception for order processing errors
     */
    public class OrderProcessingException extends Exception {}
}