<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SI_TieneComentario</fullName>
        <description>Si la tarea tiene comentario marca la casilla para contabilizar los comentarios.</description>
        <field>SI_Tiene_Comentario__c</field>
        <literalValue>1</literalValue>
        <name>SI_TieneComentario</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SI_TareaComentario</fullName>
        <actions>
            <name>SI_TieneComentario</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Task.Description</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Task.KS_Comentarios__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
