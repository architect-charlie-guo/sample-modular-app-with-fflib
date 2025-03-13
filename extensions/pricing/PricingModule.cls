/**
 * @description DI Module for pricing extension
 * Registers pricing extension implementations with the application
 */
public class PricingModule extends di_Module {
    /**
     * Configure the bindings for this module
     */
    public override void configure() {
        // Register the pricing calculator with the main application
        bind(IPricingCalculator.class).to(CustomPricingCalculator.class);
    }
}