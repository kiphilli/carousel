public virtual class TriggerFactoryHandlerBase
{
	public static boolean firstRun = true;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    //If we want to create/update objects in Test classes, we can use this flag to insert the core records without logic running on them, 
    //then change the flag back
    public static boolean byPassTrigger = false;
 
    //method used to grab the byPassTrigger current context             
    public static Boolean getByPassTriggerContext() { 
       return byPassTrigger;
    }
    
    //method used to set the byPassTrigger to false which could be used when we don't want a trigger to fire                 
    public static void setByPassTriggerFalse(){
       byPassTrigger = false;
   }

    //method used to set the byPassTrigger context back to true which can be used when more than 1 DML operation is executed within a single test method context                  
   public static void setByPassTriggerTrue(){ 
       byPassTrigger = true;
   }
 
    //method used to set the byPassTrigger context back to true which can be used when more than 1 DML operation is executed within a single test method context                  
   public static void setByPassTrigger(boolean value){ 
       byPassTrigger = value;
   }
    
    public TriggerFactoryHandlerBase()
	{
		firstRun = true;
		BatchSize = 0;
	}
    
    public void setParameters(boolean isExecuting, integer size)
    {
        this.m_isExecuting = isExecuting;
        this.BatchSize = size;
    }
	
	public virtual Boolean GetIsExecuting() { return m_isExecuting; }
	public virtual void SetIsExecuting(Boolean bExecuting) { m_isExecuting = bExecuting; }
	
	public virtual Integer GetBatchSize() { return BatchSize; }
	public virtual void SetBatchSize(Integer bSize) { BatchSize = bSize; }
              
    public virtual void OnBeforeInsert(List<SObject> newMappings){}
    
    public virtual void OnAfterInsert(List<SObject> newMappings){}
    
    @future 
    public static void OnAfterInsertAsync(Set<ID> newMappingIDs){}
    
    public virtual void OnBeforeUpdate(List<SObject> oldMappings, List<SObject> updatedMappings, Map<ID, SObject> mappingOldMap, Map<ID, SObject> mappingNewMap){}
    
    public virtual void OnAfterUpdate(List<SObject> oldMappings, List<SObject> updatedMappings, Map<ID, SObject> mappingOldMap, Map<ID, SObject> mappingMap){}
    
    @future 
    public static void OnAfterUpdateAsync(Set<ID> updatedMappingIDs){}
    
    public virtual void OnBeforeDelete(List<SObject> MappingsToDelete, Map<ID, SObject> MappingMap){}
    
    public virtual void OnAfterDelete(List<SObject> deletedMappings, Map<ID, SObject> MappingMap){}
    
    @future 
    public static void OnAfterDeleteAsync(Set<ID> deletedMappingIDs){}
    
    public virtual void OnUndelete(List<SObject> restoredMappings){}
    
    public virtual void BulkBefore(){}      
    
    public virtual void BulkAfter(){}       
    
    public virtual void cleanUp(){}    
    
    public boolean IsTriggerContext
	{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext
	{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext
	{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext
	{
        get{ return !IsTriggerContext;}
    }
}