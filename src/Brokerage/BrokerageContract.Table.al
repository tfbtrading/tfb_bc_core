table 50219 "TFB Brokerage Contract"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Brokerage Contract List";
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()

            BEGIN
                IF "No." <> xRec."No." THEN BEGIN
                    SalesSetup.GET();
                    NoSeriesMgt.TestManual(SalesSetup."TFB Brokerage Contract Nos.");
                    "No. Series" := '';
                    NoSeriesMgt.SetSeries("No.");

                END;
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ValidateTableRelation = true;

        }
        field(3; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                VendorRec: Record Vendor;
            begin
                VendorRec.Get("Vendor No.");
                "Vendor Name" := VendorRec.Name;
                SetVendorDefaults();

            end;


        }
        field(4; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = False;

            trigger OnValidate()

            var
                VendorRec: Record Vendor;
            begin

                Validate("Vendor No.", VendorRec.GetVendorNo("Vendor Name"));
                SetVendorDefaults();

            end;

        }
        field(5; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                CustomerRec: Record Customer;
            begin
                CustomerRec.Get("Customer No.");
                "Customer Name" := CustomerRec.Name;

            end;
        }
        field(14; "Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;

            trigger OnValidate()

            var
                CustomerRec: Record Customer;
            begin

                Validate("Customer No.", CustomerRec.GetCustNo("Customer Name"));

            end;

        }

        field(6; "External Reference No."; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Date Signed"; Date)
        {
            DataClassification = CustomerContent;
        }

        field(8; "Crop Year"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Payment Terms Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
            ValidateTableRelation = True;

            trigger OnValidate()

            var
                PaymentTerms: record "Payment Terms";

            begin

                PaymentTerms.Get("Payment Terms Code");
                "Payment Terms GUID" := PaymentTerms.SystemId;

            end;
        }
        field(15; "Payment Terms GUID"; GUID)
        {
            DataClassification = CustomerContent;

        }

        field(10; "Commission Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "% of Value","$ per MT";


        }
        field(11; "Percentage"; Decimal)
        {
            Caption = 'Percentage %';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                UpdateContractLines();
            end;
        }
        field(12; "Fixed Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()

            begin
                UpdateContractLines();
            end;

        }
        field(17; "Vendor Price Unit"; Enum "TFB Price Unit")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                UpdateContractLines();
            end;
        }
        field(13; "Status"; Enum "TFB Brokerage Contract Status")
        {
            DataClassification = CustomerContent;



        }
        field(16; "Currency"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Currency;
            Enabled = false;


        }
        field(30; "Total Value"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("TFB Brokerage Contract Line".Amount where("Document No." = field("No.")));

        }
        field(40; "Total Brokerage"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("TFB Brokerage Contract Line"."Brokerage Fee" where("Document No." = field("No.")));

        }
        field(50; "Container Route"; Code[20])
        {
            TableRelation = "TFB Container Route";
            ValidateTableRelation = true;

        }
        field(60; "Shipping Method Code"; Code[20])
        {
            TableRelation = "Shipment Method";
            ValidateTableRelation = true;
            Caption = 'Shipping Method';
        }
        field(70; "Est. Freight Per MT"; Decimal)
        {
            trigger OnValidate()

            begin

            end;
        }
        field(80; "No. of Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count ("TFB Brokerage Shipment" where("Contract No." = field("No."), Status = field("Shipment Status Filter")));
        }
        field(90; "Shipment Status Filter"; Enum "TFB Brokerage Shipment Status")
        {
            FieldClass = FlowFilter;
            Caption = 'Shipment Status Filter';
        }

        field(500; "Contract Attach."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;

        }

    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Vendor Name", "Customer Name", "Date Signed", "Crop Year", Status)
        {

            Caption = 'Select Brokerage Contract';
        }
        fieldgroup(Brick; "No.", "Vendor Name", "Customer Name", "Total Brokerage")
        {

        }
    }

    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;


    /// <summary> 
    /// After a vendor is chosen any dependant fields will get set with values
    /// </summary>
    local procedure SetVendorDefaults()
    var
        VendorRec: Record Vendor;
    begin
        VendorRec.Get("Vendor No.");
        "Payment Terms Code" := VendorRec."Payment Terms Code";
        "Vendor Price Unit" := VendorRec."TFB Vendor Price Unit";
        Percentage := VendorRec."TFB Brokerage Percentage";
        "Fixed Rate" := VendorRec."TFB Brokerage Fixed Rate";
        "Shipping Method Code" := VendorRec."Shipment Method Code";
        Currency := VendorRec."Currency Code";
    end;

    /// <summary> 
    /// Trigger an update of the brokerage contract lines shown
    /// </summary>
    local procedure UpdateContractLines()

    var
        recContractLines: Record "TFB Brokerage Contract Line";

    begin
        recContractLines.SetRange("Document No.", "No.");

        if recContractLines.FindSet(true) then
            repeat
                recContractLines.CalcLineTotals();
                
            Until recContractLines.Next() = 0;


    end;

    trigger OnInsert()
    begin

        If "No." = '' then begin

            SalesSetup.Get();
            SalesSetup.TestField("TFB Brokerage Contract Nos.");
            NoSeriesMgt.InitSeries(SalesSetup."TFB Brokerage Contract Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}