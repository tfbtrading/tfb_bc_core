tableextension 50115 "TFB Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(50116; "TFB Inspection Required"; Option)
        {
            DataClassification = AccountData;
            OptionMembers = "","Mandatory","Random";
            Caption = 'Inspection Req.';
        }
        field(50117; "TFB Fumigation Required"; Boolean)
        {
            DataClassification = AccountData;
            Caption = 'Fumigation Req.';

        }
        field(50118; "TFB X-Ray Hold"; Boolean)
        {
            DataClassification = AccountData;
            Caption = 'X-Ray Hold.';
        }
        field(50120; "TFB IFIP Required"; Boolean)
        {
            DataClassification = AccountData;
            Caption = 'IFIP Req.';
        }
        field(50101; "TFB Heat Treatment Required"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Heat Treatment Req.';
        }

        field(50119; "TFB Directions"; MediaSet)
        {
            DataClassification = AccountData;
            Caption = 'Directions';

        }
        field(50121; "TFB Container Entry Exists"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("TFB Container Entry" where("Order Reference" = field("No.")));
            Caption = 'Container Reference';
        }

        field(50100; "TFB Instructions"; Text[2048])
        {
            Caption = 'Instructions';
            DataClassification = CustomerContent;

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
        field(50180; "TFB Sales Blanket Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." where("Document Type" = const("Blanket Order"));
            ValidateTableRelation = true;
            Caption = 'Sales  Order No.';
        }
        field(50200; "TFB Delivery SLA"; text[255])
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery SLA';
        }
        field(50205; "TFB Customer COA Req."; Boolean)
        {

            FieldClass = FlowField;
            CalcFormula = lookup(Customer."TFB CoA Required" where("No." = field("Sell-to Customer No.")));
        }

        field(50210; "TFB Final Dest.  Loc. "; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = True;
            Caption = 'Destination warehouse';
            ObsoleteState = Removed;
            ObsoleteReason = 'Removed as no longer required as not using transfor orders';
        }
        field(50216; "TFB Est. Sailing Date"; Date)
        {
            FieldClass = FlowField;
            Caption = 'Est. Sailing Date';
            CalcFormula = lookup("TFB Container Entry"."Est. Departure Date" where("Order Reference" = field("No.")));
        }
        field(50215; "TFB Origin Port"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = true;
            Caption = 'Origin port';
        }
        field(50220; "TFB Destination Port"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
            ValidateTableRelation = true;
            Caption = 'Destination port';
        }
        field(50300; "TFB Group Purchase"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Group Purchase';
        }
        field(50320; "TFB Group Purch. Rollover Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Group. Buy Rollover Date';
        }
        field(50340; "TFB Charge Assignment"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Charge Assignment Shortcut';

        }
        field(50342; "TFB Manual Confirmation"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Confirmed By Vendor';
        }

        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                TFBCommonCode: CodeUnit "TFB Common Library";

            begin

                "TFB Instructions" := TFBCommonCode.GetCustDelInstr("Sell-to Customer No.");


            end;
        }

        modify("Buy-from Vendor No.")
        {
            trigger OnAfterValidate()

            var
                Vendor: Record Vendor;

            begin
                //Inherit default delivery sla text for this order
                "TFB Delivery SLA" := Vendor."TFB Delivery SLA";
            end;
        }

        modify("Vendor Order No.")
        {
            trigger OnAfterValidate()

            begin
                if "Vendor Order No." <> '' then
                    "TFB Manual Confirmation" := true;
            end;
        }


    }

    fieldgroups
    {
        addlast(DropDown; "Expected Receipt Date") { }
    }

    var

    procedure CreateTask()
    var
        TempTask: Record "To-do" temporary;
    begin
        TestField("Buy-from Contact No.");
        TempTask.CreateTaskFromPurchaseHeader(Rec);
    end;

    local procedure CheckDateRange()

    begin
        If "TFB End Date" <> 0D then
            If "TFB Start Date" >= "TFB End Date" then
                FIeldError("TFB End Date", 'End Date must be After Start Date');

    end;

}