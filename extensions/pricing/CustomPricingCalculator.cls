/**
 * @description Custom pricing calculator implementation
 * This extension provides specialized pricing logic
 */
public class CustomPricingCalculator implements IPricingCalculator {
    /**
     * Calculate pricing for order items
     * @param orderItems List of OrderItem records to calculate pricing for
     * @return Map of OrderItem Id to calculated price
     */
    public Map<Id, Decimal> calculatePrices(List<OrderItem> orderItems) {
        Map<Id, Decimal> prices = new Map<Id, Decimal>();
        
        for(OrderItem item : orderItems) {
            // Apply volume discounts
            Decimal price = item.UnitPrice;
            
            if(item.Quantity >= 100) {
                // 20% discount for large orders
                price = price * 0.8;
            } else if(item.Quantity >= 50) {
                // 15% discount for medium orders
                price = price * 0.85;
            } else if(item.Quantity >= 20) {
                // 10% discount for small bulk orders
                price = price * 0.9;
            }
            
            prices.put(item.Id, price);
        }
        
        return prices;
    }
    
    /**
     * Calculate tax for orders
     * @param orders List of Order records to calculate tax for
     * @return Map of Order Id to calculated tax amount
     */
    public Map<Id, Decimal> calculateTax(List<Order> orders) {
        Map<Id, Decimal> taxAmounts = new Map<Id, Decimal>();
        
        for(Order order : orders) {
            // Get account for tax information
            Account account = order.Account;
            Decimal taxRate = 0.08; // Default 8%
            
            // Apply different tax rates based on shipping state
            if(account != null && account.BillingState != null) {
                String state = account.BillingState.toUpperCase();
                
                if(state == 'NY' || state == 'NEW YORK') {
                    taxRate = 0.085; // 8.5% for NY
                } else if(state == 'CA' || state == 'CALIFORNIA') {
                    taxRate = 0.095; // 9.5% for CA
                } else if(state == 'TX' || state == 'TEXAS') {
                    taxRate = 0.0625; // 6.25% for TX
                }
            }
            
            // Calculate tax amount
            Decimal subtotal = order.Subtotal__c != null ? order.Subtotal__c : 0;
            taxAmounts.put(order.Id, subtotal * taxRate);
        }
        
        return taxAmounts;
    }
    
    /**
     * Calculate shipping costs for orders
     * @param orders List of Order records to calculate shipping for
     * @return Map of Order Id to calculated shipping amount
     */
    public Map<Id, Decimal> calculateShipping(List<Order> orders) {
        Map<Id, Decimal> shippingAmounts = new Map<Id, Decimal>();
        
        for(Order order : orders) {
            // Get account for shipping information
            Account account = order.Account;
            Decimal baseShipping = 10.00; // Base shipping cost
            
            // Apply different shipping rates based on account type
            if(account != null) {
                if(account.Type == 'Customer - Premium') {
                    baseShipping = 0.00; // Free shipping for premium customers
                } else if(account.Type == 'Customer - Standard') {
                    // Standard shipping for regular customers
                    Decimal subtotal = order.Subtotal__c != null ? order.Subtotal__c : 0;
                    
                    if(subtotal >= 500) {
                        baseShipping = 0.00; // Free shipping for orders over $500
                    } else if(subtotal >= 250) {
                        baseShipping = 5.00; // Reduced shipping for orders over $250
                    }
                }
            }
            
            shippingAmounts.put(order.Id, baseShipping);
        }
        
        return shippingAmounts;
    }
}