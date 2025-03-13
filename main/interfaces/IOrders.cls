/**
 * @description Domain interface for Order object
 * This interface defines the contract for Order-specific business logic
 */
public interface IOrders {
    /**
     * Apply all business rules to the Orders
     */
    void process();
    
    /**
     * Calculate totals for Orders including tax and shipping
     */
    void calculateTotals();
    
    /**
     * Validate Orders meet all business requirements
     * @return ValidationResult with details on any validation issues
     */
    List<ValidationResult> validate();
    
    /**
     * Generate order numbers based on business rules
     */
    void generateOrderNumbers();
    
    /**
     * Inner class to return validation results
     */
    class ValidationResult {
        public Id recordId { get; private set; }
        public Boolean isValid { get; private set; }
        public String errorMessage { get; private set; }
        
        public ValidationResult(Id recordId, Boolean isValid, String errorMessage) {
            this.recordId = recordId;
            this.isValid = isValid;
            this.errorMessage = errorMessage;
        }
    }
}