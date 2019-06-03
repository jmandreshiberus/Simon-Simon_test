<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>KS_NotificacionCoordinadorObra</fullName>
        <description>NotificacionCoordinadorObra</description>
        <protected>false</protected>
        <recipients>
            <field>KS_Coordinador__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notificaciones_generales/KS_Obra_creada_coordinador</template>
    </alerts>
    <fieldUpdates>
        <fullName>KS_RecordType_Oportunidades</fullName>
        <description>Cambia el recordType del Objeto Obra a = Oportunidades</description>
        <field>RecordTypeId</field>
        <lookupValue>KS_Oportunidades</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>RecordType_Oportunidades</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>NotificacionCoordinador</fullName>
        <actions>
            <name>KS_NotificacionCoordinadorObra</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notificación al coordinador de la obra</description>
        <formula>KS_Coordinador__c &lt;&gt;&apos;&apos;  &amp;&amp; (ISNEW() || ISCHANGED( KS_Coordinador__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
