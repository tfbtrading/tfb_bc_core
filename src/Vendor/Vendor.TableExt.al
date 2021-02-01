tableextension 50118 "TFB Vendor" extends Vendor
{
    fields
    {
        field(50119; "TFB Vendor Price Unit"; Enum "TFB Price Unit")
        {
            DataClassification = AccountData;
            Caption = 'Price Unit';

        }
        field(50120; "TFB Landed Cost Default"; Code[20])
        {
            DataClassification = CustomerContent;
            ValidateTableRelation = True;
            TableRelation = "TFB Landed Cost Template";
        }
        field(50121; "TFB Ship Via Default"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Container Route";
            ValidateTableRelation = True;
            Caption = 'Def. Ship Via Location';
        }
        field(50122; "TFB Brokerage Percentage"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50123; "TFB Brokerage Fixed Rate"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50124; "TFB Landed Cost Profile"; Code[20])
        {
            DataClassification = CustomerContent;
            ValidateTableRelation = true;
            TableRelation = "TFB Landed Cost Profile";
            Caption = 'Def. Landed Cost Profile';
        }
        field(50130; "TFB Delivery SLA"; Text[255])
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery SLA';
        }
        field(50135; "TFB Vendor Type"; Enum "TFB Vendor Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Type';
        }
        field(50136; "TFB Receive Updates"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Receive Updates';
        }

        field(50106; "TFB No. Order Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Purchase Line" where("Buy-from Vendor No." = field("No."), "Document Type" = filter(Order), type = filter(Item), "Completely Received" = const(false)));
            Caption = 'Ongoing Purch. Lines';
        }
        field(50107; "TFB No. Pstd. Inv. Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Purch. Inv. Line" where("Buy-from Vendor No." = field("No."), type = filter(Item), "Quantity (Base)" = filter('>0')));
            Caption = 'Posted Purch. Inv. Lines';
        }

        field(50110; "TFB No. Certifications"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("TFB Vendor Certification" where("Vendor No." = field("No.")));
            Caption = 'Certifications';
        }
        field(50112; "TFB Vendor Provides Ref."; Boolean)
        {
            Caption = 'Vendor Provides a Order Reference';
        }
        field(50240; "TFB Primary Contact Company ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Contact ID';
        }
        field(50245; "TFB Open Task Exists"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Open Task Exists';
            CalcFormula = exist("To-do" where("Contact Company No." = field("TFB Primary Contact Company ID"), "System To-do Type" = const(Organizer), Closed = const(false)));
        }
    }


    fieldgroups
    {
        addlast(Brick; "TFB Vendor Type", Blocked) { }
    }

}