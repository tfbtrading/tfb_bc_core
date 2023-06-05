query 50111 "TFB Item By Lot No. Ledg. Exp."
{
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Lot No." = filter(<> ''), Open = filter(= true);

            filter(Location_Code; "Location Code")
            { }
            filter(Expiration_DateFilter; "Expiration Date")
            { }
            column(Item_No_; "Item No.")
            { }
            column(Variant_Code; "Variant Code")
            { }
            column(Lot_No; "Lot No.")
            { }

            column(Expiration_Date; "Expiration Date")
            { }
            column(Remaining_Quantity_Sum; "Remaining Quantity")
            {
                ColumnFilter = Remaining_Quantity_Sum = filter(> 0);
                Method = Sum;
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = ItemLedgerEntry."Item No.";

                column(Description; Description)
                {

                }
            }
        }
    }
}