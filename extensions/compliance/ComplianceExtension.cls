/**
 * @description Extension implementation for compliance checks
 * This extension adds compliance validation before orders are processed
 */
public class ComplianceExtension implements IBeforeOrderProcess {
    /**
     * Execute compliance checks before standard order processing
     * @param orders List of Order records being processed
     */
    public void beforeProcess(List<Order> orders) {
        // Apply compliance rules to each order
        for(Order order : orders) {
            // Add compliance information
            order.Description = order.Description != null ? 
                order.Description + ' | Compliance checked: ' + System.now() :
                'Compliance checked: ' + System.now();
            
            // Example: Mark high-value orders for additional review
            if(order.GrandTotal__c != null && order.GrandTotal__c > 10000) {
                order.ComplianceStatus__c = 'Review Required';
                order.ComplianceNotes__c = 'High-value order requires additional verification';
            } else {
                order.ComplianceStatus__c = 'Approved';
            }
            
            // Example: Add industry-specific compliance notes
            if(order.Account.Industry == 'Healthcare') {
                order.ComplianceNotes__c = (order.ComplianceNotes__c != null ? 
                    order.ComplianceNotes__c + ' | ' : '') + 'HIPAA compliance required';
            } else if(order.Account.Industry == 'Financial Services') {
                order.ComplianceNotes__c = (order.ComplianceNotes__c != null ? 
                    order.ComplianceNotes__c + ' | ' : '') + 'Financial regulations apply';
            }
        }
    }
}