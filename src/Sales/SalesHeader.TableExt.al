tableextension 50135 "TFB Sales Header" extends "Sales Header" //36
{
    fields
    {
        field(50100; "TFB Instructions"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Instructions';

        }
        field(50110; "TFB Pre-order Exists"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Pre-order Exists';
            CalcFormula = exist("Sales Line" where("Document No." = field("No."), "Document Type" = field("Document Type"), "TFB Pre-Order" = const(true)));
        }
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                TFBCommonLibrary: Codeunit "TFB Common Library";
            begin
                If "Sell-to Customer No." <> '' then
                    "TFB Instructions" := TFBCommonLibrary.GetCustDelInstr("Sell-to Customer No.", "Ship-to Code");
            end;
        }

        modify("Ship-to Code")
        {
            trigger OnAfterValidate()
            var
                TFBCommonLibrary: Codeunit "TFB Common Library";
            begin
                If "Sell-to Customer No." <> '' then
                    "TFB Instructions" := TFBCommonLibrary.GetCustDelInstr("Sell-to Customer No.", "Ship-to Code");
            end;
        }

        field(50150; "TFB Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Start Date';

            trigger OnValidate()

            begin
                CheckDateRange();
            end;
        }
        field(50160; "TFB End Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'End Date';

            trigger OnValidate()

            begin
                CheckDateRange();
            end;
        }
        field(50170; "TFB Blanket DropShip"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Drop ship';

        }
        field(50180; "TFB 3PL Booking No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = '3PL Booking No.';

        }

        field(50190; "TFB Brokerage Shipment"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Brokerage Shipment";
            ValidateTableRelation = true;
            Caption = 'Brokerage Shipment';
        }
        field(50300; "TFB Group Purchase"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Group Purchase';

        }
        field(50310; "TFB Group Purchase Quote No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Group Purchase';
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Quote), Status = const(Open), "TFB Group Purchase" = const(true));
            ValidateTableRelation = true;
        }
        field(50320; "TFB Direct to Customer"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Direct to Customer (DropShip)';

        }




    }

    fieldgroups
    {
        addlast(Brick; "External Document No.", "Order Date")
        {

        }
        addlast(DropDown; "External Document No.")
        {

        }


    }



    procedure CheckDuplicateExtDocNo(var DuplicateSystemID: Guid): Boolean

    var
        SalesHeader: Record "Sales Header";

    begin
        SalesHeader.SetRange("External Document No.", Rec."External Document No.");
        SalesHeader.SetRange("Sell-to Customer No.", Rec."Sell-to Customer No.");
        SalesHeader.SetRange("Document Type", "Document Type"::Order);
        If SalesHeader.FindFirst() then begin
            DuplicateSystemID := SalesHeader.SystemId;
            Exit(true);
        end
        else
            Exit(False);
    end;


    local procedure CheckDateRange()

    begin
        If "TFB End Date" <> 0D then
            If "TFB Start Date" >= "TFB End Date" then
                FIeldError("TFB End Date", 'End Date must be After Start Date');

    end;

}