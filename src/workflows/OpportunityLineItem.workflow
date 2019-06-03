<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Actualizar_Quantity</fullName>
        <description>Actualiza el campo standard de Quantity con el valor de multiplicar la cantidad de linea por la cantidad de la ficha</description>
        <field>Quantity</field>
        <formula>KS_Cantidad__c *  KS_Cantidad_Ficha__c</formula>
        <name>Actualizar Quantity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Calcular_importe_neto_por_ficha</fullName>
        <description>Indica el importe neto multiplicado por la cantidad de la ficha</description>
        <field>KS_Neto_por_ficha__c</field>
        <formula>KS_Cantidad_Ficha__c * KS_Neto_Unitario__c * KS_Cantidad__c</formula>
        <name>Calcular importe neto por ficha</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Dto_Adicional_2_100</fullName>
        <description>Setea el valor del Dto Adicional 2 a 100%</description>
        <field>KS_Dto_adicional_2__c</field>
        <formula>1</formula>
        <name>Dto_Adicional_2_100</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Neto_por_ficha_Cliente_Final</fullName>
        <description>Calcula el Neto por ficha de Cliente Final</description>
        <field>KS_Neto_por_ficha_Cliente_Final__c</field>
        <formula>KS_Cantidad_Ficha__c *  KS_Neto_Unitario_Cliente_Final__c * KS_Cantidad__c</formula>
        <name>Neto por ficha Cliente Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Neto_por_ficha_Instalador</fullName>
        <description>Calcula el Neto por ficha para instaladores</description>
        <field>KS_Neto_por_ficha_Instalador__c</field>
        <formula>KS_Cantidad_Ficha__c *   Ks_Neto_Unitario_Instalador__c  * KS_Cantidad__c</formula>
        <name>Neto por ficha Instalador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Calculos de linea</fullName>
        <actions>
            <name>Actualizar_Quantity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Calcular_importe_neto_por_ficha</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Neto_por_ficha_Cliente_Final</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Neto_por_ficha_Instalador</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Calcula el importe Neto por el importe de Ficha / actualiza el Quantity con ks_cantidad * ks_cantidad_ficha</description>
        <formula>1+1=2</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Descuento MSC</fullName>
        <actions>
            <name>Dto_Adicional_2_100</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.KS_Material_sin_cargo__c</field>
            <operation>equals</operation>
            <value>Verdadero</value>
        </criteriaItems>
        <description>Setea el valor del descuento adicional 2 a 100% en el caso de Material Sin Cargo</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
