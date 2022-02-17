table 50226 "TFB Brokerage Shipment"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Brokerage Shipment List";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            trigger OnValidate()

            BEGIN
                IF "No." <> xRec."No." THEN BEGIN
                    SalesSetup.GET();
                    NoSeriesMgt.TestManual(SalesSetup."TFB Brokerage Shipment Nos.");
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
        field(3; "Contract No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Brokerage Contract";
            ValidateTableRelation = true;

            trigger OnValidate()
            begin
                UpdateContractDetails();

            end;
        }
        field(4; "Customer Reference"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Vendor Reference"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Vendor Invoice No."; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Vendor Invoice Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Vendor Invoice Due Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(26; "Est. Sailing Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Required Arrival Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Status"; Enum "TFB Brokerage Shipment Status")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()

            begin
                case Status of
                    Status::"Supplier Invoiced":
                        Closed := true;

                    else
                        Closed := false;

                end;
            end;
        }
        field(11; "Applied Invoice"; Code[20])
        {
            TableRelation = "Sales Invoice Header";
            ValidateTableRelation = true;
            Editable = false;
        }
        field(12; "Buy From Vendor No."; Code[20])
        {
            TableRelation = Vendor;
            Editable = false;
        }
        field(13; "Buy From Vendor Name"; Text[100])
        {
            Editable = false;
        }
        field(14; "Customer No."; Code[20])
        {
            TableRelation = Customer;
            Editable = false;
        }
        field(15; "Customer Name"; Text[100])
        {
            Editable = false;
        }
        field(16; "Sell-to Address"; Text[100])
        {
            Editable = false;
        }
        field(17; "Sell-to City"; Text[100])
        {
            Editable = false;
        }
        field(18; "Sell-to Post Code"; Text[20])
        {
            Editable = false;
        }
        field(19; "Sell-to County"; Text[30])
        {
            Editable = false;
        }
        field(23; "Sell-to Phone No."; Text[100])
        {
            Editable = false;

        }
        field(24; "Sell-to Country/Region Code"; Text[10])
        {
            Editable = false;
            TableRelation = "Country/Region";

        }

        field(20; "Container Entry No."; Code[20])
        {
            TableRelation = "TFB Container Entry";
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with direct field';
            ValidateTableRelation = true;
            Editable = false;
        }



        field(25; "Document Date"; Date)
        {
            Editable = true;

        }

        field(30; "Incoming Document Entry No."; Integer)

        {
            Editable = false;
        }
        field(50; "Container Route"; Code[20])
        {
            TableRelation = "TFB Container Route";
            ValidateTableRelation = true;

            trigger OnValidate()

            var
                ContainerRoute: Record "TFB Container Route";

            begin
                If ContainerRoute.Get("Container Route") then
                    "Destination Port" := ContainerRoute."Ship To";

            end;

        }
        field(60; "Destination Port"; Code[20])
        {
            TableRelation = Location;
            ValidateTableRelation = true;
        }
        field(70; "Shipment Method Code"; Code[20])
        {
            TableRelation = "Shipment Method";
            FieldClass = FlowField;
            CalcFormula = lookup("TFB Brokerage Contract"."Shipping Method Code" where("No." = field("Contract No.")));
        }

        field(80; "Freight per MT"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("TFB Brokerage Contract"."Est. Freight Per MT" where("No." = field("Contract No.")));
        }

        field(90; "Freight Extra"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Shipment Method"."TFB Freight Exclusive" where(Code = field("Shipment Method Code")));
        }
        field(100; Amount; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Brokerage Shipment Line".Amount where("Document No." = field("No.")));
            Editable = false;
        }
        field(110; "Brokerage Fee"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Brokerage Shipment Line"."Brokerage Fee" where("Document No." = field("No.")));
            Editable = false;
        }
        field(1302; Closed; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(65; "Vessel Details"; Text[100])
        {
            DataClassification = CustomerContent;

        }
        field(68; "Shipping Agent Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = true;
            Caption = 'Shipping Agent';
            TableRelation = "Shipping Agent";
            ValidateTableRelation = true;
        }

        field(160; "Container No."; Text[20]) { DataClassification = CustomerContent; }
        field(155; "Booking Reference"; Text[20]) { DataClassification = CustomerContent; }

        field(180; "Est. Departure Date"; Date)
        {

            DataClassification = CustomerContent;


        }
        field(190; "Est. Arrival Date"; Date)
        {
            DataClassification = CustomerContent;

        }
        field(200; "Printed"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = true;
        }

        field(210; "Special Instructions"; Text[2048])
        {
            DataClassification = CustomerContent;
            Editable = true;

        }
        field(220; "Bulkers"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = true;
        }

        field(230; "Bulker Weight (mt)"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = true;
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
        fieldgroup(Dropdown; "No.", "Contract No.", "Customer Reference", "Required Arrival Date", Status)
        {

        }
        fieldgroup(Brick; "No.", "Buy From Vendor Name", "Contract No.", "Customer Reference")
        {

        }
    }

    var

        SalesSetup: Record "Sales & Receivables Setup";

        NoSeriesMgt: Codeunit NoSeriesManagement;


    local procedure UpdateContractDetails()
    var
        BrokerageContract: Record "TFB Brokerage Contract";
        Customer: Record Customer;
        Vendor: Record Vendor;

    begin


        if BrokerageContract.Get(rec."Contract No.") then begin
            "Buy From Vendor No." := BrokerageContract."Vendor No.";
            "Buy From Vendor Name" := BrokerageContract."Vendor Name";
            "Customer No." := BrokerageContract."Customer No.";
            "Customer Name" := BrokerageContract."Customer Name";
            Validate("Container Route", BrokerageContract."Container Route");

            If Customer.Get("Customer No.") then begin
                //Set default billing address
                "Sell-to Address" := Customer.Address;
                "Sell-to City" := Customer.City;
                "Sell-to Post Code" := Customer."Post Code";
                "Sell-to County" := Customer.County;
                "Sell-to Country/Region Code" := Customer."Country/Region Code";
                "Sell-to Phone No." := Customer."Phone No.";
            end;

            If Vendor.Get("Buy From Vendor No.") then
                "Shipping Agent Code" := Vendor."Shipping Agent Code";
        end;


    end;

    trigger OnInsert()
    begin
        If "No." = '' then begin

            SalesSetup.Get();
            SalesSetup.TestField("TFB Brokerage Shipment Nos.");
            NoSeriesMgt.InitSeries(SalesSetup."TFB Brokerage Shipment Nos.", Rec."No. Series", 0D, "No.", "No. Series");
        end
        else begin
            If "Document Date" = 0D then
                "Document Date" := WorkDate();
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