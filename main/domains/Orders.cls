/**
 * @description Domain class for Order object
 * Contains business logic specific to the Order entity
 */
public class Orders extends fflib_SObjectDomain implements IOrders {
    /**
     * Constructor
     * @param records List of Order records
     */
    public Orders(List<Order> records) {
        super(records, Schema.Order.SObjectType);
    }
    
    /**
     * Apply all business rules to the Orders
     */
    public void process() {
        // Set the last review date to today
        for(Order record : (List<Order>) Records) {
            record.LastReviewDate__c = Date.today();
            
            // Apply business rules based on status
            if(record.Status == 'Draft') {
                // Business logic for draft orders
                record.Description = 'Processed on ' + System.now();
            }
        }
        
        // Generate order numbers if needed
        generateOrderNumbers();
    }
    
    /**
     * Calculate totals for Orders including tax and shipping
     */
    public void calculateTotals() {
        // Get order item data
        Set<Id> orderIds = new Set<Id>();
        for(Order record : (List<Order>) Records) {
            orderIds.add(record.Id);
        }
        
        // Query order items if not already loaded
        Map<Id, List<OrderItem>> orderItemsByOrderId = new Map<Id, List<OrderItem>>();
        List<OrderItem> orderItems = OrderItems.selector().selectByOrderId(orderIds);
        
        // Group items by order
        for(OrderItem item : orderItems) {
            if(!orderItemsByOrderId.containsKey(item.OrderId)) {
                orderItemsByOrderId.put(item.OrderId, new List<OrderItem>());
            }
            orderItemsByOrderId.get(item.OrderId).add(item);
        }
        
        // Use pricing calculator extension point if available
        IPricingCalculator pricingCalculator = getPricingCalculator();
        
        // Calculate subtotals from items
        for(Order record : (List<Order>) Records) {
            Decimal subtotal = 0;
            
            // Sum line items
            if(orderItemsByOrderId.containsKey(record.Id)) {
                for(OrderItem item : orderItemsByOrderId.get(record.Id)) {
                    subtotal += (item.UnitPrice * item.Quantity);
                }
            }
            
            record.Subtotal__c = subtotal;
            
            // Apply tax and shipping
            if(pricingCalculator != null) {
                // Use custom pricing calculator if available
                Map<Id, Decimal> taxAmounts = pricingCalculator.calculateTax(new List<Order>{ record });
                Map<Id, Decimal> shippingAmounts = pricingCalculator.calculateShipping(new List<Order>{ record });
                
                if(taxAmounts.containsKey(record.Id)) {
                    record.TaxAmount__c = taxAmounts.get(record.Id);
                }
                
                if(shippingAmounts.containsKey(record.Id)) {
                    record.ShippingAmount__c = shippingAmounts.get(record.Id);
                }
            } else {
                // Default tax and shipping calculation
                record.TaxAmount__c = subtotal * 0.08; // 8% tax rate
                record.ShippingAmount__c = 10.00; // Flat shipping rate
            }
            
            // Calculate grand total
            record.GrandTotal__c = (record.Subtotal__c != null ? record.Subtotal__c : 0) + 
                                (record.TaxAmount__c != null ? record.TaxAmount__c : 0) + 
                                (record.ShippingAmount__c != null ? record.ShippingAmount__c : 0);
        }
    }
    
    /**
     * Validate Orders meet all business requirements
     * @return List of ValidationResult with details on any validation issues
     */
    public List<ValidationResult> validate() {
        List<ValidationResult> results = new List<ValidationResult>();
        
        for(Order record : (List<Order>) Records) {
            // Basic validation
            if(record.AccountId == null) {
                results.add(new ValidationResult(record.Id, false, 'Order must be associated with an Account'));
                continue;
            }
            
            if(record.EffectiveDate == null) {
                results.add(new ValidationResult(record.Id, false, 'Effective Date is required'));
                continue;
            }
            
            // Complex business rule validation
            if(record.Status == 'Activated' && record.GrandTotal__c == 0) {
                results.add(new ValidationResult(record.Id, false, 'Activated orders must have items'));
                continue;
            }
            
            // All validations passed
            results.add(new ValidationResult(record.Id, true, 'Valid'));
        }
        
        return results;
    }
    
    /**
     * Generate order numbers based on business rules
     */
    public void generateOrderNumbers() {
        for(Order record : (List<Order>) Records) {
            if(record.OrderNumber__c == null) {
                // Format: ORD-{Year}{Month}{Day}-{Random 4-digit number}
                Date today = Date.today();
                String dateStr = String.valueOf(today.year()) + 
                                String.valueOf(today.month()).leftPad(2, '0') + 
                                String.valueOf(today.day()).leftPad(2, '0');
                
                Integer randomNum = Integer.valueOf(Math.random() * 9000) + 1000;
                record.OrderNumber__c = 'ORD-' + dateStr + '-' + randomNum;
            }
        }
    }
    
    /**
     * Get the pricing calculator implementation from DI
     * @return IPricingCalculator implementation or null if not found
     */
    private IPricingCalculator getPricingCalculator() {
        try {
            return (IPricingCalculator) di_Injector.Org.getInstance(IPricingCalculator.class);
        } catch(Exception e) {
            // No pricing calculator registered, return null
            return null;
        }
    }
    
    /**
     * fflib Domain class implementation of the Constructor
     */
    public class Constructor implements fflib_SObjectDomain.IConstructor {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new Orders(records);
        }
    }
}