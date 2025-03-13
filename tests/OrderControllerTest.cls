/**
 * @description Unit tests for OrderController
 * Demonstrates testing the controller with mocked service layer
 */
@isTest
private class OrderControllerTest {
    /**
     * Test processing orders through the controller
     */
    @isTest
    static void testProcessOrders() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert testOrder;
        
        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        MockOrdersService serviceMock = new MockOrdersService(mocks);
        
        // Register mock with Force-DI
        di_Injector.Org.Bindings.clear();
        di_Injector.Org.Bindings
            .bind(IOrdersService.class)
            .toObject(serviceMock);
        
        // Execute the test
        Test.startTest();
        Map<String, Object> result = OrderController.processOrders(new List<Id>{ testOrder.Id });
        Test.stopTest();
        
        // Verify results
        System.assertEquals(true, result.get('success'), 'Result should indicate success');
        System.assertEquals('Orders processed successfully', result.get('message'), 'Message should indicate success');
        
        // Verify service was called
        ((IOrdersService)mocks.verify(serviceMock, 1))
            .processOrders(new Set<Id>{ testOrder.Id });
    }
    
    /**
     * Test error handling in controller
     */
    @isTest
    static void testProcessOrdersWithError() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert testOrder;
        
        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        MockOrdersService serviceMock = new MockOrdersService(mocks);
        
        // Make the mock throw an exception
        mocks.startStubbing();
        serviceMock.mockProcessOrdersWithException(new Set<Id>{ testOrder.Id }, 'Test error');
        mocks.stopStubbing();
        
        // Register mock with Force-DI
        di_Injector.Org.Bindings.clear();
        di_Injector.Org.Bindings
            .bind(IOrdersService.class)
            .toObject(serviceMock);
        
        // Execute the test
        Test.startTest();
        Map<String, Object> result = OrderController.processOrders(new List<Id>{ testOrder.Id });
        Test.stopTest();
        
        // Verify results
        System.assertEquals(false, result.get('success'), 'Result should indicate failure');
        System.assertEquals('Error processing orders: Test error', result.get('message'), 'Message should indicate error');
    }
    
    /**
     * Test submitting orders for approval
     */
    @isTest
    static void testSubmitOrdersForApproval() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert testOrder;
        
        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        MockOrdersService serviceMock = new MockOrdersService(mocks);
        
        // Set up mock response
        List<IOrdersService.ProcessResult> processResults = new List<IOrdersService.ProcessResult>{
            new IOrdersService.ProcessResult(testOrder.Id, true, 'Successfully submitted')
        };
        
        mocks.startStubbing();
        serviceMock.mockSubmitOrdersForApproval(new Set<Id>{ testOrder.Id }, processResults);
        mocks.stopStubbing();
        
        // Register mock with Force-DI
        di_Injector.Org.Bindings.clear();
        di_Injector.Org.Bindings
            .bind(IOrdersService.class)
            .toObject(serviceMock);
        
        // Execute the test
        Test.startTest();
        List<Map<String, Object>> results = OrderController.submitOrdersForApproval(new List<Id>{ testOrder.Id });
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(testOrder.Id, results[0].get('recordId'), 'Record ID should match');
        System.assertEquals(true, results[0].get('success'), 'Should indicate success');
        System.assertEquals('Successfully submitted', results[0].get('message'), 'Message should match');
    }
    
    /**
     * Mock implementation of OrdersService for testing
     */
    private class MockOrdersService implements IOrdersService {
        private fflib_ApexMocks mocks;
        
        public MockOrdersService(fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }
        
        public void processOrders(Set<Id> orderIds) {
            mocks.mockVoidMethod(this, 'processOrders', new List<Type>{ Set<Id>.class }, new List<Object>{ orderIds });
        }
        
        public List<ProcessResult> submitOrdersForApproval(Set<Id> orderIds) {
            return (List<ProcessResult>) mocks.mockNonVoidMethod(
                this, 'submitOrdersForApproval', new List<Type>{ Set<Id>.class }, new List<Object>{ orderIds });
        }
        
        public void calculateOrderTotals(Set<Id> orderIds) {
            mocks.mockVoidMethod(this, 'calculateOrderTotals', new List<Type>{ Set<Id>.class }, new List<Object>{ orderIds });
        }
        
        // Helper to set up mocks
        public void mockProcessOrdersWithException(Set<Id> orderIds, String errorMessage) {
            mocks.when(mocks.methodCall(this, 'processOrders', new List<Type>{ Set<Id>.class }, new List<Object>{ orderIds }))
                .thenThrow(new OrdersService.OrderProcessingException(errorMessage));
        }
        
        public void mockSubmitOrdersForApproval(Set<Id> orderIds, List<ProcessResult> results) {
            mocks.when(mocks.methodCall(this, 'submitOrdersForApproval', new List<Type>{ Set<Id>.class }, new List<Object>{ orderIds }))
                .thenReturn(results);
        }
    }
}