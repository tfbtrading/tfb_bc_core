tableextension 50216 "TFB Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(50001; "TFB Price By Price Unit"; Decimal)
        {
            DataClassification = CustomerContent;

            CaptionClass = GetVendorLabel();

            DecimalPlaces = 2 :;

            trigger OnValidate()

            begin
                UpdateUnitPrice();
            end;
        }
        field(50004; "TFB Price Unit"; Enum "TFB Price Unit")
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Switched to a lookup';

        }
        field(50006; "TFB Price Unit Lookup"; Enum "TFB Price Unit")
        {

            FieldClass = FlowField;
            CalcFormula = lookup (Vendor."TFB Vendor Price Unit" where("No." = field("Buy-from Vendor No.")));
            Editable = false;

            Caption = 'Pricing Unit';

        }
        field(50002; "TFB VendorName"; Text[100])
        {

            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup ("Purchase Header"."Buy-from Vendor Name" where("No." = field("Document No.")));
            Editable = false;
        }
        field(50003; "TFB Line Total Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Weight';
            DecimalPlaces = 2;
            Editable = false;
            BlankZero = true;

        }
        field(50007; "TFB Container Entry No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Container Entry";
            ValidateTableRelation = true;
            Editable = false;
        }
        field(50008; "TFB Container No."; Text[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("TFB Container Entry"."Container No." where("No." = field("TFB Container Entry No.")));
            Editable = false;
        }
        field(50010; "TFB Sales External No."; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Ext. Doc. No.';
            Width = 30;
            ObsoleteState = Pending;
            ObsoleteReason = 'Switched to using a lookup field instead';
        }
        field(50012; "TFB SO Ext. No. Lookup"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Sales Header"."External Document No." where("No." = field("Sales Order No."), "Document Type" = const(Order)));
            Caption = 'SO. Ext. No. Lookup';
        }
        field(50014; "TFB SO Cust. Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Sales Header"."Sell-to Customer Name" where("No." = field("Sales Order No."), "Document Type" = const(order)));
            Caption = 'Customer Name';
        }
        field(50018; "TFB Ext. No. Lookup"; Text[100])
        {
            FieldClass = flowfield;
            CalcFormula = lookup ("Purchase Header"."Vendor Order No." where("No." = field("Document No."), "Document Type" = const(order)));
            Caption = 'Vendor Order No.';
        }
        field(50020; "TFB Blanket Order Ext. No."; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Purchase Header"."Vendor Order No." where("Document Type" = const("Blanket Order"), "No." = field("Blanket Order No.")));
        }
        field(50130; "TFB Document Date"; Date)
        {
            FieldClass = FlowField;
            Caption = 'Document Date';
            CalcFormula = lookup ("Purchase Header"."Document Date" where("Document Type" = field("Document Type"), "No." = field("Document No.")));

        }
        field(50132; "TFB Order Status"; Enum "Purchase Document Status")
        {
            FieldClass = FlowField;
            Caption = 'Order Status';
            CalcFormula = lookup ("Purchase Header".Status where("No." = field("Document No."), "Document Type" = const(Order)));

        }


        modify("Direct Unit Cost")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
            end;
        }

        modify(Quantity)
        {
            trigger OnAfterValidate()

            begin
                if Type = Type::Item then
                    "TFB Line Total Weight" := TFBPricingLogic.CalcLineTotalKg("No.", "Unit of Measure Code", Quantity)
                else
                    "TFB Line Total Weight" := 0;

            end;
        }
        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()

            begin
                UpdatePriceUnitPrice();
            end;
        }

    }

    local procedure UpdateUnitPrice()

    var
        Vendor: record Vendor;

    begin
        if Type = Type::Item then begin
            Vendor.get(rec."Buy-from Vendor No.");
            PriceUnit := Vendor."TFB Vendor Price Unit";
            Rec.Validate("Direct Unit Cost", TFBPricingLogic.CalculateUnitPriceByPriceUnit(rec."No.", rec."Unit of Measure Code", PriceUnit, rec."TFB Price By Price Unit"));

        end;
    end;


    local procedure UpdatePriceUnitPrice()
    var
        Vendor: record Vendor;
    begin
        if Type = Type::Item then begin
            Vendor.get(rec."Buy-from Vendor No.");
            PriceUnit := Vendor."TFB Vendor Price Unit";
            "TFB Price By Price Unit" := TFBPricingLogic.CalculatePriceUnitByUnitPrice(rec."No.", rec."Unit of Measure Code", PriceUnit, rec."Direct Unit Cost");

        end;
    end;

    local procedure GetVendorLabel(): text

    var

    begin
        case "TFB Price Unit Lookup" of
            "TFB Price Unit Lookup"::MT:
                exit('Price Per MT');

            "TFB Price Unit Lookup"::KG:
                exit('Price Per Kg');

            "TFB Price Unit Lookup"::LB:
                exit('Price Per lb');

            else
                exit('Price Per Price Unit');

        end;


    end;

    var

        TFBPricingLogic: Codeunit "TFB Pricing Calculations";
        PriceUnit: Enum "TFB Price Unit";



}