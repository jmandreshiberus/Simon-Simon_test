/*
Copyright (c) 2013 avidev9@gmail.com
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
*    Author : avidev9@gmail.com
*    CreatedDate : 6-Oct-2013
*    Class Name : AutoCompleteV2_Con
**/
public class AutoCompleteV2_Con {

    public String labelFieldVar{ get; set; }
    public String valueFieldVar{ get; set; }
    public String sObjVal{get;set;}
    public Integer randomJsIden{get;set;}
    public Object cacheField{get;private set;} 
    
    private Object targetFieldVar;
    
    public AutoCompleteV2_Con(){
        randomJsIden = getRandomNumber(1000000);
        sObjVal='Account';
        labelFieldVar='Name';
        valueFieldVar='Id';
    }
    
    /*Dummy setter Method*/
    public void setCacheField(Object cacheField){}
    
    public void setTargetFieldVar(Object targetFieldVar){    
        if(targetFieldVar != this.targetFieldVar){
            cacheField = getCacheFieldValue(targetFieldVar);
            this.targetFieldVar = targetFieldVar;
        }
    }
    
    public Object getTargetFieldVar(){
        return targetFieldVar;
    }

    
    /*
    *This method queries data according to the passed parameters
    ***/
    @RemoteAction
    public static List<Map<String,String>> getData(String sObjVal,String labelFieldVar,String valueFieldVar,String whereClauseVar,String param){      
        List<Map<String,String>> responses = new List<Map<String,String>>();
        param = String.escapeSingleQuotes(param);
        system.debug('param: ' + param + ' ' + labelFieldVar);
        system.debug('database.query: '+'SELECT '+getFieldCSV(valueFieldVar,labelFieldVar)+' FROM '+sObjVal+' WHERE '+labelFieldVar+' LIKE \'%'+param+'%\''+(String.isNotBlank(whereClauseVar) ? ' AND '+whereClauseVar : ' LIMIT 100 '));
        for( Sobject sObj : Database.query('SELECT '+getFieldCSV(valueFieldVar,labelFieldVar)+' FROM '+sObjVal+' WHERE '+labelFieldVar+' LIKE \''+param+'%\''+(String.isNotBlank(whereClauseVar) ? ' AND '+whereClauseVar : ' LIMIT 100 '))){
            responses.add(new Map<String,String>{
                'id' => String.valueOf(sObj.get(valueFieldVar)),
                'text' => String.valueOf(sObj.get(labelFieldVar))
            });
        }
        return responses;
    }  
    
    private Object getCacheFieldValue(Object targetFieldVar){
        Object retVal = targetFieldVar;
        if(targetFieldVar!=null){
            for(sObject sObj : Database.query('SELECT '+getFieldCSV(valueFieldVar,labelFieldVar)+' FROM '+sObjVal+' WHERE '+valueFieldVar+' =:targetFieldVar LIMIT 100')){
                retVal = sObj.get(labelFieldVar);
                break;
            }
        }
        
        return retVal;
    }
    
    /*
    *Random number generator to change the js function name if multiple components us
    ***/
    private Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }

    private static String getFieldCSV(String vfld,String lfld){
        Set<String> fields = new Set<String>{vfld.toLowerCase(),lfld.toLowerCase()};
        system.debug('getFieldCSV: ' + String.join(new List<String>(fields),','));
        return String.join(new List<String>(fields),',');
    }
    
}