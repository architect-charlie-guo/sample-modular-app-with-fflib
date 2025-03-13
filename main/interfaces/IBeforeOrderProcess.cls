/**
 * @description Extension point interface for executing custom logic before order processing
 * This allows other packages to add functionality without modifying core code
 */
public interface IBeforeOrderProcess {
    /**
     * Execute custom logic before standard order processing
     * @param orders List of Order records being processed
     */
    void beforeProcess(List<Order> orders);
}