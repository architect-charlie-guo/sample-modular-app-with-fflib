/**
 * @description Extension point interface for executing custom logic after order processing
 * This allows other packages to add functionality without modifying core code
 */
public interface IAfterOrderProcess {
    /**
     * Execute custom logic after standard order processing
     * @param orders List of Order records that have been processed
     */
    void afterProcess(List<Order> orders);
}