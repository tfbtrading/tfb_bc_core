page 50154 "TFB APIV2 - Contact DIL"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Contact';
    EntitySetCaption = 'Contacts';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'contact';
    EntitySetName = 'contacts';
    ODataKeyFields = SystemId;
    APIPublisher = 'tfb';
    APIGroup = 'identity';
    SourceTableView = where(Type = const(Person));
    PageType = API;
    InsertAllowed = false;
    SourceTable = Contact;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("No."));
                    end;
                }
                field(firstName; Rec."First Name")
                {
                    Caption = 'First Name';

                    Editable = false;

                    trigger OnValidate()
                    begin
                        if Rec.Name = '' then
                            Error(BlankContactNameErr);
                        RegisterFieldSet(Rec.FieldNo("First Name"));
                    end;
                }
                field(lastName; Rec.Surname)
                {
                    Caption = 'Last Name';

                    Editable = false;

                    trigger OnValidate()
                    begin
                        if Rec.Name = '' then
                            Error(BlankContactNameErr);
                        RegisterFieldSet(Rec.FieldNo(Surname));
                    end;
                }

                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if Rec.Name = '' then
                            Error(BlankContactNameErr);
                        RegisterFieldSet(Rec.FieldNo(Name));
                    end;
                }
                field(companyNumber; Rec."Company No.")
                {
                    Caption = 'Company Number';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Company No."));
                    end;
                }
                field(companyName; Rec."Company Name")
                {
                    Caption = 'Company Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Company Name"));
                    end;
                }
                field(businessRelation; Rec."Business Relation")
                {
                    Caption = 'Business Relation';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Business Relation"));
                    end;
                }

                field(mobilePhoneNumber; Rec."Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Mobile Phone No."));
                    end;
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("E-Mail"));
                    end;
                }
                field(onlineAccessEnabled; Rec."TFB Enable Online Access")
                {
                    Caption = 'Online Access Enabled';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Enable Online Access"));
                    end;
                }
                field(onlineIdentityId; "TFB Online Identity Id")
                {
                    Caption = 'Online Identity ID';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Online Identity Id"));
                    end;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(picture; "APIV2 - Pictures")
                {
                    Caption = 'Picture';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(Contact);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;


    trigger OnModifyRecord(): Boolean
    var
        Contact: Record Contact;
    begin
        Contact.GetBySystemId(SystemId);

        if Rec."No." = Contact."No." then
            Rec.Modify(true)
        else begin
            Contact.TransferFields(Rec, false);
            Contact.Rename(Rec."No.");
            Rec.TransferFields(Contact);
        end;

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        TaxRegistrationNumber: Text[50];
        NotProvidedContactNameErr: Label 'A "displayName" must be provided.', Comment = 'displayName is a field name and should not be translated.';
        BlankContactNameErr: Label 'The blank "displayName" is not allowed.', Comment = 'displayName is a field name and should not be translated.';
        BECountryCodeLbl: Label 'BE', Locked = true;

    local procedure SetCalculatedFields()
    var
        EnterpriseNoFieldRef: FieldRef;
    begin
        if IsEnterpriseNumber(EnterpriseNoFieldRef) then begin
            if (Rec."Country/Region Code" <> BECountryCodeLbl) and (Rec."Country/Region Code" <> '') then
                TaxRegistrationNumber := Rec."VAT Registration No."
            else
                TaxRegistrationNumber := EnterpriseNoFieldRef.Value();
        end else
            TaxRegistrationNumber := Rec."VAT Registration No.";
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);
        Clear(TaxRegistrationNumber);
        TempFieldSet.DeleteAll();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Contact, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Contact;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;

    procedure IsEnterpriseNumber(var EnterpriseNoFieldRef: FieldRef): Boolean
    var
        ContactRecordRef: RecordRef;
    begin
        ContactRecordRef.GetTable(Rec);
        if ContactRecordRef.FieldExist(11310) then begin
            EnterpriseNoFieldRef := ContactRecordRef.Field(11310);
            exit((EnterpriseNoFieldRef.Type = FieldType::Text) and (EnterpriseNoFieldRef.Name = 'Enterprise No.'));
        end else
            exit(false);
    end;
}