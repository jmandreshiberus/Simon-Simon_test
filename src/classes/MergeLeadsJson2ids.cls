public with sharing class MergeLeadsJson2ids {
    public String Id_master;
    public String Id_merge1;
    public String Id_merge2;
    
    public MergeLeadsJson2ids() {}
    
    public MergeLeadsJson2ids(String Id_master, String Id_merge1, String Id_merge2){
        this.Id_master = Id_master;
        this.Id_merge1 = Id_merge1;
        this.Id_merge2 = Id_merge2;
    }

    public static MergeLeadsJson2ids parse(String json) {
        return (MergeLeadsJson2ids) System.JSON.deserialize(json, MergeLeadsJson2ids.class);    
    }
}