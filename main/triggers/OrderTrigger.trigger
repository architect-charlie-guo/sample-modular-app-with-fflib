/**
 * @description Trigger for Order object
 * Delegates processing to the domain layer
 */
trigger OrderTrigger on Order (
    before insert, before update, before delete, 
    after insert, after update, after delete, after undelete
) {
    // Initialize the application if not already done
    if (!OrderManagementApplication.isInitialized()) {
        OrderManagementApplication.initialize();
    }
    
    // Create the domain instance for these orders
    IOrders orders = Orders.domain(Trigger.new);
    
    // Dispatch trigger event to the domain class
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            // Initialize new orders
            orders.generateOrderNumbers();
        }
        else if (Trigger.isUpdate) {
            // Apply business rules
            orders.process();
        }
        else if (Trigger.isDelete) {
            // Handle deletions if needed
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // Post-processing for new orders
        }
        else if (Trigger.isUpdate) {
            // Post-processing for updated orders
        }
        else if (Trigger.isDelete) {
            // Post-processing for deleted orders
        }
        else if (Trigger.isUndelete) {
            // Post-processing for undeleted orders
        }
    }
}