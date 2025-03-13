/**
 * @description Extension point interface for custom pricing calculations
 * This allows other packages to provide custom pricing logic
 */
public interface IPricingCalculator {
    /**
     * Calculate pricing for order items
     * @param orderItems List of OrderItem records to calculate pricing for
     * @return Map of OrderItem Id to calculated price
     */
    Map<Id, Decimal> calculatePrices(List<OrderItem> orderItems);
    
    /**
     * Calculate tax for orders
     * @param orders List of Order records to calculate tax for
     * @return Map of Order Id to calculated tax amount
     */
    Map<Id, Decimal> calculateTax(List<Order> orders);
    
    /**
     * Calculate shipping costs for orders
     * @param orders List of Order records to calculate shipping for
     * @return Map of Order Id to calculated shipping amount
     */
    Map<Id, Decimal> calculateShipping(List<Order> orders);
}