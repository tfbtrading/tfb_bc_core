table 50100 "TFB Cust. Fav. Item"
{
    DataClassification = CustomerContent;
    Caption = 'Customer Favorite Item';
    DrillDownPageId = "TFB Cust. Fav. Items";



    fields
    {
        field(1; "Customer No."; Code[20])
        {
            TableRelation = Customer;
            ValidateTableRelation = true;

        }
        field(2; "List No."; Code[20])
        {

        }
        field(10; "Item No."; Code[20])
        {

            TableRelation = Item;
            ValidateTableRelation = true;
        }

        field(15; "Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));

        }
        field(20; "Source"; Enum "TFB Cust. Item. Source")
        {

        }
        field(5706; "Substitutes Exist"; Boolean)
        {
            CalcFormula = Exist("Item Substitution" WHERE(Type = CONST(Item),
                                                           "No." = FIELD("Item No.")));
            Caption = 'Substitutes Exist';
            Editable = false;
            FieldClass = FlowField;
        }


        field(68; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
                                                                   "Drop Shipment" = const(false)
                                                                 ));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }

        field(101; "Reserved Qty. on Inventory"; Decimal)
        {
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Item No." = FIELD("Item No."),
                                                                           "Source Type" = CONST(32),
                                                                           "Source Subtype" = CONST("0"),
                                                                           "Reservation Status" = CONST(Reservation)
                                                                           ));
            Caption = 'Reserved Qty. on Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(50320; "Qty. On Sales Order"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" where("Document Type" = const(Order), "Outstanding Qty. (Base)" = filter('>0'), "No." = field("Item No."), "Sell-to Customer No." = field("Customer No.")));
            Caption = 'Out. Qty. on Sales Order';

        }

        field(72; "Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("Value Entry"."Invoiced Quantity" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                        "Item No." = FIELD("Item No."),
                                                                        "Source No." = field("Customer No."),
                                                                        "Source Type" = const(Customer),
                                                                        "Posting Date" = field("Date Filter")));
            Caption = 'Sales (Qty.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }

        field(200; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Date Filter';
        }

    }

    keys
    {
        key(PK; "Customer No.", "List No.", "Item No.")
        {
            Clustered = true;
        }


    }

    procedure SetUpNewLine()
    var
        CustFav: Record "TFB Cust. Fav. Item";
    begin
        CustFav.SetRange("Customer No.", Rec."Customer No.");

    end;




}