<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SI_Prueba_Pedido</fullName>
        <field>SI_ID_Oferta__c</field>
        <formula>KS_Oferta__r.KS_Oferta_ID__c</formula>
        <name>Oferta_en_Pedido</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Prueba_Pedido</fullName>
        <actions>
            <name>SI_Prueba_Pedido</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>KS_Pedido__c.KS_Oferta_CRM__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
