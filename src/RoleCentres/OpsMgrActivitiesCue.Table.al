table 50106 "TFB Ops Mgr Activities Cue"
{

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(6; "Sales This Month"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Sales This Month';
            DecimalPlaces = 0 : 0;
        }
        field(9; "Overdue Sales Invoice Amount"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Overdue Sales Invoice Amount';
            DecimalPlaces = 0 : 0;
        }
        field(8; "Overdue Purch. Invoice Amount"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Overdue Purch. Invoice Amount';
            DecimalPlaces = 0 : 0;
        }
        field(10; "Due This Week Filter"; Date)
        {
            Caption = 'This Week Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(20; "Due Next Week Filter"; Date)
        {
            Caption = 'Due Next Week Filter';
            FieldClass = FlowFilter;
        }

        field(25; "Overdue Filter"; Date)
        {
            Caption = 'Overdue Filter';
            FieldClass = FlowFilter;
        }

        field(26; "Recent Filter"; Date)
        {
            Caption = 'Recent Filter';
            FieldClass = FlowFilter;
        }
        field(27; "Workday Filter"; Date)
        {
            Caption = 'Workday Filter';
            FieldClass = FlowFilter;
        }

        field(30; "User ID Filter"; Code[50])
        {
            Caption = 'User ID Filter';
            FieldClass = FlowFilter;
        }

        field(110; "Quotes"; Integer)
        {
            CalcFormula = count("Sales Header" where("Document Type" = filter(Quote)));
            Caption = 'Ongoing Sales Quotes';
            FieldClass = FlowField;
        }

        field(120; "Sales Lines - All"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order)));
            Caption = 'Sales Lines - All';
        }
        field(125; "Sales Line - Created Today"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order), "TFB Document Date" = field("Workday Filter")));
            Caption = 'Sales Lines - Created Today';
        }
        field(130; "Sales Lines - This Week"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order), "Planned Shipment Date" = field("Due This Week Filter")));
            Caption = 'Sales Lines - This Week';
        }

        field(140; "Sales Lines - Next Week"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order), "Planned Shipment Date" = field("Due Next Week Filter")));
            Caption = 'Sales Lines - Next Week';
        }
        field(150; "Sales Lines - Overdue"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Document Type" = filter(Order), "Completely Shipped" = filter(false), Type = filter(Item), "Document Type" = filter(Order), "Planned Shipment Date" = field("Overdue Filter")));
            Caption = 'Sales Lines';
        }
        field(155; "Incoming Documents"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Incoming Document" where(Status = filter(<> Posted)));
            Caption = 'Incoming Documents';
        }
        field(160; "Pstd. Inv. Lines - Recent"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Line" where(Type = filter(Item), "Posting Date" = field("Recent Filter")));
            Caption = 'Recently Invoiced Lines';
        }

        field(210; "Purchase Lines - All"; Integer)
        {
            CalcFormula = count("Purchase Line" where("Document Type" = filter(Order), "Completely Received" = filter(false), Type = filter(Item)));
            Caption = 'Purchase Lines - All';
            FieldClass = FlowField;
        }
        field(215; "Purchase Lines - Created Today"; Integer)
        {
            CalcFormula = count("Purchase Line" where("Document Type" = filter(Order), "Completely Received" = filter(false), Type = filter(Item), "TFB Document Date" = field("Workday Filter")));
            Caption = 'Purchase Lines - Created Today';
            FieldClass = FlowField;
        }
        field(220; "Purchase Lines - This Week"; Integer)
        {
            CalcFormula = count("Purchase Line" where("Document Type" = filter(Order), "Completely Received" = filter(false), Type = filter(Item), "Planned Receipt Date" = field("Due This Week Filter")));
            Caption = 'Purchase Lines - All';
            FieldClass = FlowField;
        }
        field(230; "Purchase Lines - Next Week"; Integer)
        {
            CalcFormula = count("Purchase Line" where("Document Type" = filter(Order), "Completely Received" = filter(false), Type = filter(Item), "Planned Receipt Date" = field("Due Next Week Filter")));
            Caption = 'Purchase Lines - Next Week';
            FieldClass = FlowField;
        }
        field(240; "Purchase Lines - Past Due"; Integer)
        {
            CalcFormula = count("Purchase Line" where("Document Type" = filter(Order), "Completely Received" = filter(false), Type = filter(Item), "Planned Receipt Date" = field("Overdue Filter")));
            Caption = 'Purchase Lines - Next Week';
            FieldClass = FlowField;
        }
        field(245; "Purch. Invoice - This Week"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Vendor Ledger Entry" where("Due Date" = field("Due This Week Filter"), "Remaining Amount" = filter('<>0')));
            Caption = 'Purch. Invoice - Due Next Week';
        }

        field(310; "Warehouse Shipments"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Warehouse Shipment Header");
            Caption = 'Whse. Shipments';
        }
        field(320; "Containers In Progress"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("TFB Container Entry" where(Status = filter(ShippedFromPort | PendingClearance | PendingTreatment)));
            Caption = 'Inbound Shipments';
        }

        field(400; "Vendor Certificates Expired"; Integer)

        {
            FieldClass = FlowField;
            CalcFormula = count("TFB Vendor Certification" where("Expiry Date" = field("Overdue Filter")));
        }

        field(410; "Lot's without CoA"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Lot No. Information" where("TFB CoA Attach." = const(0)));
        }


        field(999; "Last Date/Time Modified"; DateTime)
        {
            Caption = 'Last Date/Time Modified';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    procedure GetAmountFormat(): Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserPersonalization: Record "User Personalization";
        CurrencySymbol: Text[10];
    begin
        GeneralLedgerSetup.Get();
        CurrencySymbol := GeneralLedgerSetup.GetCurrencySymbol();

        if UserPersonalization.Get(UserSecurityId()) and (CurrencySymbol <> '') then
            case UserPersonalization."Locale ID" of
                1030, // da-DK
              1053, // sv-Se
              1044: // no-no
                    exit('<Precision,0:0><Standard Format,0>' + CurrencySymbol);
                2057, // en-gb
              1033, // en-us
              4108, // fr-ch
              1031, // de-de
              2055, // de-ch
              1040, // it-it
              2064, // it-ch
              1043, // nl-nl
              2067, // nl-be
              2060, // fr-be
              3079, // de-at
              1035, // fi
              1034: // es-es
                    exit(CurrencySymbol + '<Precision,0:0><Standard Format,0>');
            end;

        exit(GetDefaultAmountFormat());
    end;

    local procedure GetDefaultAmountFormat(): Text
    begin
        exit('<Precision,0:0><Standard Format,0>');
    end;

}