/**
 * @description Selector class for Account object
 * Contains all query logic for the Account entity
 */
public class AccountsSelector extends fflib_SObjectSelector {
    /**
     * Define fields to query by default
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name,
            Account.Phone,
            Account.Type,
            Account.Industry,
            Account.BillingStreet,
            Account.BillingCity,
            Account.BillingState,
            Account.BillingPostalCode,
            Account.BillingCountry
        };
    }
    
    /**
     * Define the SObject type for this selector
     */
    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }
    
    /**
     * Select Accounts by their Ids
     * @param idSet Set of Account Ids to query
     * @return List of Account records
     */
    public List<Account> selectById(Set<Id> idSet) {
        return (List<Account>) selectSObjectsById(idSet);
    }
}