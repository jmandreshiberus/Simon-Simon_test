<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CambioPropietarioAntiguo</fullName>
        <description>CambioPropietarioAntiguo</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NotificacionAttend/CambioPropietarioAntiguo</template>
    </alerts>
    <alerts>
        <fullName>CambioPropietarioNuevo</fullName>
        <description>CambioPropietarioNuevo</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NotificacionAttend/CambioPropietarioNuevo</template>
    </alerts>
    <alerts>
        <fullName>CambioPropietarioPasivado</fullName>
        <description>CambioPropietarioPasivado</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@simonelectric.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NotificacionAttend/CambioPropietarioPasivado</template>
    </alerts>
    <alerts>
        <fullName>CierreTicketSF</fullName>
        <description>CierreTicketSF</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@simonelectric.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NotificacionAttend/CierreTicket</template>
    </alerts>
    <rules>
        <fullName>AttendModificacion</fullName>
        <actions>
            <name>CierreTicketSF</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Ticket__c.SI_Estado__c</field>
            <operation>equals</operation>
            <value>Cerrado</value>
        </criteriaItems>
        <criteriaItems>
            <field>Ticket__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Cambio de propietario</value>
        </criteriaItems>
        <description>Regla que envia notificacion de comentarios admin</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
