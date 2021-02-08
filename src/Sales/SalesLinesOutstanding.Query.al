query 50105 "TFB Sales Lines Outstanding"
{
    QueryType = Normal;
    Caption = 'Sales Lines Outstanding';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item);

            column(Document_No_; "Document No.")
            {

            }
            column(Line_No_; "Line No.")
            {

            }
            column(Sell_to_Customer_No_; "Sell-to Customer No.")
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
            column(Shipment_Date; "Shipment Date")
            {

            }
            column(Shipping_Agent_Code; "Shipping Agent Code")
            {

            }
            column(Unit_of_Measure; "Unit of Measure")
            {

            }


        }
    }


}