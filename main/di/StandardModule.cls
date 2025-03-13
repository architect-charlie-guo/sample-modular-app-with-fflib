/**
 * @description Standard module for dependency injection
 * Registers the standard implementations for the application
 */
public class StandardModule extends di_Module {
    /**
     * Configure the bindings for this module
     */
    public override void configure() {
        // Bind service implementations
        bind(IOrdersService.class).to(OrdersService.class);
        
        // Bind selector implementations
        bind(IOrdersSelector.class).to(OrdersSelector.class);
        bind(IOrderItemsSelector.class).to(OrderItemsSelector.class);
        
        // Note: Domain classes are constructed through fflib's Domain factory
        // and don't need explicit bindings here
    }
}