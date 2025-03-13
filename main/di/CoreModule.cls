/**
 * @description Core module for dependency injection
 * Registers basic extension points
 */
public class CoreModule extends di_Module {
    /**
     * Configure the bindings for this module
     */
    public override void configure() {
        // Register extension points
        // These are empty bindings that allow other modules to register implementations
        bind(IBeforeOrderProcess.class);
        bind(IAfterOrderProcess.class);
        bind(IPricingCalculator.class);
    }
}