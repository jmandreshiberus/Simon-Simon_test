<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>KS_Notificacion_de_Obra_Nueva</fullName>
        <description>Notificación de Obra Nueva</description>
        <protected>false</protected>
        <recipients>
            <field>KS_Responsable__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notificaciones_generales/KS_Obra_creada</template>
    </alerts>
    <rules>
        <fullName>NotificacionResponsable</fullName>
        <actions>
            <name>KS_Notificacion_de_Obra_Nueva</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>KS_Obra_Ubicacion__c.KS_Responsable__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Aviso de creación de nueva obra</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
