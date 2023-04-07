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
            CalcFormula = exist("Item Substitution" where(Type = const(Item),
                                                           "No." = field("Item No.")));
            Caption = 'Substitutes Exist';
            Editable = false;
            FieldClass = FlowField;
        }


        field(68; Inventory; Decimal)
        {
            CalcFormula = sum("Item Ledger Entry".Quantity where("Item No." = field("Item No."),
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
            CalcFormula = sum("Reservation Entry"."Quantity (Base)" where("Item No." = field("Item No."),
                                                                           "Source Type" = const(32),
                                                                           "Source Subtype" = const("0"),
                                                                           "Reservation Status" = const(Reservation)
                                                                           ));
            Caption = 'Reserved Qty. on Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(50320; "Qty. On Sales Order"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Outstanding Qty. (Base)" where("Document Type" = const(Order), "Outstanding Qty. (Base)" = filter('>0'), "No." = field("Item No."), "Sell-to Customer No." = field("Customer No.")));
            Caption = 'Out. Qty. on Sales Order';

        }

        field(72; "Sales (Qty.)"; Decimal)
        {
            CalcFormula = - sum("Value Entry"."Invoiced Quantity" where("Item Ledger Entry Type" = const(Sale),
                                                                        "Item No." = field("Item No."),
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