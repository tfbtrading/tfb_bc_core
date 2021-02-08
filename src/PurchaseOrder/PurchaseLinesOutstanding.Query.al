query 50106 "TFB Purchase Lines Outstanding"
{
    QueryType = Normal;
    Caption = 'Purchase Lines Outstanding';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item);

            column(Document_No_; "Document No.")
            {

            }
            column(Line_No_; "Line No.")
            {

            }
            column(Buy_from_Vendor_No_; "Buy-from Vendor No.")
            {

            }
            column(No_; "No.")
            {

            }
            column(Type; Type)
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Quantity__Base_; "Quantity (Base)")
            {

            }
            column(Outstanding_Qty___Base_; "Outstanding Qty. (Base)")
            {

            }
            column(Reserved_Qty___Base_; "Reserved Qty. (Base)")
            {


            }
            column(Amount; Amount)
            {

            }
            column(Expected_Receipt_Date; "Expected Receipt Date")
            {

            }
            column(Unit_of_Measure; "Unit of Measure")
            {

            }


        }
    }
}