query 50101 "TFB Customer Item Sales"
{
    QueryType = Normal;
    DataAccessIntent = ReadOnly;


    elements
    {
        dataitem(Item; Item)
        {
            column(ItemNo; "No.")
            {

            }
            column(Description; Description)
            {

            }
            dataitem(Item_Ledger_Entry; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = Item."No.";
                DataItemTableFilter = "Source Type" = const(Customer), "Document Type" = const("Sales Shipment"), Quantity = filter('<>0');

                filter(CustNo; "Source No.")
                {

                }

                column(Quantity; Quantity)
                {
                    Method = sum;
                    ReverseSign = true;
                }

            }
        }
    }



    trigger OnBeforeOpen()
    begin

    end;
}