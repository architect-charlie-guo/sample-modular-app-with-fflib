/**
 * @description DI Module for compliance extension
 * Registers compliance extension implementations with the application
 */
public class ComplianceModule extends di_Module {
    /**
     * Configure the bindings for this module
     */
    public override void configure() {
        // Register the compliance extension with the main application
        bind(IBeforeOrderProcess.class).to(ComplianceExtension.class);
    }
}