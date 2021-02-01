tableextension 50260 "TFB Item" extends Item
{
    fields
    {
        field(50261; "TFB Fumigation"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Fumigation Required?';

        }
        field(50262; "TFB Inspection"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Inspection Required';

        }
        field(50263; "TFB Heat Treatment"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Heat Treatment Required';
        }
        field(50265; "TFB Permit"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Permit Required';

        }

        field(50266; "TFB Est. Storage Duration"; Duration)
        {
            DataClassification = CustomerContent;
            Caption = 'Est. Storage Dur.';
        }

        field(50267; "TFB Default Purch. Code"; Code[20])
        {
            TableRelation = Purchasing;
            ValidateTableRelation = true;
            Caption = 'Default Puch. Code';
        }
        field(50270; "TFB Publishing Block"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Do Not Publish';
        }
        field(50272; "TFB Publish POA Only"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Publish POA Only';

        }
        field(50280; "TFB DropShip Avail."; Option)
        {
            OptionMembers = "Available","Restricted","Out of Stock";
            Caption = 'Dropship Availability';

            trigger OnValidate()

            begin
                If rec."TFB DropShip Avail." = rec."TFB DropShip Avail."::"Out of Stock" then
                    if rec."TFB DropShip ETA" = 0D then
                        FieldError("TFB DropShip ETA", 'Need to indicate next available date if out of stock at vendor');
            end;
        }
        field(50290; "TFB DropShip ETA"; Date)
        {
            Caption = 'Estimated Date Available?';
            trigger OnValidate()

            begin
                If rec."TFB DropShip Avail." = rec."TFB DropShip Avail."::"Out of Stock" then
                    if rec."TFB DropShip ETA" = 0D then
                        FieldError("TFB DropShip ETA", 'Need to indicate next available date if out of stock at vendor');
            end;
        }
        field(50300; "TFB Alt. Names"; Text[255])
        {
            DataClassification = CustomerContent;
            Caption = 'Alternative Names';
        }
        field(50310; "TFB Long Desc."; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Long Descriptions';

        }

        field(50320; "TFB Out. Qty. On Sales Order"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum ("Sales Line"."Outstanding Qty. (Base)" where("Document Type" = const(Order), "Outstanding Qty. (Base)" = filter('>0'), "No." = field("No."), "Drop Shipment" = field("Drop Shipment Filter")));
            Caption = 'Out. Qty. on Sales Order';

        }

        field(50330; "TFB Unit Price Source"; Code[20])
        {
            Caption = 'Unit Price Source';
            TableRelation = "Customer Price Group";
            ValidateTableRelation = true;
            Editable = false;
        }


    }
    fieldgroups
    {

        addlast(DropDown; Inventory, "Reserved Qty. on Inventory", "Purchasing Code", "Vendor No.")
        {

        }
        addlast(Brick; "Reserved Qty. on Inventory", "Vendor No.") { }


    }


}