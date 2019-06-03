<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notificacion_Aprobacion_Candidato_ESP</fullName>
        <description>Notificación Aprobacion Candidato ESP</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Aprobaciones_Candidatos/Notificacion_aprobacion_candidato_ESP_Aprobado</template>
    </alerts>
    <alerts>
        <fullName>Notificacion_Solicitud_Aprobacion_Candidato_ESP</fullName>
        <description>Notificacion Solicitud_Aprobacion_Candidato_ESP</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Aprobaciones_Candidatos/Notificacion_Solicitud_aprobacion_candidato_esp</template>
    </alerts>
    <alerts>
        <fullName>Notificacion_de_rechazado_Candidato_ESP</fullName>
        <description>Notificación de rechazado Candidato ESP</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Aprobaciones_Candidatos/Notificacion_aprobacion_candidato_ESP_Rechazado</template>
    </alerts>
    <alerts>
        <fullName>SAP_Solicitud_Cliente</fullName>
        <ccEmails>psamo@simon.es</ccEmails>
        <ccEmails>epelaz@simon.es</ccEmails>
        <ccEmails>jmarchena@simon.es</ccEmails>
        <ccEmails>alta_cli_sap@simon.es</ccEmails>
        <description>SAP Solicitud Cliente</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notificaciones_generales/SAP_Solicitud_Cliente</template>
    </alerts>
    <fieldUpdates>
        <fullName>Aprobar_Candidato</fullName>
        <field>KS_Aprobado__c</field>
        <literalValue>1</literalValue>
        <name>Aprobar Candidato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RechazoNo</fullName>
        <description>Cuando se modifica el campo &quot;Direccion&quot;, se modifica el campo &quot;Calidad de direccion&quot;</description>
        <field>SI_CalidadDireccion__c</field>
        <literalValue>Ok</literalValue>
        <name>RechazoNo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SI_CambioEmailValido</fullName>
        <field>SI_Mail_Validado__c</field>
        <literalValue>Si</literalValue>
        <name>CambioEmailValido</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CambioEmail</fullName>
        <actions>
            <name>SI_CambioEmailValido</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Cuando el mail no es valido pero se cambia se desmarca esa casilla.</description>
        <formula>ISCHANGED( KS_Email__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RechazoNo</fullName>
        <actions>
            <name>RechazoNo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Cuando se modifica la dirección de la cuenta, se modifica el campo &quot;Calidad de dirección&quot;.</description>
        <formula>ISCHANGED( BillingStreet )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
