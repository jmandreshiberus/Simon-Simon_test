<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Connectividad</fullName>
        <ccEmails>mmartin@simon.es</ccEmails>
        <ccEmails>jbollo@simon.es</ccEmails>
        <description>Connectividad</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ReportesMKT/MailReportesMKT</template>
    </alerts>
    <alerts>
        <fullName>IluminacionIndoor</fullName>
        <ccEmails>aferrer@simon.es</ccEmails>
        <ccEmails>mparedes@simon.es</ccEmails>
        <ccEmails>nbosch@simon.es</ccEmails>
        <ccEmails>rliu@simon.es</ccEmails>
        <description>IluminacionIndoor</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ReportesMKT/MailReportesMKT</template>
    </alerts>
    <alerts>
        <fullName>IluminacionOutdoor</fullName>
        <ccEmails>marcaya@simon.es</ccEmails>
        <ccEmails>jcamanes@simon.es</ccEmails>
        <description>IluminacionOutdoor</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ReportesMKT/MailReportesMKT</template>
    </alerts>
    <alerts>
        <fullName>PequenoMaterial</fullName>
        <ccEmails>dmansilla@simon.es</ccEmails>
        <ccEmails>lborja@simon.es</ccEmails>
        <ccEmails>cfernandez@simon.es</ccEmails>
        <description>PequenoMaterial</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ReportesMKT/MailReportesMKT</template>
    </alerts>
    <alerts>
        <fullName>PuntoRecargaVE</fullName>
        <ccEmails>avaldovinos@simon.es</ccEmails>
        <description>PuntoRecargaVE</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ReportesMKT/MailReportesMKT</template>
    </alerts>
    <alerts>
        <fullName>SistemasDeControl</fullName>
        <ccEmails>amfernandez@simon.es</ccEmails>
        <ccEmails>jmarin@simon.es</ccEmails>
        <ccEmails>anvisa@simon.es</ccEmails>
        <description>SistemasDeControl</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ReportesMKT/MailReportesMKT</template>
    </alerts>
    <rules>
        <fullName>Connect</fullName>
        <actions>
            <name>Connectividad</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>KS_Reporte__c.Conectividad__c</field>
            <operation>equals</operation>
            <value>Verdadero</value>
        </criteriaItems>
        <description>Workflow de mail a MKT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IluminacionIndoor</fullName>
        <actions>
            <name>IluminacionIndoor</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>KS_Reporte__c.Iluminaci_n_Indoor__c</field>
            <operation>equals</operation>
            <value>Verdadero</value>
        </criteriaItems>
        <description>Workflow de mail a MKT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IluminacionOutdoor</fullName>
        <actions>
            <name>IluminacionOutdoor</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>KS_Reporte__c.Iluminacion_Outdoor__c</field>
            <operation>equals</operation>
            <value>Verdadero</value>
        </criteriaItems>
        <description>Workflow de mail a MKT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PequenoMaterial</fullName>
        <actions>
            <name>PequenoMaterial</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>KS_Reporte__c.Pequenio_Material__c</field>
            <operation>equals</operation>
            <value>Verdadero</value>
        </criteriaItems>
        <description>Workflow de mail a MKT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PuntoRecargaVE</fullName>
        <actions>
            <name>PuntoRecargaVE</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>KS_Reporte__c.PUNTO_RECARGA_VE__c</field>
            <operation>equals</operation>
            <value>Verdadero</value>
        </criteriaItems>
        <description>Workflow de mail a MKT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SistemasDeControl</fullName>
        <actions>
            <name>SistemasDeControl</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>KS_Reporte__c.Sistemas_de_Control__c</field>
            <operation>equals</operation>
            <value>Verdadero</value>
        </criteriaItems>
        <description>Workflow de mail a MKT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
