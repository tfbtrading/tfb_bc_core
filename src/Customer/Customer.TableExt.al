tableextension 50101 "TFB Customer" extends Customer
{

    fields
    {
        field(50100; "TFB Contact Status"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Contact Status';
            TableRelation = "TFB Contact Status".Status;

            trigger OnValidate()

            begin
                validateContactStatus();
            end;


        }
        field(50102; "TFB Pallet Exchange"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Pallet Exchange';
        }
        field(50105; "TFB Pallet Acct Type"; Enum "TFB Pallet Acct Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Account Type';
        }
        field(50103; "TFB Pallet Account No"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Pallet Account No';

        }
        field(50104; "TFB Delivery Instructions"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Instructions';
        }
        field(50106; "TFB No. Order Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Line" where("Sell-to Customer No." = field("No."), "Document Type" = filter(Order), type = filter(Item), "Completely Shipped" = const(false)));
            Caption = 'Ongoing Sales Lines';
        }

        field(50107; "TFB No. Pstd. Inv. Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Line" where("Sell-to Customer No." = field("No."), Type = filter(Item)));
            Caption = 'Posted Sales Inv. Lines';
        }
        field(50480; "TFB Archived"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Archived';
        }
        field(50108; "TFB CoA Required"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'CoA Required';
        }
        field(50110; "TFB CoA Alt. Email"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'CoA Alt. Email';
            ExtendedDatatype = EMail;
        }
        field(50115; "TFB Quality Docs Recipient"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Quality Docs Recipients';
        }
        field(50120; "TFB Show Per Kg Only"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Per Kg Only on Documents';

        }
        field(50130; "TFB Price List Recipient"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Price List Recipient';
        }

        field(50131; "TFB Price List Partial"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Only Provide Partial Price List';
        }
        field(50132; "TFB Price List Hide Vendor"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Hide Vendors on Price List';
        }

        field(50135; "TFB Stock Update Recipient"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock Update Recipient';
        }
        field(50136; "TFB Order Update Preference"; Enum "TFB Order Update Preference")
        {
            DataClassification = CustomerContent;
            Caption = 'Order Update Preference';
            InitValue = Always;
        }

        field(50140; "TFB Outstanding Brokerage"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Brokerage Shipment Line".Quantity where("Customer No." = field("No."), Status = const(Approved), Status = const("In Progress")));

        }
        field(50150; "TFB External No. Req."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'External Doc. No. Required?';

        }

        field(50151; "TFB Lead Mgmt System"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Managed in Lead Management System';
        }
        field(50160; "TFB No. Of Fav. Items"; Integer)
        {
            FieldClass = flowField;
            CalcFormula = count("TFB Cust. Fav. Item" where("Customer No." = field("No."), "List No." = filter('DEFAULT')));
            Caption = 'No. of Favourite Items';
        }

        field(50161; "TFB Date of First Sale"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = min("Sales Invoice Header"."Posting Date" where("Sell-to Customer No." = field("No.")));
            Caption = 'Date of First Sale';
        }
        field(50162; "TFB Date of Last Sale"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Sales Invoice Header"."Posting Date" where("Sell-to Customer No." = field("No.")));
            Caption = 'Date of Last Sale';
        }
        field(50163; "TFB Date of Last Open Order"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = max("Sales Header"."Order Date" where("Sell-to Customer No." = field("No."), "Document Type" = const(Order)));
            Caption = 'Date of Last Open Order';
        }

        field(50170; "TFB Contact Stage"; enum "TFB Contact Stage")
        {
            Caption = 'Contact Stage';
            DataClassification = CustomerContent;
        }

        field(50182; "TFB Linkedin Page"; Text[255])
        {
            DataClassification = CustomerContent;
            Caption = 'LinkedIn page';
            ExtendedDatatype = URL;
        }
        field(50220; "TFB Parent Company"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = true;
            Caption = 'Parent Company';

            trigger OnValidate()

            begin
                if Rec."TFB Parent Company" = Rec."No." then
                    FieldError("TFB Parent Company", 'Cannot choose the same company as a parent');
            end;
        }
        field(50230; "TFB Reservation Strategy"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Reservation Strategy";
            ValidateTableRelation = true;
            Caption = 'Reservation Strategy';
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
        field(50260; "TFB Enable Online Access"; Boolean)
        {
            Caption = 'Enable Online Access';

        }
        field(50265; "TFB No. Online Users Enabled"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count(contact where(Type = const(Person), "Company No." = field("TFB Primary Contact Company ID")));
            Caption = 'No. Online Users Enabled';
        }
        field(50270; "TFB Override Location Shipping"; Boolean)
        {
            Caption = 'Override Location Based Shipping';

        }
        field(50280; "TFB Special Order Dropships"; Boolean)
        {
            Caption = 'Special Order for Dropships';
        }



    }
    fieldgroups
    {
        addlast(Brick; Blocked) { }
    }

    local procedure validateContactStatus()

    var
        Status: Record "TFB Contact Status";

    begin



        Status.SetRange(Status, Rec."TFB Contact Status");

        if Status.FindFirst() then
            Rec.validate("TFB Contact Stage", Status.Stage);



    end;


}