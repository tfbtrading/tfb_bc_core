/// <summary>
/// Page TFB APIV2 - Contact DIL (ID 50154).
/// </summary>
page 50175 "TFB APIV2 - Contact Review"
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
    APIGroup = 'crm';
    SourceTableView = where(Type = const(Company));
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
                field(contactStage; Rec."TFB Contact Stage")
                {
                    Caption = 'Contact Stage';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Contact Stage"));
                    end;

                }
                field(contactStatus; Rec."TFB Contact Status")
                {
                    Caption = 'Contact Status';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Contact Stage"));
                    end;

                }
                field(salesPerson; Rec."Salesperson Code")
                {
                    Caption = 'Sales Person';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Salesperson Code"));
                    end;
                }
                field(hasCustomerRelationship; Rec.ContactToCustBusinessRelationExist)
                {
                    Caption = 'Customer Relationship';
                    Editable = false;
                }
                field(salesReadiness; Rec."TFB Sales Readiness")
                {
                    Caption = 'Sales Readiness';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Sales Readiness"));
                    end;
                }
                field(defaultReviewPeriod; Rec."TFB Default Review Period")
                {
                    Caption = 'Default Review Period';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Default Review Period"));
                    end;

                }
                field(inReview; Rec."TFB In Review")
                {
                    Caption = 'In Review';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB In Review"));
                    end;
                }

                field(reviewDatePlanned; Rec."TFB Review Date - Planned")
                {
                    Caption = 'Review Date Planned';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB In Review"));
                    end;
                }

                field(reviewDateExpectedCompletion; Rec."TFB Review Date Exp. Compl.")
                {
                    Caption = 'Review Date Expected Completion';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Review Date Exp. Compl."));
                    end;
                }
                field(reviewDateLastCompleted; Rec."TFB Review Date Last Compl.")
                {
                    Caption = 'Review Date Last Completed';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Review Date Last Compl."));
                    end;
                }
                field(reviewNote; Rec."TFB Review Note")
                {
                    Caption = 'Review Note';

                    trigger OnValidate()

                    begin
                        RegisterFieldSet(Rec.FieldNo("TFB Review Note"));
                    end;
                }
                field(balance; Customer.Balance)
                {
                    Editable = false;
                    Caption = 'Balance';
                }
                field(balanceDue; Customer."Balance Due")
                {
                    Editable = false;
                    Caption = 'Balance Due';

                }
                field(noOfOrders; Customer."No. of Orders")
                {
                    Editable = false;
                    Caption = 'No. of Orders';
                }
                field(dateOfFirstSale; Customer."TFB Date of First Sale")
                {
                    Editable = false;
                    Caption = 'Date of First Sale';
                }

                field(dateOfLastSale; Customer."TFB Date of Last Sale")
                {
                    Editable = false;
                    Caption = 'Date of Last Sale';
                }
                field(dateofLastOpenOrder; customer."TFB Date of Last Open Order")
                {
                    Editable = false;
                    Caption = 'Date of Last Open Order';
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


    var
        Customer: Record Customer;


    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
        Customer := Rec.GetCustomerRelation();
    end;


    trigger OnModifyRecord(): Boolean
    var
        Contact: Record Contact;
    begin
        Contact.GetBySystemId(Rec.SystemId);

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

        TaxRegistrationNumber: Text[50];
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

    /// <summary>
    /// IsEnterpriseNumber.
    /// </summary>
    /// <param name="EnterpriseNoFieldRef">VAR FieldRef.</param>
    /// <returns>Return value of type Boolean.</returns>
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