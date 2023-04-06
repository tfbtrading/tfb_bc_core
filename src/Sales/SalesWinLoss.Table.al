table 50121 "TFB Sales WinLoss"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;


        }
        field(3; "No."; Code[20])
        {
            Caption = 'No.';


        }

        field(11; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
        }
        field(12; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Sell-to Customer No."));

        }
        field(13; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
        }

        field(27; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";

        }

        field(32; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

        }

        field(34; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";


        }
        field(35; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';


        }

        field(41; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;


        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";

        }
        field(45; "Order Class"; Code[10])
        {
            Caption = 'Order Class';
        }

        field(60; Amount; Decimal)
        {

            Caption = 'Amount';

        }
        field(61; "Amount Including VAT"; Decimal)
        {

            Caption = 'Amount Including VAT';

        }

        field(84; "Sell-to Contact"; Text[100])
        {
            Caption = 'Sell-to Contact';

        }

        field(100; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';

        }


        field(130; "Prepayment %"; Decimal)
        {
            Caption = 'Prepayment %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;


        }

        field(151; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            Editable = false;
        }
        field(152; "Quote Valid Until Date"; Date)
        {
            Caption = 'Quote Valid To Date';
        }

        field(154; "Quote Accepted"; Boolean)
        {
            Caption = 'Quote Accepted';


        }
        field(155; "Quote Accepted Date"; Date)
        {
            Caption = 'Quote Accepted Date';

        }


        field(200; "Work Description"; BLOB)
        {
            Caption = 'Work Description';
        }

        field(5050; "Campaign No."; Code[20])
        {
            Caption = 'Campaign No.';
            TableRelation = Campaign;


        }

        field(5052; "Sell-to Contact No."; Code[20])
        {
            Caption = 'Sell-to Contact No.';
            TableRelation = Contact;

        }

        field(5055; "Opportunity No."; Code[20])
        {
            Caption = 'Opportunity No.';
            TableRelation = if ("Document Type" = filter(<> Order)) Opportunity."No." where("Contact No." = field("Sell-to Contact No."),
                                                                                          Closed = const(false))
            else
            if ("Document Type" = const(Order)) Opportunity."No." where("Contact No." = field("Sell-to Contact No."),
                                                                                                                                                          "Sales Document No." = field("No."),
                                                                                                                                                          "Sales Document Type" = const(Order));

        }
        field(50500; "TFB Close Type"; Enum "TFB Quote Close Type")
        {
            Caption = 'Close Type';

        }
        field(50510; "TFB Close Opportunity Code"; Code[20])
        {
            TableRelation = "Close Opportunity Code" where(Type = field("TFB Close Type"));
            ValidateTableRelation = true;
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.")
        {
            Clustered = true;
        }
        key(Key2; "No.", "Document Type")
        {
        }
        key(Key3; "Document Type", "Sell-to Customer No.")
        {
        }
        key(Key13; SystemModifiedAt)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Amount, "Sell-to Contact", "Amount Including VAT")
        {
        }
        fieldgroup(Brick; "No.", Amount, "Sell-to Contact", "Amount Including VAT")
        {
        }
    }





    trigger OnInsert()
    begin

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