/**
 * @description Main application class for Order Management
 * Initializes dependency injection framework
 */
public class OrderManagementApplication {
    /** Flag to track initialization status */
    private static Boolean initialized = false;
    
    /**
     * Initialize the application, registering modules with Force-DI
     * This must be called at application startup
     */
    public static void initialize() {
        if (!initialized) {
            // Log initialization
            System.debug(LoggingLevel.INFO, 'Initializing Order Management Application');
            
            // Register core modules with Force-DI
            di_Injector injector = new di_Injector(new List<di_Module>{
                new CoreModule(),
                new StandardModule()
            });
            
            // Set initialization flag
            initialized = true;
            
            System.debug(LoggingLevel.INFO, 'Order Management Application initialized successfully');
        }
    }
    
    /**
     * Check if the application is initialized
     * @return Boolean indicating if initialization has occurred
     */
    public static Boolean isInitialized() {
        return initialized;
    }
}