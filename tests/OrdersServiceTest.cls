/**
 * @description Unit tests for OrdersService
 * Demonstrates how to use fflib mocks and Force-DI for testing
 */
@isTest
private class OrdersServiceTest {
    /**
     * Test processing orders successfully
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
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        MockOrdersSelector selectorMock = new MockOrdersSelector(mocks);
        MockOrders domainMock = new MockOrders(mocks);
        
        // Set up mock responses
        List<Order> orders = new List<Order>{ testOrder };
        mocks.startStubbing();
        selectorMock.mockSelectByIdWithItems(new Set<Id>{ testOrder.Id }, orders);
        domainMock.mockValidate(new List<IOrders.ValidationResult>{ 
            new IOrders.ValidationResult(testOrder.Id, true, 'Valid') 
        });
        mocks.stopStubbing();
        
        // Register mocks with Force-DI
        di_Injector.Org.Bindings.clear();
        di_Injector.Org.Bindings
            .bind(IOrdersSelector.class)
            .toObject(selectorMock);
        di_Injector.Org.Bindings
            .bind('Orders.Domain')
            .toObject(domainMock);
        
        // Create test service (with injected dependencies)
        IOrdersService service = new OrdersService();
        
        // Execute the test
        Test.startTest();
        service.processOrders(new Set<Id>{ testOrder.Id });
        Test.stopTest();
        
        // Verify mock interactions
        ((fflib_ISObjectUnitOfWork)mocks.verify(domainMock, 1))
            .process();
        ((fflib_ISObjectUnitOfWork)mocks.verify(domainMock, 1))
            .calculateTotals();
        ((fflib_ISObjectUnitOfWork)mocks.verify(domainMock, 1))
            .validate();
    }
    
    /**
     * Test process orders with validation failure
     */
    @isTest
    static void testProcessOrdersWithValidationFailure() {
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
        MockOrdersSelector selectorMock = new MockOrdersSelector(mocks);
        MockOrders domainMock = new MockOrders(mocks);
        
        // Set up mock responses
        List<Order> orders = new List<Order>{ testOrder };
        mocks.startStubbing();
        selectorMock.mockSelectByIdWithItems(new Set<Id>{ testOrder.Id }, orders);
        domainMock.mockValidate(new List<IOrders.ValidationResult>{ 
            new IOrders.ValidationResult(testOrder.Id, false, 'Invalid order') 
        });
        mocks.stopStubbing();
        
        // Register mocks with Force-DI
        di_Injector.Org.Bindings.clear();
        di_Injector.Org.Bindings
            .bind(IOrdersSelector.class)
            .toObject(selectorMock);
        di_Injector.Org.Bindings
            .bind('Orders.Domain')
            .toObject(domainMock);
        
        // Create test service (with injected dependencies)
        IOrdersService service = new OrdersService();
        
        // Execute the test
        Test.startTest();
        try {
            service.processOrders(new Set<Id>{ testOrder.Id });
            System.assert(false, 'Expected exception was not thrown');
        } catch (OrdersService.OrderProcessingException e) {
            System.assertEquals('Invalid order', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }
    
    /**
     * Mock implementation of OrdersSelector for testing
     */
    private class MockOrdersSelector implements IOrdersSelector {
        private fflib_ApexMocks mocks;
        
        public MockOrdersSelector(fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }
        
        public List<Order> selectById(Set<Id> idSet) {
            return (List<Order>) mocks.mockNonVoidMethod(
                this, 'selectById', new List<Type>{ Set<Id>.class }, new List<Object>{ idSet });
        }
        
        public List<Order> selectByIdWithItems(Set<Id> idSet) {
            return (List<Order>) mocks.mockNonVoidMethod(
                this, 'selectByIdWithItems', new List<Type>{ Set<Id>.class }, new List<Object>{ idSet });
        }
        
        public List<Order> selectByAccountId(Set<Id> accountIds) {
            return (List<Order>) mocks.mockNonVoidMethod(
                this, 'selectByAccountId', new List<Type>{ Set<Id>.class }, new List<Object>{ accountIds });
        }
        
        public List<Order> selectByDateRange(Date startDate, Date endDate) {
            return (List<Order>) mocks.mockNonVoidMethod(
                this, 'selectByDateRange', new List<Type>{ Date.class, Date.class }, 
                new List<Object>{ startDate, endDate });
        }
        
        // Helper to set up mocks
        public void mockSelectByIdWithItems(Set<Id> idSet, List<Order> returnOrders) {
            mocks.when(mocks.methodCall(this, 'selectByIdWithItems', new List<Type>{ Set<Id>.class }, 
                new List<Object>{ idSet }))
                .thenReturn(returnOrders);
        }
    }
    
    /**
     * Mock implementation of Orders domain for testing
     */
    private class MockOrders implements IOrders {
        private fflib_ApexMocks mocks;
        
        public MockOrders(fflib_ApexMocks mocks) {
            this.mocks = mocks;
        }
        
        public void process() {
            mocks.mockVoidMethod(this, 'process', new List<Type>{}, new List<Object>{});
        }
        
        public void calculateTotals() {
            mocks.mockVoidMethod(this, 'calculateTotals', new List<Type>{}, new List<Object>{});
        }
        
        public List<IOrders.ValidationResult> validate() {
            return (List<IOrders.ValidationResult>) mocks.mockNonVoidMethod(
                this, 'validate', new List<Type>{}, new List<Object>{});
        }
        
        public void generateOrderNumbers() {
            mocks.mockVoidMethod(this, 'generateOrderNumbers', new List<Type>{}, new List<Object>{});
        }
        
        // Helper to set up mocks
        public void mockValidate(List<IOrders.ValidationResult> results) {
            mocks.when(mocks.methodCall(this, 'validate', new List<Type>{}, new List<Object>{}))
                .thenReturn(results);
        }
    }
}