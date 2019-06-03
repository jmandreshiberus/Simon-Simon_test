public class KS_MergeTool_MergeAuto 
{
    public Map<String,KS_Debug__c> debugMap {get;set;}
    
    public void MergeAccounts(List<KS_Fusion__c> BatchMergeAccLst)
    {
        System.debug('-- JCAR -- KS_MergeTool_MergeAuto - MergeAccounts - INI');
        
        Map<String,RecordType> mapRecordType = KS_Debug_Utils.mapRecordType();
        debugMap = new Map<String,KS_Debug__c>();
        //List<KS_Fusion__c> MergeAccLst = [SELECT Id, Name, KS_Accion__c, KS_Id_Principal__c, KS_Id_Duplicado__c, KS_Id_Duplicado_2__c, KS_Acc_Calle__c, KS_Acc_Ciudad__c, KS_Acc_Codigo_Postal__c, KS_Acc_Estado_Provincia__c, KS_Acc_Pais__c, KS_Acc_Telefono__c, KS_Acc_Telefono_2__c, KS_Acc_Telefono_3__c, KS_Acc_Correo__c, KS_Acc_Canal__c, KS_Acc_Actividad__c, KS_Acc_Subactividad__c, KS_Acc_Sector__c FROM KS_Fusion__c WHERE KS_Accion__c = 'MERGE'];
        if(BatchMergeAccLst.size()>0)
        {
            //Saco los distribuidores SAP para excluirlos.
            Set<ID> accSet = new Set<ID>();
            for(KS_Fusion__c fdist : BatchMergeAccLst)
            {
                accSet.add(fdist.KS_Id_Principal__c);
            }
            Set<ID> DistSAPSet = new Set<ID>();
            List<Account> DistSAPLst = [SELECT Id FROM Account WHERE Id IN :accSet AND RecordType.Name = 'Distribuidores SAP'];
            for(Account a : DistSAPLst)
            {
                DistSAPSet.add(a.Id);
            }

            System.debug('-- JCAR -- -- -- -- -- -- -- -- DistSAPSet ' + DistSAPSet);
            
            //Comienzo
            Set<ID> AccIds = new Set<ID>();
            //En este Set me guardo los IDs de las cuentas duplicadas.
            Set<ID> DuplicateAccIds = new Set<ID>();
            Map<Id,Account> AccUpdate  = new Map<Id,Account>();
            for(KS_Fusion__c f : BatchMergeAccLst)
            {
                if(!DistSAPSet.contains(f.KS_Id_Principal__c) && f.KS_Force_Merge__c == false)
                {
                    if(f.KS_Id_Duplicado__c != null && f.KS_Id_Duplicado__c != '')
                    {
                        DuplicateAccIds.add(f.KS_Id_Duplicado__c);
                    }
                    if(f.KS_Id_Duplicado_2__c != null && f.KS_Id_Duplicado_2__c != '')
                    {
                        DuplicateAccIds.add(f.KS_Id_Duplicado_2__c);
                    }
                    

                    Account a = new Account(ID=f.KS_Id_Principal__c);
                    if (AccUpdate.containsKey(a.Id)) { a = AccUpdate.get(a.Id); }
                    
                    if(f.KS_Acc_Calle__c != null && f.KS_Acc_Calle__c != '')
                    {
                        a.ShippingStreet = f.KS_Acc_Calle__c;
                        a.BillingStreet = f.KS_Acc_Calle__c;
                    }
                    if(f.KS_Acc_Ciudad__c != null && f.KS_Acc_Ciudad__c !='')
                    {
                        a.ShippingCity = f.KS_Acc_Ciudad__c;
                        a.BillingCity = f.KS_Acc_Ciudad__c;
                    }
                    if(f.KS_Acc_Codigo_Postal__c != null && f.KS_Acc_Codigo_Postal__c != '')
                    {
                        a.ShippingPostalCode = f.KS_Acc_Codigo_Postal__c;
                        a.BillingPostalCode = f.KS_Acc_Codigo_Postal__c;
                    }
                    if(f.KS_Acc_Estado_Provincia__c != null && f.KS_Acc_Estado_Provincia__c != '')
                    {
                        a.ShippingState = f.KS_Acc_Estado_Provincia__c;
                        a.BillingState = f.KS_Acc_Estado_Provincia__c;
                    }
                    if(f.KS_Acc_Pais__c != null && f.KS_Acc_Pais__c != '')
                    {
                        a.ShippingCountryCode = f.KS_Acc_Pais__c;
                        a.BillingCountryCode = f.KS_Acc_Pais__c;
                    }
                    if(f.KS_Acc_Telefono__c != null && f.KS_Acc_Telefono__c != '')
                    {
                        a.Phone = f.KS_Acc_Telefono__c;
                    }
                    if(f.KS_Acc_Telefono_2__c != null && f.KS_Acc_Telefono_2__c != '')
                    {
                        a.KS_N_de_telefono_2__c = f.KS_Acc_Telefono_2__c;
                    }
                    if(f.KS_Acc_Telefono_3__c != null && f.KS_Acc_Telefono_3__c != '')
                    {
                        a.KS_N_de_telefono_3__c = f.KS_Acc_Telefono_3__c;
                    }
                    if(f.KS_Acc_Correo__c != null && f.KS_Acc_Correo__c != '')
                    {
                        a.KS_Email__c = f.KS_Acc_Correo__c;
                    }
                    if(f.KS_Acc_Canal__c != null && f.KS_Acc_Canal__c != '')
                    {
                        a.KS_Canal__c = f.KS_Acc_Canal__c;
                    }
                    if(f.KS_Acc_Actividad__c != null && f.KS_Acc_Actividad__c != '')
                    {
                        a.KS_Actividad__c = f.KS_Acc_Actividad__c;
                    }
                    if(f.KS_Acc_Subactividad__c != null && f.KS_Acc_Subactividad__c != '')
                    {
                        a.KS_Subactividad__c = f.KS_Acc_Subactividad__c;
                    }
                    if(f.KS_Acc_Sector__c != null && f.KS_Acc_Sector__c != '')
                    {
                        a.KS_Sector__c = f.KS_Acc_Sector__c;
                    }
                    //a.SI_EstadoDuplicado__c = 'No Duplicado';
                    AccUpdate.put(f.KS_Id_Principal__c, a);
                }
            }

            Map<Id,Account> AccMap = KS_MergeTool_Utils.getAccountMapBySetId(AccIds);
            Map<Id,Account> AccMapDuplicates = KS_MergeTool_Utils.getAccountMapBySetId(DuplicateAccIds);
            
            System.debug('-- JCAR -- -- -- -- -- -- -- -- AccUpdate ' + AccUpdate);
            //Actualización de Cuentas.
            if(AccUpdate.size()>0)
            {
                Database.SaveResult[] srLst = Database.update(AccUpdate.values());
                AccIds = ErrorHandler(null,null,srLst,'KS_MergeTool_MergeAuto','MergeAccounts - UpdateAccountsInfo');
            }
            
            AccMap = KS_MergeTool_Utils.getAccountMapBySetId(AccIds);
            
            //Merge
            Set<ID> AccMergedLst = new Set<ID>();
            //Set<string> duplicates = new Set<string>();
            List<string> duplicates = new List<string>();
            
            List<KS_Debug__c> AccMergeDebug = new List<KS_Debug__c>();
            List<KS_Debug__c> debugCampos = new List<KS_Debug__c>();
            
            Map<Id,String> ownMap = KS_MergeTool_Utils.getAccountOwnerUserNameMap(AccIds);
            ownMap.putAll(KS_MergeTool_Utils.getAccountOwnerUserNameMap(DuplicateAccIds));
            
            Map<ID,Account> setNoDuplicado = new Map<ID,Account>();
            for(KS_Fusion__c fu : BatchMergeAccLst)
            {
                String owner = '';
                if(AccMap.containsKey(fu.KS_Id_Principal__c))
                {
                    owner = ownMap.get(fu.KS_Id_Principal__c);
                    duplicates.clear();
                    if(fu.KS_Id_Duplicado__c != null && fu.KS_Id_Duplicado__c != '')
                    {
                        duplicates.add(fu.KS_Id_Duplicado__c);
                        owner += ' ; ' + ownMap.get(fu.KS_Id_Duplicado__c);
                    }
                    if(fu.KS_Id_Duplicado_2__c != null && fu.KS_Id_Duplicado_2__c != '')
                    {
                        duplicates.add(fu.KS_Id_Duplicado_2__c);
                        owner += ' ; ' + ownMap.get(fu.KS_Id_Duplicado_2__c);
                    }
                    
                    if(duplicates.size()>0)
                    {
                        //List<String> dupL = new List<String>(); dupL.addAll(duplicates);
                        Database.MergeResult[] mrLst = Database.merge(AccMap.get(fu.KS_Id_Principal__c), duplicates);
                        //Recojo los Ids de las cuentas que se han hecho Merge Correctamente
                        AccMergedLst.addAll(ErrorHandler(null,mrLst,null,'KS_MergeTool_MergeAuto','MergeAccounts - MergeFunction'));
                        
                        if (AccMergedLst.size()>0) {
                            setNoDuplicado.put(fu.KS_Id_Principal__c,new Account(ID=fu.KS_Id_Principal__c,SI_EstadoDuplicado__c='No Duplicado'));
                            debugCampos.addAll(
                                KS_MergeTool_Utils.debugAccount(
                                    'KS_MergeTool_MergeAuto', 'MergeAccounts - Account Merge', fu,
                                    AccMap.get(fu.KS_Id_Principal__c), 
                                    (fu.KS_Id_Duplicado__c != null ? AccMapDuplicates.get(fu.KS_Id_Duplicado__c) : null),
                                    (fu.KS_Id_Duplicado_2__c != null ? AccMapDuplicates.get(fu.KS_Id_Duplicado_2__c) : null),
                                    mapRecordType.get('KS_MERGE_CUENTA').ID, owner
                                )
                            );
                        }
                    }
                }
                else
                {
                    KS_Debug__c debug = KS_MergeTool_Utils.debugDesc(
                        'Account', 'KS_MergeTool_MergeAuto', 'MergeAccounts - Account Error', 
                        'This record : ' + fu.KS_Id_Principal__c + '  is not a valid account ID.', fu
                    );
                    //AccMergeDebug.add(debug);
                    debugMap.put(fu.Name, debug);
                }
            }
            
            //Actualización de Cuentas.
            if(setNoDuplicado.size()>0) { Database.update(setNoDuplicado.values()); }
            
            if(debugMap.size()>0)
            {
                SaveErrors(debugMap.values());
            }
            if(debugCampos.size()>0)
            {
                SaveErrors(debugCampos);
            }
            
            /////////////////////////////////////////////////////////////
            //  Reparenting de Opps con Marcas Duplicadas en Accounts  //
            /////////////////////////////////////////////////////////////


            //Listado de Marcas duplicadas en un mapa
            Map<string,string> MarcasDuplicadasMp = new Map<string,string>();
            //Set<string> MarcasDuplicadasSet = new Set<string>();
            List<KS_Organizacion_Cliente__c> MarcasDuplicadasLst = [SELECT Id,Name FROM KS_Organizacion_Cliente__c WHERE KS_Cliente_Distribucion__c IN :DuplicateAccIds];
            if(MarcasDuplicadasLst.size()>0)
            {
                for(KS_Organizacion_Cliente__c oc : MarcasDuplicadasLst)
                {
                    MarcasDuplicadasMp.put(oc.Name,oc.Id);
                    //MarcasDuplicadasSet.add(oc.Name);
                }
            }
                
            //Listado de Marcas Correctas en un Mapa
            Map<string,string> MarcasCorrectasMap = new Map<string,string>();
            List<KS_Organizacion_Cliente__c> MarcasCorrectasLst = [SELECT Id,KS_Organizacion_de_ventas__c,KS_Cliente_Distribucion__r.Id FROM KS_Organizacion_Cliente__c WHERE KS_Cliente_Distribucion__c IN :AccIds];
            if(MarcasCorrectasLst.size()>0)
            {
                for(KS_Organizacion_Cliente__c ocOk : MarcasCorrectasLst)
                {
                    //La clave es el nombre de la Organización de Ventas (que estaría duplicado) con el Id de la Cuenta. 
                    MarcasCorrectasMap.put(ocOk.KS_Organizacion_de_ventas__c + ocOk.KS_Cliente_Distribucion__r.Id,ocOk.Id);
                }
            }

            //Listado de Marcas de las Cuentas que se han hecho Merge correctamente
            Map<string,string> DuplicateOriginalMarcaMap = new Map<string,string>(); //Mapa que relaciona una Marca Duplicada con el ID de la marca correcta.
            List<KS_Organizacion_Cliente__c> MarcasLst = [SELECT Id,Name,KS_Organizacion_de_ventas__c,KS_Cliente_Distribucion__r.Id FROM KS_Organizacion_Cliente__c WHERE KS_Cliente_Distribucion__c IN :AccMergedLst];
            if(MarcasLst.size()>0)
            {
                for(KS_Organizacion_Cliente__c org : MarcasLst)
                {
                    if(MarcasDuplicadasMp.containsKey(org.Name))
                    {
                        DuplicateOriginalMarcaMap.put(org.Id, MarcasCorrectasMap.get(org.KS_Organizacion_de_ventas__c + org.KS_Cliente_Distribucion__r.Id));
                    }
                }
            }

            //Saco las Opp con Marcas duplicadas
            List<Opportunity> OppLst = [SELECT Id, KS_Organizacion_Cliente__c FROM Opportunity WHERE KS_Organizacion_Cliente__c IN :MarcasDuplicadasMp.values()];
            if(OppLst.size()>0)
            {
                for(Opportunity op : OppLst)
                {
                    if(DuplicateOriginalMarcaMap.containsKey(op.KS_Organizacion_Cliente__c))
                    {
                        op.KS_Organizacion_Cliente__c = DuplicateOriginalMarcaMap.get(op.KS_Organizacion_Cliente__c);
                    }
                }
                //Actualizo 
                Database.SaveResult[] OppSr = Database.update(OppLst);
                ErrorHandler(null,null,OppSr,'KS_MergeTool_MergeAuto','Reparenting Opportunities');
            }

            delete BatchMergeAccLst;
        }
        
        System.debug('-- JCAR -- KS_MergeTool_MergeAuto - MergeAccounts - FIN');
    }

    public void MergeContacts(List<KS_Fusion__c> BatchMergeCnLst)
    {
        System.debug('-- JCAR -- KS_MergeTool_MergeAuto - MergeContacts - INI');
        
        Map<String,RecordType> mapRecordType = KS_Debug_Utils.mapRecordType();
        debugMap = new Map<String,KS_Debug__c>();
        //List<KS_Fusion__c> MergeCnLst = [SELECT Id, Name, KS_Accion__c, KS_Id_Principal__c, KS_Id_Duplicado__c, KS_Id_Duplicado_2__c, KS_Ctc_Calle__c, KS_Ctc_Ciudad__c, KS_Ctc_Codigo_Postal__c, KS_Ctc_Estado_Provincia__c, KS_Ctc_Pais__c, KS_Ctc_Telefono__c, KS_Ctc_Movil__c, KS_Ctc_Telefono_Particular__c, KS_Ctc_Correo__c, KS_Ctc_Funcion_en_empresa__c, KS_Ctc_Cargo__c, KS_Ctc_Idioma__c FROM KS_Fusion__c WHERE KS_Accion__c = 'MERGE'];
        if(BatchMergeCnLst.size()>0)
        {
            /*for(KS_Fusion__c f : BatchMergeCnLst)
            {
                CntIds.add(f.KS_Id_Principal__c);          
            }*/
            Set<ID> CntIds = new Set<ID>();
            Set<ID> DuplicateCntIds = new Set<ID>();
            //Actualizamos los Contactos. 
            Map<Id,Contact> CnUpdate = new Map<Id,Contact>();
            for(KS_Fusion__c f : BatchMergeCnLst)
            {
                Contact c = new Contact();
                c.Id = f.KS_Id_Principal__c;
                if (CnUpdate.containsKey(c.Id)) { c = CnUpdate.get(c.Id); }
                CntIds.add(f.KS_Id_Principal__c);
                if(f.KS_Id_Duplicado__c != null && f.KS_Id_Duplicado__c != '')
                {
                    DuplicateCntIds.add(f.KS_Id_Duplicado__c);
                }
                if(f.KS_Id_Duplicado_2__c != null && f.KS_Id_Duplicado_2__c != '')
                {
                    DuplicateCntIds.add(f.KS_Id_Duplicado_2__c);
                }
                    
                if(f.KS_Ctc_Calle__c != null && f.KS_Ctc_Calle__c != '')
                {
                    c.OtherStreet = f.KS_Ctc_Calle__c;
                }
                if(f.KS_Ctc_Ciudad__c != null && f.KS_Ctc_Ciudad__c != '')
                {
                    c.OtherCity = f.KS_Ctc_Ciudad__c;
                }
                if(f.KS_Ctc_Codigo_Postal__c != null && f.KS_Ctc_Codigo_Postal__c != '')
                {
                    c.OtherPostalCode = f.KS_Ctc_Codigo_Postal__c;
                }
                if(f.KS_Ctc_Estado_Provincia__c != null && f.KS_Ctc_Estado_Provincia__c != '')
                {
                    c.OtherState = f.KS_Ctc_Estado_Provincia__c;
                }
                if(f.KS_Ctc_Pais__c != null && f.KS_Ctc_Pais__c != '')
                {
                    c.OtherCountry = f.KS_Ctc_Pais__c;
                }
                if(f.KS_Ctc_Telefono__c != null && f.KS_Ctc_Telefono__c != '')
                {
                    c.Phone = f.KS_Ctc_Telefono__c;
                }
                if(f.KS_Ctc_Movil__c != null && f.KS_Ctc_Movil__c != '')
                {
                    c.MobilePhone = f.KS_Ctc_Movil__c;
                }
                if(f.KS_Ctc_Telefono_Particular__c != null && f.KS_Ctc_Telefono_Particular__c != '')
                {
                    c.HomePhone = f.KS_Ctc_Telefono_Particular__c;
                }
                if(f.KS_Ctc_Correo__c != null && f.KS_Ctc_Correo__c != '')
                {
                    c.Email = f.KS_Ctc_Correo__c;
                }
                if(f.KS_Ctc_Funcion_en_empresa__c != null && f.KS_Ctc_Funcion_en_empresa__c != '')
                {
                    c.KS_Funcion_en_empresa__c = f.KS_Ctc_Funcion_en_empresa__c;
                }
                if(f.KS_Ctc_Idioma__c != null && f.KS_Ctc_Idioma__c != '')
                {
                    c.KS_Idioma__c = f.KS_Ctc_Idioma__c;
                }
                if(f.KS_Ctc_Cargo__c != null && f.KS_Ctc_Cargo__c != '')
                {
                    //Me falta el cargo que no lo veo.
                    //c.KS_Cargo__c = KS_Ctc_Cargo__c;
                }
                CnUpdate.put(f.KS_Id_Principal__c,c);
            }

            Map<Id,String> ownMap = KS_MergeTool_Utils.getContactOwnerUserNameMap(CntIds);
            ownMap.putAll(KS_MergeTool_Utils.getContactOwnerUserNameMap(DuplicateCntIds));
            
            Map<Id,Contact> cntMap = KS_MergeTool_Utils.getContactMapBySetId(CntIds);
            Map<Id,Contact> cntMapDuplicates = KS_MergeTool_Utils.getContactMapBySetId(DuplicateCntIds);
            
            if(CnUpdate.size()>0)
            {
                Database.SaveResult[] srLst = Database.update(CnUpdate.values());
                CntIds = ErrorHandler(null,null,srLst,'KS_MergeTool_MergeAuto','MergeContacts - UpdateContactsInfo');
            }

            Set<ID> ConMergedLst = new Set<ID>();
            List<Contact> McntList = [SELECT Id FROM Contact WHERE Id In :CntIds];
            Map<Id,Contact> CnMap = new Map<Id,Contact>(McntList);
            List<string> duplicates = new List<string>();
            
            Map<Id,Contact> setNoDuplicado = new Map<Id,Contact>();
            List<KS_Debug__c> CnMergeDebug = new List<KS_Debug__c>();
            List<KS_Debug__c> debugCampos = new List<KS_Debug__c>();
            for(KS_Fusion__c fu : BatchMergeCnLst)
            {
                String owner = '';
                if(CnMap.containsKey(fu.KS_Id_Principal__c))
                {
                    owner = ownMap.get(fu.KS_Id_Principal__c);
                    duplicates.clear();
                    if(fu.KS_Id_Duplicado__c != null && fu.KS_Id_Duplicado__c != '')
                    {
                        duplicates.add(fu.KS_Id_Duplicado__c);
                        owner += ' ; ' + ownMap.get(fu.KS_Id_Duplicado__c);
                    }
                    if(fu.KS_Id_Duplicado_2__c != null && fu.KS_Id_Duplicado_2__c != '')
                    {
                        duplicates.add(fu.KS_Id_Duplicado_2__c);
                        owner += ' ; ' + ownMap.get(fu.KS_Id_Duplicado_2__c);
                    }
                    if(duplicates.size()>0)
                    {
                        Database.MergeResult[] mrLst = Database.merge(CnMap.get(fu.KS_Id_Principal__c), duplicates);
                        ConMergedLst.addAll(ErrorHandler(null,mrLst,null,'KS_MergeTool_MergeAuto','MergeContacts - MergeFunction'));
                        
                        if (ConMergedLst.size()>0) {
                            setNoDuplicado.put(fu.KS_Id_Principal__c,new Contact(ID=fu.KS_Id_Principal__c,SI_EstadoDuplicado__c='No Duplicado'));
                            debugCampos.addAll(
                                KS_MergeTool_Utils.debugContact(
                                    'KS_MergeTool_MergeAuto', 'MergeContacts - Contact Merge', fu,
                                    cntMap.get(fu.KS_Id_Principal__c), 
                                    (fu.KS_Id_Duplicado__c != null ? cntMapDuplicates.get(fu.KS_Id_Duplicado__c) : null),
                                    (fu.KS_Id_Duplicado_2__c != null ? cntMapDuplicates.get(fu.KS_Id_Duplicado_2__c) : null),
                                    mapRecordType.get('KS_MERGE_CONTACTO').ID, owner
                                )
                            );
                        }
                    }
                }
                else
                {
                    KS_Debug__c debug = new KS_Debug__c();
                    debug.KS_Clase__c = 'KS_MergeTool_MergeAuto';
                    debug.KS_Origen_Metodo__c = 'MergeContacts - Contact Error';
                    debug.KS_Descripcion__c = 'This record : ' + fu.KS_Id_Principal__c + '  is not a valid contact ID.';     
                    CnMergeDebug.add(debug);
                }
            }
            
            if(setNoDuplicado.size()>0) { Database.update(setNoDuplicado.values()); }
            
            if(CnMergeDebug.size()>0)
            {
                SaveErrors(CnMergeDebug);
            }
            if(debugCampos.size()>0)
            {
                SaveErrors(debugCampos);
            }
            delete BatchMergeCnLst;
        }      
        
        System.debug('-- JCAR -- KS_MergeTool_MergeAuto - MergeContacts - FIN');
    }

	public void DeleteContacts(List<KS_Fusion__c> BatchDelCnLst)
    {
        System.debug('-- JCAR -- KS_MergeTool_MergeAuto - DeleteContacts - INI');
        
        //Recojo los ids de los contactos a borrar.
        Set<ID> CnIds = new Set<ID>();
        //List<KS_Fusion__c> DelCn = [SELECT Id,KS_Id_Principal__c,KS_Accion__c FROM KS_Fusion__c WHERE KS_Accion__c = 'DELETE'];
        if(BatchDelCnLst.size()>0)
        {
            for(KS_Fusion__c fu : BatchDelCnLst) 
            {
                CnIds.add(fu.KS_Id_Principal__c);
                System.debug('bucle1: ' + fu);
            }

            //Revisar si los contactos tienen: 
            Set<ID> CnAssociate = new Set<ID>();
            //Tareas/Eventos asociados
            List<Task> taskCnAssociate = [SELECT Id, WhoId FROM Task WHERE WhoId IN :CnIds];
            for(Task t : taskCnAssociate)
            {
                CnAssociate.add(t.WhoId);
            }
            List<Event> eventCnAssociate = [SELECT Id, WhoId FROM Event WHERE WhoId IN :CnIds];
            for(Event e : eventCnAssociate)
            {
                CnAssociate.add(e.WhoId);
            }
            //Reportes Visitas asociadas
            List<KS_Reporte__c> reporteCnAssociate = [SELECT Id, KS_Contacto__c FROM KS_Reporte__c WHERE KS_Contacto__c  IN :CnIds];
            for(KS_Reporte__c r : reporteCnAssociate)
            {
                CnAssociate.add(r.KS_Contacto__c);
            }
            //Figura de intervinientes
            List<KS_Intervinientes__c> intervinienteCnAssociate = [SELECT Id, KS_Contacto__c FROM KS_Intervinientes__c WHERE KS_Contacto__c  IN :CnIds];
            for(KS_Intervinientes__c i : intervinienteCnAssociate)
            {
                CnAssociate.add(i.KS_Contacto__c);
            }
            //Oferta Enviada Asociada 
            List<KS_Oferta_pendiente__c> ofertaenviadaCnAssociate = [SELECT Id, KS_Contacto__c FROM KS_Oferta_pendiente__c WHERE KS_Contacto__c  IN :CnIds];
            for(KS_Oferta_pendiente__c op : ofertaenviadaCnAssociate)
            {
                CnAssociate.add(op.KS_Contacto__c);
            }

            //El listado de contactos resultante lo quito de los contactos seleccionados.
            //Si hay contactos que tengan registros asociados, se mete un error por cada contacto. 
            if(CnAssociate.size()>0)
            {
                CnIds.removeAll(CnAssociate);
                List<Contact> ErrCn = [SELECT Id, Name FROM Contact WHERE Id IN :CnAssociate];
                if(ErrCn.size()>0)
                {
                    List<KS_Debug__c> CnDebug = new List<KS_Debug__c>();
                    for(Contact c : ErrCn)
                    {
                        KS_Debug__c debug = new KS_Debug__c();
                        debug.KS_Clase__c = 'KS_MergeTool_MergeAuto';
                        debug.KS_Origen_Metodo__c = 'DeleteContacts - Contacts has associated records';
                        debug.KS_Descripcion__c = 'This contact: ' + c.Id + '  ' + c.Name + ' has associated records';     
                        CnDebug.add(debug);
                    }
                    SaveErrors(CnDebug);
                }
            }
            
            //Saco la lista de contactos a borrar
            List<Contact> DelCnLst = [SELECT Id FROM Contact WHERE Id IN :CnIds];
            if(DelCnLst.size()>0)
            {
                Database.DeleteResult[] drList = Database.delete(DelCnLst);
                ErrorHandler(drList,null,null,'KS_MergeTool_MergeAuto','DeleteContacts');
            }
        }
        delete BatchDelCnLst;
        
        System.debug('-- JCAR -- KS_MergeTool_MergeAuto - DeleteContacts - FIN');
    }
    public Set<ID> ErrorHandler(Database.DeleteResult[] deleteRS, Database.MergeResult[] mergeRS, Database.SaveResult[] updateRS,string clase, string metodo)
    {
        List<KS_Debug__c> debugLst = new List<KS_Debug__c>();
        Set<ID> ids = new Set<ID>();
        if(deleteRS != null)
        {
            for(Database.DeleteResult dr : deleteRS)
            {
                if(!dr.isSuccess())
                {
                    List<KS_Debug__c> debug = new List<KS_Debug__c>();
                    debug = ManageErrors(dr.getErrors(),clase, metodo);
                    debugLst.addAll(debug);
                }
                else
                {
                    ids.add(dr.getId());
                }
            }
        }
        if(mergeRS != null)
        {
            for(Database.MergeResult mr : mergeRS)
            {
                if(!mr.isSuccess())
                {
                    List<KS_Debug__c> debug = new List<KS_Debug__c>();
                    debug = ManageErrors(mr.getErrors(),clase, metodo);
                    debugLst.addAll(debug);
                }
                else
                {
                    ids.add(mr.getId());

                }
            }
        }
        if(updateRS != null)
        {
            for(Database.SaveResult sr : updateRS)
            {
                if(!sr.isSuccess())
                {
                    List<KS_Debug__c> debug = new List<KS_Debug__c>();
                    debug = ManageErrors(sr.getErrors(),clase, metodo);
                    debugLst.addAll(debug);
                }
                else
                {
                    ids.add(sr.getId());
                }
            }
        }
            
        if(debugLst.size()>0)
        {
            SaveErrors(debugLst);
        }

        return ids;
    }
    private List<KS_Debug__c> ManageErrors (Database.Error[] error, string clase, string metodo)
    {
        List<KS_Debug__c> debugLst = new List<KS_Debug__c>();
        for(Database.Error err : error) 
        {
            System.debug('The following error has occurred.');                   
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Fields that affected this error: ' + err.getFields());
            
            List<string> stringLst = err.getFields();

            KS_Debug__c debug = new KS_Debug__c();
            debug.KS_Clase__c = clase;
            debug.KS_Origen_Metodo__c = metodo;
            debug.KS_Descripcion__c = err.getMessage();                           
            for(string s : stringLst)
            {
                debug.KS_Campo__c += s +',';
            }

            debugLst.add(debug);
        }
        return debugLst;
    }
    private void SaveErrors (List<KS_Debug__c> errlst)
    {
        Database.SaveResult[] srList = Database.insert(errlst);
        for(Database.SaveResult sr : srList)
        {
            if(!sr.isSuccess())
            {
                for(Database.Error srError : sr.getErrors())
                {
                    System.debug('The following error has occurred.');                   
                    System.debug(srError.getStatusCode() + ': ' +srError.getMessage());
                    System.debug('Fields that affected this error: ' + srError.getFields());
                }
            }
        }     
    }
}