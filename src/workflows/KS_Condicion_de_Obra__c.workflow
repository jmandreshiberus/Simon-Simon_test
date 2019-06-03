<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>KS_Solicitud_de_aprobacion_de_Condici_n_de_Obra_Rechazada</fullName>
        <description>Solicitud de aprobacion de Condición de Obra - Rechazada</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Conectividad__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Iluminacion__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Jefe_de_Area__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Negocio_Iberia_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Negocio_Iberia__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Resto_de_gamas__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Sist_Control__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Vehiculo_Electrico__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>KS_aprobaciones_Condicion_Obra/KS_Aprobacion_Solicitud_condicion_de_obra_rechazada</template>
    </alerts>
    <alerts>
        <fullName>KS_Solicitud_de_aprobacion_de_Condici_n_de_Obra_aprobada</fullName>
        <description>Solicitud de aprobacion de Condición de Obra - aprobada</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Conectividad__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Iluminacion__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Jefe_de_Area__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Negocio_Iberia_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Negocio_Iberia__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Resto_de_gamas__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Sist_Control__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>KS_Resp_Vehiculo_Electrico__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>KS_aprobaciones_Condicion_Obra/KS_Solicitud_de_aprobacion_condicion_obra_Aprobada</template>
    </alerts>
    <fieldUpdates>
        <fullName>KS_ActualizarFalsoAprobacion</fullName>
        <field>KS_Aprobado__c</field>
        <literalValue>0</literalValue>
        <name>ActualizarFalsoAprobacion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>KS_Marcar_como_Aprobada</fullName>
        <field>KS_Aprobado__c</field>
        <literalValue>1</literalValue>
        <name>Marcar como Aprobada</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>KS_Submitted_for_Approval_CO</fullName>
        <field>KS_Submitted_for_approval__c</field>
        <literalValue>1</literalValue>
        <name>Submitted_for_Approval_CO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>KS_Submitted_for_Approval_false</fullName>
        <field>KS_Submitted_for_approval__c</field>
        <literalValue>0</literalValue>
        <name>Submitted_for_Approval_false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>